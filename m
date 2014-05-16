From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 2/2] bonding: Fix alb mode to only use first level vlans.
Date: Fri, 16 May 2014 17:20:39 -0400
Message-ID: <1400275239-15419-3-git-send-email-vyasevic@redhat.com>
References: <1400275239-15419-1-git-send-email-vyasevic@redhat.com>
Cc: vfalico@gmail.com, kaber@trash.net, j.vosburgh@gmail.com,
	andy@greyhouse.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884AbaEPVUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 17:20:53 -0400
In-Reply-To: <1400275239-15419-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ALB/TLB learning packets use all vlans configured on top
of the bond.  This ends up being incorrect if we have a stack
of vlans on top of the bond.  ALB/TLB should only use
first level/outer most vlans in its announcements.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9f69e81..e538478 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1045,7 +1045,7 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 	/* loop through vlans and send one packet for each */
 	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
-		if (upper->priv_flags & IFF_802_1Q_VLAN)
+		if (is_vlan_dev(upper) && vlan_get_encap_level(upper) == 0)
 			alb_send_lp_vid(slave, mac_addr,
 					vlan_dev_vlan_id(upper));
 	}
-- 
1.9.0
