From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/6) bridge: add way to flush forwarding table
Date: Thu, 26 May 2005 11:04:22 -0700
Message-ID: <20050526110422.0dabeb71@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============82286245909612399=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============82286245909612399==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Add a hook to allow flushing the bridge forwarding table for testing
or reconfiguration via:

echo > /sys/class/net/brX/bridge/flush

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: bridge/net/bridge/br_private.h
===================================================================
--- bridge.orig/net/bridge/br_private.h
+++ bridge/net/bridge/br_private.h
@@ -135,6 +135,7 @@ extern void br_fdb_fini(void);
 extern void br_fdb_changeaddr(struct net_bridge_port *p,
 			      const unsigned char *newaddr);
 extern void br_fdb_cleanup(unsigned long arg);
+extern void br_fdb_flush(struct net_bridge *br);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 			   struct net_bridge_port *p);
 extern struct net_bridge_fdb_entry *__br_fdb_get(struct net_bridge *br,
Index: bridge/net/bridge/br_fdb.c
===================================================================
--- bridge.orig/net/bridge/br_fdb.c
+++ bridge/net/bridge/br_fdb.c
@@ -106,26 +106,46 @@ void br_fdb_changeaddr(struct net_bridge
 	spin_unlock_bh(&br->hash_lock);
 }
 
-void br_fdb_cleanup(unsigned long _data)
+static void fdb_flush(struct net_bridge *br, int all)
 {
-	struct net_bridge *br = (struct net_bridge *)_data;
-	unsigned long delay = hold_time(br);
+	unsigned long hold = hold_time(br);
+	unsigned long interval = HZ/10;
 	int i;
 
-	spin_lock_bh(&br->hash_lock);
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 		struct hlist_node *h, *n;
 
 		hlist_for_each_entry_safe(f, h, n, &br->hash[i], hlist) {
-			if (!f->is_static && 
-			    time_before_eq(f->ageing_timer + delay, jiffies)) 
+			unsigned long age = jiffies - f->ageing_timer;
+			if (f->is_static)
+				continue;
+
+			if (all || age >= hold)
 				fdb_delete(f);
+			else 
+				interval = min(hold - age, interval);
+
 		}
 	}
+
+	mod_timer(&br->gc_timer, jiffies + interval);
+}	
+
+void br_fdb_cleanup(unsigned long _data)
+{
+	struct net_bridge *br = (struct net_bridge *)_data;
+
+	spin_lock_bh(&br->hash_lock);
+	fdb_flush(br, 0);
 	spin_unlock_bh(&br->hash_lock);
+}
 
-	mod_timer(&br->gc_timer, jiffies + HZ/10);
+void br_fdb_flush(struct net_bridge *br)
+{
+	spin_lock_bh(&br->hash_lock);
+	fdb_flush(br, 1);
+	spin_unlock_bh(&br->hash_lock);
 }
 
 void br_fdb_delete_by_port(struct net_bridge *br, struct net_bridge_port *p)
Index: bridge/net/bridge/br_sysfs_br.c
===================================================================
--- bridge.orig/net/bridge/br_sysfs_br.c
+++ bridge/net/bridge/br_sysfs_br.c
@@ -241,6 +241,20 @@ static ssize_t show_gc_timer(struct clas
 }
 static CLASS_DEVICE_ATTR(gc_timer, S_IRUGO, show_gc_timer, NULL);
 
+static ssize_t store_flush(struct class_device *cd,
+			   const char *buf, size_t len)
+{
+	struct net_bridge *br = to_bridge(cd);
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	
+	br_fdb_flush(br);
+	return len;
+}
+static CLASS_DEVICE_ATTR(flush, S_IWUSR, NULL, store_flush);
+
+
 static struct attribute *bridge_attrs[] = {
 	&class_device_attr_forward_delay.attr,
 	&class_device_attr_hello_time.attr,
@@ -258,6 +272,7 @@ static struct attribute *bridge_attrs[] 
 	&class_device_attr_tcn_timer.attr,
 	&class_device_attr_topology_change_timer.attr,
 	&class_device_attr_gc_timer.attr,
+	&class_device_attr_flush.attr,
 	NULL
 };
 

--===============82286245909612399==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============82286245909612399==--
