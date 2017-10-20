From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 14/15] drivers, net, ppp: convert syncppp.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:48 +0300
Message-ID: <1508484229-19706-15-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable syncppp.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ppp/ppp_synctty.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index 7868c29..7196f00 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -46,6 +46,7 @@
 #include <linux/init.h>
 #include <linux/interrupt.h>
 #include <linux/slab.h>
+#include <linux/refcount.h>
 #include <asm/unaligned.h>
 #include <linux/uaccess.h>
 
@@ -72,7 +73,7 @@ struct syncppp {
 
 	struct tasklet_struct tsk;
 
-	atomic_t	refcnt;
+	refcount_t	refcnt;
 	struct completion dead_cmp;
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 };
@@ -141,14 +142,14 @@ static struct syncppp *sp_get(struct tty_struct *tty)
 	read_lock(&disc_data_lock);
 	ap = tty->disc_data;
 	if (ap != NULL)
-		atomic_inc(&ap->refcnt);
+		refcount_inc(&ap->refcnt);
 	read_unlock(&disc_data_lock);
 	return ap;
 }
 
 static void sp_put(struct syncppp *ap)
 {
-	if (atomic_dec_and_test(&ap->refcnt))
+	if (refcount_dec_and_test(&ap->refcnt))
 		complete(&ap->dead_cmp);
 }
 
@@ -182,7 +183,7 @@ ppp_sync_open(struct tty_struct *tty)
 	skb_queue_head_init(&ap->rqueue);
 	tasklet_init(&ap->tsk, ppp_sync_process, (unsigned long) ap);
 
-	atomic_set(&ap->refcnt, 1);
+	refcount_set(&ap->refcnt, 1);
 	init_completion(&ap->dead_cmp);
 
 	ap->chan.private = ap;
@@ -232,7 +233,7 @@ ppp_sync_close(struct tty_struct *tty)
 	 * our channel ops (i.e. ppp_sync_send/ioctl) are in progress
 	 * by the time it returns.
 	 */
-	if (!atomic_dec_and_test(&ap->refcnt))
+	if (!refcount_dec_and_test(&ap->refcnt))
 		wait_for_completion(&ap->dead_cmp);
 	tasklet_kill(&ap->tsk);
 
-- 
2.7.4
