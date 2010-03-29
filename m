From: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Subject: [PATCH] net/wireless/libertas: do not call wiphy_unregister() w/o wiphy_register()
Date: Mon, 29 Mar 2010 17:14:18 +0200
Message-ID: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
Cc: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>,
	Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The libertas driver calls wiphy_unregister() without a prior
wiphy_register() when a devices fails initialization. Fix this by
introducing a private flag.

[    9.310000] Unable to handle kernel NULL pointer dereference at virtual address 00000000

[...]

[    9.330000] [<c0311310>] (wiphy_unregister+0xfc/0x19c) from [<bf00c9ec>] (lbs_cfg_free+0x70/0x9c [libertas])
[    9.330000] [<bf00c9ec>] (lbs_cfg_free+0x70/0x9c [libertas]) from [<bf014fdc>] (lbs_remove_card+0x180/0x210 [libertas])
[    9.330000] [<bf014fdc>] (lbs_remove_card+0x180/0x210 [libertas]) from [<bf035394>] (if_sdio_probe+0xdc4/0xef4 [libertas_sdio])
[    9.330000] [<bf035394>] (if_sdio_probe+0xdc4/0xef4 [libertas_sdio]) from [<c0230d14>] (sdio_bus_probe+0xd4/0xf0)
[    9.330000] [<c0230d14>] (sdio_bus_probe+0xd4/0xf0) from [<c01a6034>] (driver_probe_device+0xa4/0x174)
[    9.330000] [<c01a6034>] (driver_probe_device+0xa4/0x174) from [<c01a6164>] (__driver_attach+0x60/0x84)
[    9.330000] [<c01a6164>] (__driver_attach+0x60/0x84) from [<c01a5854>] (bus_for_each_dev+0x4c/0x8c)
[    9.330000] [<c01a5854>] (bus_for_each_dev+0x4c/0x8c) from [<c01a50e4>] (bus_add_driver+0xa0/0x228)
[    9.330000] [<c01a50e4>] (bus_add_driver+0xa0/0x228) from [<c01a6470>] (driver_register+0xc0/0x150)
[    9.330000] [<c01a6470>] (driver_register+0xc0/0x150) from [<bf03a06c>] (if_sdio_init_module+0x6c/0x108 [libertas_sdio])
[    9.330000] [<bf03a06c>] (if_sdio_init_module+0x6c/0x108 [libertas_sdio]) from [<c00263ac>] (do_one_initcall+0x5c/0x1bc)
[    9.330000] [<c00263ac>] (do_one_initcall+0x5c/0x1bc) from [<c0069f80>] (sys_init_module+0xc0/0x1f0)
[    9.330000] [<c0069f80>] (sys_init_module+0xc0/0x1f0) from [<c0026f00>] (ret_fast_syscall+0x0/0x30)

Signed-off-by: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: Holger Schurig <hs4233-x6+DxXLjN1AJvtFkdXX2Hg4jNU5vUVPG@public.gmane.org>
Cc: Bing Zhao <bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Cc: libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/net/wireless/libertas/cfg.c |    8 ++++++--
 drivers/net/wireless/libertas/dev.h |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 4396dcc..82ebe14 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -172,6 +172,8 @@ int lbs_cfg_register(struct lbs_private *priv)
 	if (ret < 0)
 		lbs_pr_err("cannot register wiphy device\n");
 
+	priv->wiphy_registered = true;
+
 	ret = register_netdev(priv->dev);
 	if (ret)
 		lbs_pr_err("cannot register network device\n");
@@ -190,9 +192,11 @@ void lbs_cfg_free(struct lbs_private *priv)
 	if (!wdev)
 		return;
 
-	if (wdev->wiphy) {
+	if (priv->wiphy_registered)
 		wiphy_unregister(wdev->wiphy);
+
+	if (wdev->wiphy)
 		wiphy_free(wdev->wiphy);
-	}
+
 	kfree(wdev);
 }
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless/libertas/dev.h
index 6977ee8..6875e14 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -36,6 +36,7 @@ struct lbs_private {
 
 	/* CFG80211 */
 	struct wireless_dev *wdev;
+	bool wiphy_registered;
 
 	/* Mesh */
 	struct net_device *mesh_dev; /* Virtual device */
-- 
1.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
