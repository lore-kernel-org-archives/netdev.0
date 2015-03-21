From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2 1/4] bonding: Handle notifications during work-queue processing gracefully
Date: Fri, 20 Mar 2015 22:39:21 -0700
Message-ID: <1426916361-18328-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:34549 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbbCUFjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:39:24 -0400
Received: by padet14 with SMTP id et14so8061383pad.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:39:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RTNL is required for sending notifications and if rtnl can not be
acquired, current code skips sending notification. This is especially
bad if the monitoring values selected are large.

This patch adds a bitmask and uses a bit per such work-queue and attempts
to reschedule the work (aggressively) until notifications are sent out and
then resumes the regular cycle.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/net/bonding.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/net/bonding.h b/include/net/bonding.h
index 0ac45b4f7f2a..fede3ab4bbcf 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -239,6 +239,7 @@ struct bonding {
 	struct   delayed_work ad_work;
 	struct   delayed_work mcast_work;
 	struct   delayed_work slave_arr_work;
+	unsigned long notif_work_mask;
 #ifdef CONFIG_DEBUG_FS
 	/* debugging support via debugfs */
 	struct	 dentry *debug_dir;
@@ -259,6 +260,24 @@ struct bond_vlan_tag {
 	unsigned short	vlan_id;
 };
 
+typedef enum {
+	BOND_MII_NOTIF = 0,
+	BOND_ARP_NOTIF,
+	BOND_AD_NOTIF,
+} bond_notif_pending_t;
+
+static inline bool bond_get_notif_pending(struct bonding *bond,
+					  bond_notif_pending_t bit)
+{
+	return !!test_and_clear_bit(bit, &bond->notif_work_mask);
+}
+
+static inline void bond_set_notif_pending(struct bonding *bond,
+					  bond_notif_pending_t bit)
+{
+		set_bit(bit, &bond->notif_work_mask);
+}
+
 /**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
-- 
2.2.0.rc0.207.ga3a616c
