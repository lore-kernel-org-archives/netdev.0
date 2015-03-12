From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 1/4] bonding: Handle notifications during work-queue processing gracefully
Date: Wed, 11 Mar 2015 22:54:36 -0700
Message-ID: <1426139676-27124-1-git-send-email-maheshb@google.com>
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
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33173 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbbCLGBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 02:01:05 -0400
Received: by ykp131 with SMTP id 131so2274301ykp.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 23:01:04 -0700 (PDT)
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
 include/net/bonding.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/net/bonding.h b/include/net/bonding.h
index 0ac45b4f7f2a..3be7e0004121 100644
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
@@ -259,6 +260,27 @@ struct bond_vlan_tag {
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
+	return !!test_bit(bit, &bond->notif_work_mask);
+}
+
+static inline void bond_set_notif_pending(struct bonding *bond,
+					  bond_notif_pending_t bit, bool set)
+{
+	if (set)
+		test_and_set_bit(bit, &bond->notif_work_mask);
+	else
+		test_and_clear_bit(bit, &bond->notif_work_mask);
+}
+
 /**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
-- 
2.2.0.rc0.207.ga3a616c
