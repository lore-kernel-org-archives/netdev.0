From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH] netlink: fix splat in skb_clone with large messages
Date: Fri, 28 Jun 2013 03:04:23 +0200
Message-ID: <1372381463-14958-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	artem.savkov@gmail.com, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44141 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754219Ab3F1BEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 21:04:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since (c05cdb1 netlink: allow large data transfers from user-space),
netlink splats if it invokes skb_clone on large netlink skbs since:

* skb_shared_info was not correctly initialized.
* skb->destructor is not set in the cloned skb.

This was spotted by trinity:

[  894.990671] BUG: unable to handle kernel paging request at ffffc9000047b001
[  894.991034] IP: [<ffffffff81a212c4>] skb_clone+0x24/0xc0
[...]
[  894.991034] Call Trace:
[  894.991034]  [<ffffffff81ad299a>] nl_fib_input+0x6a/0x240
[  894.991034]  [<ffffffff81c3b7e6>] ? _raw_read_unlock+0x26/0x40
[  894.991034]  [<ffffffff81a5f189>] netlink_unicast+0x169/0x1e0
[  894.991034]  [<ffffffff81a601e1>] netlink_sendmsg+0x251/0x3d0

Fix it by:

1) introducing a new netlink_skb_clone function that is used in nl_fib_input,
   that sets our special skb->destructor in the cloned skb. Moreover, handle
   the release of the large cloned skb head area in the destructor path.

2) not allowing large skbuffs in the netlink broadcast path. I cannot find
   any reasonable use of the large data transfer using netlink in that path,
   moreover this helps to skip extra skb_clone handling.

I found two more netlink clients that are cloning the skbs, but they are
not in the sendmsg path. Therefore, the sole client cloning that I found
seems to be the fib frontend.

Thanks to Eric Dumazet for helping to address this issue.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
* Tested with libmnl: http://people.netfilter.org/pablo/fib-test.c and
  http://people.netfilter.org/pablo/nl-crash.c, that exercise the skb clone
  path of fib frontend and the general input path of most netlink families
  in a very simple manner, should be similar to what trinity triggers.

* While grepping through the tree, I found two more netlink subsystems that
  clone the skb, kernel/taskstats.c and genetlink, but they don't occur in
  the sendmsg path.

 include/linux/netlink.h  |   16 ++++++++++++++++
 net/ipv4/fib_frontend.c  |    2 +-
 net/netlink/af_netlink.c |   35 ++++++++++++++++++-----------------
 3 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index f78b430..1478b35 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -85,6 +85,22 @@ int netlink_attachskb(struct sock *sk, struct sk_buff *skb,
 void netlink_detachskb(struct sock *sk, struct sk_buff *skb);
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb);
 
+static inline struct sk_buff *
+netlink_skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
+{
+	struct sk_buff *nskb;
+
+	nskb = skb_clone(skb, gfp_mask);
+	if (!nskb)
+		return NULL;
+
+	/* This is a large skb, set destructor callback to release head */
+	if (is_vmalloc_addr(skb->head))
+		nskb->destructor = skb->destructor;
+
+	return nskb;
+}
+
 /*
  *	skb should fit one page. This choice is good for headerless malloc.
  *	But we should limit to 8K so that userspace does not have to
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 05a4888..b3f627a 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -961,7 +961,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	    nlmsg_len(nlh) < sizeof(*frn))
 		return;
 
-	skb = skb_clone(skb, GFP_KERNEL);
+	skb = netlink_skb_clone(skb, GFP_KERNEL);
 	if (skb == NULL)
 		return;
 	nlh = nlmsg_hdr(skb);
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 275d901..0dab6c6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -751,7 +751,10 @@ static void netlink_skb_destructor(struct sk_buff *skb)
 	}
 #endif
 	if (is_vmalloc_addr(skb->head)) {
-		vfree(skb->head);
+		if (!skb->cloned ||
+		    !atomic_dec_return(&(skb_shinfo(skb)->dataref)))
+			vfree(skb->head);
+
 		skb->head = NULL;
 	}
 	if (skb->sk != NULL)
@@ -1434,33 +1437,31 @@ struct sock *netlink_getsockbyfilp(struct file *filp)
 	return sock;
 }
 
-static struct sk_buff *netlink_alloc_large_skb(unsigned int size)
+static struct sk_buff *netlink_alloc_large_skb(unsigned int size,
+					       int broadcast)
 {
 	struct sk_buff *skb;
 	void *data;
 
-	if (size <= NLMSG_GOODSIZE)
+	if (size <= NLMSG_GOODSIZE || broadcast)
 		return alloc_skb(size, GFP_KERNEL);
 
-	skb = alloc_skb_head(GFP_KERNEL);
-	if (skb == NULL)
-		return NULL;
+	size = SKB_DATA_ALIGN(size) +
+	       SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
 
 	data = vmalloc(size);
 	if (data == NULL)
-		goto err;
+		return NULL;
 
-	skb->head	= data;
-	skb->data	= data;
-	skb_reset_tail_pointer(skb);
-	skb->end	= skb->tail + size;
-	skb->len	= 0;
-	skb->destructor = netlink_skb_destructor;
+	skb = build_skb(data, size);
+	if (skb == NULL)
+		vfree(data);
+	else {
+		skb->head_frag = 0;
+		skb->destructor = netlink_skb_destructor;
+	}
 
 	return skb;
-err:
-	kfree_skb(skb);
-	return NULL;
 }
 
 /*
@@ -2139,7 +2140,7 @@ static int netlink_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 	err = -ENOBUFS;
-	skb = netlink_alloc_large_skb(len);
+	skb = netlink_alloc_large_skb(len, dst_group);
 	if (skb == NULL)
 		goto out;
 
-- 
1.7.10.4
