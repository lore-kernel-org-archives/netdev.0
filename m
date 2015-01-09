From: Ethan Zhao <ethan.zhao@oracle.com>
Subject: [PATCH] i40e: don't enable and init FCOE by default
	when do PF reset
Date: Sat, 10 Jan 2015 01:37:46 +0900
Message-ID: <1420821466-5747-1-git-send-email-ethan.zhao@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ethan Zhao <ethan.zhao@oracle.com>, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	brian.maly@oracle.com, linux-kernel@vger.kernel.org, ethan.kernel@gmail.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com, mitch.a.williams@intel.com
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

While do PF reset with function i40e_reset_and_rebuild(), it will
call i40e_init_pf_fcoe() by default if FCOE is defined, thus if the
PF is resetted, FCOE will be enabled whatever it was - enabled or
not.

Such bug might be hit when PF resumes from suspend, run diagnostic
test with ethtool, setup VLAN etc.

Passed building with v3.19-rc3.

Signed-off-by: Ethan Zhao <ethan.zhao@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a5f2660..a2572cc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6180,9 +6180,12 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	}
 #endif /* CONFIG_I40E_DCB */
 #ifdef I40E_FCOE
-	ret = i40e_init_pf_fcoe(pf);
-	if (ret)
-		dev_info(&pf->pdev->dev, "init_pf_fcoe failed: %d\n", ret);
+	if (pf->flags & I40E_FLAG_FCOE_ENABLED) {
+		ret = i40e_init_pf_fcoe(pf);
+		if (ret)
+			dev_info(&pf->pdev->dev,
+				 "init_pf_fcoe failed: %d\n", ret);
+	}
 
 #endif
 	/* do basic switch setup */
-- 
1.8.3.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
