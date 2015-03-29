From: Anton Nayshtut <anton@swortex.com>
Subject: [PATCH] Bonding Overriding Configuration logic restored.
Date: Sun, 29 Mar 2015 14:20:25 +0300
Message-ID: <1427628025-9752-1-git-send-email-anton@swortex.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Anton Nayshtut <anton@swortex.com>,
	Alexey Bogoslavsky <alexey@swortex.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33458 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbC2LUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 07:20:36 -0400
Received: by wgbgs4 with SMTP id gs4so51105827wgb.0
        for <netdev@vger.kernel.org>; Sun, 29 Mar 2015 04:20:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit 3900f29021f0bc7fe9815aa32f1a993b7dfdd402 ("bonding: slight
optimizztion for bond_slave_override()") the override logic was to send packets
with non-zero queue_id through the slave with corresponding queue_id, under two
conditions only - if the slave can transmit and it's up.

The above mentioned commit changed this logic by introducing an additional
condition - whether the bond is active (indirectly, using the slave_can_tx and
later - bond_is_active_slave), that prevents the user from implementing more
complex policies according to the Documentation/networking/bonding.txt.

Signed-off-by: Anton Nayshtut <anton@swortex.com>
Signed-off-by: Alexey Bogoslavsky <alexey@swortex.com>
---
 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0dceba1..68ad39a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3797,7 +3797,8 @@ static inline int bond_slave_override(struct bonding *bond,
 	/* Find out if any slaves have the same mapping as this skb. */
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		if (slave->queue_id == skb->queue_mapping) {
-			if (bond_slave_can_tx(slave)) {
+			if (bond_slave_is_up(slave) &&
+			    slave->link == BOND_LINK_UP) {
 				bond_dev_queue_xmit(bond, skb, slave->dev);
 				return 0;
 			}
-- 
1.9.1
