From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/16] nfp: prepare print macros for use without netdev
Date: Mon,  5 Jun 2017 17:01:46 -0700
Message-ID: <20170606000157.17556-6-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36605 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751266AbdFFACY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:24 -0400
Received: by mail-pf0-f182.google.com with SMTP id m17so90021927pfg.3
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:24 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To be able to reuse print macros easily with control vNICs make the
macros check if netdev pointer is populated and use dev_* print
functions otherwise.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h | 33 +++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 2e526338f678..b14aa31d494a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -50,15 +50,32 @@
 
 #include "nfp_net_ctrl.h"
 
-#define nn_err(nn, fmt, args...)  netdev_err((nn)->dp.netdev, fmt, ## args)
-#define nn_warn(nn, fmt, args...) netdev_warn((nn)->dp.netdev, fmt, ## args)
-#define nn_info(nn, fmt, args...) netdev_info((nn)->dp.netdev, fmt, ## args)
-#define nn_dbg(nn, fmt, args...)  netdev_dbg((nn)->dp.netdev, fmt, ## args)
+#define nn_pr(nn, lvl, fmt, args...)					\
+	({								\
+		struct nfp_net *__nn = (nn);				\
+									\
+		if (__nn->dp.netdev)					\
+			netdev_printk(lvl, __nn->dp.netdev, fmt, ## args); \
+		else							\
+			dev_printk(lvl, __nn->dp.dev, "ctrl: " fmt, ## args); \
+	})
+
+#define nn_err(nn, fmt, args...)	nn_pr(nn, KERN_ERR, fmt, ## args)
+#define nn_warn(nn, fmt, args...)	nn_pr(nn, KERN_WARNING, fmt, ## args)
+#define nn_info(nn, fmt, args...)	nn_pr(nn, KERN_INFO, fmt, ## args)
+#define nn_dbg(nn, fmt, args...)	nn_pr(nn, KERN_DEBUG, fmt, ## args)
+
 #define nn_dp_warn(dp, fmt, args...)					\
-	do {								\
-		if (unlikely(net_ratelimit()))				\
-			netdev_warn((dp)->netdev, fmt, ## args);	\
-	} while (0)
+	({								\
+		struct nfp_net_dp *__dp = (dp);				\
+									\
+		if (unlikely(net_ratelimit())) {			\
+			if (__dp->netdev)				\
+				netdev_warn(__dp->netdev, fmt, ## args); \
+			else						\
+				dev_warn(__dp->dev, fmt, ## args);	\
+		}							\
+	})
 
 /* Max time to wait for NFP to respond on updates (in seconds) */
 #define NFP_NET_POLL_TIMEOUT	5
-- 
2.11.0
