From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 3/6] ipv6: introduce ipv6_make_skb
Date: Sat, 31 Jan 2015 10:40:15 -0500
Message-ID: <1422718818-21093-4-git-send-email-vyasevic@redhat.com>
References: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Cc: herbert@gondor.apana.org.au, hannes@stressinduktion.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:45911 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbbAaPkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 10:40:39 -0500
Received: by mail-qg0-f52.google.com with SMTP id z107so42237443qgd.11
        for <netdev@vger.kernel.org>; Sat, 31 Jan 2015 07:40:39 -0800 (PST)
In-Reply-To: <1422718818-21093-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit is very similar to
commit 1c32c5ad6fac8cee1a77449f5abf211e911ff830
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Tue Mar 1 02:36:47 2011 +0000

    inet: Add ip_make_skb and ip_finish_skb

It adds IPv6 version of the helpers ip6_make_skb and ip6_finish_skb.

The job of ip6_make_skb is to collect messages into an ipv6 packet
and poplulate ipv6 eader.  The job of ip6_finish_skb is to transmit
the generated skb.  Together they replicated the job of
ip6_push_pending_frames() while also provide the capability to be
called independently.  This will be needed to add lockless UDP sendmsg
support.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 include/net/ipv6.h    |  19 ++++++++++
 net/ipv6/ip6_output.c | 103 ++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 103 insertions(+), 19 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4292929..8027ca5 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -788,6 +788,25 @@ int ip6_push_pending_frames(struct sock *sk);
 
 void ip6_flush_pending_frames(struct sock *sk);
 
+int ip6_send_skb(struct sk_buff *skb);
+
+struct sk_buff *__ip6_make_skb(struct sock *sk, struct sk_buff_head *queue,
+			       struct inet_cork_full *cork,
+			       struct inet6_cork *v6_cork);
+struct sk_buff *ip6_make_skb(struct sock *sk,
+			     int getfrag(void *from, char *to, int offset,
+					 int len, int odd, struct sk_buff *skb),
+			     void *from, int length, int transhdrlen,
+			     int hlimit, int tclass, struct ipv6_txoptions *opt,
+			     struct flowi6 *fl6, struct rt6_info *rt,
+			     unsigned int flags, int dontfrag);
+
+static inline struct sk_buff *ip6_finish_skb(struct sock *sk)
+{
+	return __ip6_make_skb(sk, &sk->sk_write_queue, &inet_sk(sk)->cork,
+			      &inet6_sk(sk)->cork);
+}
+
 int ip6_dst_lookup(struct sock *sk, struct dst_entry **dst, struct flowi6 *fl6);
 struct dst_entry *ip6_dst_lookup_flow(struct sock *sk, struct flowi6 *fl6,
 				      const struct in6_addr *final_dst);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1b66453..b89d3c2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1564,22 +1564,23 @@ static void ip6_cork_release(struct inet_cork_full *cork,
 	memset(&cork->fl, 0, sizeof(cork->fl));
 }
 
