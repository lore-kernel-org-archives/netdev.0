From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v4 6/7] net: pch_gbe: Allow longer for resets
Date: Mon, 5 Jun 2017 10:31:35 -0700
Message-ID: <20170605173136.10795-7-paul.burton@imgtec.com>
References: <20170602234042.22782-1-paul.burton@imgtec.com>
 <20170605173136.10795-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        <linux-mips@linux-mips.org>, Eric Dumazet <edumazet@google.com>,
        Jarod Wilson <jarod@redhat.com>,
        Tobias Klauser <tklauser@distanz.ch>,
        Paul Burton <paul.burton@imgtec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:24850 "EHLO
        mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752036AbdFEReH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 13:34:07 -0400
In-Reply-To: <20170605173136.10795-1-paul.burton@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resets of the EG20T MAC on the MIPS Boston development board take longer
than the 1000 loops that pch_gbe_wait_clr_bit was performing. Rather
than simply increasing the number of loops, switch to using
readl_poll_timeout_atomic() from linux/iopoll.h in order to provide some
independence from the speed of the CPU.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org

---

Changes in v4: None

Changes in v3:
- Switch to using readl_poll_timeout_atomic().

Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index c8554d3adf1c..c109646803a4 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -24,6 +24,7 @@
 #include <linux/ptp_classify.h>
 #include <linux/gpio.h>
 #include <linux/gpio/consumer.h>
+#include <linux/iopoll.h>
 #include <linux/of_gpio.h>
 
 #define DRV_VERSION     "1.01"
@@ -318,13 +319,11 @@ s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
  */
 static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
 {
+	int err;
 	u32 tmp;
 
-	/* wait busy */
-	tmp = 1000;
-	while ((ioread32(reg) & bit) && --tmp)
-		cpu_relax();
-	if (!tmp)
+	err = readl_poll_timeout_atomic(reg, tmp, !(tmp & bit), 10, 500);
+	if (err)
 		pr_err("Error: busy bit is not cleared\n");
 }
 
-- 
2.13.0
