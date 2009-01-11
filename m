From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] infiniband: fix for NIPQUAD removal
Date: Sat, 10 Jan 2009 21:26:34 -0800
Message-ID: <1231651594.5714.65.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:59087 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbZAKF0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 00:26:38 -0500
Received: by wf-out-1314.google.com with SMTP id 27so10773311wfd.4
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2009 21:26:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 63779436ab4ad0867bcea53bf853b0004d7b895di (drivers: replace NIPQUAD())
accidentally replaced some HIPQUAD()s causing IP addresses to be
printed in reverse order, add temporary local vars until the byteswapping
can be pushed further up the stack.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/infiniband/hw/nes/nes_cm.c    |   12 +++++++++---
 drivers/infiniband/hw/nes/nes_utils.c |    4 +++-
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_cm.c b/drivers/infiniband/hw/nes/nes_cm.c
index 6ba57e9..a01b448 100644
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
@@ -816,6 +817,7 @@ static struct nes_cm_listener *find_listener(struct nes_cm_core *cm_core,
 {
 	unsigned long flags;
 	struct nes_cm_listener *listen_node;
+	__be32 tmp_addr = cpu_to_be32(dst_addr);
 
 	/* walk list and find cm_node associated with this session ID */
 	spin_lock_irqsave(&cm_core->listen_list_lock, flags);
@@ -833,7 +835,7 @@ static struct nes_cm_listener *find_listener(struct nes_cm_core *cm_core,
 	spin_unlock_irqrestore(&cm_core->listen_list_lock, flags);
 
 	nes_debug(NES_DBG_CM, "Unable to find listener for %pI4:%x\n",
-		  &dst_addr, dst_port);
+		  &tmp_addr, dst_port);
 
 	/* no listener */
 	return NULL;
@@ -2059,6 +2061,7 @@ static int mini_cm_recv_pkt(struct nes_cm_core *cm_core,
 	struct tcphdr *tcph;
 	struct nes_cm_info nfo;
 	int skb_handled = 1;
+	__be32 tmp_daddr, tmp_saddr;
 
 	if (!skb)
 		return 0;
@@ -2074,8 +2077,11 @@ static int mini_cm_recv_pkt(struct nes_cm_core *cm_core,
 	nfo.rem_addr = ntohl(iph->saddr);
 	nfo.rem_port = ntohs(tcph->source);
 
+	tmp_daddr = cpu_to_be32(iph->daddr);
+	tmp_saddr = cpu_to_be32(iph->saddr);
+
 	nes_debug(NES_DBG_CM, "Received packet: dest=%pI4:0x%04X src=%pI4:0x%04X\n",
-		  &iph->daddr, tcph->dest, &iph->saddr, tcph->source);
+		  &tmp_daddr, tcph->dest, &tmp_saddr, tcph->source);
 
 	do {
 		cm_node = find_node(cm_core,
diff --git a/drivers/infiniband/hw/nes/nes_utils.c b/drivers/infiniband/hw/nes/nes_utils.c
index aa9b734..6f3bc1b 100644
--- a/drivers/infiniband/hw/nes/nes_utils.c
+++ b/drivers/infiniband/hw/nes/nes_utils.c
@@ -655,6 +655,7 @@ int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr, u32 acti
 	struct nes_adapter *nesadapter = nesdev->nesadapter;
 	int arp_index;
 	int err = 0;
+	__be32 tmp_addr;
 
 	for (arp_index = 0; (u32) arp_index < nesadapter->arp_table_size; arp_index++) {
 		if (nesadapter->arp_table[arp_index].ip_addr == ip_addr)
@@ -682,8 +683,9 @@ int nes_arp_table(struct nes_device *nesdev, u32 ip_addr, u8 *mac_addr, u32 acti
 
 	/* DELETE or RESOLVE */
 	if (arp_index == nesadapter->arp_table_size) {
+		tmp_addr = cpu_to_be32(ip_addr);
 		nes_debug(NES_DBG_NETDEV, "MAC for %pI4 not in ARP table - cannot %s\n",
-			  &ip_addr, action == NES_ARP_RESOLVE ? "resolve" : "delete");
+			  &tmp_addr, action == NES_ARP_RESOLVE ? "resolve" : "delete");
 		return -1;
 	}
 
-- 
1.6.1.94.g9388



