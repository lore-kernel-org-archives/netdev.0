From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] macvlan: Introduce 'passthru' mode to takeover the
 underlying device
Date: Thu, 28 Oct 2010 16:10:50 -0700
Message-ID: <1288307450.30131.82.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the current default 'vepa' mode, a KVM guest using virtio with 
macvtap backend has the following limitations.
- cannot change/add a mac address on the guest virtio-net
- cannot create a vlan device on the guest virtio-net
- cannot enable promiscuous mode on guest virtio-net

To address these limitations, this patch introduces a new mode called
'passthru' when creating a macvlan device which allows takeover of the
underlying device and passing it to a guest using virtio with macvtap
backend.

Only one macvlan device is allowed in passthru mode and it inherits
the mac address from the underlying device and sets it in promiscuous 
mode to receive and forward all the packets.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

-------------------------------------------------------------------------

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0ef0eb0..bca3cb7 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -38,6 +38,7 @@ struct macvlan_port {
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
 	struct list_head	vlans;
 	struct rcu_head		rcu;
+	bool 			passthru;
 };
 
 #define macvlan_port_get_rcu(dev) \
@@ -169,6 +170,7 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 			macvlan_broadcast(skb, port, NULL,
 					  MACVLAN_MODE_PRIVATE |
 					  MACVLAN_MODE_VEPA    |
+					  MACVLAN_MODE_PASSTHRU|
 					  MACVLAN_MODE_BRIDGE);
 		else if (src->mode == MACVLAN_MODE_VEPA)
 			/* flood to everyone except source */
@@ -185,7 +187,10 @@ static struct sk_buff *macvlan_handle_frame(struct sk_buff *skb)
 		return skb;
 	}
 
-	vlan = macvlan_hash_lookup(port, eth->h_dest);
+	if (port->passthru)
+		vlan = list_first_entry(&port->vlans, struct macvlan_dev, list);
+	else
+		vlan = macvlan_hash_lookup(port, eth->h_dest);
 	if (vlan == NULL)
 		return skb;
 
@@ -284,6 +289,11 @@ static int macvlan_open(struct net_device *dev)
 	struct net_device *lowerdev = vlan->lowerdev;
 	int err;
 
+	if (vlan->port->passthru) {
+		dev_set_promiscuity(lowerdev, 1);
+		goto hash_add;
+	}
+
 	err = -EBUSY;
 	if (macvlan_addr_busy(vlan->port, dev->dev_addr))
 		goto out;
@@ -296,6 +306,8 @@ static int macvlan_open(struct net_device *dev)
 		if (err < 0)
 			goto del_unicast;
 	}
+
+hash_add:
 	macvlan_hash_add(vlan);
 	return 0;
 
@@ -310,12 +322,18 @@ static int macvlan_stop(struct net_device *dev)
 	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct net_device *lowerdev = vlan->lowerdev;
 
+	if (vlan->port->passthru) {
+		dev_set_promiscuity(lowerdev, -1);
+		goto hash_del;
+	}
+
 	dev_mc_unsync(lowerdev, dev);
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
 
 	dev_uc_del(lowerdev, dev->dev_addr);
 
+hash_del:
 	macvlan_hash_del(vlan);
 	return 0;
 }
@@ -549,6 +567,7 @@ static int macvlan_port_create(struct net_device *dev)
 	if (port == NULL)
 		return -ENOMEM;
 
+	port->passthru = false;
 	port->dev = dev;
 	INIT_LIST_HEAD(&port->vlans);
 	for (i = 0; i < MACVLAN_HASH_SIZE; i++)
@@ -593,6 +612,7 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		case MACVLAN_MODE_PRIVATE:
 		case MACVLAN_MODE_VEPA:
 		case MACVLAN_MODE_BRIDGE:
+		case MACVLAN_MODE_PASSTHRU:
 			break;
 		default:
 			return -EINVAL;
@@ -661,6 +681,10 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	}
 	port = macvlan_port_get(lowerdev);
 
+	/* Only 1 macvlan device can be created in passthru mode */
+	if (port->passthru)
+		return -EINVAL;
+
 	vlan->lowerdev = lowerdev;
 	vlan->dev      = dev;
 	vlan->port     = port;
@@ -671,6 +695,13 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	if (data && data[IFLA_MACVLAN_MODE])
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
+	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
+		if (!list_empty(&port->vlans))
+			return -EINVAL;
+		port->passthru = true;
+		memcpy(dev->dev_addr, lowerdev->dev_addr, ETH_ALEN);
+	}
+
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto destroy_port;
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 2fc66dd..8454805 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -232,6 +232,7 @@ enum macvlan_mode {
 	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
 	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
+	MACVLAN_MODE_PASSTHRU = 8,/* take over the underlying device */
 };
 
 /* SR-IOV virtual function management section */


