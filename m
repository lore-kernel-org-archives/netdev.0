From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 09/15] drivers, net: convert masces_rx_sa.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:43 +0300
Message-ID: <1508484229-19706-10-git-send-email-elena.reshetova@intel.com>
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
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-hams-owner@vger.kernel.org
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

The variable masces_rx_sa.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/macsec.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index ccbe4eaf..733e1c2 100644
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
 
@@ -1339,7 +1340,7 @@ static int init_rx_sa(struct macsec_rx_sa *rx_sa, char *sak, int key_len,
 
 	rx_sa->active = false;
 	rx_sa->next_pn = 1;
-	atomic_set(&rx_sa->refcnt, 1);
+	refcount_set(&rx_sa->refcnt, 1);
 	spin_lock_init(&rx_sa->lock);
 
 	return 0;
-- 
2.7.4

