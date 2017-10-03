From: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
Subject: [PATCH V2] Fix a sleep-in-atomic bug in shash_setkey_unaligned
Date: Tue,  3 Oct 2017 10:25:22 +0800
Message-ID: <1506997522-26684-1-git-send-email-baijiaju1990@163.com>
Cc: linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
        nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, vyasevich-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The SCTP program may sleep under a spinlock, and the function call path is:
sctp_generate_t3_rtx_event (acquire the spinlock)
  sctp_do_sm
    sctp_side_effects
      sctp_cmd_interpreter
        sctp_make_init_ack
          sctp_pack_cookie
            crypto_shash_setkey
              shash_setkey_unaligned
                kmalloc(GFP_KERNEL)

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

Signed-off-by: Jia-Ju Bai <baijiaju1990-9Onoh4P/yGk@public.gmane.org>
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
