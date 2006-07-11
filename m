From: Ralf Baechle <ralf@linux-mips.org>
Subject: [AX.25] Optimize AX.25 socket list lock
Date: Tue, 11 Jul 2006 23:20:45 +0100
Message-ID: <20060711222045.GA5823@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:53442 "EHLO
	ftp.linux-mips.org") by vger.kernel.org with ESMTP id S1751032AbWGLJUp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 05:20:45 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now all uses of the ax25_list_lock lock are _bh locks but knowing
some code is only ever getting invoked from _bh context we can better.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
 net/ax25/af_ax25.c       |   14 +++++++-------
 net/ax25/ax25_ds_subr.c  |    8 ++++----
 net/ax25/ax25_ds_timer.c |    4 ++--
 3 files changed, 13 insertions(+), 13 deletions(-)

Index: linux-net/net/ax25/ax25_ds_subr.c
===================================================================
--- linux-net.orig/net/ax25/ax25_ds_subr.c	2006-07-11 22:51:41.000000000 +0100
+++ linux-net/net/ax25/ax25_ds_subr.c	2006-07-11 23:15:23.000000000 +0100
@@ -80,7 +80,7 @@ void ax25_ds_enquiry_response(ax25_cb *a
 	ax25_start_t3timer(ax25);
 	ax25_ds_set_timer(ax25->ax25_dev);
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(ax25o, node, &ax25_list) {
 		if (ax25o == ax25)
 			continue;
@@ -106,7 +106,7 @@ void ax25_ds_enquiry_response(ax25_cb *a
 		if (ax25o->state != AX25_STATE_0)
 			ax25_start_t3timer(ax25o);
 	}
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 }
 
 void ax25_ds_establish_data_link(ax25_cb *ax25)
@@ -162,13 +162,13 @@ static int ax25_check_dama_slave(ax25_de
 	int res = 0;
 	struct hlist_node *node;
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(ax25, node, &ax25_list)
 		if (ax25->ax25_dev == ax25_dev && (ax25->condition & AX25_COND_DAMA_MODE) && ax25->state > AX25_STATE_1) {
 			res = 1;
 			break;
 		}
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 
 	return res;
 }
Index: linux-net/net/ax25/ax25_ds_timer.c
===================================================================
--- linux-net.orig/net/ax25/ax25_ds_timer.c	2006-07-11 22:51:44.000000000 +0100
+++ linux-net/net/ax25/ax25_ds_timer.c	2006-07-11 23:15:00.000000000 +0100
@@ -85,7 +85,7 @@ static void ax25_ds_timeout(unsigned lon
 		return;
 	}
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(ax25, node, &ax25_list) {
 		if (ax25->ax25_dev != ax25_dev || !(ax25->condition & AX25_COND_DAMA_MODE))
 			continue;
@@ -93,7 +93,7 @@ static void ax25_ds_timeout(unsigned lon
 		ax25_send_control(ax25, AX25_DISC, AX25_POLLON, AX25_COMMAND);
 		ax25_disconnect(ax25, ETIMEDOUT);
 	}
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 
 	ax25_dev_dama_off(ax25_dev);
 }
Index: linux-net/net/ax25/af_ax25.c
===================================================================
--- linux-net.orig/net/ax25/af_ax25.c	2006-07-11 22:51:44.000000000 +0100
+++ linux-net/net/ax25/af_ax25.c	2006-07-11 23:15:00.000000000 +0100
@@ -145,7 +145,7 @@ struct sock *ax25_find_listener(ax25_add
 	ax25_cb *s;
 	struct hlist_node *node;
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(s, node, &ax25_list) {
 		if ((s->iamdigi && !digi) || (!s->iamdigi && digi))
 			continue;
@@ -154,12 +154,12 @@ struct sock *ax25_find_listener(ax25_add
 			/* If device is null we match any device */
 			if (s->ax25_dev == NULL || s->ax25_dev->dev == dev) {
 				sock_hold(s->sk);
-				spin_unlock_bh(&ax25_list_lock);
+				spin_unlock(&ax25_list_lock);
 				return s->sk;
 			}
 		}
 	}
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 
 	return NULL;
 }
@@ -174,7 +174,7 @@ struct sock *ax25_get_socket(ax25_addres
 	ax25_cb *s;
 	struct hlist_node *node;
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(s, node, &ax25_list) {
 		if (s->sk && !ax25cmp(&s->source_addr, my_addr) &&
 		    !ax25cmp(&s->dest_addr, dest_addr) &&
@@ -185,7 +185,7 @@ struct sock *ax25_get_socket(ax25_addres
 		}
 	}
 
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 
 	return sk;
 }
@@ -235,7 +235,7 @@ void ax25_send_to_raw(ax25_address *addr
 	struct sk_buff *copy;
 	struct hlist_node *node;
 
-	spin_lock_bh(&ax25_list_lock);
+	spin_lock(&ax25_list_lock);
 	ax25_for_each(s, node, &ax25_list) {
 		if (s->sk != NULL && ax25cmp(&s->source_addr, addr) == 0 &&
 		    s->sk->sk_type == SOCK_RAW &&
@@ -248,7 +248,7 @@ void ax25_send_to_raw(ax25_address *addr
 				kfree_skb(copy);
 		}
 	}
-	spin_unlock_bh(&ax25_list_lock);
+	spin_unlock(&ax25_list_lock);
 }
 
 /*
