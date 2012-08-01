From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next] igb: add delay to allow igb loopback test to succeed on 8086:10c9
Date: Wed,  1 Aug 2012 13:44:23 +0200
Message-ID: <1343821463-18052-1-git-send-email-sassmann@kpanic.de>
Cc: e1000-devel@lists.sourceforge.net, carolyn.wyborny@intel.com,
	sassmann@kpanic.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab2HALqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 07:46:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some 8086:10c9 NICs have a problem completing the ethtool loopback test.
The result looks like this:

ethtool -t eth1
The test result is FAIL
The test extra info:
Register test  (offline)         0
Eeprom test    (offline)         0
Interrupt test (offline)         0
Loopback test  (offline)         13
Link test   (on/offline)         0

A bisect clearly points to commit a95a07445ee97a2fef65befafbadcc30ca1bd145.
However that seems to only trigger the bug. While adding some printk the
problem disappeared, so this might be a timing issue. After some trial and
error I discovered that adding a small delay just before igb_write_phy_reg()
in igb_integrated_phy_loopback() allows the loopback test to succeed.
I was unable to figure out the root cause so far but I expect it to be
somewhere in the following executing path
igb_integrated_phy_loopback
->igb_write_phy_reg_igp
  ->igb_write_phy_reg_mdic
    ->igb_acquire_phy_82575
      ->igb_acquire_swfw_sync_82575

As this workaround only introduces a minor delay, which is not in the hot
path I hope this is acceptable. The problem could only be oberved on
8086:10c9 NICs so far and not all of them show the behaviour. I did not
restrict the workaround to this type of NIC as it should do no harm to
other igb NICs.

With the patch below the loopback test succeeded 500 times in a row
using a NIC that would otherwise fail.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index a19c84c..f62fa25 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1497,6 +1497,9 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 		break;
 	}
 
+	/* add small delay to avoid loopback test failure */
+	msleep(50);
+
 	/* force 1000, set loopback */
 	igb_write_phy_reg(hw, PHY_CONTROL, 0x4140);
 
-- 
1.7.4.4
