From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 1/3] net: check mac address length for dev_set_mac_address()
Date: Tue, 25 Apr 2017 22:03:21 -0700
Message-ID: <1493183003-884-2-git-send-email-xiyou.wangcong@gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35044 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993375AbdDZFDh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:03:37 -0400
Received: by mail-pg0-f66.google.com with SMTP id 68so992666pgj.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:03:37 -0700 (PDT)
In-Reply-To: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_mac_address() accepts a struct sockaddr pointer as
input but we have various types of mac addresse whose lengths
are up to MAX_ADDR_LEN, this is confusing.

Make it void like ->ndo_set_mac_address() and let callers check
its length before calling it. It is too late to fix dev_ifsioc()
due to API compatiblity, so just reject those larger than
sizeof(struct sockaddr).

This is also a preparation for the following patches.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 10 +++++++---
 net/core/dev_ioctl.c      |  2 ++
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b25..40e674c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3271,7 +3271,7 @@ int dev_set_alias(struct net_device *, const char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int dev_set_mtu(struct net_device *, int);
 void dev_set_group(struct net_device *, int);
-int dev_set_mac_address(struct net_device *, struct sockaddr *);
+int dev_set_mac_address(struct net_device *, void *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
 int dev_get_phys_port_id(struct net_device *dev,
 			 struct netdev_phys_item_id *ppid);
diff --git a/net/core/dev.c b/net/core/dev.c
index 533a6d6..cc670e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6610,13 +6610,17 @@ EXPORT_SYMBOL(dev_set_group);
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
@@ -6625,7 +6629,7 @@ int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
 		return -EINVAL;
 	if (!netif_device_present(dev))
 		return -ENODEV;
-	err = ops->ndo_set_mac_address(dev, sa);
+	err = ops->ndo_set_mac_address(dev, addr);
 	if (err)
 		return err;
 	dev->addr_assign_type = NET_ADDR_SET;
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index b94b1d2..11f262e 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -261,6 +261,8 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 		return dev_set_mtu(dev, ifr->ifr_mtu);
 
 	case SIOCSIFHWADDR:
+		if (dev->addr_len > sizeof(struct sockaddr))
+			return -EINVAL;
 		return dev_set_mac_address(dev, &ifr->ifr_hwaddr);
 
 	case SIOCSIFHWBROADCAST:
-- 
2.5.5
