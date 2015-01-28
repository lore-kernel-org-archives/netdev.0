From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/4] net: am2150: fix nmclan_cs.c shared interrupt handling
Date: Wed, 28 Jan 2015 15:15:04 +0100
Message-ID: <1422454504-439085-5-git-send-email-arnd@arndb.de>
References: <1422454504-439085-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-pcmcia@lists.infradead.org,
 jeffrey.t.kirsher@intel.com, kas@fi.muni.cz, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
In-Reply-To: <1422454504-439085-1-git-send-email-arnd@arndb.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: "linux-pcmcia" <linux-pcmcia-bounces@lists.infradead.org>
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

A recent patch tried to work around a valid warning for the use of a
deprecated interface by blindly changing from the old
pcmcia_request_exclusive_irq() interface to pcmcia_request_irq().

This driver has an interrupt handler that is not currently aware
of shared interrupts, but can be easily converted to be.
At the moment, the driver reads the interrupt status register
repeatedly until it contains only zeroes in the interesting bits,
and handles each bit individually.

This patch adds the missing part of returning IRQ_NONE in case none
of the bits are set to start with, so we can move on to the next
interrupt source.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5f5316fcd08ef7 ("am2150: Update nmclan_cs.c to use update PCMCIA API")
---
 drivers/net/ethernet/amd/nmclan_cs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 5b22764ba88d..27245efe9f50 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -952,6 +952,8 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
   do {
     /* WARNING: MACE_IR is a READ/CLEAR port! */
     status = inb(ioaddr + AM2150_MACE_BASE + MACE_IR);
+    if (!(status & ~MACE_IMR_DEFAULT) && IntrCnt == MACE_MAX_IR_ITERATIONS)
+      return IRQ_NONE;
 
     pr_debug("mace_interrupt: irq 0x%X status 0x%X.\n", irq, status);
 
-- 
2.1.0.rc2
