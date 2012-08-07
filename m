From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 3/3] igb: add delay to allow igb loopback test to succeed on 8086:10c9
Date: Tue,  7 Aug 2012 01:04:17 -0700
Message-ID: <1344326657-9376-4-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49719 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab2HGIFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2012 04:05:47 -0400
In-Reply-To: <1344326657-9376-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

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

The problem could only be observed on 8086:10c9 NICs so far and not all
of them show the behaviour. I did not restrict the workaround to this
type of NIC as it should do no harm to other igb NICs.

With the patch below the loopback test succeeded 500 times in a row
using a NIC that would otherwise fail.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 90550f5..7059111 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1498,6 +1498,9 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 		break;
 	}
 
+	/* add small delay to avoid loopback test failure */
+	msleep(50);
+
 	/* force 1000, set loopback */
 	igb_write_phy_reg(hw, PHY_CONTROL, 0x4140);
 
-- 
1.7.11.2
