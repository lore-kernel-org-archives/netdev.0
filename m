From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm tree with the net tree
Date: Wed, 13 Jun 2012 15:27:51 +1000
Message-ID: <20120613152751.26274816833e07c29a63ba3d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__13_Jun_2012_15_27_51_+1000_DR7_44fyjw/fMp6i"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Roese <sr@denx.de>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, Viresh Kumar <viresh.kumar@st.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__13_Jun_2012_15_27_51_+1000_DR7_44fyjw/fMp6i
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm tree got a conflict in
drivers/net/ethernet/stmicro/stmmac/stmmac.h between commit 883ffd6e6411
("net: stmmac: Fix clock en-/disable calls") from the net tree and commit
"net/stmmac: remove conditional compilation of clk code" from the akpm
tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/eth=
ernet/stmicro/stmmac/stmmac.h
index dc20c56..900c5e6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -82,9 +82,7 @@ struct stmmac_priv {
 	struct stmmac_counters mmc;
 	struct dma_features dma_cap;
 	int hw_cap_support;
-#ifdef CONFIG_HAVE_CLK
 	struct clk *stmmac_clk;
-#endif
 	int clk_csr;
 	int synopsys_id;
 };
@@ -105,46 +103,6 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *de=
vice,
 				     struct plat_stmmacenet_data *plat_dat,
 				     void __iomem *addr);
=20
-#ifdef CONFIG_HAVE_CLK
-static inline int stmmac_clk_enable(struct stmmac_priv *priv)
-{
-	if (!IS_ERR(priv->stmmac_clk))
-		return clk_prepare_enable(priv->stmmac_clk);
-
-	return 0;
-}
-
-static inline void stmmac_clk_disable(struct stmmac_priv *priv)
-{
-	if (IS_ERR(priv->stmmac_clk))
-		return;
-
-	clk_disable_unprepare(priv->stmmac_clk);
-}
-static inline int stmmac_clk_get(struct stmmac_priv *priv)
-{
-	priv->stmmac_clk =3D clk_get(priv->device, NULL);
-
-	if (IS_ERR(priv->stmmac_clk))
-		return PTR_ERR(priv->stmmac_clk);
-
-	return 0;
-}
-#else
-static inline int stmmac_clk_enable(struct stmmac_priv *priv)
-{
-	return 0;
-}
-static inline void stmmac_clk_disable(struct stmmac_priv *priv)
-{
-}
-static inline int stmmac_clk_get(struct stmmac_priv *priv)
-{
-	return 0;
-}
-#endif /* CONFIG_HAVE_CLK */
-
-
 #ifdef CONFIG_STMMAC_PLATFORM
 extern struct platform_driver stmmac_pltfr_driver;
 static inline int stmmac_register_platform(void)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/ne=
t/ethernet/stmicro/stmmac/stmmac_main.c
index 590e95b..bb63678 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -28,6 +28,7 @@
 	https://bugzilla.stlinux.com/
 **************************************************************************=
*****/
=20
+#include <linux/clk.h>
 #include <linux/kernel.h>
 #include <linux/interrupt.h>
 #include <linux/ip.h>
@@ -165,12 +166,8 @@ static void stmmac_verify_args(void)
=20
 static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 {
-#ifdef CONFIG_HAVE_CLK
 	u32 clk_rate;
=20
-	if (IS_ERR(priv->stmmac_clk))
-		return;
-
 	clk_rate =3D clk_get_rate(priv->stmmac_clk);
=20
 	/* Platform provided default clk_csr would be assumed valid
@@ -192,7 +189,6 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 	   * we can not estimate the proper divider as it is not known
 	   * the frequency of clk_csr_i. So we do not change the default
 	   * divider. */
-#endif
 }
=20
 #if defined(STMMAC_XMIT_DEBUG) || defined(STMMAC_RX_DEBUG)
@@ -974,7 +970,7 @@ static int stmmac_open(struct net_device *dev)
 	} else
 		priv->tm->enable =3D 1;
 #endif
-	stmmac_clk_enable(priv);
+	clk_prepare_enable(priv->stmmac_clk);
=20
 	stmmac_check_ether_addr(priv);
=20
@@ -1078,7 +1074,7 @@ open_error:
 	if (priv->phydev)
 		phy_disconnect(priv->phydev);
=20
-	stmmac_clk_disable(priv);
+	clk_disable_unprepare(priv->stmmac_clk);
=20
 	return ret;
 }
