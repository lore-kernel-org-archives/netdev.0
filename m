From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] x25_forward_call(): fix NULL dereferences
Date: Mon, 19 Mar 2007 10:24:03 +0100
Message-ID: <20070319092403.GK752@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:34829 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753306AbXCSJYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2007 05:24:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes two NULL dereferences spotted by the Coverity checker.

For a better understanding, the "diff -uwp" output (that ignores the 
indentation changes) is:

--- linux-2.6.21-rc3-mm2/net/x25/x25_forward.c.old	2007-03-19 02:28:34.000000000 +0100
+++ linux-2.6.21-rc3-mm2/net/x25/x25_forward.c	2007-03-19 02:31:45.000000000 +0100
@@ -25,9 +25,10 @@ int x25_forward_call(struct x25_address 
 	struct sk_buff *skbn;
 	short same_lci = 0;
 	int rc = 0;
 
-	if ((rt = x25_get_route(dest_addr)) != NULL) {
+	if ((rt = x25_get_route(dest_addr)) == NULL)
+		goto out_no_route;
 
 		if ((neigh_new = x25_get_neigh(rt->dev)) == NULL) {
 			/* This shouldnt happen, if it occurs somehow
 			 * do something sensible
@@ -75,16 +76,17 @@ int x25_forward_call(struct x25_address 
 			goto out_put_nb;
 		}
 		x25_transmit_link(skbn, neigh_new);
 		rc = 1;
-	}
 
 
 out_put_nb:
 	x25_neigh_put(neigh_new);
 
 out_put_route:
 	x25_route_put(rt);
+
+out_no_route:
 	return rc;
 }
 


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 net/x25/x25_forward.c |   86 +++++++++++++++++++++---------------------
 1 file changed, 44 insertions(+), 42 deletions(-)

--- linux-2.6.21-rc3-mm2/net/x25/x25_forward.c.old	2007-03-19 02:28:34.000000000 +0100
+++ linux-2.6.21-rc3-mm2/net/x25/x25_forward.c	2007-03-19 02:31:45.000000000 +0100
@@ -26,64 +26,66 @@ int x25_forward_call(struct x25_address 
 	short same_lci = 0;
 	int rc = 0;
 
-	if ((rt = x25_get_route(dest_addr)) != NULL) {
+	if ((rt = x25_get_route(dest_addr)) == NULL)
+		goto out_no_route;
 
-		if ((neigh_new = x25_get_neigh(rt->dev)) == NULL) {
-			/* This shouldnt happen, if it occurs somehow
-			 * do something sensible
-			 */
-			goto out_put_route;
-		}
-
-		/* Avoid a loop. This is the normal exit path for a
-		 * system with only one x.25 iface and default route
+	if ((neigh_new = x25_get_neigh(rt->dev)) == NULL) {
+		/* This shouldnt happen, if it occurs somehow
+		 * do something sensible
 		 */
-		if (rt->dev == from->dev) {
-			goto out_put_nb;
-		}
+		goto out_put_route;
+	}
 
-		/* Remote end sending a call request on an already
-		 * established LCI? It shouldnt happen, just in case..
-		 */
-		read_lock_bh(&x25_forward_list_lock);
-		list_for_each(entry, &x25_forward_list) {
-			x25_frwd = list_entry(entry, struct x25_forward, node);
-			if (x25_frwd->lci == lci) {
-				printk(KERN_WARNING "X.25: call request for lci which is already registered!, transmitting but not registering new pair\n");
-				same_lci = 1;
-			}
-		}
-		read_unlock_bh(&x25_forward_list_lock);
+	/* Avoid a loop. This is the normal exit path for a
+	 * system with only one x.25 iface and default route
+	 */
+	if (rt->dev == from->dev) {
+		goto out_put_nb;
+	}
 
-		/* Save the forwarding details for future traffic */
-		if (!same_lci){
-			if ((new_frwd = kmalloc(sizeof(struct x25_forward),
-							GFP_ATOMIC)) == NULL){
-				rc = -ENOMEM;
-				goto out_put_nb;
-			}
-			new_frwd->lci = lci;
-			new_frwd->dev1 = rt->dev;
-			new_frwd->dev2 = from->dev;
-			write_lock_bh(&x25_forward_list_lock);
-			list_add(&new_frwd->node, &x25_forward_list);
-			write_unlock_bh(&x25_forward_list_lock);
+	/* Remote end sending a call request on an already
+	 * established LCI? It shouldnt happen, just in case..
+	 */
+	read_lock_bh(&x25_forward_list_lock);
+	list_for_each(entry, &x25_forward_list) {
+		x25_frwd = list_entry(entry, struct x25_forward, node);
+		if (x25_frwd->lci == lci) {
+			printk(KERN_WARNING "X.25: call request for lci which is already registered!, transmitting but not registering new pair\n");
+			same_lci = 1;
 		}
+	}
+	read_unlock_bh(&x25_forward_list_lock);
 
-		/* Forward the call request */
-		if ( (skbn = skb_clone(skb, GFP_ATOMIC)) == NULL){
+	/* Save the forwarding details for future traffic */
+	if (!same_lci){
+		if ((new_frwd = kmalloc(sizeof(struct x25_forward),
+						GFP_ATOMIC)) == NULL){
+			rc = -ENOMEM;
 			goto out_put_nb;
 		}
-		x25_transmit_link(skbn, neigh_new);
-		rc = 1;
+		new_frwd->lci = lci;
+		new_frwd->dev1 = rt->dev;
+		new_frwd->dev2 = from->dev;
+		write_lock_bh(&x25_forward_list_lock);
+		list_add(&new_frwd->node, &x25_forward_list);
+		write_unlock_bh(&x25_forward_list_lock);
 	}
 
+	/* Forward the call request */
+	if ( (skbn = skb_clone(skb, GFP_ATOMIC)) == NULL){
+		goto out_put_nb;
+	}
+	x25_transmit_link(skbn, neigh_new);
+	rc = 1;
+
 
 out_put_nb:
 	x25_neigh_put(neigh_new);
 
 out_put_route:
 	x25_route_put(rt);
+
+out_no_route:
 	return rc;
 }
 

