From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] [ROSE] packet routing improvement
Date: Mon, 14 Feb 2011 18:49:25 +0100
Message-ID: <4D596B25.9080309@free.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070909060704090103040909"
Cc: ralf@linux-mips.org, davem@davemloft.net,
	Bernard Pidoux F6BVP <f6bvp@free.fr>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shiva144.upmc.fr ([134.157.0.144]:51463 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750932Ab1BNSCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Feb 2011 13:02:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070909060704090103040909
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

This is a resend of my dec 12, 2010 post.
It appears that I forgot to Cc to Linux Netdev list.
The reason for this patch follows.
A second one follows in next message.

[PATCH] [ROSE] rose AX25 packet routing improvement

FPAC AX25 packet application is using Linux kernel ROSE
routing skills in order to connect or send packets to remote stations
knowing their ROSE address via a network of interconnected nodes.

Each FPAC node has a ROSE routing table that Linux ROSE module is
looking at each time a ROSE frame is relayed by the node or when
a connect request to a neighbor node is received.

A previous patch improved the system time response by looking at
already established routes each time the system was looking for a
route to relay a frame. If a neighbor node routing the destination
address was already connected, then the frame would be sent
through him. If not, a connection request would be issued.

The present patch extends the same routing capability to a connect
request asked by a user locally connected into an FPAC node.
Without this patch, a connect request was not well handled unless it
was directed to an immediate connected neighbor of the local node.

Implemented at a number of ROSE FPAC node stations, the present patch 
improved dramatically FPAC ROSE routing time response and efficiency.

Signed-off-by: Bernard Pidoux <f6bvp@free.fr>




--------------070909060704090103040909
Content-Type: text/x-patch;
 name="rose_get_neigh.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="rose_get_neigh.patch"

--- a/net/rose/rose_route.c	2010-08-27 01:47:12.000000000 +0200
+++ b/net/rose/rose_route.c	2010-12-02 12:46:57.724550823 +0100
@@ -672,29 +672,34 @@
  *	Find a neighbour or a route given a ROSE address.
  */
 struct rose_neigh *rose_get_neigh(rose_address *addr, unsigned char *cause,
-	unsigned char *diagnostic, int new)
+	unsigned char *diagnostic, int route_frame)
 {
 	struct rose_neigh *res = NULL;
 	struct rose_node *node;
 	int failed = 0;
 	int i;
 
-	if (!new) spin_lock_bh(&rose_node_list_lock);
+	if (!route_frame) spin_lock_bh(&rose_node_list_lock);
 	for (node = rose_node_list; node != NULL; node = node->next) {
 		if (rosecmpm(addr, &node->address, node->mask) == 0) {
 			for (i = 0; i < node->count; i++) {
-				if (new) {
-					if (node->neighbour[i]->restarted) {
-						res = node->neighbour[i];
-						goto out;
-					}
+				if (node->neighbour[i]->restarted) {
+					res = node->neighbour[i];
+					goto out;
 				}
-				else {
+			}
+		}
+	}
+	if (!route_frame) { /* connect request */
+		for (node = rose_node_list; node != NULL; node = node->next) {
+			if (rosecmpm(addr, &node->address, node->mask) == 0) {
+				for (i = 0; i < node->count; i++) {
 					if (!rose_ftimer_running(node->neighbour[i])) {
 						res = node->neighbour[i];
+						failed = 0;
 						goto out;
-					} else
-						failed = 1;
+					}
+					failed = 1;
 				}
 			}
 		}
@@ -709,8 +714,7 @@
 	}
 
 out:
-	if (!new) spin_unlock_bh(&rose_node_list_lock);
-
+	if (!route_frame) spin_unlock_bh(&rose_node_list_lock);
 	return res;
 }
 


--------------070909060704090103040909--
