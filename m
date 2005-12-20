From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] bridge: handle speed detection after carrier
	changes
Date: Tue, 20 Dec 2005 15:19:51 -0800
Message-ID: <20051220232154.731654000@localhost.localdomain>
References: <20051220231949.772360000@localhost.localdomain>
Content-Type: multipart/mixed; boundary="===============95176788067613982=="
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

--===============95176788067613982==
Content-Disposition: inline; filename=br-speed-nocarrier.patch

Speed of a interface may not be available until carrier
is detected in the case of autonegotiation. To get the correct value
we need to recheck speed after carrier event.  But the check needs to
be done in a context that is similar to normal ethtool interface (can sleep).

Also, delay check for 1ms to try avoid any carrier bounce transitions.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br-2.6.16.orig/net/bridge/br_if.c
+++ br-2.6.16/net/bridge/br_if.c
@@ -32,9 +32,8 @@
  * ethtool, use ethtool_ops.  Also, since driver might sleep need to
  * not be holding any locks.
  */
-static int br_initial_port_cost(struct net_device *dev)
+static int port_cost(struct net_device *dev)
 {
-
 	struct ethtool_cmd ecmd = { ETHTOOL_GSET };
 	struct ifreq ifr;
 	mm_segment_t old_fs;
@@ -58,10 +57,6 @@ static int br_initial_port_cost(struct n
 			return 2;
 		case SPEED_10:
 			return 100;
-		default:
-			pr_info("bridge: can't decode speed from %s: %d\n",
-				dev->name, ecmd.speed);
-			return 100;
 		}
 	}
 
@@ -75,6 +70,35 @@ static int br_initial_port_cost(struct n
 	return 100;	/* assume old 10Mbps */
 }
 
+
+/*
+ * Check for port carrier transistions.
+ * Called from work queue to allow for calling functions that
+ * might sleep (such as speed check), and to debounce.
+ */
+static void port_carrier_check(void *arg)
+{
+	struct net_bridge_port *p = arg;
+
+	rtnl_lock();
+	if (netif_carrier_ok(p->dev)) {
+		u32 cost = port_cost(p->dev);
+
+		spin_lock_bh(&p->br->lock);
+		if (p->state == BR_STATE_DISABLED) {
+			p->path_cost = cost;
+			br_stp_enable_port(p);
+		}
+		spin_unlock_bh(&p->br->lock);
+	} else {
+		spin_lock_bh(&p->br->lock);
+		if (p->state != BR_STATE_DISABLED)
+			br_stp_disable_port(p);
+		spin_unlock_bh(&p->br->lock);
+	}
+	rtnl_unlock();
+}
+
 static void destroy_nbp(struct net_bridge_port *p)
 {
 	struct net_device *dev = p->dev;
@@ -102,6 +126,9 @@ static void del_nbp(struct net_bridge_po
 	dev->br_port = NULL;
 	dev_set_promiscuity(dev, -1);
 
+	cancel_delayed_work(&p->carrier_check);
+	flush_scheduled_work();
+
 	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
 	spin_unlock_bh(&br->lock);
@@ -195,10 +222,9 @@ static int find_portno(struct net_bridge
 	return (index >= BR_MAX_PORTS) ? -EXFULL : index;
 }
 
-/* called with RTNL */
+/* called with RTNL but without bridge lock */
 static struct net_bridge_port *new_nbp(struct net_bridge *br, 
-				       struct net_device *dev,
-				       unsigned long cost)
+				       struct net_device *dev)
 {
 	int index;
 	struct net_bridge_port *p;
@@ -215,12 +241,13 @@ static struct net_bridge_port *new_nbp(s
 	p->br = br;
 	dev_hold(dev);
 	p->dev = dev;
-	p->path_cost = cost;
+	p->path_cost = port_cost(dev);
  	p->priority = 0x8000 >> BR_PORT_BITS;
 	dev->br_port = p;
 	p->port_no = index;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
+	INIT_WORK(&p->carrier_check, port_carrier_check, p);
 	kobject_init(&p->kobj);
 
 	return p;
@@ -351,7 +378,7 @@ int br_add_if(struct net_bridge *br, str
 	if (dev->br_port != NULL)
 		return -EBUSY;
 
-	if (IS_ERR(p = new_nbp(br, dev, br_initial_port_cost(dev))))
+	if (IS_ERR(p = new_nbp(br, dev)))
 		return PTR_ERR(p);
 
  	if ((err = br_fdb_insert(br, p, dev->dev_addr)))
--- br-2.6.16.orig/net/bridge/br_notify.c
+++ br-2.6.16/net/bridge/br_notify.c
@@ -52,17 +52,9 @@ static int br_device_event(struct notifi
 		br_stp_recalculate_bridge_id(br);
 		break;
 
-	case NETDEV_CHANGE:	/* device is up but carrier changed */
-		if (!(br->dev->flags & IFF_UP))
-			break;
-
-		if (netif_carrier_ok(dev)) {
-			if (p->state == BR_STATE_DISABLED)
-				br_stp_enable_port(p);
-		} else {
-			if (p->state != BR_STATE_DISABLED)
-				br_stp_disable_port(p);
-		}
+	case NETDEV_CHANGE:
+		if (br->dev->flags & IFF_UP)
+			schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE);
 		break;
 
 	case NETDEV_FEAT_CHANGE:
--- br-2.6.16.orig/net/bridge/br_private.h
+++ br-2.6.16/net/bridge/br_private.h
@@ -27,6 +27,8 @@
 #define BR_PORT_BITS	10
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
 
+#define BR_PORT_DEBOUNCE (HZ/10)
+
 typedef struct bridge_id bridge_id;
 typedef struct mac_addr mac_addr;
 typedef __u16 port_id;
@@ -78,6 +80,7 @@ struct net_bridge_port
 	struct timer_list		hold_timer;
 	struct timer_list		message_age_timer;
 	struct kobject			kobj;
+	struct work_struct		carrier_check;
 	struct rcu_head			rcu;
 };
 

--
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger


--===============95176788067613982==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/bridge

--===============95176788067613982==--
