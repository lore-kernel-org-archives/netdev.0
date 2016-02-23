From: Diego Viola <diego.viola@gmail.com>
Subject: [PATCH v3] net: jme: fix suspend/resume on JMC260
Date: Tue, 23 Feb 2016 12:04:04 -0300
Message-ID: <1456239844-4109-1-git-send-email-diego.viola@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	richard.weinberger@gmail.com, pavel@ucw.cz, rjw@rjwysocki.net,
	davem@davemloft.net, valdis.kletnieks@vt.edu,
	Diego Viola <diego.viola@gmail.com>
To: cooldavid@cooldavid.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The JMC260 network card fails to suspend/resume because the call to
jme_start_irq() was too early, moving the call to jme_start_irq() after
the call to jme_reset_link() makes it work.

Prior this change suspend/resume would fail unless /sys/power/pm_async=0
was explicitly specified.

Relevant bug report: https://bugzilla.kernel.org/show_bug.cgi?id=112351

Signed-off-by: Diego Viola <diego.viola@gmail.com>
---
 drivers/net/ethernet/jme.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index b1de7af..8adbe8f 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3312,13 +3312,14 @@ jme_resume(struct device *dev)
 		jme_reset_phy_processor(jme);
 	jme_phy_calibration(jme);
 	jme_phy_setEA(jme);
-	jme_start_irq(jme);
 	netif_device_attach(netdev);
 
 	atomic_inc(&jme->link_changing);
 
 	jme_reset_link(jme);
 
+	jme_start_irq(jme);
+
 	return 0;
 }
 
-- 
2.7.1
