From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: [PATCHv1 net-next 2/5] netlink: mmap: apply mmaped skb helper
 functions
Date: Wed, 12 Aug 2015 17:32:47 +0900
Message-ID: <20150812083247.GC13385@gmail.com>
References: <20150722131730.GA18037@gmail.com>
 <20150812082824.GA13385@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:32820 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933560AbbHLIcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 04:32:52 -0400
Received: by pabyb7 with SMTP id yb7so9911673pab.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 01:32:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150812082824.GA13385@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
---
 net/netfilter/nfnetlink_log.c        |    2 +-
 net/netfilter/nfnetlink_queue_core.c |    6 +++---
 net/netlink/af_netlink.c             |   26 +++++++++++++-------------
 3 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4670821..cca2c50 100644
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
index 685cc6a..8d07036 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -389,7 +389,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 			sizeof(struct nfgenmsg), 0);
 	if (!nlh) {
 		skb_tx_error(entskb);
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		return NULL;
 	}
 	nfmsg = nlmsg_data(nlh);
@@ -536,7 +536,7 @@ nfqnl_build_packet_message(struct net *net, struct nfqnl_instance *queue,
 
 nla_put_failure:
 	skb_tx_error(entskb);
-	kfree_skb(skb);
+	netlink_free_skb(skb);
 	net_err_ratelimited("nf_queue: error creating packet message\n");
 	return NULL;
 }
@@ -584,7 +584,7 @@ __nfqnl_enqueue_packet(struct net *net, struct nfqnl_instance *queue,
 	return 0;
 
 err_out_free_nskb:
-	kfree_skb(nskb);
+	netlink_free_skb(nskb);
 err_out_unlock:
 	spin_unlock_bh(&queue->lock);
 	if (failopen)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 98ed579..45c8502 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -205,7 +205,7 @@ static int __netlink_deliver_tap_skb(struct sk_buff *skb,
 	int ret = -ENOMEM;
 
 	dev_hold(dev);
-	nskb = skb_clone(skb, GFP_ATOMIC);
+	nskb = netlink_skb_clone(skb, GFP_ATOMIC);
 	if (nskb) {
 		nskb->dev = dev;
 		nskb->protocol = htons((u16) sk->sk_protocol);
@@ -764,7 +764,7 @@ static int netlink_mmap_sendmsg(struct sock *sk, struct msghdr *msg,
 
 		err = security_netlink_send(sk, skb);
 		if (err) {
-			kfree_skb(skb);
+			kfree_skb_partial(skb, true);
 			goto out;
 		}
 
@@ -804,7 +804,7 @@ static void netlink_queue_mmaped_skb(struct sock *sk, struct sk_buff *skb)
 	netlink_set_status(hdr, NL_MMAP_STATUS_VALID);
 
 	NETLINK_CB(skb).flags |= NETLINK_SKB_DELIVERED;
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 }
 
 static void netlink_ring_set_copied(struct sock *sk, struct sk_buff *skb)
@@ -1804,7 +1804,7 @@ int netlink_unicast(struct sock *ssk, struct sk_buff *skb,
 retry:
 	sk = netlink_getsockbyportid(ssk, portid);
 	if (IS_ERR(sk)) {
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		return PTR_ERR(sk);
 	}
 	if (netlink_is_kernel(sk))
@@ -1812,7 +1812,7 @@ retry:
 
 	if (sk_filter(sk, skb)) {
 		err = skb->len;
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 		sock_put(sk);
 		return err;
 	}
@@ -1876,7 +1876,7 @@ struct sk_buff *netlink_alloc_skb(struct sock *ssk, unsigned int size,
 	return skb;
 
 err2:
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 	netlink_overrun(sk);
 err1:
@@ -1884,7 +1884,7 @@ err1:
 	return NULL;
 
 out_free:
-	kfree_skb(skb);
+	kfree_skb_partial(skb, true);
 	spin_unlock_bh(&sk->sk_receive_queue.lock);
 out_put:
 	sock_put(sk);
@@ -2029,7 +2029,7 @@ static void do_one_broadcast(struct sock *sk,
 	sock_hold(sk);
 	if (p->skb2 == NULL) {
 		if (skb_shared(p->skb)) {
-			p->skb2 = skb_clone(p->skb, p->allocation);
+			p->skb2 = netlink_skb_clone(p->skb, p->allocation);
 		} else {
 			p->skb2 = skb_get(p->skb);
 			/*
@@ -2105,7 +2105,7 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
 	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list)
 		do_one_broadcast(sk, &info);
 
-	consume_skb(skb);
+	netlink_consume_skb(skb);
 
 	netlink_unlock_table();
 
@@ -2810,7 +2810,7 @@ static int netlink_dump(struct sock *sk)
 		mutex_unlock(nlk->cb_mutex);
 
 		if (sk_filter(sk, skb))
-			kfree_skb(skb);
+			netlink_free_skb(skb);
 		else
 			__netlink_sendskb(sk, skb);
 		return 0;
@@ -2825,7 +2825,7 @@ static int netlink_dump(struct sock *sk)
 	memcpy(nlmsg_data(nlh), &len, sizeof(len));
 
 	if (sk_filter(sk, skb))
-		kfree_skb(skb);
+		netlink_free_skb(skb);
 	else
 		__netlink_sendskb(sk, skb);
 
@@ -2840,7 +2840,7 @@ static int netlink_dump(struct sock *sk)
 
 errout_skb:
 	mutex_unlock(nlk->cb_mutex);
-	kfree_skb(skb);
+	netlink_free_skb(skb);
 	return err;
 }
 
@@ -2858,7 +2858,7 @@ int __netlink_dump_start(struct sock *ssk, struct sk_buff *skb,
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
