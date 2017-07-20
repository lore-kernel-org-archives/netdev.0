From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net: check mac address length for dev_set_mac_address()
Date: Thu, 20 Jul 2017 11:27:58 -0700
Message-ID: <20170720182758.20204-2-xiyou.wangcong@gmail.com>
References: <20170720182758.20204-1-xiyou.wangcong@gmail.com>
Cc: dsahern@gmail.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34105 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935863AbdGTS2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 14:28:09 -0400
Received: by mail-pf0-f196.google.com with SMTP id o88so2995827pfk.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 11:28:08 -0700 (PDT)
In-Reply-To: <20170720182758.20204-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_mac_address() accepts a struct sockaddr pointer as
input but we have various types of mac addresse whose lengths
are up to MAX_ADDR_LEN, this is confusing.

Make it void like ->ndo_set_mac_address() and let callers check
its length before calling it. It is too late to fix dev_ifsioc()
due to API compatibility, so just reject those larger than
sizeof(struct sockaddr).

Fortunately, only a few IPv6 tunnel devices have addr_len
larger than sizeof(struct sockaddr) and they don't support
ndo_set_mac_addr(). But team driver seems still buggy without
this patch.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 10 +++++++---
 net/core/dev_ioctl.c      |  2 ++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 779b23595596..d7e872fa4656 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3287,7 +3287,7 @@ int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int __dev_set_mtu(struct net_device *, int);
 int dev_set_mtu(struct net_device *, int);
 void dev_set_group(struct net_device *, int);
-int dev_set_mac_address(struct net_device *, struct sockaddr *);
+int dev_set_mac_address(struct net_device *, void *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_item_id *ppid);
diff --git a/net/core/dev.c b/net/core/dev.c
index 02440518dd69..1802303bd0a7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6844,13 +6844,17 @@ EXPORT_SYMBOL(dev_set_group);
 /**
  *	dev_set_mac_address - Change Media Access Control Address
  *	@dev: device
- *	@sa: new address
+ *	@addr: new address, whose type could be either struct sockaddr or
+ *	any other compatible type whose length is up to MAX_ADDR_LEN depending
+ *	on the dev->addr_len. Callers should check if its length is smaller than
+ *	dev->addr_len!!
  *
  *	Change the hardware (MAC) address of the device
  */
-int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
+int dev_set_mac_address(struct net_device *dev, void *addr)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct sockaddr *sa = addr;
 	int err;
 
 	if (!ops->ndo_set_mac_address)
@@ -6859,7 +6863,7 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
-	err = ops->ndo_set_mac_address(dev, sa);
+	err = ops->ndo_set_mac_address(dev, addr);
 	if (err)
 		return err;
 	dev->addr_assign_type = NET_ADDR_SET;
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 82fd4c9c4a1b..3f41601d7b7c 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -262,6 +262,8 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		return dev_set_mtu(dev, ifr->ifr_mtu);
 
 	case SIOCSIFHWADDR:
+		if (dev->addr_len > sizeof(struct sockaddr))
+			return -EINVAL;
 		return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
 	case SIOCSIFHWBROADCAST:
-- 
2.13.0
