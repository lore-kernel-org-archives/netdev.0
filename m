From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Sun, 11 Nov 2012 16:20:01 -0500
Message-ID: <1352668801-14373-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, Xi Wang <xi.wang@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:33851 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512Ab2KKVUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 16:20:19 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so5497526vcb.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 13:20:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(1<<optname) is undefined behavior in C with a negative optname or
optname larger than 31.  In those cases the result of the shift is
not necessarily zero (e.g., on x86).

This patch simplifies the code with a switch statement on optname.
It also allows the compiler to generate better code (e.g., using a
64-bit mask).

Signed-off-by: Xi Wang <xi.wang@gmail.com>
---
 net/ipv4/ip_sockglue.c |   35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5eea4a8..14bbfcf 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -457,19 +457,28 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	struct inet_sock *inet = inet_sk(sk);
 	int val = 0, err;
 
-	if (((1<<optname) & ((1<<IP_PKTINFO) | (1<<IP_RECVTTL) |
-			     (1<<IP_RECVOPTS) | (1<<IP_RECVTOS) |
-			     (1<<IP_RETOPTS) | (1<<IP_TOS) |
-			     (1<<IP_TTL) | (1<<IP_HDRINCL) |
-			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
-			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
-			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
-			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
-	    optname == IP_UNICAST_IF ||
-	    optname == IP_MULTICAST_TTL ||
-	    optname == IP_MULTICAST_ALL ||
-	    optname == IP_MULTICAST_LOOP ||
-	    optname == IP_RECVORIGDSTADDR) {
+	switch (optname) {
+	case IP_PKTINFO:
+	case IP_RECVTTL:
+	case IP_RECVOPTS:
+	case IP_RECVTOS:
+	case IP_RETOPTS:
+	case IP_TOS:
+	case IP_TTL:
+	case IP_HDRINCL:
+	case IP_MTU_DISCOVER:
+	case IP_RECVERR:
+	case IP_ROUTER_ALERT:
+	case IP_FREEBIND:
+	case IP_PASSSEC:
+	case IP_TRANSPARENT:
+	case IP_MINTTL:
+	case IP_NODEFRAG:
+	case IP_UNICAST_IF:
+	case IP_MULTICAST_TTL:
+	case IP_MULTICAST_ALL:
+	case IP_MULTICAST_LOOP:
+	case IP_RECVORIGDSTADDR:
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
-- 
1.7.10.4
