From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next] ipv6: pass up EMSGSIZE msg for UDP socket in Ipv6
Date: Wed, 17 Feb 2016 13:58:22 -0800
Message-ID: <1455746302-53543-1-git-send-email-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>, Wei Wang <weiwan@google.com>
To: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33854 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161234AbcBQV7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:59:24 -0500
Received: by mail-pa0-f54.google.com with SMTP id fy10so18129990pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 13:59:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In ipv4,  when  the machine receives a ICMP_FRAG_NEEDED message,  the
connected UDP socket will get EMSGSIZE message on its next read from the
socket.
However, this is not the case for ipv6.
This fix modifies the udp err handler in Ipv6 for ICMP6_PKT_TOOBIG to
make it similar to ipv4 behavior. That is when the machine gets an
ICMP6_PKT_TOOBIG message, the connected UDP socket will get EMSGSIZE
message on its next read from the socket.

Signed-off-by: Wei Wang <weiwan@google.com>
---
 net/ipv6/udp.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 22e28a4..a0da656 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -590,6 +590,7 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	const struct in6_addr *daddr = &hdr->daddr;
 	struct udphdr *uh = (struct udphdr *)(skb->data+offset);
 	struct sock *sk;
+	int harderr;
 	int err;
 	struct net *net = dev_net(skb->dev);
 
@@ -601,26 +602,27 @@ void __udp6_lib_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	}
 
+	harderr = icmpv6_err_convert(type, code, &err);
+	np = inet6_sk(sk);
+
 	if (type == ICMPV6_PKT_TOOBIG) {
 		if (!ip6_sk_accept_pmtu(sk))
 			goto out;
 		ip6_sk_update_pmtu(skb, sk, info);
+		if (np->pmtudisc != IPV6_PMTUDISC_DONT)
+			harderr = 1;
 	}
 	if (type == NDISC_REDIRECT) {
 		ip6_sk_redirect(skb, sk);
 		goto out;
 	}
 
-	np = inet6_sk(sk);
-
-	if (!icmpv6_err_convert(type, code, &err) && !np->recverr)
-		goto out;
-
-	if (sk->sk_state != TCP_ESTABLISHED && !np->recverr)
-		goto out;
-
-	if (np->recverr)
+	if (!np->recverr) {
+		if (!harderr || sk->sk_state != TCP_ESTABLISHED)
+			goto out;
+	} else {
 		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info), (u8 *)(uh+1));
+	}
 
 	sk->sk_err = err;
 	sk->sk_error_report(sk);
-- 
2.7.0.rc3.207.g0ac5344
