From: Kardonik Michael <Michael.Kardonik@nxp.com>
Subject: [PATCH] e1000e: changed some expensive calls of udelay to usleep_range
Date: Tue, 5 Sep 2017 15:27:24 -0500
Message-ID: <1504643244-9233-1-git-send-email-Michael.Kardonik@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Matthew Tan <matthew.tan_1@nxp.com>
To: <leoyang.li@nxp.com>, <michael.kardonik@nxp.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        Shannon Nelson <shannon.nelson@intel.com>,
        Carolyn Wyborny <carolyn.wyborny@intel.com>,
        Don Skidmore <donald.c.skidmore@intel.com>,
        Matthew Vick <matthew.vick@intel.com>,
        John Ronciak <john.ronciak@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        <intel-wired-lan@lists.osuosl.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calls to udelay are not preemtable by userspace so userspace
applications experience a large (~200us) latency when running on core0. 
Instead usleep_range can be used to be more friendly to userspace
since it is preemtable. This is due to udelay using busy-wait loops
while usleep_rang uses hrtimers instead. It is recommended to use
udelay when the delay is <10us since at that precision overhead of
usleep_range hrtimer setup causes issues. However, the replaced calls
are for 50us and 100us so this should not be not an issue.
There is no open bug that this patch is fixing, but we see a good
boost in zero loss performance of specific user space application 
(dpdk l3fwd) when this patch is applied: we get from 32% of 10Gb line 
to 49%.

Signed-off-by: Matthew Tan <matthew.tan_1@nxp.com>
Signed-off-by: Michael Kardonik <michael.kardonik@nxp.com>

---
 drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index de13aea..e318fdc 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -158,7 +158,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		udelay(50);
+		usleep_range(50, 60);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -183,7 +183,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		udelay(100);
+		usleep_range(100, 110);
 
 	return 0;
 }
@@ -222,7 +222,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * the lower time out
 	 */
 	for (i = 0; i < (E1000_GEN_POLL_TIMEOUT * 3); i++) {
-		udelay(50);
+		usleep_range(50, 60);
 		mdic = er32(MDIC);
 		if (mdic & E1000_MDIC_READY)
 			break;
@@ -246,7 +246,7 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 	 * reading duplicate data in the next MDIC transaction.
 	 */
 	if (hw->mac.type == e1000_pch2lan)
-		udelay(100);
+		usleep_range(100, 110);
 
 	return 0;
 }
-- 
2.7.4
