From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 4.4-rc2 xfrm_lookup kasan trace
Date: Mon, 30 Nov 2015 17:22:11 -0800
Message-ID: <1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151130232733.GA27119@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35015 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763AbbLABWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 20:22:15 -0500
Received: by pacej9 with SMTP id ej9so202729963pac.2
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 17:22:14 -0800 (PST)
In-Reply-To: <20151130232733.GA27119@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-30 at 18:27 -0500, Dave Jones wrote:
> My router fell off the internet. When I got home, I found a few hundred
> of these traces in the logs, and it refusing to route packets.
> 
> Oddly, it only prints a stack trace, and no clue as to why it printed that trace.
> 
> There was also nothing in the log prior to this that indicates how it got that B taint flag.
> 
> 	Dave

Arg, that would be another bug caused by SYNACK attached to request
socket....

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 2134e6d815bc..2f2fda879105 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -213,15 +213,20 @@ struct inet_sock {
 /* SYNACK messages might be attached to request sockets.
  * Some places want to reach the listener in this case.
  */
-static inline struct sock *skb_to_full_sk(const struct sk_buff *skb)
+static inline struct sock *sk_to_full_sk(struct sock *sk)
 {
-	struct sock *sk = skb->sk;
-
+#ifdef CONFIG_INET
 	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
 		sk = inet_reqsk(sk)->rsk_listener;
+#endif
 	return sk;
 }
 
+static inline struct sock *skb_to_full_sk(const struct sk_buff *skb)
+{
+	return sk_to_full_sk(skb->sk);
+}
+
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
 	return (struct inet_sock *)sk;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 09bfcbac63bb..6bfa61d52e3d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2198,6 +2198,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	xdst = NULL;
 	route = NULL;
 
+	sk = sk_to_full_sk((struct sock *)sk);
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		num_pols = 1;
 		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
@@ -2477,6 +2478,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	pol = NULL;
+	sk = sk_to_full_sk(sk);
 	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 		if (IS_ERR(pol)) {
