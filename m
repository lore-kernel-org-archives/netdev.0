From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] bridge: allow setting hardware address of
	bridge pseudo-dev
Date: Tue, 20 Dec 2005 15:19:50 -0800
Message-ID: <20051220232154.626376000@localhost.localdomain>
References: <20051220231949.772360000@localhost.localdomain>
Content-Type: multipart/mixed; boundary="===============79205538924624475=="
Cc: netdev@vger.kernel.org, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: David Miller <davem@davemloft.net>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============79205538924624475==
Content-Disposition: inline; filename=br-setmac.patch

Some people are using bridging to hide multiple machines from an ISP
that restricts by MAC address. So in that case allow the bridge mac
address to be set to any of the existing interfaces.  I don't want to
allow any arbitrary value and confuse STP.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- br-2.6.orig/net/bridge/br_device.c
+++ br-2.6/net/bridge/br_device.c
@@ -15,7 +15,8 @@
 
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/module.h>
+#include <linux/etherdevice.h>
+
 #include <asm/uaccess.h>
 #include "br_private.h"
 
@@ -82,6 +83,29 @@ static int br_change_mtu(struct net_devi
 	return 0;
 }
 
+/* Allow setting mac address of pseudo-bridge to be same as
+ * any of the bound interfaces
+ */
+static int br_set_mac_address(struct net_device *dev, void *p)
+{
+	struct net_bridge *br = netdev_priv(dev);
+	struct sockaddr *addr = p;
+	struct net_bridge_port *port;
+	int err = -EADDRNOTAVAIL;
+
+	spin_lock_bh(&br->lock);
+	list_for_each_entry(port, &br->port_list, list) {
+		if (!compare_ether_addr(port->dev->dev_addr, addr->sa_data)) {
+			br_stp_change_bridge_id(br, addr->sa_data);
+			err = 0;
+			break;
+		}
+	}
+	spin_unlock_bh(&br->lock);
+
+	return err;
+}
+
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -98,6 +122,6 @@ void br_dev_setup(struct net_device *dev
 	SET_MODULE_OWNER(dev);
 	dev->stop = br_dev_stop;
 	dev->tx_queue_len = 0;
-	dev->set_mac_address = NULL;
+	dev->set_mac_address = br_set_mac_address;
 	dev->priv_flags = IFF_EBRIDGE;
 }
--- br-2.6.orig/net/bridge/br_private.h
+++ br-2.6/net/bridge/br_private.h
@@ -201,6 +201,7 @@ extern void br_stp_disable_bridge(struct
 extern void br_stp_enable_port(struct net_bridge_port *p);
 extern void br_stp_disable_port(struct net_bridge_port *p);
 extern void br_stp_recalculate_bridge_id(struct net_bridge *br);
+extern void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *a);
 extern void br_stp_set_bridge_priority(struct net_bridge *br,
 				       u16 newprio);
 extern void br_stp_set_port_priority(struct net_bridge_port *p,
--- br-2.6.orig/net/bridge/br_stp_if.c
+++ br-2.6/net/bridge/br_stp_if.c
@@ -120,8 +120,7 @@ void br_stp_disable_port(struct net_brid
 }
 
 /* called under bridge lock */
-static void br_stp_change_bridge_id(struct net_bridge *br, 
-				    const unsigned char *addr)
+void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 {
 	unsigned char oldaddr[6];
 	struct net_bridge_port *p;

--
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger


--===============79205538924624475==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/bridge

--===============79205538924624475==--
