From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/16] drivers, net, hamradio: convert sixpack.refcnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:35 +0300
Message-ID: <1490691403-4016-9-git-send-email-elena.reshetova@intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rdma@vger.kernel.org, linux-hams@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wireless@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, blogic@openwrt.org,
        matthias.bgg@gmail.com, yishaih@mellanox.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, j@w1.fi,
        kvalo@codeaurora.org, peterz@infradead.org, keescook@chromium.org,
        gregkh@linuxfoundation.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/net/hamradio/6pack.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 922bf44..ea6c975 100644
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
 
@@ -580,7 +580,7 @@ static int sixpack_open(struct tty_struct *tty)
 	sp->dev = dev;
 
 	spin_lock_init(&sp->lock);
-	atomic_set(&sp->refcnt, 1);
+	refcount_set(&sp->refcnt, 1);
 	sema_init(&sp->dead_sem, 0);
 
 	/* !!! length of the buffers. MTU is IP MTU, not PACLEN!  */
@@ -676,7 +676,7 @@ static void sixpack_close(struct tty_struct *tty)
 	 * We have now ensured that nobody can start using ap from now on, but
 	 * we have to wait for all existing users to finish.
 	 */
-	if (!atomic_dec_and_test(&sp->refcnt))
+	if (!refcount_dec_and_test(&sp->refcnt))
 		down(&sp->dead_sem);
 
 	/* We must stop the queue to avoid potentially scribbling
-- 
2.7.4

