From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-07-19
Date: Mon, 19 Jul 2010 15:17:09 -0400
Message-ID: <20100719191709.GA6115@tuxdriver.com>
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

In this round we have two more-or-less-one-liners intended for 2.6.25.

The hostap fix is the third (and hopefully final) bite at the apple
for correcting an initialization failure.  The first two attempts
created and then reinstated a regression caused by a discrepency
between the PCI and PCMCIA support within hostap.  The regression
was caused by checking the value of dev->base_addr, which the PCI
code was not setting.  Testing by the regression reporter indicates
that his device is finally working again with this fix.

The rt2x00 fix merely reorders some initialization so that unwinding
that init in an error path works as expected.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 91a72a70594e5212c97705ca6a694bd307f7a26b:

  net/core: neighbour update Oops (2010-07-14 18:02:16 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

John W. Linville (1):
      hostap_pci: set dev->base_addr during probe

Stephen Boyd (1):
      rt2x00: Fix lockdep warning in rt2x00lib_probe_dev()

 drivers/net/wireless/hostap/hostap_pci.c |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c  |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index d24dc7d..972a9c3 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -330,6 +330,7 @@ static int prism2_pci_probe(struct pci_dev *pdev,
 
         dev->irq = pdev->irq;
         hw_priv->mem_start = mem;
+	dev->base_addr = (unsigned long) mem;
 
 	prism2_pci_cor_sreset(local);
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 3ae468c..f20d3ee 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -854,6 +854,11 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 		    BIT(NL80211_IFTYPE_WDS);
 
 	/*
+	 * Initialize configuration work.
+	 */
+	INIT_WORK(&rt2x00dev->intf_work, rt2x00lib_intf_scheduled);
+
+	/*
 	 * Let the driver probe the device to detect the capabilities.
 	 */
 	retval = rt2x00dev->ops->lib->probe_hw(rt2x00dev);
@@ -863,11 +868,6 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	}
 
 	/*
-	 * Initialize configuration work.
-	 */
-	INIT_WORK(&rt2x00dev->intf_work, rt2x00lib_intf_scheduled);
-
-	/*
 	 * Allocate queue array.
 	 */
 	retval = rt2x00queue_allocate(rt2x00dev);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
