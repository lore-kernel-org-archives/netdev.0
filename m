From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: net/kbuild trees build failure
Date: Mon, 7 Dec 2009 11:09:03 -0500
Message-ID: <20091207160903.GB18939@tuxdriver.com>
References: <20091207200317.57820f0a.sfr@canb.auug.org.au> <20091207114158.GA2428@merkur.ravnborg.org> <4B1CF39A.5050806@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Reinette Chatre <reinette.chatre@intel.com>
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935313AbZLGQPN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B1CF39A.5050806@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 07, 2009 at 01:22:50PM +0100, Michal Marek wrote:
> On 7.12.2009 12:41, Sam Ravnborg wrote:
> > On Mon, Dec 07, 2009 at 08:03:17PM +1100, Stephen Rothwell wrote:
> >> Hi Dave,
> >>
> >> Today's linux-next build (powerpc allyesconfig) failed like this:
> >>
> >> In file included from drivers/net/wireless/iwlwifi/iwl3945-base.c:57:
> >> drivers/net/wireless/iwlwifi/iwl-core.h:66:30: error: linux/utsrelease.h: No such file or directory
> >>
> >> Caused by commit 250cce26d5d03337aec4ff8405121f026adb4a89 ("iwlwifi:
> >> driver version track kernel version") from the net tree interacting with
> >> commit 8e5c76aace9705b6983cfbf5eb2f2e869dab6738 ("kbuild: move
> >> utsrelease.h to include/generated") from the kbuild tree.
> >>
> >> I applied this patch for today (and will carry it as necessary):
> > 
> > The right fix would be to use 'utsname()->sysname' (I think sysname
> > is the right member).
> 
> ->release would be the right one. One could also question why iwlwifi
> needs to repeat the kernel version it was built / is running against,
> but I that's not the point here :). Dave, John, can we agree that
> whichever tree gets merged first, the other tree applies the one-liner?

Hmmm...well, the suggested fixes are fine for the printk (i.e. runtime)
usage.  But (other than Stephen's) they don't seem to help with the
MODULE_VERSION (i.e. compile time) usage.  Is there an approved
solution for that?

For some reason the Intel drivers encode some of their build options
into their MODULE_VERSION string.  Other than that, the vermagic
field from modinfo would seem to suffice for replacing this version
information.  Honestly, I'm not too fond of the "build options in
the version string" stuff...perhaps we could just get rid of it all?

From: John W. Linville <linville@tuxdriver.com>
Subject: [PATCH] iwlwifi: remove DRV_VERSION altogether

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   18 +-----------------
 drivers/net/wireless/iwlwifi/iwl-core.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   16 +---------------
 4 files changed, 2 insertions(+), 34 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index b8377ef..9d9dfef 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -67,23 +67,7 @@
  */
 #define DRV_DESCRIPTION	"Intel(R) Wireless WiFi Link AGN driver for Linux"
 
-#ifdef CONFIG_IWLWIFI_DEBUG
-#define VD "d"
-#else
-#define VD
-#endif
-
-#ifdef CONFIG_IWLWIFI_SPECTRUM_MEASUREMENT
-#define VS "s"
-#else
-#define VS
-#endif
-
-#define DRV_VERSION     IWLWIFI_VERSION VD VS
-
-
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
-MODULE_VERSION(DRV_VERSION);
 MODULE_AUTHOR(DRV_COPYRIGHT " " DRV_AUTHOR);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("iwl4965");
@@ -3707,7 +3691,7 @@ static int __init iwl_init(void)
 {
 
 	int ret;
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION "\n");
 	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
 
 	ret = iwlagn_rate_control_register();
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 574d366..1e79a57 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -43,7 +43,6 @@
 
 
 MODULE_DESCRIPTION("iwl core");
-MODULE_VERSION(IWLWIFI_VERSION);
 MODULE_AUTHOR(DRV_COPYRIGHT " " DRV_AUTHOR);
 MODULE_LICENSE("GPL");
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 675b7df..31594b2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -72,7 +72,6 @@ struct iwl_host_cmd;
 struct iwl_cmd;
 
 
-#define IWLWIFI_VERSION UTS_RELEASE "-k"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2009 Intel Corporation"
 #define DRV_AUTHOR     "<ilw@linux.intel.com>"
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 2a28a1f..fb9e7c3 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -64,24 +64,10 @@
 #define DRV_DESCRIPTION	\
 "Intel(R) PRO/Wireless 3945ABG/BG Network Connection driver for Linux"
 
-#ifdef CONFIG_IWLWIFI_DEBUG
-#define VD "d"
-#else
-#define VD
-#endif
-
-#ifdef CONFIG_IWL3945_SPECTRUM_MEASUREMENT
-#define VS "s"
-#else
-#define VS
-#endif
-
-#define DRV_VERSION  IWLWIFI_VERSION VD VS
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2009 Intel Corporation"
 #define DRV_AUTHOR     "<ilw@linux.intel.com>"
 
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
-MODULE_VERSION(DRV_VERSION);
 MODULE_AUTHOR(DRV_COPYRIGHT " " DRV_AUTHOR);
 MODULE_LICENSE("GPL");
 
@@ -4278,7 +4264,7 @@ static int __init iwl3945_init(void)
 {
 
 	int ret;
-	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
+	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION "\n");
 	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
 
 	ret = iwl3945_rate_control_register();
-- 
1.6.2.5

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
