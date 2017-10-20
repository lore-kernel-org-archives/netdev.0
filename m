From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 13/15] drivers, net, ppp: convert ppp_file.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:47 +0300
Message-ID: <1508484229-19706-14-git-send-email-elena.reshetova@intel.com>
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
Received: from mga09.intel.com ([134.134.136.24]:15861 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752525AbdJTHZR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 03:25:17 -0400
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

The variable ppp_file.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ppp/ppp_generic.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index e365866..6566107 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -51,6 +51,7 @@
 #include <asm/unaligned.h>
 #include <net/slhc_vj.h>
 #include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #include <linux/nsproxy.h>
 #include <net/net_namespace.h>
@@ -84,7 +85,7 @@ struct ppp_file {
 	struct sk_buff_head xq;		/* pppd transmit queue */
 	struct sk_buff_head rq;		/* receive queue for pppd */
 	wait_queue_head_t rwait;	/* for poll on reading /dev/ppp */
-	atomic_t	refcnt;		/* # refs (incl /dev/ppp attached) */
+	refcount_t	refcnt;		/* # refs (incl /dev/ppp attached) */
 	int		hdrlen;		/* space to leave for headers */
 	int		index;		/* interface unit / channel number */
 	int		dead;		/* unit/channel has been shut down */
@@ -408,7 +409,7 @@ static int ppp_release(struct inode *unused, struct file *file)
 				unregister_netdevice(ppp->dev);
 			rtnl_unlock();
 		}
-		if (atomic_dec_and_test(&pf->refcnt)) {
+		if (refcount_dec_and_test(&pf->refcnt)) {
 			switch (pf->kind) {
 			case INTERFACE:
 				ppp_destroy_interface(PF_TO_PPP(pf));
@@ -881,7 +882,7 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		mutex_lock(&pn->all_ppp_mutex);
 		ppp = ppp_find_unit(pn, unit);
 		if (ppp) {
-			atomic_inc(&ppp->file.refcnt);
+			refcount_inc(&ppp->file.refcnt);
 			file->private_data = &ppp->file;
 			err = 0;
 		}
@@ -896,7 +897,7 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		spin_lock_bh(&pn->all_channels_lock);
 		chan = ppp_find_channel(pn, unit);
 		if (chan) {
-			atomic_inc(&chan->file.refcnt);
+			refcount_inc(&chan->file.refcnt);
 			file->private_data = &chan->file;
 			err = 0;
 		}
@@ -1348,7 +1349,7 @@ static int ppp_dev_init(struct net_device *dev)
 	 * that ppp_destroy_interface() won't run before the device gets
 	 * unregistered.
 	 */
-	atomic_inc(&ppp->file.refcnt);
+	refcount_inc(&ppp->file.refcnt);
 
 	return 0;
 }
@@ -1377,7 +1378,7 @@ static void ppp_dev_priv_destructor(struct net_device *dev)
 	struct ppp *ppp;
 
 	ppp = netdev_priv(dev);
-	if (atomic_dec_and_test(&ppp->file.refcnt))
+	if (refcount_dec_and_test(&ppp->file.refcnt))
 		ppp_destroy_interface(ppp);
 }
 
@@ -2676,7 +2677,7 @@ ppp_unregister_channel(struct ppp_channel *chan)
 
 	pch->file.dead = 1;
 	wake_up_interruptible(&pch->file.rwait);
-	if (atomic_dec_and_test(&pch->file.refcnt))
+	if (refcount_dec_and_test(&pch->file.refcnt))
 		ppp_destroy_channel(pch);
 }
 
@@ -3046,7 +3047,7 @@ init_ppp_file(struct ppp_file *pf, int kind)
 	pf->kind = kind;
 	skb_queue_head_init(&pf->xq);
 	skb_queue_head_init(&pf->rq);
-	atomic_set(&pf->refcnt, 1);
+	refcount_set(&pf->refcnt, 1);
 	init_waitqueue_head(&pf->rwait);
 }
 
@@ -3164,7 +3165,7 @@ ppp_connect_channel(struct channel *pch, int unit)
 	list_add_tail(&pch->clist, &ppp->channels);
 	++ppp->n_channels;
 	pch->ppp = ppp;
-	atomic_inc(&ppp->file.refcnt);
+	refcount_inc(&ppp->file.refcnt);
 	ppp_unlock(ppp);
 	ret = 0;
 
@@ -3195,7 +3196,7 @@ ppp_disconnect_channel(struct channel *pch)
 		if (--ppp->n_channels == 0)
 			wake_up_interruptible(&ppp->file.rwait);
 		ppp_unlock(ppp);
-		if (atomic_dec_and_test(&ppp->file.refcnt))
+		if (refcount_dec_and_test(&ppp->file.refcnt))
 			ppp_destroy_interface(ppp);
 		err = 0;
 	}
-- 
2.7.4
