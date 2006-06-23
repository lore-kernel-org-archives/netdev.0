From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NETROM] Fix possible null pointer dereference.
Date: Fri, 23 Jun 2006 22:44:37 +0100
Message-ID: <20060623214437.GA8463@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:5584 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1752112AbWFWVol
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 17:44:41 -0400
Received: from localhost.localdomain ([127.0.0.1]:39345 "EHLO bacchus.dhis.org")
	by ftp.linux-mips.org with ESMTP id S8133768AbWFWVoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 22:44:39 +0100
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If in nr_link_failed the neighbour list is non-empty but the node list
is empty we'll end dereferencing a  in a NULL pointer.

This fixes coverity 362.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 net/netrom/nr_route.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

Index: linux-net/net/netrom/nr_route.c
===================================================================
--- linux-net.orig/net/netrom/nr_route.c	2006-06-23 22:40:27.000000000 +0100
+++ linux-net/net/netrom/nr_route.c	2006-06-23 22:42:52.000000000 +0100
@@ -725,15 +725,17 @@ void nr_link_failed(ax25_cb *ax25, int r
 	struct nr_node  *nr_node = NULL;
 
 	spin_lock_bh(&nr_neigh_list_lock);
-	nr_neigh_for_each(s, node, &nr_neigh_list)
+	nr_neigh_for_each(s, node, &nr_neigh_list) {
 		if (s->ax25 == ax25) {
 			nr_neigh_hold(s);
 			nr_neigh = s;
 			break;
 		}
+	}
 	spin_unlock_bh(&nr_neigh_list_lock);
 
-	if (nr_neigh == NULL) return;
+	if (nr_neigh == NULL)
+		return;
 
 	nr_neigh->ax25 = NULL;
 	ax25_cb_put(ax25);
@@ -743,11 +745,13 @@ void nr_link_failed(ax25_cb *ax25, int r
 		return;
 	}
 	spin_lock_bh(&nr_node_list_lock);
-	nr_node_for_each(nr_node, node, &nr_node_list)
+	nr_node_for_each(nr_node, node, &nr_node_list) {
 		nr_node_lock(nr_node);
-		if (nr_node->which < nr_node->count && nr_node->routes[nr_node->which].neighbour == nr_neigh)
+		if (nr_node->which < nr_node->count &&
+		    nr_node->routes[nr_node->which].neighbour == nr_neigh)
 			nr_node->which++;
 		nr_node_unlock(nr_node);
+	}
 	spin_unlock_bh(&nr_node_list_lock);
 	nr_neigh_put(nr_neigh);
 }
