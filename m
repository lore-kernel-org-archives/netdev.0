From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] e1000e: fix mismatch in mutex lock-unlock in
	e1000_reset_hw_82571()
Date: Thu, 18 Apr 2013 22:15:18 -0700
Message-ID: <1366348518-5594-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ldv-project@linuxtesting.org, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey Khoroshilov <khoroshilov@ispras.ru>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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

If e1000_get_hw_semaphore_82574() succeed, it acquires swflag_mutex,
otherwise it does not. But the returned value of
e1000_get_hw_semaphore_82574() is ignored, so unlocking of swflag_mutex
happens anyway.

The patch fixes the issue by breaking reset if MIC ownership is not acquired.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/intel/e1000e/82571.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 2faffbd..a6bd80e 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1003,8 +1003,10 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	default:
 		break;
 	}
-	if (ret_val)
+	if (ret_val) {
 		e_dbg("Cannot acquire MDIO ownership\n");
+		return ret_val;
+	}
 
 	ctrl = er32(CTRL);
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Precog is a next-generation analytics platform capable of advanced
analytics on semi-structured data. The platform includes APIs for building
apps and a phenomenal toolset for data science. Developers can use
our toolset for easy data analysis & visualization. Get a free account!
http://www2.precog.com/precogplatform/slashdotnewsletter
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
