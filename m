From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH V2] wan: dscc4:  use msecs_to_jiffies for conversions
Date: Sun,  7 Jun 2015 12:35:46 +0200
Message-ID: <1433673346-22183-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:40177 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbbFGKnz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Jun 2015 06:43:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

API compliance scanning with coccinelle flagged:
./drivers/net/wan/dscc4.c:1036:1-33:
        WARNING: timeout (10) seems HZ dependent
./drivers/net/wan/dscc4.c:554:2-34:
        WARNING: timeout (10) seems HZ dependent
./drivers/net/wan/dscc4.c:599:2-34:
        WARNING: timeout (10) seems HZ dependent

Numeric constants passed to schedule_timeout_*() make the effective
timeout HZ dependent which does not seem to be the intent here.
Fixed up by converting the constant to jiffies with msecs_to_jiffies(),
passing 100ms (assuming HZ==100 in the original code).

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

V2: As the intended timeout is not documented and msecs_to_jiffies(10) may
    be a factor 10 off from constant 10, the value is transformed assuming
    HZ=100 to be on the safe side as suggested by David Miller
    <davem@davemloft.net> to minimize the probability of breaking this 
    old code.

Patch was compile tested with x86_64_defconfig + CONFIG_WAN=y
CONFIG_HDLC=m, CONFIG_DSCC4=m

Patch is against 4.1-rc6 (localversion-next is -next-20150605)

 drivers/net/wan/dscc4.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 0822356..2ce5249 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -551,7 +551,7 @@ static int dscc4_wait_ack_cec(struct dscc4_dev_priv *dpriv,
 			       msg, i);
 			goto done;
 		}
-		schedule_timeout_uninterruptible(10);
+		schedule_timeout_uninterruptible(msecs_to_jiffies(100));
 		rmb();
 	} while (++i > 0);
 	netdev_err(dev, "%s timeout\n", msg);
@@ -596,7 +596,7 @@ static inline int dscc4_xpr_ack(struct dscc4_dev_priv *dpriv)
 		    (dpriv->iqtx[cur] & cpu_to_le32(Xpr)))
 			break;
 		smp_rmb();
-		schedule_timeout_uninterruptible(10);
+		schedule_timeout_uninterruptible(msecs_to_jiffies(100));
 	} while (++i > 0);
 
 	return (i >= 0 ) ? i : -EAGAIN;
@@ -1033,7 +1033,7 @@ static void dscc4_pci_reset(struct pci_dev *pdev, void __iomem *ioaddr)
 	/* Flush posted writes */
 	readl(ioaddr + GSTAR);
 
-	schedule_timeout_uninterruptible(10);
+	schedule_timeout_uninterruptible(msecs_to_jiffies(100));
 
 	for (i = 0; i < 16; i++)
 		pci_write_config_dword(pdev, i << 2, dscc4_pci_config_store[i]);
-- 
1.7.10.4
