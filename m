From: sjur.brandeland@stericsson.com
Subject: [net-next 09/11] caif-hsi: Add rtnl support
Date: Mon, 25 Jun 2012 19:49:41 +0200
Message-ID: <1340646583-21059-10-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57421 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab2FYRuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:08 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so3429750bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:07 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Add RTNL support for managing the caif hsi interface.
The HSI HW interface is no longer registering as a device,
instead we use symbol_get to get hold of the HSI API.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  226 ++++++++++++++++++++++++++---------=
--------
 include/net/caif/caif_hsi.h |   21 ++++-
 2 files changed, 157 insertions(+), 90 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index d80759e..a14f85c 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -20,7 +20,7 @@
 #include <linux/sched.h>
 #include <linux/if_arp.h>
 #include <linux/timer.h>
-#include <linux/rtnetlink.h>
+#include <net/rtnetlink.h>
 #include <linux/pkt_sched.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/caif_hsi.h>
@@ -79,7 +79,6 @@ MODULE_PARM_DESC(hsi_low_threshold, "HSI high thresho=
ld (FLOW ON).");
 #define HIGH_WATER_MARK  hsi_high_threshold
=20
 static LIST_HEAD(cfhsi_list);
-static spinlock_t cfhsi_list_lock;
=20
 static void cfhsi_inactivity_tout(unsigned long arg)
 {
@@ -1148,42 +1147,6 @@ static void cfhsi_setup(struct net_device *dev)
 	cfhsi->ndev =3D dev;
 }
=20
-int cfhsi_probe(struct platform_device *pdev)
-{
-	struct cfhsi *cfhsi =3D NULL;
-	struct net_device *ndev;
-
-	int res;
-
-	ndev =3D alloc_netdev(sizeof(struct cfhsi), "cfhsi%d", cfhsi_setup);
-	if (!ndev)
-		return -ENODEV;
-
-	cfhsi =3D netdev_priv(ndev);
-	cfhsi->ndev =3D ndev;
-	cfhsi->pdev =3D pdev;
-
-	/* Assign the HSI device. */
-	cfhsi->dev =3D pdev->dev.platform_data;
-
-	/* Assign the driver to this HSI device. */
-	cfhsi->dev->drv =3D &cfhsi->drv;
-
-	/* Register network device. */
-	res =3D register_netdev(ndev);
-	if (res) {
-		dev_err(&ndev->dev, "%s: Registration error: %d.\n",
-			__func__, res);
-		free_netdev(ndev);
-	}
-	/* Add CAIF HSI device to list. */
-	spin_lock(&cfhsi_list_lock);
-	list_add_tail(&cfhsi->list, &cfhsi_list);
-	spin_unlock(&cfhsi_list_lock);
-
-	return res;
-}
-
 static int cfhsi_open(struct net_device *ndev)
 {
 	struct cfhsi *cfhsi =3D netdev_priv(ndev);
@@ -1364,85 +1327,170 @@ static int cfhsi_close(struct net_device *ndev=
)
 	return 0;
 }
=20
+static void cfhsi_uninit(struct net_device *dev)
+{
+	struct cfhsi *cfhsi =3D netdev_priv(dev);
+	ASSERT_RTNL();
+	symbol_put(cfhsi_get_device);
+	list_del(&cfhsi->list);
+}
+
 static const struct net_device_ops cfhsi_ops =3D {
+	.ndo_uninit =3D cfhsi_uninit,
 	.ndo_open =3D cfhsi_open,
 	.ndo_stop =3D cfhsi_close,
 	.ndo_start_xmit =3D cfhsi_xmit
 };
=20
-int cfhsi_remove(struct platform_device *pdev)
+static void cfhsi_netlink_parms(struct nlattr *data[], struct cfhsi *c=
fhsi)
 {
-	struct list_head *list_node;
-	struct list_head *n;
-	struct cfhsi *cfhsi =3D NULL;
-	struct cfhsi_dev *dev;
+	int i;
=20
-	dev =3D (struct cfhsi_dev *)pdev->dev.platform_data;
-	spin_lock(&cfhsi_list_lock);
-	list_for_each_safe(list_node, n, &cfhsi_list) {
-		cfhsi =3D list_entry(list_node, struct cfhsi, list);
-		/* Find the corresponding device. */
-		if (cfhsi->dev =3D=3D dev) {
-			/* Remove from list. */
-			list_del(list_node);
-			spin_unlock(&cfhsi_list_lock);
-			return 0;
-		}
+	if (!data) {
+		pr_debug("no params data found\n");
+		return;
 	}
-	spin_unlock(&cfhsi_list_lock);
-	return -ENODEV;
+
+	i =3D __IFLA_CAIF_HSI_INACTIVITY_TOUT;
+	if (data[i])
+		inactivity_timeout =3D nla_get_u32(data[i]);
+
+	i =3D __IFLA_CAIF_HSI_AGGREGATION_TOUT;
+	if (data[i])
+		aggregation_timeout =3D nla_get_u32(data[i]);
+
+	i =3D __IFLA_CAIF_HSI_HEAD_ALIGN;
+	if (data[i])
+		hsi_head_align =3D nla_get_u32(data[i]);
+
+	i =3D __IFLA_CAIF_HSI_TAIL_ALIGN;
+	if (data[i])
+		hsi_tail_align =3D nla_get_u32(data[i]);
+
+	i =3D __IFLA_CAIF_HSI_QHIGH_WATERMARK;
+	if (data[i])
+		hsi_high_threshold =3D nla_get_u32(data[i]);
+}
+
+static int caif_hsi_changelink(struct net_device *dev, struct nlattr *=
tb[],
+				struct nlattr *data[])
+{
+	cfhsi_netlink_parms(data, netdev_priv(dev));
+	netdev_state_change(dev);
+	return 0;
 }
=20
-struct platform_driver cfhsi_plat_drv =3D {
-	.probe =3D cfhsi_probe,
-	.remove =3D cfhsi_remove,
-	.driver =3D {
-		   .name =3D "cfhsi",
-		   .owner =3D THIS_MODULE,
-		   },
+static const struct nla_policy caif_hsi_policy[__IFLA_CAIF_HSI_MAX + 1=
] =3D {
+	[__IFLA_CAIF_HSI_INACTIVITY_TOUT] =3D { .type =3D NLA_U32, .len =3D 4=
 },
+	[__IFLA_CAIF_HSI_AGGREGATION_TOUT] =3D { .type =3D NLA_U32, .len =3D =
4 },
+	[__IFLA_CAIF_HSI_HEAD_ALIGN] =3D { .type =3D NLA_U32, .len =3D 4 },
+	[__IFLA_CAIF_HSI_TAIL_ALIGN] =3D { .type =3D NLA_U32, .len =3D 4 },
+	[__IFLA_CAIF_HSI_QHIGH_WATERMARK] =3D { .type =3D NLA_U32, .len =3D 4=
 },
+	[__IFLA_CAIF_HSI_QLOW_WATERMARK] =3D { .type =3D NLA_U32, .len =3D 4 =
},
 };
=20
-static void __exit cfhsi_exit_module(void)
+static size_t caif_hsi_get_size(const struct net_device *dev)
+{
+	int i;
+	size_t s =3D 0;
+	for (i =3D __IFLA_CAIF_HSI_UNSPEC + 1; i < __IFLA_CAIF_HSI_MAX; i++)
+		s +=3D nla_total_size(caif_hsi_policy[i].len);
+	return s;
+}
+
+static int caif_hsi_fill_info(struct sk_buff *skb, const struct net_de=
vice *dev)
+{
+	if (nla_put_u32(skb, __IFLA_CAIF_HSI_INACTIVITY_TOUT,
+			inactivity_timeout) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_AGGREGATION_TOUT,
+			aggregation_timeout) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_HEAD_ALIGN, hsi_head_align) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_TAIL_ALIGN, hsi_tail_align) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_QHIGH_WATERMARK,
+			hsi_high_threshold) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_QLOW_WATERMARK,
+			hsi_low_threshold))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
+static int caif_hsi_newlink(struct net *src_net, struct net_device *de=
v,
+			  struct nlattr *tb[], struct nlattr *data[])
 {
-	struct list_head *list_node;
-	struct list_head *n;
 	struct cfhsi *cfhsi =3D NULL;
+	struct platform_device *(*get_dev)(void);
=20
-	spin_lock(&cfhsi_list_lock);
-	list_for_each_safe(list_node, n, &cfhsi_list) {
-		cfhsi =3D list_entry(list_node, struct cfhsi, list);
+	ASSERT_RTNL();
+
+	cfhsi =3D netdev_priv(dev);
+	cfhsi_netlink_parms(data, cfhsi);
+	dev_net_set(cfhsi->ndev, src_net);
+
+	get_dev =3D symbol_get(cfhsi_get_device);
+	if (!get_dev) {
+		pr_err("%s: failed to get the cfhsi device symbol\n", __func__);
+		return -ENODEV;
+	}
+
+	/* Assign the HSI device. */
+	cfhsi->pdev =3D (*get_dev)();
+	if (!cfhsi->pdev) {
+		pr_err("%s: failed to get the cfhsi device\n", __func__);
+		goto err;
+	}
=20
-		/* Remove from list. */
-		list_del(list_node);
-		spin_unlock(&cfhsi_list_lock);
+	/* Assign the HSI device. */
+	cfhsi->dev =3D cfhsi->pdev->dev.platform_data;
+
+	/* Assign the driver to this HSI device. */
+	cfhsi->dev->drv =3D &cfhsi->drv;
=20
-		unregister_netdevice(cfhsi->ndev);
+	if (register_netdevice(dev)) {
+		pr_warn("%s: device rtml registration failed\n", __func__);
+		goto err;
=20
-		spin_lock(&cfhsi_list_lock);
 	}
-	spin_unlock(&cfhsi_list_lock);
+	/* Add CAIF HSI device to list. */
+	list_add_tail(&cfhsi->list, &cfhsi_list);
=20
-	/* Unregister platform driver. */
-	platform_driver_unregister(&cfhsi_plat_drv);
+	return 0;
+err:
+	symbol_put(cfhsi_get_device);
+	return -ENODEV;
 }
=20
-static int __init cfhsi_init_module(void)
+static struct rtnl_link_ops caif_hsi_link_ops __read_mostly =3D {
+	.kind		=3D "cfhsi",
+	.priv_size	=3D sizeof(struct cfhsi),
+	.setup		=3D cfhsi_setup,
+	.maxtype	=3D __IFLA_CAIF_HSI_MAX,
+	.policy	=3D caif_hsi_policy,
+	.newlink	=3D caif_hsi_newlink,
+	.changelink	=3D caif_hsi_changelink,
+	.get_size	=3D caif_hsi_get_size,
+	.fill_info	=3D caif_hsi_fill_info,
+};
+
+static void __exit cfhsi_exit_module(void)
 {
-	int result;
+	struct list_head *list_node;
+	struct list_head *n;
+	struct cfhsi *cfhsi;
=20
-	/* Initialize spin lock. */
-	spin_lock_init(&cfhsi_list_lock);
+	rtnl_link_unregister(&caif_hsi_link_ops);
=20
-	/* Register platform driver. */
-	result =3D platform_driver_register(&cfhsi_plat_drv);
-	if (result) {
-		printk(KERN_ERR "Could not register platform HSI driver: %d.\n",
-			result);
-		goto err_dev_register;
+	rtnl_lock();
+	list_for_each_safe(list_node, n, &cfhsi_list) {
+		cfhsi =3D list_entry(list_node, struct cfhsi, list);
+		unregister_netdev(cfhsi->ndev);
 	}
+	rtnl_unlock();
+}
=20
- err_dev_register:
-	return result;
+static int __init cfhsi_init_module(void)
+{
+	return rtnl_link_register(&caif_hsi_link_ops);
 }
=20
 module_init(cfhsi_init_module);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 439dadc..a77b2bd 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -170,7 +170,26 @@ struct cfhsi {
=20
 	unsigned long bits;
 };
-
 extern struct platform_driver cfhsi_driver;
=20
+/**
+ * enum ifla_caif_hsi - CAIF HSI NetlinkRT parameters.
+ * @IFLA_CAIF_HSI_INACTIVITY_TOUT: Inactivity timeout before
+ *			taking the HSI wakeline down, in milliseconds.
+ * When using RT Netlink to create, destroy or configure a CAIF HSI in=
terface,
+ * enum ifla_caif_hsi is used to specify the configuration attributes.
+ */
+enum ifla_caif_hsi {
+	__IFLA_CAIF_HSI_UNSPEC,
+	__IFLA_CAIF_HSI_INACTIVITY_TOUT,
+	__IFLA_CAIF_HSI_AGGREGATION_TOUT,
+	__IFLA_CAIF_HSI_HEAD_ALIGN,
+	__IFLA_CAIF_HSI_TAIL_ALIGN,
+	__IFLA_CAIF_HSI_QHIGH_WATERMARK,
+	__IFLA_CAIF_HSI_QLOW_WATERMARK,
+	__IFLA_CAIF_HSI_MAX
+};
+
+extern struct platform_device *cfhsi_get_device(void);
+
 #endif		/* CAIF_HSI_H_ */
--=20
1.7.5.4
