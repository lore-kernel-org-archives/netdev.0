From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/6] bonding: verify if bond has ip only once on arp validate
Date: Wed, 19 Jun 2013 19:34:41 +0200
Message-ID: <1371663286-12518-2-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5502 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757152Ab3FSRen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 13:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's extra work to verify bond's ip presence for every slave, so take it
out of the loop.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bc1246f..3d8b5ba 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2602,13 +2602,16 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 	int i;
 	__be32 *targets = bond->params.arp_targets;
 
+	if (!bond_has_this_ip(bond, tip)) {
+		pr_debug("bva: tip %pI4 not found\n", &tip);
+		return;
+	}
+
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
-		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
-			 &sip, &tip, i, &targets[i],
-			 bond_has_this_ip(bond, tip));
+		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip)\n",
+			 &sip, &tip, i, &targets[i]);
 		if (sip == targets[i]) {
-			if (bond_has_this_ip(bond, tip))
-				slave->last_arp_rx = jiffies;
+			slave->last_arp_rx = jiffies;
 			return;
 		}
 	}
-- 
1.7.1
