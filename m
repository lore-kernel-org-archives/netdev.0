From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically
 configured
Date: Mon, 16 Feb 2015 12:03:45 -0500
Message-ID: <20150216120345.4dfd9950@uryu.home.lan>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com>
	<20150213212830.GA29912@electric-eye.fr.zoreil.com>
	<54E1568D.5000100@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>,
	<mst@redhat.com>, <jasowang@redhat.com>, <viro@zeniv.linux.org.uk>,
	<davem@davemloft.net>, <sergei.shtylyov@cogentembedded.com>,
	<jonathon.reinhart@gmail.com>
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:38783 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482AbbBPRDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 12:03:52 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so19108957qcw.6
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 09:03:52 -0800 (PST)
In-Reply-To: <54E1568D.5000100@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like to propose this is as a more complete alternative.

From: Stephen Hemminger <stephen@networkpluber.org>
Subject: [PATCH] tun: support overriding ethtool information

Extensions to allow masqurade of ethtool info and device statistics.
This is useful to provide correct information to SNMP and OSPF routing
daemons when doing hw/sw offload of network device.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/tun.c              | 139 +++++++++++++++++++++++++++++++++++++----
 include/uapi/linux/if_tunnel.h |   9 +++
 2 files changed, 135 insertions(+), 13 deletions(-)

--- a/drivers/net/tun.c	2015-02-16 11:58:00.651506008 -0500
+++ b/drivers/net/tun.c	2015-02-16 11:59:15.560842558 -0500
@@ -60,6 +60,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
+#include <linux/if_tunnel.h>
 #include <linux/if_vlan.h>
 #include <linux/crc32.h>
 #include <linux/nsproxy.h>
@@ -204,6 +205,9 @@ struct tun_struct {
 	struct list_head disabled;
 	void *security;
 	u32 flow_count;
+	u8 duplex;
+	u32 speed;
+	struct ip_tunnel_info	info;
 };
 
 static inline u16 tun16_to_cpu(struct tun_struct *tun, __virtio16 val)
@@ -866,6 +870,33 @@ static netdev_features_t tun_net_fix_fea
 
 	return (features & tun->set_features) | (features & ~TUN_USER_FEATURES);
 }
+
+static int
+tun_net_set_info(struct net_device *dev, const void __user *data)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	struct ip_tunnel_info info;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (copy_from_user(&info, data, sizeof(info)))
+		return -EFAULT;
+
+	strlcpy(tun->info.driver, info.driver, sizeof(tun->info.driver));
+	strlcpy(tun->info.bus, info.bus, sizeof(tun->info.bus));
+	return 0;
+}
+
+static int
+tun_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	if (cmd != SIOCDRVINFO)
+		return -EOPNOTSUPP;
+
+	return tun_net_set_info(dev, ifr->ifr_ifru.ifru_data);
+}
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void tun_poll_controller(struct net_device *dev)
 {
@@ -904,6 +935,7 @@ static const struct net_device_ops tap_n
 	.ndo_change_mtu		= tun_net_change_mtu,
 	.ndo_fix_features	= tun_net_fix_features,
 	.ndo_set_rx_mode	= tun_net_mclist,
+	.ndo_do_ioctl		= tun_net_ioctl,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_select_queue	= tun_select_queue,
@@ -1408,6 +1440,8 @@ static void tun_setup(struct net_device
 
 	tun->owner = INVALID_UID;
 	tun->group = INVALID_GID;
+	tun->speed = SPEED_10;
+	tun->duplex = DUPLEX_FULL;
 
 	dev->ethtool_ops = &tun_ethtool_ops;
 	dev->destructor = tun_free_netdev;
@@ -1654,6 +1688,11 @@ static int tun_set_iff(struct net *net,
 
 		spin_lock_init(&tun->lock);
 
+		strlcpy(tun->info.driver, DRV_NAME, sizeof(tun->info.driver));
+		strlcpy(tun->info.bus,
+			(ifr->ifr_flags & IFF_TUN) ? "tun" : "tap",
+			sizeof(tun->info.bus));
+
 		err = security_tun_dev_alloc_security(&tun->security);
 		if (err < 0)
 			goto err_free_dev;
@@ -2253,10 +2292,12 @@ static struct miscdevice tun_miscdev = {
 
 static int tun_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
+	struct tun_struct *tun = netdev_priv(dev);
+
 	cmd->supported		= 0;
 	cmd->advertising	= 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
-	cmd->duplex		= DUPLEX_FULL;
+	ethtool_cmd_speed_set(cmd, tun->speed);
+	cmd->duplex		= tun->duplex;
 	cmd->port		= PORT_TP;
 	cmd->phy_address	= 0;
 	cmd->transceiver	= XCVR_INTERNAL;
@@ -2266,21 +2307,24 @@ static int tun_get_settings(struct net_d
 	return 0;
 }
 
+static int tun_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	tun->speed = ethtool_cmd_speed(ecmd);
+	tun->duplex = ecmd->duplex;
+
+	return 0;
+}
+
 static void tun_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
-	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->driver, tun->info.driver, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 
-	switch (tun->flags & TUN_TYPE_MASK) {
-	case IFF_TUN:
-		strlcpy(info->bus_info, "tun", sizeof(info->bus_info));
-		break;
-	case IFF_TAP:
-		strlcpy(info->bus_info, "tap", sizeof(info->bus_info));
-		break;
-	}
+	strlcpy(info->bus_info, tun->info.bus, sizeof(info->bus_info));
 }
 
 static u32 tun_get_msglevel(struct net_device *dev)
@@ -2303,6 +2347,7 @@ static void tun_set_msglevel(struct net_
 
 static const struct ethtool_ops tun_ethtool_ops = {
 	.get_settings	= tun_get_settings,
+	.set_settings	= tun_set_settings,
 	.get_drvinfo	= tun_get_drvinfo,
 	.get_msglevel	= tun_get_msglevel,
 	.set_msglevel	= tun_set_msglevel,
--- a/include/uapi/linux/if_tunnel.h	2015-02-16 11:58:00.651506008 -0500
+++ b/include/uapi/linux/if_tunnel.h	2015-02-16 11:58:00.651506008 -0500
@@ -17,6 +17,12 @@
 #define SIOCADD6RD      (SIOCDEVPRIVATE + 9)
 #define SIOCDEL6RD      (SIOCDEVPRIVATE + 10)
 #define SIOCCHG6RD      (SIOCDEVPRIVATE + 11)
+#define SIOCDRVINFO	(SIOCDEVPRIVATE + 12)
+
+struct ip_tunnel_info {
+	char driver[32];
+	char bus[32];
+};
 
 #define GRE_CSUM	__cpu_to_be16(0x8000)
 #define GRE_ROUTING	__cpu_to_be16(0x4000)
