From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 1/5] bonding: split bond_set_slave_link_state into two parts
Date: Mon, 27 Mar 2017 11:37:30 -0700
Message-ID: <20170327183730.30787-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36067 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdC0Sh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:37:58 -0400
Received: by mail-pg0-f67.google.com with SMTP id 81so14990135pgh.3
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:37:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Split the function into two (a) propose (b) commit phase without
changing the semantics for the original API.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/net/bonding.h | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/net/bonding.h b/include/net/bonding.h
index 3c857778a6ca..fb2dd97857c4 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -153,7 +153,8 @@ struct slave {
 	unsigned long last_link_up;
 	unsigned long last_rx;
 	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
-	s8     link;    /* one of BOND_LINK_XXXX */
+	s8     link;		/* one of BOND_LINK_XXXX */
+	s8     link_new_state;	/* one of BOND_LINK_XXXX */
 	s8     new_link;
 	u8     backup:1,   /* indicates backup slave. Value corresponds with
 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
@@ -504,13 +505,17 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
 	return slave->inactive;
 }
 
-static inline void bond_set_slave_link_state(struct slave *slave, int state,
-					     bool notify)
+static inline void bond_propose_link_state(struct slave *slave, int state)
+{
+	slave->link_new_state = state;
+}
+
+static inline void bond_commit_link_state(struct slave *slave, bool notify)
 {
-	if (slave->link == state)
+	if (slave->link == slave->link_new_state)
 		return;
 
-	slave->link = state;
+	slave->link = slave->link_new_state;
 	if (notify) {
 		bond_queue_slave_event(slave);
 		bond_lower_state_changed(slave);
@@ -523,6 +528,13 @@ static inline void bond_set_slave_link_state(struct slave *slave, int state,
 	}
 }
 
+static inline void bond_set_slave_link_state(struct slave *slave, int state,
+					     bool notify)
+{
+	bond_propose_link_state(slave, state);
+	bond_commit_link_state(slave, notify);
+}
+
 static inline void bond_slave_link_notify(struct bonding *bond)
 {
 	struct list_head *iter;
-- 
2.12.1.578.ge9c3154ca4-goog
