From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: Re: [PATCH net-next 6/7] drivers/net/e1000e: Use
 pr_<level> and netdev_<level>
Date: Tue, 23 Feb 2010 11:17:07 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A90614784CF@orsmsx509.amr.corp.intel.com>
References: <cover.1266893507.git.joe@perches.com>
	<78b154eab5d37da22dda3bf3e77fe32013009fa3.1266893508.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <78b154eab5d37da22dda3bf3e77fe32013009fa3.1266893508.git.joe@perches.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Monday, February 22, 2010 6:57 PM, Joe Perches wrote:
> Convert e_<level> to netdev_<level>
> Remove #define PFX
> Use #define pr_fmt
> Convert a few printks to pr_<level>
> Coalesce long formats
> Typo spelling fix
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/e1000e/82571.c   |   57 +++++++++++-------
>  drivers/net/e1000e/e1000.h   |   21 -------
>  drivers/net/e1000e/es2lan.c  |   27 +++++----
>  drivers/net/e1000e/ethtool.c |   37 ++++++------
>  drivers/net/e1000e/ich8lan.c |   90 +++++++++++++++++------------
>  drivers/net/e1000e/lib.c     |  131
>  +++++++++++++++++++++---------------------
>  drivers/net/e1000e/netdev.c  |   95 +++++++++++++++---------------
>  drivers/net/e1000e/param.c   |   20 +++--- drivers/net/e1000e/phy.c 
>  |  114 ++++++++++++++++++------------------ 9 files changed, 302
> insertions(+), 290 deletions(-) 
> 

As an alternative to Joe's large patch to e1000e, I would like to suggest the following much less intrusive patch.  Compile-tested only.
  
Convert e_<level> to netdev_<level>
Use #define pr_fmt
Convert a few printks to pr_<level>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---
 drivers/net/e1000e/e1000.h  |   19 +++++--------------
 drivers/net/e1000e/netdev.c |    9 +++++----
 2 files changed, 10 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index c2ec095..ecd817f 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -42,25 +42,16 @@
 
 struct e1000_info;
 
-#define e_printk(level, adapter, format, arg...) \
-	printk(level "%s: %s: " format, pci_name(adapter->pdev), \
-	       adapter->netdev->name, ## arg)
-
-#ifdef DEBUG
 #define e_dbg(format, arg...) \
-	e_printk(KERN_DEBUG , hw->adapter, format, ## arg)
-#else
-#define e_dbg(format, arg...) do { (void)(hw); } while (0)
-#endif
-
+	netdev_dbg(hw->adapter->netdev, format, ## arg)
 #define e_err(format, arg...) \
-	e_printk(KERN_ERR, adapter, format, ## arg)
+	netdev_err(adapter->netdev, format, ## arg)
 #define e_info(format, arg...) \
-	e_printk(KERN_INFO, adapter, format, ## arg)
+	netdev_info(adapter->netdev, format, ## arg)
 #define e_warn(format, arg...) \
-	e_printk(KERN_WARNING, adapter, format, ## arg)
+	netdev_warn(adapter->netdev, format, ## arg)
 #define e_notice(format, arg...) \
-	e_printk(KERN_NOTICE, adapter, format, ## arg)
+	netdev_notice(adapter->netdev, format, ## arg)
 
 
 /* Interrupt modes, as used by the IntMode parameter */
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..d83c3cf 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -5403,10 +5405,9 @@ static struct pci_driver e1000_driver = {
 static int __init e1000_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
-	       e1000e_driver_name, e1000e_driver_version);
-	printk(KERN_INFO "%s: Copyright (c) 1999 - 2009 Intel Corporation.\n",
-	       e1000e_driver_name);
+	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
+	       e1000e_driver_version);
+	pr_info("Copyright (c) 1999 - 2009 Intel Corporation.\n");
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
