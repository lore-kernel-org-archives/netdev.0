From: roy.qing.li@gmail.com
Subject: [PATCH net-next 2/2] dccp: remove unnecessary codes in ipv6.c
Date: Mon,  2 Jul 2012 11:19:00 +0800
Message-ID: <1341199140-17135-2-git-send-email-roy.qing.li@gmail.com>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62414 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753364Ab2GBDTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 23:19:15 -0400
Received: by mail-pz0-f46.google.com with SMTP id y13so6800989dad.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 20:19:15 -0700 (PDT)
In-Reply-To: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

opt always equals np->opts, so it is meaningless to define opt, and
check if opt does not equal np->opts and then try to free opt.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/dccp/ipv6.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9991be0..02162cf 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -239,7 +239,6 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	struct inet6_request_sock *ireq6 = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
-	struct ipv6_txoptions *opt = NULL;
 	struct in6_addr *final_p, final;
 	struct flowi6 fl6;
 	int err = -1;
@@ -255,9 +254,8 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 	fl6.fl6_sport = inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, flowi6_to_flowi(&fl6));
 
-	opt = np->opt;
 
-	final_p = fl6_update_dst(&fl6, opt, &final);
+	final_p = fl6_update_dst(&fl6, np->opt, &final);
 
 	dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
 	if (IS_ERR(dst)) {
@@ -274,13 +272,11 @@ static int dccp_v6_send_response(struct sock *sk, struct request_sock *req,
 							 &ireq6->loc_addr,
 							 &ireq6->rmt_addr);
 		fl6.daddr = ireq6->rmt_addr;
-		err = ip6_xmit(sk, skb, &fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
 done:
-	if (opt != NULL && opt != np->opt)
-		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
 	return err;
 }
@@ -475,7 +471,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	struct inet_sock *newinet;
 	struct dccp6_sock *newdp6;
 	struct sock *newsk;
-	struct ipv6_txoptions *opt;
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		/*
@@ -520,7 +515,6 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		return newsk;
 	}
 
-	opt = np->opt;
 
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
@@ -532,7 +526,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 		memset(&fl6, 0, sizeof(fl6));
 		fl6.flowi6_proto = IPPROTO_DCCP;
 		fl6.daddr = ireq6->rmt_addr;
-		final_p = fl6_update_dst(&fl6, opt, &final);
+		final_p = fl6_update_dst(&fl6, np->opt, &final);
 		fl6.saddr = ireq6->loc_addr;
 		fl6.flowi6_oif = sk->sk_bound_dev_if;
 		fl6.fl6_dport = inet_rsk(req)->rmt_port;
@@ -597,11 +591,8 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	 * Yes, keeping reference count would be much more clever, but we make
 	 * one more one thing there: reattach optmem to newsk.
 	 */
-	if (opt != NULL) {
-		newnp->opt = ipv6_dup_options(newsk, opt);
-		if (opt != np->opt)
-			sock_kfree_s(sk, opt, opt->tot_len);
-	}
+	if (np->opt != NULL)
+		newnp->opt = ipv6_dup_options(newsk, np->opt);
 
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newnp->opt != NULL)
@@ -627,8 +618,6 @@ out_nonewsk:
 	dst_release(dst);
 out:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-	if (opt != NULL && opt != np->opt)
-		sock_kfree_s(sk, opt, opt->tot_len);
 	return NULL;
 }
 
-- 
1.7.1
