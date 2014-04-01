From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH] vlan: Try to adjust lower device mtu when configuring 802.1AD vlans
Date: Tue,  1 Apr 2014 17:17:34 -0400
Message-ID: <1396387054-4510-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Patrik McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751366AbaDAVRn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 17:17:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

802.1AD vlans supposed to encapsulate 802.1Q vlans.  To
do this, we need an extra 4 bytes of header which are typically
not accounted for by lower devices.  Some devices can not
support frames longer then 1522 bytes at all.  Such devices
can not really support 802.1AD, even in software, without
the vlan reducing its mtu value.

This patch propses to increate the lower devices MTU to 1504
in case of 802.1AD configuration, and if device doesn't
support it, fail the creation of the vlan.  The user has an
option to configure older-style Q-in-Q vlans and manually
lower the mtu to support such encapsulation.

CC: Patrik McHardy <kaber@trash.net>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan.c         | 17 +++++++++++++++++
 net/8021q/vlan_netlink.c | 11 ++++++++---
 2 files changed, 25 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 175273f..0328d73 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -126,6 +126,7 @@ int vlan_check_real_dev(struct net_device *real_dev,
 			__be16 protocol, u16 vlan_id)
 {
 	const char *name = real_dev->name;
+	int err;
 
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_info("VLANs not supported on %s\n", name);
@@ -135,6 +136,21 @@ int vlan_check_real_dev(struct net_device *real_dev,
 	if (vlan_find_dev(real_dev, protocol, vlan_id) != NULL)
 		return -EEXIST;
 
+	if (protocol == htons(ETH_P_8021AD)) {
+		/* 8021AD vlan is meant to encapsulate 8021Q and thus we
+		 * need to make sure that lower device can handle a
+		 * larger mtu.
+		 * If the lower device still has a default ethernet mtu,
+		 * bump it up 4 bytes.  If not, it was set by user and
+		 * we'll trust the user knows what he is doing.
+		 */
+		if (real_dev->mtu == VLAN_ETH_DATA_LEN &&
+		    dev_set_mtu(real_dev, real_dev->mtu + VLAN_HLEN))
+			pr_warn("802.1AD mode is not supported on %s due to mtu limitations.\n", name);
+			return -EOPNOTSUPP
+		} 
+	}
+
 	return 0;
 }
 
@@ -259,6 +275,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 * hope the underlying device can handle it.
 	 */
 	new_dev->mtu = real_dev->mtu;
+
 	new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
 
 	vlan = vlan_dev_priv(new_dev);
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c7e634a..a925a8d 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -144,10 +144,15 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
-	if (!tb[IFLA_MTU])
-		dev->mtu = real_dev->mtu;
-	else if (dev->mtu > real_dev->mtu)
+	if (!tb[IFLA_MTU]) {
+		if (vlan->vlan_proto == htons(ETH_P_8021AD) &&
+	    	    real_dev->mtu == VLAN_ETH_DATA_LEN + VLAN_HLEN)
+			dev->mtu = VLAN_ETH_DATA_LEN;
+		else
+			dev->mtu = real_dev->mtu;
+	} else if (dev->mtu > real_dev->mtu) {
 		return -EINVAL;
+	}
 
 	err = vlan_changelink(dev, tb, data);
 	if (err < 0)
-- 
1.8.5.3
