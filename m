From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Fix for ipx interface module_get panic.
Date: Thu, 30 Oct 2003 13:00:23 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030130023.44bd9b6a.shemminger@osdl.org>
References: <20031028040421.98826.qmail@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David Liontooth" <liontooth@post.com>
In-Reply-To: <20031028040421.98826.qmail@mail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is the fix for the ipx module_get oops; it has been tested by acme.
The problem was that ipx was trying to use module counts to keep from being
unloaded when it had bottom half interfaces.  And one of these interfaces
could be created automatically when packet was received and no sockets open
(module ref count was zero).

The fix is to get rid of using module ref counts to control this, and instead
cleanup the table on module exit.

diff -Nru a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
--- a/net/ipx/af_ipx.c	Thu Oct 30 12:01:21 2003
+++ b/net/ipx/af_ipx.c	Thu Oct 30 12:01:21 2003
@@ -326,7 +326,6 @@
 	if (intrfc->if_dev)
 		dev_put(intrfc->if_dev);
 	kfree(intrfc);
-	module_put(THIS_MODULE);
 }
 
 void ipxitf_down(struct ipx_interface *intrfc)
@@ -358,6 +357,17 @@
 	return NOTIFY_DONE;
 }
 
+
+static __exit void ipxitf_cleanup(void)
+{
+	struct ipx_interface *i, *tmp;
+
+	spin_lock_bh(&ipx_interfaces_lock);
+	list_for_each_entry_safe(i, tmp, &ipx_interfaces, node) 
+		__ipxitf_put(i);
+	spin_unlock_bh(&ipx_interfaces_lock);
+}
+
 static void ipxitf_def_skb_handler(struct sock *sock, struct sk_buff *skb)
 {
 	if (sock_queue_rcv_skb(sock, skb) < 0)
@@ -888,7 +898,6 @@
 		INIT_HLIST_HEAD(&intrfc->if_sklist);
 		atomic_set(&intrfc->refcnt, 1);
 		spin_lock_init(&intrfc->if_sklist_lock);
-		__module_get(THIS_MODULE);
 	}
 
 	return intrfc;
@@ -1979,20 +1988,12 @@
 
 static void __exit ipx_proto_finito(void)
 {
-	/*
-	 * No need to worry about having anything on the ipx_interfaces list,
-	 * when a interface is created we increment the module usage count, so
-	 * the module will only be unloaded when there are no more interfaces
-	 */
-	if (unlikely(!list_empty(&ipx_interfaces)))
-		BUG();
-	if (unlikely(!list_empty(&ipx_routes)))
-		BUG();
-
 	ipx_proc_exit();
 	ipx_unregister_sysctl();
 
 	unregister_netdevice_notifier(&ipx_dev_notifier);
+
+	ipxitf_cleanup();
 
 	unregister_snap_client(pSNAP_datalink);
 	pSNAP_datalink = NULL;
