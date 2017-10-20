From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 10/15] drivers, net: convert masces_rx_sc.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:44 +0300
Message-ID: <1508484229-19706-11-git-send-email-elena.reshetova@intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:15411 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752112AbdJTHZN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 03:25:13 -0400
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

The variable masces_rx_sc.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/macsec.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 733e1c2..e0aeb51 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -172,7 +172,7 @@ struct macsec_rx_sc {
 	bool active;
 	struct macsec_rx_sa __rcu *sa[MACSEC_NUM_AN];
 	struct pcpu_rx_sc_stats __percpu *stats;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	struct rcu_head rcu_head;
 };
 
@@ -331,12 +331,12 @@ static void free_rx_sc_rcu(struct rcu_head *head)
 
 static struct macsec_rx_sc *macsec_rxsc_get(struct macsec_rx_sc *sc)
 {
-	return atomic_inc_not_zero(&sc->refcnt) ? sc : NULL;
+	return refcount_inc_not_zero(&sc->refcnt) ? sc : NULL;
 }
 
 static void macsec_rxsc_put(struct macsec_rx_sc *sc)
 {
-	if (atomic_dec_and_test(&sc->refcnt))
+	if (refcount_dec_and_test(&sc->refcnt))
 		call_rcu(&sc->rcu_head, free_rx_sc_rcu);
 }
 
@@ -1411,7 +1411,7 @@ static struct macsec_rx_sc *create_rx_sc(struct net_device *dev, sci_t sci)
 
 	rx_sc->sci = sci;
 	rx_sc->active = true;
-	atomic_set(&rx_sc->refcnt, 1);
+	refcount_set(&rx_sc->refcnt, 1);
 
 	secy = &macsec_priv(dev)->secy;
 	rcu_assign_pointer(rx_sc->next, secy->rx_sc);
-- 
2.7.4
