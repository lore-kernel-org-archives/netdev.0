From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) propgate bridge internal MTU changes
Date: Wed, 28 Jul 2004 15:37:25 -0700
Sender: bridge-bounces@lists.osdl.org
Message-ID: <20040728153725.7ace281c@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1235860022803843=="
Cc: netdev@oss.sgi.com, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: "David S. Miller" <davem@redhat.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============1235860022803843==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Need to propagate MTU changes that the bridge does to it's pseudo interface
up to others. There ends up being a double call to br_min_mtu() but that's
harmless.

Cleans up the EXPORT_SYMBOLS including dev_change_flags which is used by vlan.
Shouldn't be basing exports on kernel config options like this.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-07-28 15:33:20 -07:00
+++ b/net/bridge/br_if.c	2004-07-28 15:33:20 -07:00
@@ -295,6 +295,7 @@
 	return ret;
 }
 
+/* Mtu of the bridge pseudo-device 1500 or the minimum of the ports */
 int br_min_mtu(const struct net_bridge *br)
 {
 	const struct net_bridge_port *p;
@@ -347,7 +348,7 @@
 			br_stp_enable_port(p);
 		spin_unlock_bh(&br->lock);
 
-		br->dev->mtu = br_min_mtu(br);
+		dev_set_mtu(br->dev, br_min_mtu(br));
 	}
 
 	return err;
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	2004-07-28 15:33:20 -07:00
+++ b/net/bridge/br_notify.c	2004-07-28 15:33:20 -07:00
@@ -48,7 +48,7 @@
 		break;
 
 	case NETDEV_CHANGEMTU:
-		br->dev->mtu = br_min_mtu(br);
+		dev_set_mtu(br->dev, br_min_mtu(br));
 		break;
 
 	case NETDEV_DOWN:
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	2004-07-28 15:33:20 -07:00
+++ b/net/core/dev.c	2004-07-28 15:33:20 -07:00
@@ -3426,6 +3426,8 @@
 EXPORT_SYMBOL(dev_remove_pack);
 EXPORT_SYMBOL(dev_set_allmulti);
 EXPORT_SYMBOL(dev_set_promiscuity);
+EXPORT_SYMBOL(dev_change_flags);
+EXPORT_SYMBOL(dev_set_mtu);
 EXPORT_SYMBOL(free_netdev);
 EXPORT_SYMBOL(netdev_boot_setup_check);
 EXPORT_SYMBOL(netdev_set_master);
@@ -3443,10 +3445,7 @@
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 EXPORT_SYMBOL(br_handle_frame_hook);
 #endif
-/* for 801q VLAN support */
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-EXPORT_SYMBOL(dev_change_flags);
-#endif
+
 #ifdef CONFIG_KMOD
 EXPORT_SYMBOL(dev_load);
 #endif

--===============1235860022803843==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============1235860022803843==--
