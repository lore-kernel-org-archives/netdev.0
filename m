From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 11/16] drivers, net: convert masces_tx_sa.refcnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:38 +0300
Message-ID: <1490691403-4016-12-git-send-email-elena.reshetova@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:27969 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754756AbdC1I62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 04:58:28 -0400
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 drivers/net/macsec.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 1869223..2851dda 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -188,7 +188,7 @@ struct macsec_tx_sa {
 	struct macsec_key key;
 	spinlock_t lock;
 	u32 next_pn;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	bool active;
 	struct macsec_tx_sa_stats __percpu *stats;
 	struct rcu_head rcu;
@@ -362,7 +362,7 @@ static struct macsec_tx_sa *macsec_txsa_get(struct macsec_tx_sa __rcu *ptr)
 	if (!sa || !sa->active)
 		return NULL;
 
-	if (!atomic_inc_not_zero(&sa->refcnt))
+	if (!refcount_inc_not_zero(&sa->refcnt))
 		return NULL;
 
 	return sa;
@@ -379,7 +379,7 @@ static void free_txsa(struct rcu_head *head)
 
 static void macsec_txsa_put(struct macsec_tx_sa *sa)
 {
-	if (atomic_dec_and_test(&sa->refcnt))
+	if (refcount_dec_and_test(&sa->refcnt))
 		call_rcu(&sa->rcu, free_txsa);
 }
 
@@ -1422,7 +1422,7 @@ static int init_tx_sa(struct macsec_tx_sa *tx_sa, char *sak, int key_len,
 	}
 
 	tx_sa->active = false;
-	atomic_set(&tx_sa->refcnt, 1);
+	refcount_set(&tx_sa->refcnt, 1);
 	spin_lock_init(&tx_sa->lock);
 
 	return 0;
-- 
2.7.4
