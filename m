From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 02/04] r8169: remove poll_locked logic
Date: Sun, 28 Oct 2007 18:22:14 +0100
Message-ID: <20071028172214.GC24622@electric-eye.fr.zoreil.com>
References: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:48509 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751506AbXJ1R3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 13:29:06 -0400
Content-Disposition: inline
In-Reply-To: <20071028171937.GA24622@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Disabling napi polling early is well enough.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c5eaf49..b94fa7e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2991,13 +2991,16 @@ static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
-	unsigned int poll_locked = 0;
 	unsigned int intrmask;
 
 	rtl8169_delete_timer(dev);
 
 	netif_stop_queue(dev);
 
+#ifdef CONFIG_R8169_NAPI
+	napi_disable(&tp->napi);
+#endif
+
 core_down:
 	spin_lock_irq(&tp->lock);
 
@@ -3011,13 +3014,6 @@ core_down:
 
 	synchronize_irq(dev->irq);
 
-	if (!poll_locked) {
-#ifdef CONFIG_R8169_NAPI
-		napi_disable(&tp->napi);
-#endif
-		poll_locked++;
-	}
-
 	/* Give a racing hard_start_xmit a few cycles to complete. */
 	synchronize_sched();  /* FIXME: should this be synchronize_irq()? */
 
-- 
1.5.2.4

