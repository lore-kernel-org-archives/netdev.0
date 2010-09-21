From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-09-21
Date: Tue, 21 Sep 2010 14:26:20 -0400
Message-ID: <20100921182620.GB2448@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are two more small fixes intended for 2.6.36.  One is a one-liner
(kmalloc->kzalloc) that prevents a potential information leak.
The other is a small fix that skips firmware reloads (a workaround
for firmware problems) while a scan is in progress in order to avoid
the stack trace cited in the commit log.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 3779298b81cd9a2531cec93e3beefc1acdb01382:

  Merge branch 'vhost-net' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost (2010-09-20 11:13:34 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Johannes Berg (1):
      wext: fix potential private ioctl memory content leak

Wey-Yi Guy (1):
      iwlwifi: do not perferm force reset while doing scan

 drivers/net/wireless/iwlwifi/iwl-core.c |    5 +++++
 net/wireless/wext-priv.c                |    2 +-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 07dbc27..e23c406 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -2613,6 +2613,11 @@ int iwl_force_reset(struct iwl_priv *priv, int mode, bool external)
 	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return -EINVAL;
 
+	if (test_bit(STATUS_SCANNING, &priv->status)) {
+		IWL_DEBUG_INFO(priv, "scan in progress.\n");
+		return -EINVAL;
+	}
+
 	if (mode >= IWL_MAX_FORCE_RESET) {
 		IWL_DEBUG_INFO(priv, "invalid reset request.\n");
 		return -EINVAL;
diff --git a/net/wireless/wext-priv.c b/net/wireless/wext-priv.c
index 3feb28e..674d426 100644
--- a/net/wireless/wext-priv.c
+++ b/net/wireless/wext-priv.c
@@ -152,7 +152,7 @@ static int ioctl_private_iw_point(struct iw_point *iwp, unsigned int cmd,
 	} else if (!iwp->pointer)
 		return -EFAULT;
 
-	extra = kmalloc(extra_size, GFP_KERNEL);
+	extra = kzalloc(extra_size, GFP_KERNEL);
 	if (!extra)
 		return -ENOMEM;
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
