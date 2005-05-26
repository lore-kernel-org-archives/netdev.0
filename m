From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/6) bridge: set features based on enslaved
	devices
Date: Thu, 26 May 2005 11:04:16 -0700
Message-ID: <20050526110416.66a08e87@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============63601099669858141=="
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
   bridge@osdl.org
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

--===============63601099669858141==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Make features of the bridge pseudo-device be a subset of the underlying
devices.  Motivated by Xen and others who use bridging to do failover.

Signed-off-by: Catalin BOIE <catab at umrella.ro>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Index: bridge/net/bridge/br_private.h
===================================================================
--- bridge.orig/net/bridge/br_private.h
+++ bridge/net/bridge/br_private.h
@@ -174,6 +174,7 @@ extern int br_add_if(struct net_bridge *
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
 extern int br_min_mtu(const struct net_bridge *br);
+extern void br_features_recompute(struct net_bridge *br);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
Index: bridge/net/bridge/br_notify.c
===================================================================
--- bridge.orig/net/bridge/br_notify.c
+++ bridge/net/bridge/br_notify.c
@@ -65,6 +65,15 @@ static int br_device_event(struct notifi
 		}
 		break;
 
+	case NETDEV_FEAT_CHANGE:
+		if (br->dev->flags & IFF_UP) 
+			br_features_recompute(br);
+
+		/* could do recursive feature change notification
+		 * but who would care?? 
+		 */
+		break;
+
 	case NETDEV_DOWN:
 		if (br->dev->flags & IFF_UP)
 			br_stp_disable_port(p);
Index: bridge/net/bridge/br_device.c
===================================================================
--- bridge.orig/net/bridge/br_device.c
+++ bridge/net/bridge/br_device.c
@@ -21,10 +21,7 @@
 
 static struct net_device_stats *br_dev_get_stats(struct net_device *dev)
 {
-	struct net_bridge *br;
-
-	br = dev->priv;
-
+	struct net_bridge *br = netdev_priv(dev);
 	return &br->statistics;
 }
 
@@ -54,9 +51,11 @@ int br_dev_xmit(struct sk_buff *skb, str
 
 static int br_dev_open(struct net_device *dev)
 {
-	netif_start_queue(dev);
+	struct net_bridge *br = netdev_priv(dev);
 
-	br_stp_enable_bridge(dev->priv);
+	br_features_recompute(br);
+	netif_start_queue(dev);
+	br_stp_enable_bridge(br);
 
 	return 0;
 }
@@ -67,7 +66,7 @@ static void br_dev_set_multicast_list(st
 
 static int br_dev_stop(struct net_device *dev)
 {
-	br_stp_disable_bridge(dev->priv);
+	br_stp_disable_bridge(netdev_priv(dev));
 
 	netif_stop_queue(dev);
 
@@ -76,7 +75,7 @@ static int br_dev_stop(struct net_device
 
 static int br_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if ((new_mtu < 68) || new_mtu > br_min_mtu(dev->priv))
+	if (new_mtu < 68 || new_mtu > br_min_mtu(netdev_priv(dev)))
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
Index: bridge/net/bridge/br_if.c
===================================================================
--- bridge.orig/net/bridge/br_if.c
+++ bridge/net/bridge/br_if.c
@@ -314,6 +314,28 @@ int br_min_mtu(const struct net_bridge *
 	return mtu;
 }
 
+/*
+ * Recomputes features using slave's features
+ */
+void br_features_recompute(struct net_bridge *br)
+{
+	struct net_bridge_port *p;
+	unsigned long features, checksum;
+
+	features = NETIF_F_SG | NETIF_F_FRAGLIST 
+		| NETIF_F_HIGHDMA | NETIF_F_TSO;
+	checksum = NETIF_F_IP_CSUM;	/* least commmon subset */
+
+	list_for_each_entry(p, &br->port_list, list) {
+		if (!(p->dev->features 
+		      & (NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM)))
+			checksum = 0;
+		features &= p->dev->features;
+	}
+
+	br->dev->features = features | checksum | NETIF_F_LLTX;
+}
+
 /* called with RTNL */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
@@ -368,6 +390,7 @@ int br_del_if(struct net_bridge *br, str
 
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
+	br_features_recompute(br);
 	spin_unlock_bh(&br->lock);
 
 	return 0;

--===============63601099669858141==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============63601099669858141==--
