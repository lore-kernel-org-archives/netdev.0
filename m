From: Clemens Buchacher <drizzd@aon.at>
Subject: [PATCH] jme: fix irq storm after suspend/resume
Date: Sat, 22 Oct 2011 14:56:20 +0200
Message-ID: <20111022125620.GA2256@ecki.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Adrian Chadd <adrian@freebsd.org>,
	Mohammed Shafi <shafi.wireless@gmail.com>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the device is down during suspend/resume, interrupts are enabled
without a registered interrupt handler, causing a storm of
unhandled interrupts until the IRQ is disabled because "nobody
cared".

Instead, check that the device is up before touching it in the
suspend/resume code.

Fixes https://bugzilla.kernel.org/show_bug.cgi?id=39112

Helped-by: Adrian Chadd <adrian@freebsd.org>
Helped-by: Mohammed Shafi <shafi.wireless@gmail.com>
Signed-off-by: Clemens Buchacher <drizzd@aon.at>
---

Unfortunately, bugzilla.kernel.org is still down. There is at least
one other person who reported the issue, and I don't have their
email address. So for now, I am the only one who tested this fix.

The patch applies to current tip (2efd7c0) of Linus' tree. I also
tested it based on v3.0 and it worked the same.

Many thanks to Adrian and Mohammed for helping me debug this issue.
See this thread for the history:
 http://mid.gmane.org/20110827113253.GA1444@ecki

 drivers/net/jme.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 3ac262f..7a8a3b6 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -3131,6 +3131,9 @@ jme_suspend(struct device *dev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
+	if (!netif_running(netdev))
+		return 0;
+
 	atomic_dec(&jme->link_changing);
 
 	netif_device_detach(netdev);
@@ -3171,6 +3174,9 @@ jme_resume(struct device *dev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct jme_adapter *jme = netdev_priv(netdev);
 
+	if (!netif_running(netdev))
+		return 0;
+
 	jme_clear_pm(jme);
 	jme_phy_on(jme);
 	if (test_bit(JME_FLAG_SSET, &jme->flags))
-- 
1.7.7
