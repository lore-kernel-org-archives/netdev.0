From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ax25 fix for premature free.
Date: Tue, 12 Aug 2003 15:39:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812153901.6e700dcb.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
	<20030812135655.7334887b.shemminger@osdl.org>
	<20030812230951.E28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030812230951.E28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The problem is that you are freeing the ax25 control block too soon for the case
of sockets that were never bound.  If the socket is not bound, it never makes it
into the node list and the refcount is 1.  So when you decrement in ax25_cb_del
by calling ax25_cb_put it gets freed.  

This fixes the problem, it assumes your earlier patch has been applied.

diff -Nru a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
--- a/net/ax25/af_ax25.c	Tue Aug 12 15:35:33 2003
+++ b/net/ax25/af_ax25.c	Tue Aug 12 15:35:33 2003
@@ -66,10 +66,12 @@
  */
 static void ax25_cb_del(ax25_cb *ax25)
 {
-	spin_lock_bh(&ax25_list_lock);
-	hlist_del_init(&ax25->ax25_node);
-	spin_unlock_bh(&ax25_list_lock);
-	ax25_cb_put(ax25);
+	if (!hlist_unhashed(&ax25->ax25_node)) {
+		spin_lock_bh(&ax25_list_lock);
+		hlist_del(&ax25->ax25_node);
+		spin_unlock_bh(&ax25_list_lock);
+		ax25_cb_put(ax25);
+	}
 }
 
 /*
