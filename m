From: Vince Fuller <vaf@cisco.com>
Subject: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Mon, 7 Jan 2008 17:10:57 -0800
Message-ID: <20080108011057.GA21168@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, vaf@cisco.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:51514 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756826AbYAHBNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 20:13:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

from Vince Fuller <vaf@vaf.net>

This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
(aka "class-E") address space as consistent with the Internet Draft
draft-fuller-240space-00.txt.

Signed-off-by: Vince Fuller <vaf@vaf.net>

---

--- include/linux/in.h.orig	2007-04-12 10:16:20.000000000 -0700
+++ include/linux/in.h	2008-01-07 16:54:38.000000000 -0800
@@ -215,8 +215,16 @@ struct sockaddr_in {
 #define	IN_MULTICAST(a)		IN_CLASSD(a)
 #define IN_MULTICAST_NET	0xF0000000
 
+#define IN_CLASSE(a)		((((long int) (a)) & 0xf0000000) == 0xf0000000)
+#define	IN_CLASSE_NET		0xffffff00
+#define	IN_CLASSE_NSHIFT	8
+#define	IN_CLASSE_HOST		(0xffffffff & ~IN_CLASSE_NET)
+
+/* 
+ * these are no longer used
 #define	IN_EXPERIMENTAL(a)	((((long int) (a)) & 0xf0000000) == 0xf0000000)
 #define	IN_BADCLASS(a)		IN_EXPERIMENTAL((a))
+*/
 
 /* Address to accept any incoming messages. */
 #define	INADDR_ANY		((unsigned long int) 0x00000000)
--- net/ipv4/devinet.c.orig	2007-04-12 10:16:23.000000000 -0700
+++ net/ipv4/devinet.c	2008-01-07 16:55:59.000000000 -0800
@@ -594,6 +594,8 @@ static __inline__ int inet_abc_len(__be3
 			rc = 16;
 		else if (IN_CLASSC(haddr))
 			rc = 24;
+		else if (IN_CLASSE(haddr))
+			rc = 24;
 	}
 
   	return rc;
--- net/ipv4/fib_frontend.c.orig	2007-06-07 10:47:08.000000000 -0700
+++ net/ipv4/fib_frontend.c	2008-01-07 16:55:59.000000000 -0800
@@ -152,7 +152,7 @@ unsigned inet_addr_type(__be32 addr)
 	struct fib_result	res;
 	unsigned ret = RTN_BROADCAST;
 
-	if (ZERONET(addr) || BADCLASS(addr))
+	if (ZERONET(addr) || addr == INADDR_BROADCAST)
 		return RTN_BROADCAST;
 	if (MULTICAST(addr))
 		return RTN_MULTICAST;
--- net/ipv4/ipconfig.c.orig	2007-04-12 10:16:23.000000000 -0700
+++ net/ipv4/ipconfig.c	2008-01-07 16:55:59.000000000 -0800
@@ -379,6 +379,8 @@ static int __init ic_defaults(void)
 			ic_netmask = htonl(IN_CLASSB_NET);
 		else if (IN_CLASSC(ntohl(ic_myaddr)))
 			ic_netmask = htonl(IN_CLASSC_NET);
+		else if (IN_CLASSE(ntohl(ic_myaddr)))
+			ic_netmask = htonl(IN_CLASSE_NET);
 		else {
 			printk(KERN_ERR "IP-Config: Unable to guess netmask for address %u.%u.%u.%u\n",
 				NIPQUAD(ic_myaddr));
--- net/ipv4/route.c.orig	2007-04-12 10:16:24.000000000 -0700
+++ net/ipv4/route.c	2008-01-07 16:55:59.000000000 -0800
@@ -1140,7 +1140,7 @@ void ip_rt_redirect(__be32 old_gw, __be3
 		return;
 
 	if (new_gw == old_gw || !IN_DEV_RX_REDIRECTS(in_dev)
-	    || MULTICAST(new_gw) || BADCLASS(new_gw) || ZERONET(new_gw))
+	    || MULTICAST(new_gw) || new_gw == INADDR_BROADCAST || ZERONET(new_gw))
 		goto reject_redirect;
 
 	if (!IN_DEV_SHARED_MEDIA(in_dev)) {
@@ -1617,7 +1617,7 @@ static int ip_route_input_mc(struct sk_b
 	if (in_dev == NULL)
 		return -EINVAL;
 
-	if (MULTICAST(saddr) || BADCLASS(saddr) || LOOPBACK(saddr) ||
+	if (MULTICAST(saddr) || saddr == INADDR_BROADCAST || LOOPBACK(saddr) ||
 	    skb->protocol != htons(ETH_P_IP))
 		goto e_inval;
 
@@ -1935,7 +1935,7 @@ static int ip_route_input_slow(struct sk
 	   by fib_lookup.
 	 */
 
-	if (MULTICAST(saddr) || BADCLASS(saddr) || LOOPBACK(saddr))
+	if (MULTICAST(saddr) || saddr == INADDR_BROADCAST || LOOPBACK(saddr))
 		goto martian_source;
 
 	if (daddr == htonl(0xFFFFFFFF) || (saddr == 0 && daddr == 0))
@@ -1947,7 +1947,7 @@ static int ip_route_input_slow(struct sk
 	if (ZERONET(saddr))
 		goto martian_source;
 
-	if (BADCLASS(daddr) || ZERONET(daddr) || LOOPBACK(daddr))
+	if (ZERONET(daddr) || LOOPBACK(daddr))
 		goto martian_destination;
 
 	/*
@@ -2171,7 +2171,7 @@ static inline int __mkroute_output(struc
 		res->type = RTN_BROADCAST;
 	else if (MULTICAST(fl->fl4_dst))
 		res->type = RTN_MULTICAST;
-	else if (BADCLASS(fl->fl4_dst) || ZERONET(fl->fl4_dst))
+	else if (ZERONET(fl->fl4_dst))
 		return -EINVAL;
 
 	if (dev_out->flags & IFF_LOOPBACK)
@@ -2391,7 +2391,7 @@ static int ip_route_output_slow(struct r
 	if (oldflp->fl4_src) {
 		err = -EINVAL;
 		if (MULTICAST(oldflp->fl4_src) ||
-		    BADCLASS(oldflp->fl4_src) ||
+		    oldflp->fl4_src == INADDR_BROADCAST ||
 		    ZERONET(oldflp->fl4_src))
 			goto out;
 
