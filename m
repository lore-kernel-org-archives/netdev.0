From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH v4 net-next 1/2] ppp: define reusable device creation
 functions
Date: Thu, 28 Apr 2016 17:55:28 +0200
Message-ID: <20160428155528.GA24349@alphalink.fr>
References: <cover.1461854990.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	walter harms <wharms@bfs.de>
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1461854990.git.g.nault@alphalink.fr>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move PPP device initialisation and registration out of
ppp_create_interface().
This prepares code for device registration with rtnetlink.

While there, simplify the prototype of ppp_create_interface():

  * Since ppp_dev_configure() takes care of setting file->private_data,
    there's no need to return a ppp structure to ppp_unattached_ioctl()
    anymore.

  * The unit parameter is made read/write so that ppp_create_interface()
    can tell which unit number has been assigned.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 drivers/net/ppp/ppp_generic.c | 206 ++++++++++++++++++++++++------------------
 1 file changed, 118 insertions(+), 88 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f572b31..59077c8 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -183,6 +183,11 @@ struct channel {
 #endif /* CONFIG_PPP_MULTILINK */
 };
 
+struct ppp_config {
+	struct file *file;
+	s32 unit;
+};
+
 /*
  * SMP locking issues:
  * Both the ppp.rlock and ppp.wlock locks protect the ppp.channels
@@ -269,8 +274,7 @@ static void ppp_ccp_peek(struct ppp *ppp, struct sk_buff *skb, int inbound);
 static void ppp_ccp_closed(struct ppp *ppp);
 static struct compressor *find_compressor(int type);
 static void ppp_get_stats(struct ppp *ppp, struct ppp_stats *st);
-static struct ppp *ppp_create_interface(struct net *net, int unit,
-					struct file *file, int *retp);
+static int ppp_create_interface(struct net *net, struct file *file, int *unit);
 static void init_ppp_file(struct ppp_file *pf, int kind);
 static void ppp_destroy_interface(struct ppp *ppp);
 static struct ppp *ppp_find_unit(struct ppp_net *pn, int unit);
@@ -853,12 +857,12 @@ static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
 		/* Create a new ppp unit */
 		if (get_user(unit, p))
 			break;
-		ppp = ppp_create_interface(net, unit, file, &err);
-		if (!ppp)
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
@@ -960,6 +964,94 @@ static struct pernet_operations ppp_net_ops = {
 	.size = sizeof(struct ppp_net),
 };
 
+static int ppp_unit_register(struct ppp *ppp, int unit)
+{
+	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
+	int ret;
+
+	mutex_lock(&pn->all_ppp_mutex);
+
+	if (unit < 0) {
+		ret = unit_get(&pn->units_idr, ppp);
+		if (ret < 0)
+			goto err;
+	} else {
+		/* Caller asked for a specific unit number. Fail with -EEXIST
+		 * if unavailable. For backward compatibility, return -EEXIST
+		 * too if idr allocation fails; this makes pppd retry without
+		 * requesting a specific unit number.
+		 */
+		if (unit_find(&pn->units_idr, unit)) {
+			ret = -EEXIST;
+			goto err;
+		}
+		ret = unit_set(&pn->units_idr, ppp, unit);
+		if (ret < 0) {
+			/* Rewrite error for backward compatibility */
+			ret = -EEXIST;
+			goto err;
+		}
+	}
+	ppp->file.index = ret;
+
+	snprintf(ppp->dev->name, IFNAMSIZ, "ppp%i", ppp->file.index);
+
+	ret = register_netdevice(ppp->dev);
+	if (ret < 0)
+		goto err_unit;
+
+	atomic_inc(&ppp_unit_count);
+
+	mutex_unlock(&pn->all_ppp_mutex);
+
+	return 0;
+
+err_unit:
+	unit_put(&pn->units_idr, ppp->file.index);
+err:
+	mutex_unlock(&pn->all_ppp_mutex);
+
+	return ret;
+}
+
+static int ppp_dev_configure(struct net *src_net, struct net_device *dev,
+			     const struct ppp_config *conf)
+{
+	struct ppp *ppp = netdev_priv(dev);
+	int indx;
+	int err;
+
+	ppp->dev = dev;
+	ppp->ppp_net = src_net;
+	ppp->mru = PPP_MRU;
+	ppp->owner = conf->file;
+
+	init_ppp_file(&ppp->file, INTERFACE);
+	ppp->file.hdrlen = PPP_HDRLEN - 2; /* don't count proto bytes */
+
+	for (indx = 0; indx < NUM_NP; ++indx)
+		ppp->npmode[indx] = NPMODE_PASS;
+	INIT_LIST_HEAD(&ppp->channels);
+	spin_lock_init(&ppp->rlock);
+	spin_lock_init(&ppp->wlock);
+#ifdef CONFIG_PPP_MULTILINK
+	ppp->minseq = -1;
+	skb_queue_head_init(&ppp->mrq);
+#endif /* CONFIG_PPP_MULTILINK */
+#ifdef CONFIG_PPP_FILTER
+	ppp->pass_filter = NULL;
+	ppp->active_filter = NULL;
+#endif /* CONFIG_PPP_FILTER */
+
+	err = ppp_unit_register(ppp, conf->unit);
+	if (err < 0)
+		return err;
+
+	conf->file->private_data = &ppp->file;
+
+	return 0;
+}
+
 #define PPP_MAJOR	108
 
 /* Called at boot time if ppp is compiled into the kernel,
@@ -2732,102 +2824,40 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
  * or if there is already a unit with the requested number.
  * unit == -1 means allocate a new number.
  */
