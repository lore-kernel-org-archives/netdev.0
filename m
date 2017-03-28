From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/16] drivers, net: convert masces_rx_sa.refcnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:36 +0300
Message-ID: <1490691403-4016-10-git-send-email-elena.reshetova@intel.com>
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
 drivers/net/macsec.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index ff0a5ed..bc0b00a 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -16,6 +16,7 @@
 #include <crypto/aead.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
+#include <linux/refcount.h>
 #include <net/genetlink.h>
 #include <net/sock.h>
 #include <net/gro_cells.h>
@@ -146,7 +147,7 @@ struct macsec_rx_sa {
 	struct macsec_key key;
 	spinlock_t lock;
 	u32 next_pn;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	bool active;
 	struct macsec_rx_sa_stats __percpu *stats;
 	struct macsec_rx_sc *sc;
@@ -314,7 +315,7 @@ static struct macsec_rx_sa *macsec_rxsa_get(struct macsec_rx_sa __rcu *ptr)
 	if (!sa || !sa->active)
 		return NULL;
 
-	if (!atomic_inc_not_zero(&sa->refcnt))
+	if (!refcount_inc_not_zero(&sa->refcnt))
 		return NULL;
 
 	return sa;
@@ -350,7 +351,7 @@ static void free_rxsa(struct rcu_head *head)
 
 static void macsec_rxsa_put(struct macsec_rx_sa *sa)
 {
-	if (atomic_dec_and_test(&sa->refcnt))
+	if (refcount_dec_and_test(&sa->refcnt))
 		call_rcu(&sa->rcu, free_rxsa);
 }
 
@@ -1324,7 +1325,7 @@ static int init_rx_sa(struct macsec_rx_sa *rx_sa, char *sak, int key_len,
 
 	rx_sa->active = false;
 	rx_sa->next_pn = 1;
-	atomic_set(&rx_sa->refcnt, 1);
+	refcount_set(&rx_sa->refcnt, 1);
 	spin_lock_init(&rx_sa->lock);
 
 	return 0;
-- 
2.7.4

