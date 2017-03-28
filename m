From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 12/16] drivers, net, ppp: convert asyncppp.refcnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:39 +0300
Message-ID: <1490691403-4016-13-git-send-email-elena.reshetova@intel.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
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
 drivers/net/ppp/ppp_async.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ppp/ppp_async.c b/drivers/net/ppp/ppp_async.c
index feb9569..2d08f7e 100644
--- a/drivers/net/ppp/ppp_async.c
+++ b/drivers/net/ppp/ppp_async.c
@@ -69,7 +69,7 @@ struct asyncppp {
 
 	struct tasklet_struct tsk;
 
-	atomic_t	refcnt;
+	refcount_t	refcnt;
 	struct semaphore dead_sem;
 	struct ppp_channel chan;	/* interface to generic ppp layer */
 	unsigned char	obuf[OBUFSIZE];
@@ -140,14 +140,14 @@ static struct asyncppp *ap_get(struct tty_struct *tty)
 	read_lock(&disc_data_lock);
 	ap = tty->disc_data;
 	if (ap != NULL)
-		atomic_inc(&ap->refcnt);
+		refcount_inc(&ap->refcnt);
 	read_unlock(&disc_data_lock);
 	return ap;
 }
 
 static void ap_put(struct asyncppp *ap)
 {
-	if (atomic_dec_and_test(&ap->refcnt))
+	if (refcount_dec_and_test(&ap->refcnt))
 		up(&ap->dead_sem);
 }
 
@@ -185,7 +185,7 @@ ppp_asynctty_open(struct tty_struct *tty)
 	skb_queue_head_init(&ap->rqueue);
 	tasklet_init(&ap->tsk, ppp_async_process, (unsigned long) ap);
 
-	atomic_set(&ap->refcnt, 1);
+	refcount_set(&ap->refcnt, 1);
 	sema_init(&ap->dead_sem, 0);
 
 	ap->chan.private = ap;
@@ -234,7 +234,7 @@ ppp_asynctty_close(struct tty_struct *tty)
 	 * our channel ops (i.e. ppp_async_send/ioctl) are in progress
 	 * by the time it returns.
 	 */
-	if (!atomic_dec_and_test(&ap->refcnt))
+	if (!refcount_dec_and_test(&ap->refcnt))
 		down(&ap->dead_sem);
 	tasklet_kill(&ap->tsk);
 
-- 
2.7.4
