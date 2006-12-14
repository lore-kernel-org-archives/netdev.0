From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25 7/7] Fix unchecked rose_add_loopback_neigh uses
Date: Thu, 14 Dec 2006 23:42:13 +0100
Message-ID: <11661361353489-git-send-email-ralf@linux-mips.org>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rose_add_loopback_neigh uses kmalloc and the callers were ignoring the
error value.  Rewrite to let the caller deal with the allocation.  This
allows the use of static allocation of kmalloc use entirely.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 include/net/rose.h       |    4 ++--
 net/rose/rose_loopback.c |    5 +++--
 net/rose/rose_route.c    |   45 +++++++++++++++++++++------------------------
 3 files changed, 26 insertions(+), 28 deletions(-)

Index: linux-net/include/net/rose.h
===================================================================
--- linux-net.orig/include/net/rose.h
+++ linux-net/include/net/rose.h
@@ -188,12 +188,12 @@ extern void rose_kick(struct sock *);
 extern void rose_enquiry_response(struct sock *);
 
 /* rose_route.c */
-extern struct rose_neigh *rose_loopback_neigh;
+extern struct rose_neigh rose_loopback_neigh;
 extern struct file_operations rose_neigh_fops;
 extern struct file_operations rose_nodes_fops;
 extern struct file_operations rose_routes_fops;
 
-extern int __must_check rose_add_loopback_neigh(void);
+extern void rose_add_loopback_neigh(void);
 extern int __must_check rose_add_loopback_node(rose_address *);
 extern void rose_del_loopback_node(rose_address *);
 extern void rose_rt_device_down(struct net_device *);
Index: linux-net/net/rose/rose_loopback.c
===================================================================
--- linux-net.orig/net/rose/rose_loopback.c
+++ linux-net/net/rose/rose_loopback.c
@@ -79,7 +79,8 @@ static void rose_loopback_timer(unsigned
 
 		skb->h.raw = skb->data;
 
-		if ((sk = rose_find_socket(lci_o, rose_loopback_neigh)) != NULL) {
+		sk = rose_find_socket(lci_o, &rose_loopback_neigh);
+		if (sk) {
 			if (rose_process_rx_frame(sk, skb) == 0)
 				kfree_skb(skb);
 			continue;
@@ -87,7 +88,7 @@ static void rose_loopback_timer(unsigned
 
 		if (frametype == ROSE_CALL_REQUEST) {
 			if ((dev = rose_dev_get(dest)) != NULL) {
-				if (rose_rx_call_request(skb, dev, rose_loopback_neigh, lci_o) == 0)
+				if (rose_rx_call_request(skb, dev, &rose_loopback_neigh, lci_o) == 0)
 					kfree_skb(skb);
 			} else {
 				kfree_skb(skb);
Index: linux-net/net/rose/rose_route.c
===================================================================
--- linux-net.orig/net/rose/rose_route.c
+++ linux-net/net/rose/rose_route.c
@@ -46,7 +46,7 @@ static DEFINE_SPINLOCK(rose_neigh_list_l
 static struct rose_route *rose_route_list;
 static DEFINE_SPINLOCK(rose_route_list_lock);
 
-struct rose_neigh *rose_loopback_neigh;
+struct rose_neigh rose_loopback_neigh;
 
 /*
  *	Add a new route to a node, and in the process add the node and the
@@ -361,33 +361,30 @@ out:
 /*
  *	Add the loopback neighbour.
  */
-int rose_add_loopback_neigh(void)
+void rose_add_loopback_neigh(void)
 {
-	if ((rose_loopback_neigh = kmalloc(sizeof(struct rose_neigh), GFP_ATOMIC)) == NULL)
-		return -ENOMEM;
+	struct rose_neigh *sn = &rose_loopback_neigh;
 
-	rose_loopback_neigh->callsign  = null_ax25_address;
-	rose_loopback_neigh->digipeat  = NULL;
-	rose_loopback_neigh->ax25      = NULL;
-	rose_loopback_neigh->dev       = NULL;
-	rose_loopback_neigh->count     = 0;
-	rose_loopback_neigh->use       = 0;
-	rose_loopback_neigh->dce_mode  = 1;
-	rose_loopback_neigh->loopback  = 1;
-	rose_loopback_neigh->number    = rose_neigh_no++;
-	rose_loopback_neigh->restarted = 1;
+	sn->callsign  = null_ax25_address;
+	sn->digipeat  = NULL;
+	sn->ax25      = NULL;
+	sn->dev       = NULL;
+	sn->count     = 0;
+	sn->use       = 0;
+	sn->dce_mode  = 1;
+	sn->loopback  = 1;
+	sn->number    = rose_neigh_no++;
+	sn->restarted = 1;
 
-	skb_queue_head_init(&rose_loopback_neigh->queue);
+	skb_queue_head_init(&sn->queue);
 
-	init_timer(&rose_loopback_neigh->ftimer);
-	init_timer(&rose_loopback_neigh->t0timer);
+	init_timer(&sn->ftimer);
+	init_timer(&sn->t0timer);
 
 	spin_lock_bh(&rose_neigh_list_lock);
-	rose_loopback_neigh->next = rose_neigh_list;
-	rose_neigh_list           = rose_loopback_neigh;
+	sn->next = rose_neigh_list;
+	rose_neigh_list           = sn;
 	spin_unlock_bh(&rose_neigh_list_lock);
-
-	return 0;
 }
 
 /*
@@ -421,13 +418,13 @@ int rose_add_loopback_node(rose_address 
 	rose_node->mask         = 10;
 	rose_node->count        = 1;
 	rose_node->loopback     = 1;
-	rose_node->neighbour[0] = rose_loopback_neigh;
+	rose_node->neighbour[0] = &rose_loopback_neigh;
 
 	/* Insert at the head of list. Address is always mask=10 */
 	rose_node->next = rose_node_list;
 	rose_node_list  = rose_node;
 
-	rose_loopback_neigh->count++;
+	rose_loopback_neigh.count++;
 
 out:
 	spin_unlock_bh(&rose_node_list_lock);
@@ -458,7 +455,7 @@ void rose_del_loopback_node(rose_address
 
 	rose_remove_node(rose_node);
 
-	rose_loopback_neigh->count--;
+	rose_loopback_neigh.count--;
 
 out:
 	spin_unlock_bh(&rose_node_list_lock);
