From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [RFC PATCH 2/5] netlink: mmap: apply mmaped skb helper functions
Date: Wed, 22 Jul 2015 22:20:19 +0900
Message-ID: <20150722132018.GC18037@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:35778 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756761AbbGVNUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 09:20:25 -0400
Received: by pdrg1 with SMTP id g1so138767535pdr.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 06:20:24 -0700 (PDT)
Received: from gmail.com (softbank220009032004.bbtec.net. [220.9.32.4])
        by smtp.gmail.com with ESMTPSA id no6sm3405331pdb.42.2015.07.22.06.20.22
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Jul 2015 06:20:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netfilter/nfnetlink_log.c        |    2 +-
 net/netfilter/nfnetlink_queue_core.c |    8 ++++----
 net/netlink/af_netlink.c             |   26 +++++++++++++-------------
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4ef1fae..2294b02 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -357,7 +357,7 @@ __nfulnl_send(struct nfulnl_instance *inst)
 						 0);
 		if (WARN_ONCE(!nlh, "bad nlskb size: %u, tailroom %d\n",
 			      inst->skb->len, skb_tailroom(inst->skb))) {
-			kfree_skb(inst->skb);
+			netlink_free_skb(inst->skb);
 			goto out;
 		}
 	}
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 11c7682..ed1c9f5 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -364,7 +364,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			sizeof(struct nfgenmsg), 0);
 	if (!nlh) {
 		skb_tx_error(entskb);
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		return NULL;
 	}
 	nfmsg = nlmsg_data(nlh);
@@ -499,7 +499,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 		nla->nla_type = NFQA_PAYLOAD;
 		nla->nla_len = nla_attr_size(data_len);
 
-		if (skb_zerocopy(skb, entskb, data_len, hlen))
+		if (netlink_skb_zerocopy(skb, entskb, data_len, hlen))
 			goto nla_put_failure;
 	}
 
@@ -508,7 +508,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 
 nla_put_failure:
 	skb_tx_error(entskb);
-	kfree_skb(skb);
+	netlink_free_skb(skb);
 	net_err_ratelimited("nf_queue: error creating packet message\n");
 	return NULL;
 }
@@ -556,7 +556,7 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	return 0;
 
 err_out_free_nskb:
-	kfree_skb(nskb);
+	netlink_free_skb(nskb);
 err_out_unlock:
 	spin_unlock_bh(&queue->lock);
 	if (failopen)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index a0a32f4..5632ad0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -204,7 +204,7 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 	int ret = -ENOMEM;
 
 	dev_hold(dev);
-	nskb = skb_clone(skb, GFP_ATOMIC);
+	nskb = netlink_skb_clone(skb, GFP_ATOMIC);
 	if (nskb) {
 		nskb->dev = dev;
 		nskb->protocol = htons((u16) sk->sk_protocol);
@@ -747,7 +747,7 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 
 		err = security_netlink_send(sk, skb);
 		if (err) {
-			kfree_skb(skb);
+			kfree_skb_partial(skb, true);
 			goto out;
 		}
 
@@ -787,7 +787,7 @@ static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
 	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
 
 	NETLINK_CB(skb).flags |= NETLINK_SKB_DELIVERED;
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 }
 
 static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
@@ -1782,7 +1782,7 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 retry:
 	sk = netlink_getsockbyportid(ssk, portid);
 	if (IS_ERR(sk)) {
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
@@ -1790,7 +1790,7 @@ retry:
 
 	if (sk_filter(sk, skb)) {
 		err = skb->len;
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		sock_put(sk);
 		return err;
 	}
@@ -1854,7 +1854,7 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	return skb;
 
 err2:
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	netlink_overrun(sk);
 err1:
@@ -1862,7 +1862,7 @@ err1:
 	return NULL;
 
 out_free:
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 out_put:
 	sock_put(sk);
@@ -2024,7 +2024,7 @@ static void do_one_broadcast(struct sock *sk,
 	sock_hold(sk);
 	if (p->skb2 == NULL) {
 		if (skb_shared(p->skb)) {
-			p->skb2 = skb_clone(p->skb, p->allocation);
+			p->skb2 = netlink_skb_clone(p->skb, p->allocation);
 		} else {
 			p->skb2 = skb_get(p->skb);
 			/*
@@ -2090,7 +2090,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
 	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
 
-	consume_skb(skb);
+	netlink_consume_skb(skb);
 
 	netlink_unlock_table();
 
@@ -2755,7 +2755,7 @@ static int netlink_dump(struct sock *sk)
 		mutex_unlock(nlk->cb_mutex);
 
 		if (sk_filter(sk, skb))
-			kfree_skb(skb);
+			netlink_free_skb(skb);
 		else
 			__netlink_sendskb(sk, skb);
 		return 0;
@@ -2770,7 +2770,7 @@ static int netlink_dump(struct sock *sk)
 	memcpy(nlmsg_data(nlh), &len, sizeof(len));
 
 	if (sk_filter(sk, skb))
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 	else
 		__netlink_sendskb(sk, skb);
 
@@ -2785,7 +2785,7 @@ static int netlink_dump(struct sock *sk)
 
 errout_skb:
 	mutex_unlock(nlk->cb_mutex);
-	kfree_skb(skb);
+	netlink_free_skb(skb);
 	return err;
 }
 
@@ -2803,7 +2803,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
 	 * a reference to the skb.
 	 */
 	if (netlink_skb_is_mmaped(skb)) {
-		skb = skb_copy(skb, GFP_KERNEL);
+		skb = netlink_skb_copy(skb, GFP_KERNEL);
 		if (skb == NULL)
 			return -ENOBUFS;
 	} else
-- 
1.7.10.4


----- End forwarded message -----
