From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: route non-local sources for raw socket
Date: Sun, 7 Aug 2011 22:16:09 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108072212390.1423@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:59359 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754605Ab1HGTL0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Aug 2011 15:11:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The raw sockets can provide source address for
routing but their privileges are not considered. We
can provide non-local source address, make sure the
FLOWI_FLAG_ANYSRC flag is set if socket has privileges
for this, i.e. based on hdrincl (IP_HDRINCL) and
transparent flags.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v3.0/linux/include/net/inet_sock.h linux/include/net/inet_sock.h
--- v3.0/linux/include/net/inet_sock.h	2011-07-22 09:43:31.000000000 +0300
+++ linux/include/net/inet_sock.h	2011-08-07 19:09:37.365347358 +0300
@@ -238,7 +238,7 @@ static inline __u8 inet_sk_flowi_flags(c
 {
 	__u8 flags = 0;
 
-	if (inet_sk(sk)->transparent)
+	if (inet_sk(sk)->transparent || inet_sk(sk)->hdrincl)
 		flags |= FLOWI_FLAG_ANYSRC;
 	if (sk->sk_protocol == IPPROTO_TCP)
 		flags |= FLOWI_FLAG_PRECOW_METRICS;
diff -urp v3.0/linux/net/ipv4/raw.c linux/net/ipv4/raw.c
--- v3.0/linux/net/ipv4/raw.c	2011-07-22 09:43:33.000000000 +0300
+++ linux/net/ipv4/raw.c	2011-08-06 20:38:48.493063515 +0300
@@ -563,7 +563,8 @@ static int raw_sendmsg(struct kiocb *ioc
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
 			   inet->hdrincl ? IPPROTO_RAW : sk->sk_protocol,
-			   FLOWI_FLAG_CAN_SLEEP, daddr, saddr, 0, 0);
+			   inet_sk_flowi_flags(sk) | FLOWI_FLAG_CAN_SLEEP,
+			   daddr, saddr, 0, 0);
 
 	if (!inet->hdrincl) {
 		err = raw_probe_proto_opt(&fl4, msg);
