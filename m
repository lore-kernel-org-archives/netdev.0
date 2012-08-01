From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [PATCH net-next] igb: add delay to allow igb loopback test to
 succeed on 8086:10c9
Date: Wed, 1 Aug 2012 14:56:38 +0000
Message-ID: <9BBC4E0CF881AA4299206E2E1412B62630D880DC@ORSMSX102.amr.corp.intel.com>
References: <1343821463-18052-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stefan Assmann <sassmann@kpanic.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14909 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755230Ab2HAO4l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2012 10:56:41 -0400
In-Reply-To: <1343821463-18052-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Stefan Assmann [mailto:sassmann@kpanic.de] 
Sent: Wednesday, August 01, 2012 4:44 AM
To: netdev@vger.kernel.org
Cc: e1000-devel@lists.sourceforge.net; Wyborny, Carolyn; sassmann@kpanic.de
Subject: [PATCH net-next] igb: add delay to allow igb loopback test to succeed on 8086:10c9

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
However that seems to only trigger the bug. While adding some printk the problem disappeared, so this might be a timing issue. After some trial and error I discovered that adding a small delay just before igb_write_phy_reg() in igb_integrated_phy_loopback() allows the loopback test to succeed.
I was unable to figure out the root cause so far but I expect it to be somewhere in the following executing path igb_integrated_phy_loopback
->igb_write_phy_reg_igp
  ->igb_write_phy_reg_mdic
    ->igb_acquire_phy_82575
      ->igb_acquire_swfw_sync_82575

As this workaround only introduces a minor delay, which is not in the hot path I hope this is acceptable. The problem could only be oberved on
8086:10c9 NICs so far and not all of them show the behaviour. I did not restrict the workaround to this type of NIC as it should do no harm to other igb NICs.

With the patch below the loopback test succeeded 500 times in a row using a NIC that would otherwise fail.

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

ACK.  Jeff will be pulling this into his tree.  

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation
