From: David Lamparter <equinox@diac24.net>
Subject: [PATCH] net: vlan: fix compile breakage from 69ecca8
Date: Wed, 20 Jul 2011 21:43:53 +0200
Message-ID: <1311191033-714631-1-git-send-email-equinox@diac24.net>
References: <0E5EAE44-204C-4F4D-926C-F4D973B0CDB1@qlogic.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Lamparter <equinox@diac24.net>, linux-driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <rdunlap@xenotime.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:60523 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751695Ab1GTToi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 15:44:38 -0400
In-Reply-To: <0E5EAE44-204C-4F4D-926C-F4D973B0CDB1@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

well, there was too much wood to see the tree and I messed up the
configuration dependencies. let's make it work with unset
CONFIG_VLAN_8021Q and remove the second definition of vlan_find_dev.

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: linux-driver@qlogic.com
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Randy Dunlap <rdunlap@xenotime.net>
---
sorry for the mess-up... compiled with CONFIG_VLAN_8021Q=n,m and y
this time; don't have qlcnic hw to test.

 drivers/net/qlcnic/qlcnic_main.c |    4 +++-
 include/linux/if_vlan.h          |    5 -----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 3579229..a2c39e9 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -4198,13 +4198,15 @@ static void
 qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct vlan_group *grp;
+	struct vlan_group *grp = NULL;
 	struct net_device *dev;
 	u16 vid;
 
 	qlcnic_config_indev_addr(adapter, netdev, event);
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	grp = rcu_dereference_rtnl(netdev->vlgrp);
+#endif
 	if (!grp)
 		return;
 
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bc03e40..dbe41dc 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -135,11 +135,6 @@ vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	       unsigned int vlan_tci);
 
 #else
-static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
-					       u16 vlan_id)
-{
-	return NULL;
-}
 
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
-- 
1.7.5.3

