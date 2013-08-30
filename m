From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] i40e: Convert pf_<level> macros to
	functions
Date: Fri, 30 Aug 2013 16:06:10 -0700
Message-ID: <daa992875a6f542adc41069daeb81246e46b7f80.1377903831.git.joe@perches.com>
References: <cover.1377903831.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1377903831.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Reduces object size ~10KB by removing "%s: ", __func__
and using the %pf extension and __builtin_return_address(0)
to emit the function name.

$ size drivers/net/ethernet/intel/i40e/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 166271	  36043	  50032	 252346	  3d9ba	drivers/net/ethernet/intel/i40e/built-in.o.new
 177030	  35867	  49936	 262833	  402b1	drivers/net/ethernet/intel/i40e/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 12 ++++----
 drivers/net/ethernet/intel/i40e/i40e_main.c | 45 +++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index a39d1c6..9e61ce90 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -565,11 +565,11 @@ void i40e_vlan_stripping_enable(struct i40e_vsi *vsi);
 
 /* i40e_pf message logging */
 
-#define pf_err(pf, fmt, ...)						\
-	dev_err(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
-#define pf_warn(pf, fmt, ...)						\
-	dev_warn(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
-#define pf_info(pf, fmt, ...)						\
-	dev_info(&(pf)->pdev->dev, "%s: " fmt, __func__, ##__VA_ARGS__)
+__printf(2, 3)
+void pf_err(const struct i40e_pf *pf, const char *fmt, ...);
+__printf(2, 3)
+void pf_warn(const struct i40e_pf *pf, const char *fmt, ...);
+__printf(2, 3)
+void pf_info(const struct i40e_pf *pf, const char *fmt, ...);
 
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d1f6744..4366de3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7340,3 +7340,48 @@ static void __exit i40e_exit_module(void)
 	i40e_dbg_exit();
 }
 module_exit(i40e_exit_module);
+
+__printf(2, 3)
+void pf_err(const struct i40e_pf *pf, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	dev_err(&pf->pdev->dev, "%pf: %pV",
+		__builtin_return_address(0), &vaf);
+
+	va_end(args);
+}
+
+__printf(2, 3)
+void pf_warn(const struct i40e_pf *pf, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	dev_warn(&pf->pdev->dev, "%pf: %pV",
+		 __builtin_return_address(0), &vaf);
+
+	va_end(args);
+}
+
+__printf(2, 3)
+void pf_info(const struct i40e_pf *pf, const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	dev_info(&pf->pdev->dev, "%pf: %pV",
+		 __builtin_return_address(0), &vaf);
+
+	va_end(args);
+}
-- 
1.8.1.2.459.gbcd45b4.dirty


------------------------------------------------------------------------------
Learn the latest--Visual Studio 2012, SharePoint 2013, SQL 2012, more!
Discover the easy way to master current and previous Microsoft technologies
and advance your career. Get an incredible 1,500+ hours of step-by-step
tutorial videos with LearnDevNow. Subscribe today and save!
http://pubads.g.doubleclick.net/gampad/clk?id=58040911&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
