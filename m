From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (1/3) add ethtool ioctl forwarding to vlan
Date: Tue, 3 Aug 2004 10:50:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

When network devices are used in bridges, the bridge does an ethtool
ioctl to pick up the speed; this doesn't work with vlans.
This patch makes any ethtool gets forwarded to the under lying
real device.  It seemed to make sense to do MII as well.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-07-27 15:45:02 -07:00
+++ b/net/8021q/vlan.c	2004-07-27 15:45:02 -07:00
@@ -358,6 +358,7 @@
 	new_dev->set_mac_address = vlan_dev_set_mac_address;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->destructor = free_netdev;
+	new_dev->do_ioctl = vlan_dev_ioctl;
 }
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
diff -Nru a/net/8021q/vlan.h b/net/8021q/vlan.h
--- a/net/8021q/vlan.h	2004-07-27 15:45:02 -07:00
+++ b/net/8021q/vlan.h	2004-07-27 15:45:02 -07:00
@@ -65,6 +65,7 @@
 int vlan_dev_set_mac_address(struct net_device *dev, void* addr);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
+int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
 int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	2004-07-27 15:45:02 -07:00
+++ b/net/8021q/vlan_dev.c	2004-07-27 15:45:02 -07:00
@@ -757,6 +757,30 @@
 	vlan_flush_mc_list(dev);
 	return 0;
 }
+
+int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	int err = -EOPNOTSUPP;
+
+	switch(cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (real_dev->do_ioctl && netif_device_present(real_dev)) {
+			strncpy(ifr->ifr_name, real_dev->name, IFNAMSIZ);
+			err = real_dev->do_ioctl(dev, ifr, cmd);
+		}
+		break;
+
+	case SIOCETHTOOL:
+		strncpy(ifr->ifr_name, real_dev->name, IFNAMSIZ);
+		err = dev_ethtool(ifr);
+	}
+
+	return err;
+}
+
 /** Taken from Gleb + Lennert's VLAN code, and modified... */
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
