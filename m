From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/5] farsync: fix off-by-one bug in fst_add_one
Date: Mon, 14 Mar 2016 15:18:35 +0100
Message-ID: <1457965120-3155420-3-git-send-email-arnd@arndb.de>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Cc: netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-6 finds an out of bounds access in the fst_add_one function
when calculating the end of the mmio area:

drivers/net/wan/farsync.c: In function 'fst_add_one':
drivers/net/wan/farsync.c:418:53: error: index 2 denotes an offset greater than size of 'u8[2][8192] {aka unsigned char[2][8192]}' [-Werror=array-bounds]
 #define BUF_OFFSET(X)   (BFM_BASE + offsetof(struct buf_window, X))
                                                     ^
include/linux/compiler-gcc.h:158:21: note: in definition of macro '__compiler_offsetof'
  __builtin_offsetof(a, b)
                     ^
drivers/net/wan/farsync.c:418:37: note: in expansion of macro 'offsetof'
 #define BUF_OFFSET(X)   (BFM_BASE + offsetof(struct buf_window, X))
                                     ^~~~~~~~
drivers/net/wan/farsync.c:2519:36: note: in expansion of macro 'BUF_OFFSET'
                                  + BUF_OFFSET ( txBuffer[i][NUM_TX_BUFFER][0]);
                                    ^~~~~~~~~~

The warning is correct, but not critical because this appears
to be a write-only variable that is set by each WAN driver but
never accessed afterwards.

I'm taking the minimal fix here, using the correct pointer by
pointing 'mem_end' to the last byte inside of the register area
as all other WAN drivers do, rather than the first byte outside of
it. An alternative would be to just remove the mem_end member
entirely.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/wan/farsync.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 44541dbc5c28..69b994f3b8c5 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2516,7 +2516,7 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
                 dev->mem_start   = card->phys_mem
                                  + BUF_OFFSET ( txBuffer[i][0][0]);
                 dev->mem_end     = card->phys_mem
-                                 + BUF_OFFSET ( txBuffer[i][NUM_TX_BUFFER][0]);
+                                 + BUF_OFFSET ( txBuffer[i][NUM_TX_BUFFER - 1][LEN_RX_BUFFER - 1]);
                 dev->base_addr   = card->pci_conf;
                 dev->irq         = card->irq;
 
-- 
2.7.0
