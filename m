From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] nes: fix reversed IP address
Date: Fri, 09 Jan 2009 22:24:35 -0800
Message-ID: <1231568675.5714.25.camel@brick>
References: <adaprivom8o.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:40249 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770AbZAJGYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 01:24:38 -0500
Received: by wf-out-1314.google.com with SMTP id 27so10235504wfd.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 22:24:38 -0800 (PST)
In-Reply-To: <adaprivom8o.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 63779436ab4ad0867bcea53bf853b0004d7b895di (drivers: replace NIPQUAD())
accidentally replaced two HIPQUAD()s causing IP addresses to be
printed in reverse order, add two temporary local vars.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
I'll start working on a patch working directly with _be32s, but this
is the safest for now.

 drivers/infiniband/hw/nes/nes_cm.c    |    3 ++-
 drivers/infiniband/hw/nes/nes_utils.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 6ba57e9..2395b20 100644
--- a/drivers/infiniband/hw/nes/nes_cm.c
+++ b/drivers/infiniband/hw/nes/nes_cm.c
@@ -778,12 +778,13 @@ static struct nes_cm_node *find_node(struct nes_cm_core *cm_core,
 	unsigned long flags;
 	struct list_head *hte;
 	struct nes_cm_node *cm_node;
+	__be32 tmp_addr = cpu_to_be32(loc_addr);
 
 	/* get a handle on the hte */
 	hte = &cm_core->connected_nodes;
 
 	nes_debug(NES_DBG_CM, "Searching for an owner node: %pI4:%x from core %p->%p\n",
-		  &loc_addr, loc_port, cm_core, hte);
+		  &tmp_addr, loc_port, cm_core, hte);
 
 	/* walk list and find cm_node associated with this session ID */
 	spin_lock_irqsave(&cm_core->ht_lock, flags);
diff --git a/drivers/infiniband/hw/nes/nes_utils.c b/drivers/infiniband/hw/nes/nes_utils.c
index aa9b734..feb7401 100644
--- a/drivers/infiniband/hw/nes/nes_utils.c
+++ b/drivers/infiniband/hw/nes/nes_utils.c
@@ -655,6 +655,7 @@ int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr, u32 acti
 	struct nes_adapter *nesadapter = nesdev->nesadapter;
 	int arp_index;
 	int err = 0;
+	__be32 tmp_addr = cpu_to_be32(ip_addr);
 
 	for (arp_index = 0; (u32) arp_index < nesadapter->arp_table_size; arp_index++) {
 		if (nesadapter->arp_table[arp_index].ip_addr == ip_addr)
@@ -683,7 +684,7 @@ int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr, u32 acti
 	/* DELETE or RESOLVE */
 	if (arp_index == nesadapter->arp_table_size) {
 		nes_debug(NES_DBG_NETDEV, "MAC for %pI4 not in ARP table - cannot %s\n",
-			  &ip_addr, action == NES_ARP_RESOLVE ? "resolve" : "delete");
+			  &tmp_addr, action == NES_ARP_RESOLVE ? "resolve" : "delete");
 		return -1;
 	}
 
-- 
1.6.1.94.g9388



