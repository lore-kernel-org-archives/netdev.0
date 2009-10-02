From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] net: export device speed and duplex via sysfs
Date: Fri, 2 Oct 2009 14:07:42 -0400
Message-ID: <20091002180742.GH4436@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757853AbZJBSHj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 14:07:39 -0400
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id n92I7hQx026436
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 14:07:43 -0400
Received: from gospo.usersys.redhat.com (gospo.rdu.redhat.com [10.11.228.52])
	by int-mx05.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id n92I7gje020640
	for <netdev@vger.kernel.org>; Fri, 2 Oct 2009 14:07:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This exports the link-speed (in Mbps) and duplex of an interface via
sysfs.  This eliminates the need to use ethtool just to check the
link-speed.  Not requiring 'ethtool' and not relying on the SIOCETHTOOL
ioctl should be helpful in an embedded environment where space is at a
premium as well.

NOTE: This patch also intentionally allows non-root users to check the link
speed and duplex -- something not possible with ethtool.

Here's some sample output:

# cat /sys/class/net/eth0/speed 
100
# cat /sys/class/net/eth0/duplex
half
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full 
                                100baseT/Half 100baseT/Full 
                                1000baseT/Half 1000baseT/Full 
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 100Mb/s
        Duplex: Half
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: g
        Wake-on: g
        Current message level: 0x000000ff (255)
        Link detected: yes

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 net/core/net-sysfs.c |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index ad91e9e..d5964b2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -130,6 +130,46 @@ static ssize_t show_carrier(struct device *dev,
 	return -EINVAL;
 }
 
+static ssize_t show_speed(struct device *dev,
+			  struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	int ret = -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
+		struct ethtool_cmd cmd = { ETHTOOL_GSET };
+
+		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)
+			return -EINVAL;
+		ret = sprintf(buf, fmt_dec, cmd.speed);
+	}
+	rtnl_unlock();
+	return ret;
+}
+
+static ssize_t show_duplex(struct device *dev,
+			   struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	int ret = -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
+		struct ethtool_cmd cmd = { ETHTOOL_GSET };
+
+		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)
+			return -EINVAL;
+		ret = sprintf(buf, "%s\n", cmd.duplex ? "full" : "half");
+	}
+	rtnl_unlock();
+	return ret;
+}
+
 static ssize_t show_dormant(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
@@ -259,6 +299,8 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(address, S_IRUGO, show_address, NULL),
 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
 	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
+	__ATTR(speed, S_IRUGO, show_speed, NULL),
+	__ATTR(duplex, S_IRUGO, show_duplex, NULL),
 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
 	__ATTR(operstate, S_IRUGO, show_operstate, NULL),
 	__ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu),
-- 
1.6.2.5

