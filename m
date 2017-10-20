From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/15] drivers, net, hamradio: convert sixpack.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:42 +0300
Message-ID: <1508484229-19706-9-git-send-email-elena.reshetova@intel.com>
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

The variable sixpack.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/hamradio/6pack.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index bbc7b78..32f49c4 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -35,7 +35,7 @@
 #include <linux/tcp.h>
 #include <linux/semaphore.h>
 #include <linux/compat.h>
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #define SIXPACK_VERSION    "Revision: 0.3.0"
 
@@ -120,7 +120,7 @@ struct sixpack {
 
 	struct timer_list	tx_t;
 	struct timer_list	resync_t;
-	atomic_t		refcnt;
+	refcount_t		refcnt;
 	struct semaphore	dead_sem;
 	spinlock_t		lock;
 };
@@ -381,7 +381,7 @@ static struct sixpack *sp_get(struct tty_struct *tty)
 	read_lock(&disc_data_lock);
 	sp = tty->disc_data;
 	if (sp)
-		atomic_inc(&sp->refcnt);
+		refcount_inc(&sp->refcnt);
 	read_unlock(&disc_data_lock);
 
 	return sp;
@@ -389,7 +389,7 @@ static struct sixpack *sp_get(struct tty_struct *tty)
 
 static void sp_put(struct sixpack *sp)
 {
-	if (atomic_dec_and_test(&sp->refcnt))
+	if (refcount_dec_and_test(&sp->refcnt))
 		up(&sp->dead_sem);
 }
 
@@ -576,7 +576,7 @@ static int sixpack_open(struct tty_struct *tty)
 	sp->dev = dev;
 
 	spin_lock_init(&sp->lock);
-	atomic_set(&sp->refcnt, 1);
+	refcount_set(&sp->refcnt, 1);
 	sema_init(&sp->dead_sem, 0);
 
 	/* !!! length of the buffers. MTU is IP MTU, not PACLEN!  */
@@ -670,7 +670,7 @@ static void sixpack_close(struct tty_struct *tty)
 	 * We have now ensured that nobody can start using ap from now on, but
 	 * we have to wait for all existing users to finish.
 	 */
-	if (!atomic_dec_and_test(&sp->refcnt))
+	if (!refcount_dec_and_test(&sp->refcnt))
 		down(&sp->dead_sem);
 
 	/* We must stop the queue to avoid potentially scribbling
-- 
2.7.4
