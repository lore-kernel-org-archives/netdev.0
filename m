From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net] ppp: fix device unregistration upon netns deletion
Date: Thu, 13 Aug 2015 15:18:25 +0200
Message-ID: <d2b0363f2f54f5681c4c632b18617feb9ec0d8a9.1439469593.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:34608 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752012AbbHMN0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 09:26:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP devices may get automatically unregistered when their network
namespace is getting removed. This happens if the ppp control plane
daemon (e.g. pppd) exits while it is the last user of this namespace.

This leads to several races:

  * ppp_exit_net() may destroy the per namespace idr (pn->units_idr)
    before all file descriptors were released. Successive ppp_release()
    calls may then cleanup PPP devices with ppp_shutdown_interface() and
    try to use the already destroyed idr.

  * Automatic device unregistration may also happen before the
    ppp_release() call for that device gets executed. Once called on
    the file owning the device, ppp_release() will then clean it up and
    try to unregister it a second time.

To fix these issues, operations defined in ppp_shutdown_interface() are
moved to the PPP device's ndo_uninit() callback. This allows PPP
devices to be properly cleaned up by unregister_netdev() and friends.
So checking for ppp->owner is now an accurate test to decide if a PPP
device should be unregistered.

Setting ppp->owner is done in ppp_create_interface(), before device
registration, in order to avoid unprotected modification of this field.

Finally ppp_exit_net() now starts by unregistering all remaining PPP
devices to ensure that none will get unregistered after the call to
idr_destroy().

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 79 +++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 9d15566..1dc478a 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -269,9 +269,9 @@ static void ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound);
 static void ppp_ccp_closed(struct ppp *ppp);
 static struct compressor *find_compressor(int type);
 static void ppp_get_stats(struct ppp *ppp, struct ppp_stats *st);
-static struct ppp *ppp_create_interface(struct net *net, int unit, int *retp);
+static struct ppp *ppp_create_interface(struct net *net, int unit,
+					struct file *file, int *retp);
 static void init_ppp_file(struct ppp_file *pf, int kind);
-static void ppp_shutdown_interface(struct ppp *ppp);
 static void ppp_destroy_interface(struct ppp *ppp);
 static struct ppp *ppp_find_unit(struct ppp_net *pn, int unit);
 static struct channel *ppp_find_channel(struct ppp_net *pn, int unit);
@@ -392,8 +392,10 @@ static int ppp_release(struct inode *unused, struct file *file)
 		file->private_data = NULL;
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
+			rtnl_lock();
 			if (file == ppp->owner)
-				ppp_shutdown_interface(ppp);
+				unregister_netdevice(ppp->dev);
+			rtnl_unlock();
 		}
 		if (atomic_dec_and_test(&pf->refcnt)) {
 			switch (pf->kind) {
@@ -593,8 +595,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		mutex_lock(&ppp_mutex);
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
+			rtnl_lock();
 			if (file == ppp->owner)
-				ppp_shutdown_interface(ppp);
+				unregister_netdevice(ppp->dev);
+			rtnl_unlock();
 		}
 		if (atomic_long_read(&file->f_count) < 2) {
 			ppp_release(NULL, file);
@@ -838,11 +842,10 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		/* Create a new ppp unit */
 		if (get_user(unit, p))
 			break;
-		ppp = ppp_create_interface(net, unit, &err);
+		ppp = ppp_create_interface(net, unit, file, &err);
 		if (!ppp)
 			break;
 		file->private_data = &ppp->file;
-		ppp->owner = file;
 		err = -EFAULT;
 		if (put_user(ppp->file.index, p))
 			break;
@@ -916,6 +919,17 @@ static __net_init int ppp_init_net(struct net *net)
 static __net_exit void ppp_exit_net(struct net *net)
 {
 	struct ppp_net *pn = net_generic(net, ppp_net_id);
+	struct ppp *ppp;
+	LIST_HEAD(list);
+	int id;
+
+	rtnl_lock();
+	idr_for_each_entry(&pn->units_idr, ppp, id) {
+		unregister_netdevice_queue(ppp->dev, &list);
+	}
+
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
 
 	idr_destroy(&pn->units_idr);
 }
@@ -1088,8 +1102,28 @@ static int ppp_dev_init(struct net_device *dev)
 	return 0;
 }
 
+static void ppp_dev_uninit(struct net_device *dev)
+{
+	struct ppp *ppp = netdev_priv(dev);
+	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
+
+	ppp_lock(ppp);
+	ppp->closing = 1;
+	ppp_unlock(ppp);
+
+	mutex_lock(&pn->all_ppp_mutex);
+	unit_put(&pn->units_idr, ppp->file.index);
+	mutex_unlock(&pn->all_ppp_mutex);
+
+	ppp->owner = NULL;
+
+	ppp->file.dead = 1;
+	wake_up_interruptible(&ppp->file.rwait);
+}
+
 static const struct net_device_ops ppp_netdev_ops = {
 	.ndo_init	 = ppp_dev_init,
+	.ndo_uninit      = ppp_dev_uninit,
 	.ndo_start_xmit  = ppp_start_xmit,
 	.ndo_do_ioctl    = ppp_net_ioctl,
 	.ndo_get_stats64 = ppp_get_stats64,
@@ -2667,8 +2701,8 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
  * or if there is already a unit with the requested number.
  * unit == -1 means allocate a new number.
  */
-static struct ppp *
-ppp_create_interface(struct net *net, int unit, int *retp)
+static struct ppp *ppp_create_interface(struct net *net, int unit,
+					struct file *file, int *retp)
 {
 	struct ppp *ppp;
 	struct ppp_net *pn;
@@ -2688,6 +2722,7 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	ppp->mru = PPP_MRU;
 	init_ppp_file(&ppp->file, INTERFACE);
 	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
+	ppp->owner = file;
 	for (i = 0; i < NUM_NP; ++i)
 		ppp->npmode[i] = NPMODE_PASS;
 	INIT_LIST_HEAD(&ppp->channels);
@@ -2776,34 +2811,6 @@ init_ppp_file(struct ppp_file *pf, int kind)
 }
 
 /*
- * Take down a ppp interface unit - called when the owning file
- * (the one that created the unit) is closed or detached.
- */
-static void ppp_shutdown_interface(struct ppp *ppp)
-{
-	struct ppp_net *pn;
-
-	pn = ppp_pernet(ppp->ppp_net);
-	mutex_lock(&pn->all_ppp_mutex);
-
-	/* This will call dev_close() for us. */
-	ppp_lock(ppp);
-	if (!ppp->closing) {
-		ppp->closing = 1;
-		ppp_unlock(ppp);
-		unregister_netdev(ppp->dev);
-		unit_put(&pn->units_idr, ppp->file.index);
-	} else
-		ppp_unlock(ppp);
-
-	ppp->file.dead = 1;
-	ppp->owner = NULL;
-	wake_up_interruptible(&ppp->file.rwait);
-
-	mutex_unlock(&pn->all_ppp_mutex);
-}
-
-/*
  * Free the memory used by a ppp unit.  This is only called once
  * there are no channels connected to the unit and no file structs
  * that reference the unit.
-- 
2.5.0
