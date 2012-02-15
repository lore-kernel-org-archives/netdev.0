From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH] igb: output register's information related to RX/TX queue[4-15]
Date: Wed, 15 Feb 2012 15:19:36 +0900
Message-ID: <4F3B4E78.3060804@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:34396 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751945Ab2BOGTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 01:19:48 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 683203EE0BD
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:19:46 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ED3945DE5B
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:19:46 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9907A45DE59
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:19:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B6E81DB804E
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:19:44 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F3961DB8047
	for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 15:19:44 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current igb outputs registers related to TX/RX queues(ex. RDT, RDH, TDT, TDH).
But it thinks the number of RX/TX queues is 4. But 82576 has 16 RX/TX queues.
This patch modifies igb to output the rest of the registers if the device is
82576.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |   38 +++++++++++++++++++++++++-
 1 files changed, 37 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index aa399a8..6d15e96 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -335,7 +335,7 @@ static void igb_set_msglevel(struct net_device *netdev, u32 data)
 
 static int igb_get_regs_len(struct net_device *netdev)
 {
-#define IGB_REGS_LEN 551
+#define IGB_REGS_LEN 739
 	return IGB_REGS_LEN * sizeof(u32);
 }
 
@@ -556,6 +556,42 @@ static void igb_get_regs(struct net_device *netdev,
 	regs_buff[552] = adapter->stats.b2ospc;
 	regs_buff[553] = adapter->stats.o2bspc;
 	regs_buff[554] = adapter->stats.b2ogprc;
+
+	if (hw->mac.type != e1000_82576)
+		return;
+	for (i = 0; i < 12; i++)
+		regs_buff[555 + i] = rd32(E1000_SRRCTL(i + 4));
+	for (i = 0; i < 4; i++)
+		regs_buff[567 + i] = rd32(E1000_PSRTYPE(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[571 + i] = rd32(E1000_RDBAL(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[583 + i] = rd32(E1000_RDBAH(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[595 + i] = rd32(E1000_RDLEN(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[607 + i] = rd32(E1000_RDH(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[619 + i] = rd32(E1000_RDT(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[631 + i] = rd32(E1000_RXDCTL(i + 4));
+
+	for (i = 0; i < 12; i++)
+		regs_buff[643 + i] = rd32(E1000_TDBAL(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[655 + i] = rd32(E1000_TDBAH(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[667 + i] = rd32(E1000_TDLEN(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[679 + i] = rd32(E1000_TDH(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[691 + i] = rd32(E1000_TDT(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[703 + i] = rd32(E1000_TXDCTL(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[715 + i] = rd32(E1000_TDWBAL(i + 4));
+	for (i = 0; i < 12; i++)
+		regs_buff[727 + i] = rd32(E1000_TDWBAH(i + 4));
 }
 
 static int igb_get_eeprom_len(struct net_device *netdev)
