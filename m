From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] vlan ioctl propagation (rev.2)
Date: Fri, 6 Aug 2004 14:39:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040806143928.711d92eb@dell_ss3.pdx.osdl.net>
References: <20040806091305.4d405664@dell_ss3.pdx.osdl.net>
	<20040806132145.675fd17d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040806132145.675fd17d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a redo of the patch to propagate ethtool and mii ioctl's
on vlan's to the underlying real device.  This time the request
is copied to a new buffer, to avoid the colon name rewrite issues.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-08-06 11:09:08 -07:00
+++ b/net/8021q/vlan.c	2004-08-06 11:09:08 -07:00
@@ -358,6 +358,7 @@
 	new_dev->set_mac_address = vlan_dev_set_mac_address;
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->destructor = free_netdev;
+	new_dev->do_ioctl = vlan_dev_ioctl;
 }
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
diff -Nru a/net/8021q/vlan.h b/net/8021q/vlan.h
--- a/net/8021q/vlan.h	2004-08-06 11:09:08 -07:00
+++ b/net/8021q/vlan.h	2004-08-06 11:09:08 -07:00
@@ -65,6 +65,7 @@
 int vlan_dev_set_mac_address(struct net_device *dev, void* addr);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
+int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
 int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	2004-08-06 11:09:08 -07:00
+++ b/net/8021q/vlan_dev.c	2004-08-06 11:09:08 -07:00
@@ -757,6 +757,34 @@
 	vlan_flush_mc_list(dev);
 	return 0;
 }
+
+int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct ifreq ifrr;
+	int err = -EOPNOTSUPP;
+
+	strncpy(ifrr.ifr_name, real_dev->name, IFNAMSIZ);
+	ifrr.ifr_ifru = ifr->ifr_ifru;
+
+	switch(cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (real_dev->do_ioctl && netif_device_present(real_dev)) 
+			err = real_dev->do_ioctl(dev, &ifrr, cmd);
+		break;
+
+	case SIOCETHTOOL:
+		err = dev_ethtool(&ifrr);
+	}
+
+	if (!err) 
+		ifr->ifr_ifru = ifrr.ifr_ifru;
+
+	return err;
+}
+
 /** Taken from Gleb + Lennert's VLAN code, and modified... */
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
