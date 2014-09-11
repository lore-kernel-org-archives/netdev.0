From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 1/7] bonding: 3ad: clean up curr_slave_lock usage
Date: Thu, 11 Sep 2014 22:49:22 +0200
Message-ID: <1410468568-13781-2-git-send-email-nikolay@redhat.com>
References: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757364AbaIKUul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Sep 2014 16:50:41 -0400
In-Reply-To: <1410468568-13781-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the read_lock in bond_3ad_lacpdu_recv() since when the slave is
being released its rx_handler is removed before 3ad unbind, so even if
packets arrive, they won't see the slave in an inconsistent state.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: Only remove the curr_slave_lock from bond_3ad_lacpdu_recv, leave it in
    bond_3ad_state_machine_handler

 drivers/net/bonding/bond_3ad.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 5d27a6207384..dfd3a7835d17 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2476,20 +2476,16 @@ err_free:
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave)
 {
-	int ret = RX_HANDLER_ANOTHER;
 	struct lacpdu *lacpdu, _lacpdu;
 
 	if (skb->protocol != PKT_TYPE_LACPDU)
-		return ret;
+		return RX_HANDLER_ANOTHER;
 
 	lacpdu = skb_header_pointer(skb, 0, sizeof(_lacpdu), &_lacpdu);
 	if (!lacpdu)
-		return ret;
+		return RX_HANDLER_ANOTHER;
 
-	read_lock(&bond->curr_slave_lock);
-	ret = bond_3ad_rx_indication(lacpdu, slave, skb->len);
-	read_unlock(&bond->curr_slave_lock);
-	return ret;
+	return bond_3ad_rx_indication(lacpdu, slave, skb->len);
 }
 
 /**
-- 
1.9.3
