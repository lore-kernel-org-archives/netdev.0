From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [PATCH] Multicast socket option
Date: Thu, 28 May 2009 10:00:46 -0700
Message-ID: <4A1EC33E.1080201@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45507 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845AbZE1RAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 13:00:49 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4SGvIii003167
	for <netdev@vger.kernel.org>; Thu, 28 May 2009 10:57:18 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4SH0mOh121746
	for <netdev@vger.kernel.org>; Thu, 28 May 2009 11:00:49 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4SH0l3T002464
	for <netdev@vger.kernel.org>; Thu, 28 May 2009 11:00:48 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After some discussion offline with Christoph Lameter and David Stevens 
regarding multicast behaviour in Linux, I'm submitting a slightly
modified patch from the one Christoph submitted earlier.

This patch provides a new socket option IP_MULTICAST_ALL.

In this case, default behaviour is _unchanged_ from the current
Linux standard. The socket option is set by default to provide 
original behaviour. Sockets wishing to receive data only from 
multicast groups they join explicitly will need to clear this 
socket option. 


Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>
Signed-off-by: Christoph Lameter<cl@linux.com>
Acked-by: David Stevens <dlstevens@us.ibm.com>


diff -urN linux-2.6.29.2/include/linux/in.h linux-2.6.29.2.new/include/linux/in.h
--- linux-2.6.29.2/include/linux/in.h	2009-04-27 13:37:11.000000000 -0400
+++ linux-2.6.29.2.new/include/linux/in.h	2009-05-18 16:22:06.000000000 -0400
@@ -107,6 +107,7 @@
 #define MCAST_JOIN_SOURCE_GROUP		46
 #define MCAST_LEAVE_SOURCE_GROUP	47
 #define MCAST_MSFILTER			48
+#define IP_MULTICAST_ALL		49
 
 #define MCAST_EXCLUDE	0
 #define MCAST_INCLUDE	1
diff -urN linux-2.6.29.2/include/net/inet_sock.h linux-2.6.29.2.new/include/net/inet_sock.h
--- linux-2.6.29.2/include/net/inet_sock.h	2009-04-27 13:37:11.000000000 -0400
+++ linux-2.6.29.2.new/include/net/inet_sock.h	2009-05-18 16:22:06.000000000 -0400
@@ -130,7 +130,8 @@
 				freebind:1,
 				hdrincl:1,
 				mc_loop:1,
-				transparent:1;
+				transparent:1,
+				mc_all:1;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist	*mc_list;
diff -urN linux-2.6.29.2/net/ipv4/af_inet.c linux-2.6.29.2.new/net/ipv4/af_inet.c
--- linux-2.6.29.2/net/ipv4/af_inet.c	2009-04-27 13:37:11.000000000 -0400
+++ linux-2.6.29.2.new/net/ipv4/af_inet.c	2009-05-18 16:22:06.000000000 -0400
@@ -376,6 +376,7 @@
 	inet->uc_ttl	= -1;
 	inet->mc_loop	= 1;
 	inet->mc_ttl	= 1;
+	inet->mc_all	= 1;
 	inet->mc_index	= 0;
 	inet->mc_list	= NULL;
 
diff -urN linux-2.6.29.2/net/ipv4/igmp.c linux-2.6.29.2.new/net/ipv4/igmp.c
--- linux-2.6.29.2/net/ipv4/igmp.c	2009-04-27 13:37:11.000000000 -0400
+++ linux-2.6.29.2.new/net/ipv4/igmp.c	2009-05-18 16:22:33.000000000 -0400
@@ -2196,7 +2196,7 @@
 			break;
 	}
 	if (!pmc)
-		return 1;
+		return inet->mc_all;
 	psl = pmc->sflist;
 	if (!psl)
 		return pmc->sfmode == MCAST_EXCLUDE;
diff -urN linux-2.6.29.2/net/ipv4/ip_sockglue.c linux-2.6.29.2.new/net/ipv4/ip_sockglue.c
--- linux-2.6.29.2/net/ipv4/ip_sockglue.c	2009-04-27 13:37:11.000000000 -0400
+++ linux-2.6.29.2.new/net/ipv4/ip_sockglue.c	2009-05-18 16:22:06.000000000 -0400
@@ -449,6 +449,7 @@
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
 	    optname == IP_MULTICAST_TTL ||
+	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
 	    optname == IP_RECVORIGDSTADDR) {
 		if (optlen >= sizeof(int)) {
@@ -895,6 +896,13 @@
 		kfree(gsf);
 		break;
 	}
+	case IP_MULTICAST_ALL:
+		if (optlen<1)
+			goto e_inval;
+		if (val != 0 && val != 1)
+			goto e_inval;
+		inet->mc_all = val;
+		break;
 	case IP_ROUTER_ALERT:
 		err = ip_ra_control(sk, val ? 1 : 0, NULL);
 		break;
@@ -1147,6 +1155,9 @@
 		release_sock(sk);
 		return err;
 	}
+	case IP_MULTICAST_ALL:
+		val = inet->mc_all;
+		break;
 	case IP_PKTOPTIONS:
 	{
 		struct msghdr msg;

