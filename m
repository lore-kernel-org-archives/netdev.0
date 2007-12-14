From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH] [ROSE] finding a connected ROSE neighbor node
Date: Fri, 14 Dec 2007 23:23:48 +0100
Message-ID: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050902030408010001020502"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:48179 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbXLNWxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:53:15 -0500
Received: from smtp5-g19.free.fr (smtp5-g19.free.fr [212.27.42.35])
	by postfix1-g20.free.fr (Postfix) with ESMTP id 35CAC2030284
	for <netdev@vger.kernel.org>; Fri, 14 Dec 2007 23:53:14 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050902030408010001020502
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This patch introduces a test to determine if a neighbor node with a 
given ROSE address is already connected and if so returns its address.
The previous test was only performed on timer t0 and not on parameter 
restarted that is true when a node is connected.
Also, previously the test was not performed on the whole node list.
A new function __rose_get_neigh() is introduced to cure a spin lock 
conflict related to rose_node_list_lock.

signed off by Alexey Dobriyan,adobriyan@gmail.com
signed off by Bernard Pidoux, f6bvp @ amsat.org



--------------050902030408010001020502
Content-Type: text/plain;
 name="rose-2.6.24-rc5.patch2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rose-2.6.24-rc5.patch2"

--- linux-2.6.24-rc5/include/net/rose.h	2007-12-11 04:48:43.000000000 +0100
+++ b/include/net/rose.h	2007-12-14 14:25:02.000000000 +0100
@@ -202,6 +202,7 @@
 extern struct net_device *rose_dev_get(rose_address *);
 extern struct rose_route *rose_route_free_lci(unsigned int, struct rose_neigh *);
 extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char *, unsigned char *);
+extern struct rose_neigh *__rose_get_neigh(rose_address *, unsigned char *, unsigned char *);
 extern int  rose_rt_ioctl(unsigned int, void __user *);
 extern void rose_link_failed(ax25_cb *, int);
 extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
--- linux-2.6.24-rc5/net/rose/rose_route.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/rose_route.c	2007-12-14 14:25:02.000000000 +0100
@@ -664,25 +664,22 @@
 /*
  *	Find a neighbour given a ROSE address.
  */
-struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
+struct rose_neigh *__rose_get_neigh(rose_address *addr, unsigned char *cause,
 	unsigned char *diagnostic)
 {
-	struct rose_neigh *res = NULL;
 	struct rose_node *node;
 	int failed = 0;
 	int i;
 
-	spin_lock_bh(&rose_node_list_lock);
 	for (node = rose_node_list; node != NULL; node = node->next) {
 		if (rosecmpm(addr, &node->address, node->mask) == 0) {
 			for (i = 0; i < node->count; i++) {
-				if (!rose_ftimer_running(node->neighbour[i])) {
-					res = node->neighbour[i];
-					goto out;
-				} else
-					failed = 1;
+				if (node->neighbour[i]->restarted)
+					return node->neighbour[i];
+				if (!rose_ftimer_running(node->neighbour[i]))			
+					return node->neighbour[i];
+				failed = 1;
 			}
-			break;
 		}
 	}
 
@@ -694,7 +691,16 @@
 		*diagnostic = 0;
 	}
 
-out:
+	return NULL;
+}
+
+struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
+	unsigned char *diagnostic)
+{
+	struct rose_neigh *res;
+
+	spin_lock_bh(&rose_node_list_lock);
+	res = __rose_get_neigh(addr, cause, diagnostic);
 	spin_unlock_bh(&rose_node_list_lock);
 
 	return res;
@@ -1019,7 +1025,7 @@
 		rose_route = rose_route->next;
 	}
 
-	if ((new_neigh = rose_get_neigh(dest_addr, &cause, &diagnostic)) == NULL) {
+	if ((new_neigh = __rose_get_neigh(dest_addr, &cause, &diagnostic)) == NULL) {
 		rose_transmit_clear_request(rose_neigh, lci, cause, diagnostic);
 		goto out;
 	}
--- linux-2.6.24-rc5/net/rose/af_rose.c	2007-12-11 04:48:43.000000000 +0100
+++ b/net/rose/af_rose.c	2007-12-14 14:25:02.000000000 +0100
@@ -750,7 +750,7 @@
 	sk->sk_state   = TCP_CLOSE;
 	sock->state = SS_UNCONNECTED;
 
-	rose->neighbour = rose_get_neigh(&addr->srose_addr, &cause,
+	rose->neighbour = __rose_get_neigh(&addr->srose_addr, &cause,
 					 &diagnostic);
 	if (!rose->neighbour)
 		return -ENETUNREACH;

--------------050902030408010001020502--