-static struct ppp *ppp_create_interface(struct net *net, int unit,
-					struct file *file, int *retp)
+static int ppp_create_interface(struct net *net, struct file *file, int *unit)
 {
+	struct ppp_config conf = {
+		.file = file,
+		.unit = *unit,
+	};
+	struct net_device *dev;
 	struct ppp *ppp;
-	struct ppp_net *pn;
-	struct net_device *dev = NULL;
-	int ret = -ENOMEM;
-	int i;
+	int err;
 
 	dev = alloc_netdev(sizeof(struct ppp), "", NET_NAME_ENUM, ppp_setup);
-	if (!dev)
-		goto out1;
-
-	pn = ppp_pernet(net);
-
-	ppp = netdev_priv(dev);
-	ppp->dev = dev;
-	ppp->mru = PPP_MRU;
-	init_ppp_file(&ppp->file, INTERFACE);
-	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
-	ppp->owner = file;
-	for (i = 0; i < NUM_NP; ++i)
-		ppp->npmode[i] = NPMODE_PASS;
-	INIT_LIST_HEAD(&ppp->channels);
-	spin_lock_init(&ppp->rlock);
-	spin_lock_init(&ppp->wlock);
-#ifdef CONFIG_PPP_MULTILINK
-	ppp->minseq = -1;
-	skb_queue_head_init(&ppp->mrq);
-#endif /* CONFIG_PPP_MULTILINK */
-#ifdef CONFIG_PPP_FILTER
-	ppp->pass_filter = NULL;
-	ppp->active_filter = NULL;
-#endif /* CONFIG_PPP_FILTER */
-
-	/*
-	 * drum roll: don't forget to set
-	 * the net device is belong to
-	 */
+	if (!dev) {
+		err = -ENOMEM;
+		goto err;
+	}
 	dev_net_set(dev, net);
 
 	rtnl_lock();
-	mutex_lock(&pn->all_ppp_mutex);
-
-	if (unit < 0) {
-		unit = unit_get(&pn->units_idr, ppp);
-		if (unit < 0) {
-			ret = unit;
-			goto out2;
-		}
-	} else {
-		ret = -EEXIST;
-		if (unit_find(&pn->units_idr, unit))
-			goto out2; /* unit already exists */
-		/*
-		 * if caller need a specified unit number
-		 * lets try to satisfy him, otherwise --
-		 * he should better ask us for new unit number
-		 *
-		 * NOTE: yes I know that returning EEXIST it's not
-		 * fair but at least pppd will ask us to allocate
-		 * new unit in this case so user is happy :)
-		 */
-		unit = unit_set(&pn->units_idr, ppp, unit);
-		if (unit < 0)
-			goto out2;
-	}
-
-	/* Initialize the new ppp unit */
-	ppp->file.index = unit;
-	sprintf(dev->name, "ppp%d", unit);
 
-	ret = register_netdevice(dev);
-	if (ret != 0) {
-		unit_put(&pn->units_idr, unit);
-		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
-			   dev->name, ret);
-		goto out2;
-	}
-
-	ppp->ppp_net = net;
+	err = ppp_dev_configure(net, dev, &conf);
+	if (err < 0)
+		goto err_dev;
+	ppp = netdev_priv(dev);
+	*unit = ppp->file.index;
 
-	atomic_inc(&ppp_unit_count);
-	mutex_unlock(&pn->all_ppp_mutex);
 	rtnl_unlock();
 
-	*retp = 0;
-	return ppp;
+	return 0;
 
-out2:
-	mutex_unlock(&pn->all_ppp_mutex);
+err_dev:
 	rtnl_unlock();
 	free_netdev(dev);
-out1:
-	*retp = ret;
-	return NULL;
+err:
+	return err;
 }
 
 /*
-- 
2.8.1

