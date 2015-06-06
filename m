From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] cosa: use msecs_to_jiffies for conversions
Date: Sat,  6 Jun 2015 09:51:51 +0200
Message-ID: <1433577111-7404-1-git-send-email-hofrat@osadl.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Jan Yenya Kasprzak <kas@fi.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:33335 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751288AbbFFIAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Jun 2015 04:00:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

API compliance scanning with coccinelle flagged:
./drivers/net/wan/cosa.c:520:2-18: WARNING: 
	timeout (30) seems HZ dependent

Numeric constants passed to schedule_timeout() make the effective
timeout HZ dependent which makes little sense in a device probe.
Fixed up by converting the constant to jiffies with msecs_to_jiffies()

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

As the actually intended timeout is not documented and msecs_to_jiffies
timeouts can be a factor 10 different from the current effective timeout
As the original driver predates variable HZ (2.2.26 drivers/net/cosa.c
also is using schedule_timeout(30)) this is probably assuming HZ=100 
and thus the timeout would need to be 300, this needs to be checked by 
someone who knows the details of this driver.
In any case it should be passed in a HZ independent manner.

Patch was compile tested with i386_defconfig + CONFIG_WAN=y
CONFIG_ISA=y, CONFIG_HDLC=m, CONFIG_COSA=m

Patch is against 4.1-rc6 (localversion-next is -next-20150605)

 drivers/net/wan/cosa.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index bcfa01a..4cce63c 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -517,7 +517,7 @@ static int cosa_probe(int base, int irq, int dma)
 		 */
 		set_current_state(TASK_INTERRUPTIBLE);
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
-		schedule_timeout(30);
+		schedule_timeout(msecs_to_jiffies(300));
 		irq = probe_irq_off(irqs);
 		/* Disable all IRQs from the card */
 		cosa_putstatus(cosa, 0);
-- 
1.7.10.4
