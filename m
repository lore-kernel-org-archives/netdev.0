From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/13) aarp purge table on module unload
Date: Fri, 29 Aug 2003 14:00:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030829140046.1241f018.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Schulist <jschlst@samba.org>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Aarp does not clean the arp table when the appletalk module
is unloaded, and therefore can leak memory.

diff -Nru a/net/appletalk/aarp.c b/net/appletalk/aarp.c
--- a/net/appletalk/aarp.c	Fri Aug 29 13:31:00 2003
+++ b/net/appletalk/aarp.c	Fri Aug 29 13:31:00 2003
@@ -339,6 +339,32 @@
 	return NOTIFY_DONE;
 }
 
+/* Expire all entries in a hash chain */
+static void __aarp_expire_all(struct aarp_entry **n)
+{
+	struct aarp_entry *t;
+
+	while (*n) {
+		t = *n;
+		*n = (*n)->next;
+		__aarp_expire(t);
+	}
+}
+
+/* Cleanup all hash chains -- module unloading */
+static void aarp_purge(void)
+{
+	int ct;
+
+	write_lock_bh(&aarp_lock);
+	for (ct = 0; ct < AARP_HASH_SIZE; ct++) {
+		__aarp_expire_all(&resolved[ct]);
+		__aarp_expire_all(&unresolved[ct]);
+		__aarp_expire_all(&proxies[ct]);
+	}
+	write_unlock_bh(&aarp_lock);
+}
+
 /*
  *	Create a new aarp entry.  This must use GFP_ATOMIC because it
  *	runs while holding spinlocks.
@@ -958,6 +984,7 @@
 	del_timer(&aarp_timer);
 	unregister_netdevice_notifier(&aarp_notifier);
 	unregister_snap_client(aarp_dl);
+	aarp_purge();
 }
 
 #ifdef CONFIG_PROC_FS