-int ip6_push_pending_frames(struct sock *sk)
+struct sk_buff *__ip6_make_skb(struct sock *sk,
+			       struct sk_buff_head *queue,
+			       struct inet_cork_full *cork,
+			       struct inet6_cork *v6_cork)
 {
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
 	struct in6_addr final_dst_buf, *final_dst = &final_dst_buf;
-	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct net *net = sock_net(sk);
 	struct ipv6hdr *hdr;
-	struct ipv6_txoptions *opt = np->cork.opt;
-	struct rt6_info *rt = (struct rt6_info *)inet->cork.base.dst;
-	struct flowi6 *fl6 = &inet->cork.fl.u.ip6;
+	struct ipv6_txoptions *opt = v6_cork->opt;
+	struct rt6_info *rt = (struct rt6_info *)cork->base.dst;
+	struct flowi6 *fl6 = &cork->fl.u.ip6;
 	unsigned char proto = fl6->flowi6_proto;
-	int err = 0;
 
-	skb = __skb_dequeue(&sk->sk_write_queue);
+	skb = __skb_dequeue(queue);
 	if (skb == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);
@@ -1587,7 +1588,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	/* move skb->data to ip header from ext header */
 	if (skb->data < skb_network_header(skb))
 		__skb_pull(skb, skb_network_offset(skb));
-	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
+	while ((tmp_skb = __skb_dequeue(queue)) != NULL) {
 		__skb_pull(tmp_skb, skb_network_header_len(skb));
 		*tail_skb = tmp_skb;
 		tail_skb = &(tmp_skb->next);
@@ -1612,10 +1613,10 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb_reset_network_header(skb);
 	hdr = ipv6_hdr(skb);
 
-	ip6_flow_hdr(hdr, np->cork.tclass,
+	ip6_flow_hdr(hdr, v6_cork->tclass,
 		     ip6_make_flowlabel(net, skb, fl6->flowlabel,
 					np->autoflowlabel));
-	hdr->hop_limit = np->cork.hop_limit;
+	hdr->hop_limit = v6_cork->hop_limit;
 	hdr->nexthdr = proto;
 	hdr->saddr = fl6->saddr;
 	hdr->daddr = *final_dst;
@@ -1632,25 +1633,45 @@ int ip6_push_pending_frames(struct sock *sk)
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 	}
 
+	ip6_cork_release(cork, v6_cork);
+out:
+	return skb;
+}
+
+int ip6_send_skb(struct sk_buff *skb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
+	int err;
+
 	err = ip6_local_out(skb);
 	if (err) {
 		if (err > 0)
 			err = net_xmit_errno(err);
 		if (err)
-			goto error;
+			IP6_INC_STATS(net, rt->rt6i_idev,
+				      IPSTATS_MIB_OUTDISCARDS);
 	}
 
-out:
-	ip6_cork_release(&inet->cork, &np->cork);
 	return err;
-error:
-	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
-	goto out;
+}
+
+int ip6_push_pending_frames(struct sock *sk)
+{
+	struct sk_buff *skb;
+
+	skb = ip6_finish_skb(sk);
+	if (!skb)
+		return 0;
+
+	return ip6_send_skb(skb);
 }
 EXPORT_SYMBOL_GPL(ip6_push_pending_frames);
 
 static void __ip6_flush_pending_frames(struct sock *sk,
-				       struct sk_buff_head *queue)
+				       struct sk_buff_head *queue,
+				       struct inet_cork_full *cork,
+				       struct inet6_cork *v6_cork)
 {
 	struct sk_buff *skb;
 
@@ -1661,11 +1682,55 @@ static void __ip6_flush_pending_frames(struct sock *sk,
 		kfree_skb(skb);
 	}
 
-	ip6_cork_release(&inet_sk(sk)->cork, &inet6_sk(sk)->cork);
+	ip6_cork_release(cork, v6_cork);
 }
 
 void ip6_flush_pending_frames(struct sock *sk)
 {
-	__ip6_flush_pending_frames(sk, &sk->sk_write_queue);
+	__ip6_flush_pending_frames(sk, &sk->sk_write_queue,
+				   &inet_sk(sk)->cork, &inet6_sk(sk)->cork);
 }
 EXPORT_SYMBOL_GPL(ip6_flush_pending_frames);
+
+struct sk_buff *ip6_make_skb(struct sock *sk,
+			     int getfrag(void *from, char *to, int offset,
+					 int len, int odd, struct sk_buff *skb),
+			     void *from, int length, int transhdrlen,
+			     int hlimit, int tclass,
+			     struct ipv6_txoptions *opt, struct flowi6 *fl6,
+			     struct rt6_info *rt, unsigned int flags,
+			     int dontfrag)
+{
+	struct inet_cork_full cork;
+	struct inet6_cork v6_cork;
+	struct sk_buff_head queue;
+	int exthdrlen = (opt ? opt->opt_flen : 0);
+	int err;
+
+	if (flags & MSG_PROBE)
+		return NULL;
+
+	__skb_queue_head_init(&queue);
+
+	cork.base.flags = 0;
+	cork.base.addr = 0;
+	cork.base.opt = NULL;
+	v6_cork.opt = NULL;
+	err = ip6_setup_cork(sk, &cork, &v6_cork, hlimit, tclass, opt, rt, fl6);
+	if (err)
+		return ERR_PTR(err);
+
+	if (dontfrag < 0)
+		dontfrag = inet6_sk(sk)->dontfrag;
+
+	err = __ip6_append_data(sk, fl6, &queue, &cork.base, &v6_cork,
+				&current->task_frag, getfrag, from,
+				length + exthdrlen, transhdrlen + exthdrlen,
+				flags, dontfrag);
+	if (err) {
+		__ip6_flush_pending_frames(sk, &queue, &cork, &v6_cork);
+		return ERR_PTR(err);
+	}
+
+	return __ip6_make_skb(sk, &queue, &cork, &v6_cork);
+}
-- 
1.9.3
