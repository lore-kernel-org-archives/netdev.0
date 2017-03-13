From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/10] net: Add netif_is_vrf_master helper
Date: Mon, 13 Mar 2017 08:38:27 +0100
Message-ID: <1489390713-2634-4-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36552 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751539AbdCMHik (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:40 -0400
Received: by mail-wr0-f196.google.com with SMTP id l37so18870376wrc.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:38 -0700 (PDT)
In-Reply-To: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Drivers capable of offloading VRF configurations need to know the ports
are enslaved to an actual VRF device and not some other L3 master.

Add a flag to indicate netdev is a VRF master and a corresponding
helper.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/vrf.c         | 2 +-
 include/linux/netdevice.h | 8 ++++++++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 22379da..5c9a98e 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -1257,7 +1257,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 	if (vrf->tb_id == RT_TABLE_UNSPEC)
 		return -EINVAL;
 
-	dev->priv_flags |= IFF_L3MDEV_MASTER;
+	dev->priv_flags |= IFF_L3MDEV_MASTER | IFF_VRF_MASTER;
 
 	err = register_netdevice(dev);
 	if (err)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97456b25..7908d31 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1356,6 +1356,7 @@ struct net_device_ops {
  * @IFF_PHONY_HEADROOM: the headroom value is controlled by an external
  *	entity (i.e. the master device for bridged veth)
  * @IFF_MACSEC: device is a MACsec device
+ * @IFF_VRF_MASTER: device is a VRF master device
  */
 enum netdev_priv_flags {
 	IFF_802_1Q_VLAN			= 1<<0,
@@ -1386,6 +1387,7 @@ enum netdev_priv_flags {
 	IFF_RXFH_CONFIGURED		= 1<<25,
 	IFF_PHONY_HEADROOM		= 1<<26,
 	IFF_MACSEC			= 1<<27,
+	IFF_VRF_MASTER			= 1<<28,
 };
 
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1415,6 +1417,7 @@ enum netdev_priv_flags {
 #define IFF_TEAM			IFF_TEAM
 #define IFF_RXFH_CONFIGURED		IFF_RXFH_CONFIGURED
 #define IFF_MACSEC			IFF_MACSEC
+#define IFF_VRF_MASTER			IFF_VRF_MASTER
 
 /**
  *	struct net_device - The DEVICE structure.
@@ -4155,6 +4158,11 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+static inline bool netif_is_vrf_master(const struct net_device *dev)
+{
+	return dev->priv_flags & IFF_VRF_MASTER;
+}
+
 static inline bool netif_is_l3_master(const struct net_device *dev)
 {
 	return dev->priv_flags & IFF_L3MDEV_MASTER;
-- 
2.7.4
