From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) bridge linkstate handling
Date: Wed, 28 Jul 2004 16:24:13 -0700
Sender: bridge-bounces@lists.osdl.org
Message-ID: <20040728162413.0de73ea3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============48534440934429579=="
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

--===============48534440934429579==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

This makes bridge port status reflect both the state of the interface
from software (up/down) and the carrier.  It makes STP handle link failure
(cable breakage, etc).  The original concept comes from a 
Mark Ruijter <bridge@siennax.com> who implemented it differently.
My way is simpler and requires no polling.

Obviously, this link state detection will only work if the network card
handles the events properly.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-07-28 15:56:15 -07:00
+++ b/net/bridge/br_if.c	2004-07-28 15:56:15 -07:00
@@ -344,7 +344,8 @@
 
 		spin_lock_bh(&br->lock);
 		br_stp_recalculate_bridge_id(br);
-		if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
+		if ((br->dev->flags & IFF_UP) 
+		    && (dev->flags & IFF_UP) && netif_carrier_ok(dev))
 			br_stp_enable_port(p);
 		spin_unlock_bh(&br->lock);
 
diff -Nru a/net/bridge/br_notify.c b/net/bridge/br_notify.c
--- a/net/bridge/br_notify.c	2004-07-28 15:56:15 -07:00
+++ b/net/bridge/br_notify.c	2004-07-28 15:56:15 -07:00
@@ -19,58 +19,59 @@
 
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr);
 
-struct notifier_block br_device_notifier =
-{
+struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
 static int br_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
-	struct net_device *dev;
-	struct net_bridge_port *p;
+	struct net_device *dev = ptr;
+	struct net_bridge_port *p = dev->br_port;
 	struct net_bridge *br;
 
-	dev = ptr;
-	p = dev->br_port;
-
 	if (p == NULL)
 		return NOTIFY_DONE;
 
 	br = p->br;
+	if ( !(br->dev->flags & IFF_UP))
+		return NOTIFY_DONE;
+
+	if (event == NETDEV_CHANGEMTU) {
+		dev_set_mtu(br->dev, br_min_mtu(br));
+		return NOTIFY_DONE;
+	}
 
+	spin_lock_bh(&br->lock);
 	switch (event) {
 	case NETDEV_CHANGEADDR:
-		spin_lock_bh(&br->lock);
 		br_fdb_changeaddr(p, dev->dev_addr);
-		if (br->dev->flags & IFF_UP)
-			br_stp_recalculate_bridge_id(br);
-		spin_unlock_bh(&br->lock);
+		br_stp_recalculate_bridge_id(br);
 		break;
 
-	case NETDEV_CHANGEMTU:
-		dev_set_mtu(br->dev, br_min_mtu(br));
+	case NETDEV_CHANGE:	/* device is up but carrier changed */
+		if (netif_carrier_ok(dev)) {
+			if (p->state == BR_STATE_DISABLED)
+				br_stp_enable_port(p);
+		} else {
+			if (p->state != BR_STATE_DISABLED)
+				br_stp_disable_port(p);
+		}
 		break;
 
 	case NETDEV_DOWN:
-		if (br->dev->flags & IFF_UP) {
-			spin_lock_bh(&br->lock);
-			br_stp_disable_port(p);
-			spin_unlock_bh(&br->lock);
-		}
+		br_stp_disable_port(p);
 		break;
 
 	case NETDEV_UP:
-		if (br->dev->flags & IFF_UP) {
-			spin_lock_bh(&br->lock);
+		if (netif_carrier_ok(dev)) 
 			br_stp_enable_port(p);
-			spin_unlock_bh(&br->lock);
-		}
 		break;
 
 	case NETDEV_UNREGISTER:
 		br_del_if(br, dev);
 		break;
-	}
+	} 
+	spin_unlock_bh(&br->lock);
 
 	return NOTIFY_DONE;
 }
diff -Nru a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
--- a/net/bridge/br_stp_if.c	2004-07-28 15:56:15 -07:00
+++ b/net/bridge/br_stp_if.c	2004-07-28 15:56:15 -07:00
@@ -52,7 +52,7 @@
 	br_config_bpdu_generation(br);
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (p->dev->flags & IFF_UP)
+		if ((p->dev->flags & IFF_UP) && netif_carrier_ok(p->dev))
 			br_stp_enable_port(p);
 
 	}

--===============48534440934429579==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============48534440934429579==--
