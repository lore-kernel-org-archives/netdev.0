From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH -next 1/2] gianfar: Implement proper, per netdevice wakeup
	management
Date: Wed, 28 Jan 2009 23:38:54 +0300
Message-ID: <20090128203854.GA14693__21676.7090409578$1233175266$gmane$org@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch implements wakeup management for the gianfar driver.

The driver should set wakeup enable if WOL is enabled, so that
phylib won't power off an attached PHY.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c         |    5 +++++
 drivers/net/gianfar_ethtool.c |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3f7eab4..3a8359e 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -463,6 +463,9 @@ static int gfar_probe(struct of_device *ofdev,
 		goto register_fail;
 	}
 
+	device_init_wakeup(&dev->dev,
+		priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+
 	/* fill out IRQ number and name fields */
 	len_devname = strlen(dev->name);
 	strncpy(&priv->int_name_tx[0], dev->name, len_devname);
@@ -1200,6 +1203,8 @@ static int gfar_enet_open(struct net_device *dev)
 
 	netif_start_queue(dev);
 
+	device_set_wakeup_enable(&dev->dev, priv->wol_en);
+
 	return err;
 }
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 59b3b5d..dbf06e9 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -600,6 +600,7 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 
 	spin_lock_irqsave(&priv->bflock, flags);
 	priv->wol_en = wol->wolopts & WAKE_MAGIC ? 1 : 0;
+	device_set_wakeup_enable(&dev->dev, priv->wol_en);
 	spin_unlock_irqrestore(&priv->bflock, flags);
 
 	return 0;
-- 
1.5.6.5
