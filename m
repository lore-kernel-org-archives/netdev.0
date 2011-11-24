From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH net-next] igb: reset PHY after recovering from PHY power down
Date: Thu, 24 Nov 2011 12:18:07 +0900
Message-ID: <4ECDB76F.1090104@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:42556 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755564Ab1KXDSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 22:18:34 -0500
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 560D93EE0BD
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:18:32 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BD8345DF48
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:18:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 23B1845DE5A
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:18:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 16FB31DB8050
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:18:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0B7E1DB8040
	for <netdev@vger.kernel.org>; Thu, 24 Nov 2011 12:18:31 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to 82576_Datasheet.pdf, PHY setting is lost after PHY power down.
So resetting PHY is needed when recovering from PHY power down to set a default
setting to PHY register.

Owing to this lack, NIC doesn't link up in some rare situation.
The situation I encountered is following.


1.Both ports connect to switch.
+---------+           +--------+
|         |-----------|        |
| 82576NS |           | switch |
|         |-----------|        |
+---------+           +--------+

2.Detach both cables from switch.
+---------+           +--------+
|         |-------    |        |
| 82576NS |           | switch |
|         |-------    |        |
+---------+           +--------+

3.Detach one cable from one port.
+---------+           +--------+
|         |-------    |        |
| 82576NS |           | switch |
|         |           |        |
+---------+           +--------+

4.Attach that cable to the other port.(It means connecting directly each port)
+---------+           +--------+
|         |-------+   |        |
| 82576NS |       |   | switch |
|         |-------+   |        |
+---------+           +--------+

As a result, NIC doesn't link up sometimes.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bd9b30e..4d4f065 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2496,6 +2496,7 @@ static int igb_open(struct net_device *netdev)
 		goto err_setup_rx;
 
 	igb_power_up_link(adapter);
+	igb_reset_phy(hw);
 
 	/* before we allocate an interrupt, we must be ready to handle it.
 	 * Setting DEBUG_SHIRQ in the kernel makes it fire an interrupt