@@ -1131,7 +1127,7 @@ static int stmmac_release(struct net_device *dev)
 #ifdef CONFIG_STMMAC_DEBUG_FS
 	stmmac_exit_fs();
 #endif
-	stmmac_clk_disable(priv);
+	clk_disable_unprepare(priv->stmmac_clk);
=20
 	return 0;
 }
@@ -1926,11 +1922,14 @@ struct stmmac_priv *stmmac_dvr_probe(struct device =
*device,
 	ret =3D register_netdev(ndev);
 	if (ret) {
 		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
-		goto error;
+		goto error_netdev_register;
 	}
=20
-	if (stmmac_clk_get(priv))
+	priv->stmmac_clk =3D clk_get(priv->device, NULL);
+	if (IS_ERR(priv->stmmac_clk)) {
 		pr_warning("%s: warning: cannot get CSR clock\n", __func__);
+		goto error_clk_get;
+	}
=20
 	/* If a specific clk_csr value is passed from the platform
 	 * this means that the CSR Clock Range selection cannot be
@@ -1948,15 +1947,17 @@ struct stmmac_priv *stmmac_dvr_probe(struct device =
*device,
 	if (ret < 0) {
 		pr_debug("%s: MDIO bus (id: %d) registration failed",
 			 __func__, priv->plat->bus_id);
-		goto error;
+		goto error_mdio_register;
 	}
=20
 	return priv;
=20
-error:
-	netif_napi_del(&priv->napi);
-
+error_mdio_register:
+	clk_put(priv->stmmac_clk);
+error_clk_get:
 	unregister_netdev(ndev);
+error_netdev_register:
+	netif_napi_del(&priv->napi);
 	free_netdev(ndev);
=20
 	return NULL;
@@ -2025,7 +2026,7 @@ int stmmac_suspend(struct net_device *ndev)
 	else {
 		stmmac_set_mac(priv->ioaddr, false);
 		/* Disable clock in case of PWM is off */
-		stmmac_clk_disable(priv);
+		clk_disable_unprepare(priv->stmmac_clk);
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 	return 0;
@@ -2050,7 +2051,7 @@ int stmmac_resume(struct net_device *ndev)
 		priv->hw->mac->pmt(priv->ioaddr, 0);
 	else
 		/* enable the clk prevously disabled */
-		stmmac_clk_enable(priv);
+		clk_prepare_enable(priv->stmmac_clk);
=20
 	netif_device_attach(ndev);
=20

--Signature=_Wed__13_Jun_2012_15_27_51_+1000_DR7_44fyjw/fMp6i
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJP2CTYAAoJEECxmPOUX5FE8t0QAINYkJZsEEUDjmaSYuY+FyW7
aPMqzHzWyvuoQM3vPpau9SCaXEa8lmCwIgPqvbxRIgNFaLXcYJP8XTR5HD/+i5vB
OqQRRJ0GRDXVhyqHInptaSeKdpE/EwMJeJ4iJCPKSEFhTv0El+VRoEBYY+ir6d6b
nPrz753Rj9MYqyUbNg1Zhm0pb/oquHb4wekwH74dmZ0Rf3e3gmYdY61kYXeqtU9z
LKYRkpxsB1c9yxTccxJ6yna9oOdlzBKbNJ/kQswZNCNWCTQxKHCq+jnghqFFCTD7
SwvbwxXOyDxOhsos89imLIOdRUz7l1Wvo3dPVHMsu2LX8HVK8u9BLxZP79gqKkW+
B73m+8OLeJhLJJxv01Tle4d0zGhZ5lczpe6hFdvTzKrlaR3Taftekls92FJXrbp6
Y/Dvam8HYj0XjxKzdOpAnH4ashpEJp9JcbbIdoCniPlPEw0s9IU43+7sYsvj9stN
8FqlYrzjnRfLnEAfMTqmPyV9qR0WxIVfFqBkC9+EXI92NuNYle3hcCbPPO4XFkWn
6FVmXWj7JsVzoJtQQeiH+7aGI+8hj49W/OJ96MXd8WsqVxPl7Ih6E3EzLIJ9u2a8
wCFGWH8CPGLkl+n7FEv9lqfaRSzAVMKCgWgqX0LiaitWiDtv5n695bBhFrOm04dg
tRAp7V2H3ZpZ0YC7enoE
=JZoV
-----END PGP SIGNATURE-----

--Signature=_Wed__13_Jun_2012_15_27_51_+1000_DR7_44fyjw/fMp6i--
