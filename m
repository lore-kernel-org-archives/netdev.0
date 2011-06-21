From: Guenter Roeck <guenter.roeck@ericsson.com>
Subject: [PATCH RFC] igb: Fix false positive return of
	igb_get_auto_rd_done for 82580
Date: Tue, 21 Jun 2011 12:02:49 -0700
Message-ID: <1308682969-20690-1-git-send-email-guenter.roeck@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Tong Ho <tong.ho@ericsson.com>, Guenter Roeck <guenter.roeck@ericsson.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Jesse Brandeburg
	<jesse.brandeburg@intel.com>, Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>, Don Skidm
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Tong Ho <tong.ho@ericsson.com>

82580 re-reads the port specific portion of eeprom after port reset.
If called immediately after a reset, igb_get_auto_rd_done() returns
false positive because the done bit has yet to transition from 1 to 0.

Add wrfl() immediately after resetting 82580 port or device,
plus a 1ms delay, to avoid the problem.

Signed-off-by: Tong Ho <tong.ho@ericsson.com>
Signed-off-by: Guenter Roeck <guenter.roeck@ericsson.com>
---
Sent as RFC since I am not entirely sure if the solution is the correct one
to address the problem we are seeing. If there is a better solution, please
let me know.

 drivers/net/igb/e1000_82575.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 0f563c8..28dae48 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1735,10 +1735,10 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 		ctrl |= E1000_CTRL_RST;
 
 	wr32(E1000_CTRL, ctrl);
+	wrfl();
 
 	/* Add delay to insure DEV_RST has time to complete */
-	if (global_device_reset)
-		msleep(5);
+	msleep(global_device_reset ? 5 : 1);
 
 	ret_val = igb_get_auto_rd_done(hw);
 	if (ret_val) {
-- 
1.7.3.1


------------------------------------------------------------------------------
EditLive Enterprise is the world's most technically advanced content
authoring tool. Experience the power of Track Changes, Inline Image
Editing and ensure content is compliant with Accessibility Checking.
http://p.sf.net/sfu/ephox-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
