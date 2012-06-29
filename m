From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next] caif-hsi: Fix merge issues.
Date: Fri, 29 Jun 2012 08:36:20 +0200
Message-ID: <1340951780-27406-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65293 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab2F2GhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 02:37:01 -0400
Received: by lbbgm6 with SMTP id gm6so4195662lbb.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 23:36:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

=46ix the failing merge in net-next by reverting the last
net-next merge for caif_hsi.c and then merge in the commit:
"caif-hsi: Bugfix - Piggyback'ed embedded CAIF frame lost"
from the net repository.=20

The commit:"caif-hsi: Add missing return in error path" from
net repository was dropped, as it changed code previously removed in th=
e=20
net-next repository.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

---
Hi Dave,

>Sjur please send me any necessary fixups and please be more mindful in
>the future of the incredible merge pain you put me through when you
>have such fundamentally overlapping changes like that and don't
>provide me with a sample merge resolution like other people do.

Yes this merge went really bad, sorry for the pain I have caused you!
I'll try to provide you with merge instruction or sample merge
resolutions in the future if there are conflicts.

Regards,
Sjur


---
 drivers/net/caif/caif_hsi.c |   72 ++++++++++++++++-------------------=
--------
 1 files changed, 27 insertions(+), 45 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 087eb83..0def8b3 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1131,51 +1131,7 @@ static void cfhsi_setup(struct net_device *dev)
 	cfhsi->cfdev.use_stx =3D false;
 	cfhsi->cfdev.use_fcs =3D false;
 	cfhsi->ndev =3D dev;
-}
-
-int cfhsi_probe(struct platform_device *pdev)
-{
-	struct cfhsi_ops *(*get_ops)(void);
-	struct cfhsi *cfhsi =3D NULL;
-	struct net_device *ndev;
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
-	get_ops =3D symbol_get(cfhsi_get_ops);
-	if (!get_ops) {
-		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
-		return -ENODEV;
-	}
-
-	/* Assign the HSI device. */
-	cfhsi->ops =3D (*get_ops)();
-	if (!cfhsi->ops) {
-		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
-		goto err;
-	}
-
-	/* Assign the driver to this HSI device. */
-	cfhsi->ops->cb_ops =3D &cfhsi->cb_ops;
-	res =3D register_netdevice(ndev);
-	if (res) {
-		dev_err(&ndev->dev, "%s: Registration error: %d.\n",
-			__func__, res);
-		free_netdev(ndev);
-	}
-	/* Add CAIF HSI device to list. */
-	list_add_tail(&cfhsi->list, &cfhsi_list);
-
-	return res;
-err:
-	symbol_put(cfhsi_get_ops);
-	return -ENODEV;
+	cfhsi->cfg =3D hsi_default_config;
 }
=20
 static int cfhsi_open(struct net_device *ndev)
@@ -1454,6 +1410,7 @@ static int caif_hsi_newlink(struct net *src_net, =
struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
 	struct cfhsi *cfhsi =3D NULL;
+	struct cfhsi_ops *(*get_ops)(void);
=20
 	ASSERT_RTNL();
=20
@@ -1461,7 +1418,32 @@ static int caif_hsi_newlink(struct net *src_net,=
 struct net_device *dev,
 	cfhsi_netlink_parms(data, cfhsi);
 	dev_net_set(cfhsi->ndev, src_net);
=20
+	get_ops =3D symbol_get(cfhsi_get_ops);
+	if (!get_ops) {
+		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
+		return -ENODEV;
+	}
+
+	/* Assign the HSI device. */
+	cfhsi->ops =3D (*get_ops)();
+	if (!cfhsi->ops) {
+		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
+		goto err;
+	}
+
+	/* Assign the driver to this HSI device. */
+	cfhsi->ops->cb_ops =3D &cfhsi->cb_ops;
+	if (register_netdevice(dev)) {
+		pr_warn("%s: caif_hsi device registration failed\n", __func__);
+		goto err;
+	}
+	/* Add CAIF HSI device to list. */
+	list_add_tail(&cfhsi->list, &cfhsi_list);
+
 	return 0;
+err:
+	symbol_put(cfhsi_get_ops);
+	return -ENODEV;
 }
=20
 static struct rtnl_link_ops caif_hsi_link_ops __read_mostly =3D {
--=20
1.7.5.4
