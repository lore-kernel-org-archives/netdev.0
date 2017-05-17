From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] bonding: fix accounting of active ports in 3ad
Date: Wed, 17 May 2017 11:11:44 -0400
Message-ID: <20170517151144.57865-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37788 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751637AbdEQPMC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 11:12:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As of 7bb11dc9f59d and 0622cab0341c, bond slaves in a 3ad bond are not
removed from the aggregator when they are down, and the active slave count
is NOT equal to number of ports in the aggregator, but rather the number
of ports in the aggregator that are still enabled. The sysfs spew for
bonding_show_ad_num_ports() has a comment that says "Show number of active
802.3ad ports.", but it's currently showing total number of ports, both
active and inactive. Remedy it by using the same logic introduced in
7bb11dc9f59d in __bond_3ad_get_active_agg_info(), so sysfs, procfs and
netlink all report the number of active ports. Note that this means that
IFLA_BOND_AD_INFO_NUM_PORTS really means NUM_ACTIVE_PORTS instead of
NUM_PORTS, and thus perhaps should be renamed for clarity.

Lightly tested on a dual i40e lacp bond, simulating link downs with an ip
link set dev <slave2> down, was able to produce the state where I could
see both in the same aggregator, but a number of ports count of 1.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c5fd4259da33..b44a6aeb346d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2577,7 +2577,7 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 		return -1;
 
 	ad_info->aggregator_id = aggregator->aggregator_identifier;
-	ad_info->ports = aggregator->num_of_ports;
+	ad_info->ports = __agg_active_ports(aggregator);
 	ad_info->actor_key = aggregator->actor_oper_aggregator_key;
 	ad_info->partner_key = aggregator->partner_oper_aggregator_key;
 	ether_addr_copy(ad_info->partner_system,
-- 
2.12.1
