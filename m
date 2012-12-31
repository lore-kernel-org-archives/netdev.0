From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 01/15] via-rhine: YARB: fix broken resume of ifdown case (NetworkManager).
Date: Mon, 31 Dec 2012 16:25:35 +0100
Message-ID: <1356967549-5056-2-git-send-email-andi@lisas.de>
References: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54079 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab2LaPen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:43 -0500
In-Reply-To: <1356967549-5056-1-git-send-email-andi@lisas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

Well, it's probably not a *breakage* this time after all
(handling probably was never fully correct before).

resume() in the case of an ifdown iface
(as e.g. usually done by NetworkManager)
did not restore the card to proper full post-probe() card state
(see resume()s !netif_running() check),
thereby causing the subsequent iface open() as done by NM to fail,
since that one requires full post-probe() card state
(e.g. PHY available) yet the PHY was not available
(at least in the case of full-shutdown S2R).

Some related NetworkManager links are
  https://bugs.mageia.org/show_bug.cgi?id=7498
  http://crunchbang.org/forums/viewtopic.php?id=15169
  https://bugzilla.redhat.com/show_bug.cgi?id=477964
  https://bugzilla.redhat.com/show_bug.cgi?id=549089

Suspend/resume behaviour verified with both NM running and not running,
and with both mem (S2R) and standby.
Tested on Neoware CA10 (VIA C3), will also test on EPoX 8K5A2+.

Signed-off-by: Andreas Mohr <andim2@users.sf.net>
---
 drivers/net/ethernet/via/via-rhine.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 7992b3e..5facb0b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2324,13 +2324,20 @@ static int rhine_resume(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
-	if (!netif_running(dev))
-		return 0;
-
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 #endif
+	/*
+	 * FIXME: some power calls here are being done
+	 * internally in netdev setup parts below, too -
+	 * should be corrected eventually.
+	 */
 	rhine_power_init(dev);
+	rhine_hw_init(dev, rp->pioaddr);
+
+	if (!netif_running(dev))
+		return 0;
+
 	free_tbufs(dev);
 	free_rbufs(dev);
 	alloc_tbufs(dev);
-- 
1.7.2.5
