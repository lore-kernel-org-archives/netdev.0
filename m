From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Tue,  3 Oct 2017 10:22:44 +0800
Message-ID: <1506997364-26541-1-git-send-email-baijiaju1990@163.com>
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
        linux-sctp@vger.kernel.org, linux-wireless@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@163.com>
To: davem@davemloft.net, herbert@gondor.apana.org.au,
        nhorman@tuxdriver.com, vyasevich@gmail.com, luto@kernel.org,
        kvalo@codeaurora.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the same reason, the orinoco driver may sleep in interrupt handler, 
and the function call path is:
orinoco_rx_isr_tasklet
  orinoco_rx
    orinoco_mic
      crypto_shash_setkey
        shash_setkey_unaligned
          kmalloc(GFP_KERNEL)

To fix it, GFP_KERNEL is replaced with GFP_ATOMIC.
This bug is found by my static analysis tool and my code review.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 crypto/shash.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/crypto/shash.c b/crypto/shash.c
index 5e31c8d..8fcecc6 100644
--- a/crypto/shash.c
+++ b/crypto/shash.c
@@ -41,7 +41,7 @@ static int shash_setkey_unaligned(struct crypto_shash *tfm, const u8 *key,
 	int err;
 
 	absize = keylen + (alignmask & ~(crypto_tfm_ctx_alignment() - 1));
-	buffer = kmalloc(absize, GFP_KERNEL);
+	buffer = kmalloc(absize, GFP_ATOMIC);
 	if (!buffer)
 		return -ENOMEM;
 
-- 
1.7.9.5
