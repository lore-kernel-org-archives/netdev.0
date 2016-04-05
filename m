From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [RFC PATCH 1/6] ppp: simplify usage of ppp_create_interface()
Date: Tue, 5 Apr 2016 02:56:19 +0200
Message-ID: <ca1a344f9983dc1a823e2b7e1dca6f746ef17542.1459807527.git.g.nault@alphalink.fr>
References: <cover.1459807527.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:55796 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbcDEA4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 20:56:23 -0400
Content-Disposition: inline
In-Reply-To: <cover.1459807527.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set file->private_data inside ppp_create_interface() to avoid the need
for returning the new ppp structure to the caller.
Also, make the unit parameter read/write so that caller can still
retrieve the PPP unit number assigned to the interface.

Avoiding setting ->private_data in the caller will allow for pushing
ppp_mutex down when handling the PPPIOCNEWUNIT ioctl (as locking
ppp_mutex is required before setting ->private_data).

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 47 +++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f572b31..ec83b83 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -269,8 +269,7 @@ static void ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound);
 static void ppp_ccp_closed(struct ppp *ppp);
 static struct compressor *find_compressor(int type);
 static void ppp_get_stats(struct ppp *ppp, struct ppp_stats *st);
-static struct ppp *ppp_create_interface(struct net *net, int unit,
-					struct file *file, int *retp);
+static int ppp_create_interface(struct net *net, struct file *file, int *unit);
 static void init_ppp_file(struct ppp_file *pf, int kind);
 static void ppp_destroy_interface(struct ppp *ppp);
 static struct ppp *ppp_find_unit(struct ppp_net *pn, int unit);
@@ -853,12 +852,13 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		/* Create a new ppp unit */
 		if (get_user(unit, p))
 			break;
-		ppp = ppp_create_interface(net, unit, file, &err);
-		if (!ppp)
+
+		err = ppp_create_interface(net, file, &unit);
+		if (err < 0)
 			break;
-		file->private_data = &ppp->file;
+
 		err = -EFAULT;
-		if (put_user(ppp->file.index, p))
+		if (put_user(unit, p))
 			break;
 		err = 0;
 		break;
@@ -2732,8 +2732,7 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
  * or if there is already a unit with the requested number.
  * unit == -1 means allocate a new number.
  */
-static struct ppp *ppp_create_interface(struct net *net, int unit,
-					struct file *file, int *retp)
+static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 {
 	struct ppp *ppp;
 	struct ppp_net *pn;
@@ -2776,15 +2775,13 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
 	rtnl_lock();
 	mutex_lock(&pn->all_ppp_mutex);
 
-	if (unit < 0) {
-		unit = unit_get(&pn->units_idr, ppp);
-		if (unit < 0) {
-			ret = unit;
+	if (*unit < 0) {
+		ret = unit_get(&pn->units_idr, ppp);
+		if (ret < 0)
 			goto out2;
-		}
 	} else {
 		ret = -EEXIST;
-		if (unit_find(&pn->units_idr, unit))
+		if (unit_find(&pn->units_idr, *unit))
 			goto out2; /* unit already exists */
 		/*
 		 * if caller need a specified unit number
@@ -2795,39 +2792,41 @@ static struct ppp *ppp_create_interface(struct net *net, int unit,
 		 * fair but at least pppd will ask us to allocate
 		 * new unit in this case so user is happy :)
 		 */
-		unit = unit_set(&pn->units_idr, ppp, unit);
-		if (unit < 0)
+		ret = unit_set(&pn->units_idr, ppp, *unit);
+		if (ret < 0) {
+			ret = -EEXIST;
 			goto out2;
+		}
 	}
 
 	/* Initialize the new ppp unit */
-	ppp->file.index = unit;
-	sprintf(dev->name, "ppp%d", unit);
+	ppp->file.index = ret;
+	sprintf(dev->name, "ppp%d", ret);
 
 	ret = register_netdevice(dev);
 	if (ret != 0) {
-		unit_put(&pn->units_idr, unit);
+		unit_put(&pn->units_idr, ppp->file.index);
 		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
 			   dev->name, ret);
 		goto out2;
 	}
 
 	ppp->ppp_net = net;
-
+	file->private_data = &ppp->file;
+	*unit = ppp->file.index;
 	atomic_inc(&ppp_unit_count);
+
 	mutex_unlock(&pn->all_ppp_mutex);
 	rtnl_unlock();
 
-	*retp = 0;
-	return ppp;
+	return 0;
 
 out2:
 	mutex_unlock(&pn->all_ppp_mutex);
 	rtnl_unlock();
 	free_netdev(dev);
 out1:
-	*retp = ret;
-	return NULL;
+	return ret;
 }
 
 /*
-- 
2.8.0.rc3
