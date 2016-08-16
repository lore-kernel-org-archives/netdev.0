From: Pavel Andrianov <andrianov@ispras.ru>
Subject: [PATCH] smc91c92_cs : add a spinlock to avoid race condition
Date: Tue, 16 Aug 2016 16:39:06 +0300
Message-ID: <1471354746-27110-1-git-send-email-andrianov@ispras.ru>
Cc: Pavel Andrianov <andrianov@ispras.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vaishali.thakkar@oracle.com,
	ldv-project@linuxtesting.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

smc_reset may be executed in parallel with timer function media_check.
To avoid data race in smc_set_xcvr a spinlock was added.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Pavel Andrianov <andrianov@ispras.ru>
---
 drivers/net/ethernet/smsc/smc91c92_cs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index db3c696..69d865c 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1637,6 +1637,7 @@ static void smc_reset(struct net_device *dev)
     unsigned int ioaddr = dev->base_addr;
     struct smc_private *smc = netdev_priv(dev);
     int i;
+    unsigned long flags;
 
     netdev_dbg(dev, "smc91c92 reset called.\n");
 
@@ -1647,6 +1648,7 @@ static void smc_reset(struct net_device *dev)
     outw(RCR_SOFTRESET, ioaddr + RCR);
     udelay(10);
 
+    spin_lock_irqsave(&smc->lock, flags);
     /* Clear the transmit and receive configuration registers. */
     outw(RCR_CLEAR, ioaddr + RCR);
     outw(TCR_CLEAR, ioaddr + TCR);
@@ -1699,6 +1701,7 @@ static void smc_reset(struct net_device *dev)
     SMC_SELECT_BANK(2);
     outw((IM_EPH_INT | IM_RX_OVRN_INT | IM_RCV_INT) << 8,
 	 ioaddr + INTERRUPT);
+    spin_unlock_irqrestore(&smc->lock, flags);
 }
 
 /*======================================================================
-- 
2.7.4
