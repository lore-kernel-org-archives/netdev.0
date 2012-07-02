From: roy.qing.li@gmail.com
Subject: [PATCH net-next 1/2] ipv6: remove unnecessary codes in tcp_ipv6.c
Date: Mon,  2 Jul 2012 11:18:59 +0800
Message-ID: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62414 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798Ab2GBDTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 23:19:07 -0400
Received: by dady13 with SMTP id y13so6800989dad.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 20:19:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

opt always equals np->opts, so it is meaningless to define opt, and
check if opt does not equal np->opts and then try to free opt.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/tcp_ipv6.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 9c06eaf..6cc67ed 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -486,7 +486,6 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 	struct inet6_request_sock *treq = inet6_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff * skb;
-	struct ipv6_txoptions *opt = np->opt;
 	int err = -ENOMEM;
 
 	/* First, grab a route. */
@@ -500,13 +499,11 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 
 		fl6->daddr = treq->rmt_addr;
 		skb_set_queue_mapping(skb, queue_mapping);
-		err = ip6_xmit(sk, skb, fl6, opt, np->tclass);
+		err = ip6_xmit(sk, skb, fl6, np->opt, np->tclass);
 		err = net_xmit_eval(err);
 	}
 
 done:
-	if (opt && opt != np->opt)
-		sock_kfree_s(sk, opt, opt->tot_len);
 	return err;
 }
 
@@ -1229,7 +1226,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	struct inet_sock *newinet;
 	struct tcp_sock *newtp;
 	struct sock *newsk;
-	struct ipv6_txoptions *opt;
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
@@ -1290,7 +1286,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 
 	treq = inet6_rsk(req);
-	opt = np->opt;
 
 	if (sk_acceptq_is_full(sk))
 		goto out_overflow;
@@ -1359,11 +1354,8 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	   but we make one more one thing there: reattach optmem
 	   to newsk.
 	 */
-	if (opt) {
-		newnp->opt = ipv6_dup_options(newsk, opt);
-		if (opt != np->opt)
-			sock_kfree_s(sk, opt, opt->tot_len);
-	}
+	if (np->opt)
+		newnp->opt = ipv6_dup_options(newsk, np->opt);
 
 	inet_csk(newsk)->icsk_ext_hdr_len = 0;
 	if (newnp->opt)
@@ -1410,8 +1402,6 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 out_overflow:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENOVERFLOWS);
 out_nonewsk:
-	if (opt && opt != np->opt)
-		sock_kfree_s(sk, opt, opt->tot_len);
 	dst_release(dst);
 out:
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_LISTENDROPS);
-- 
1.7.1
