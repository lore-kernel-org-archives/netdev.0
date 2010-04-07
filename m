From: Manfred Rudigier <Manfred.Rudigier@omicron.at>
Subject: [RFC PATCH net-next 1/4] gianfar: Added stub support for
 SIOCSHWTSTAMP
Date: Wed, 7 Apr 2010 11:46:08 +0200
Message-ID: <95DC1AA8EC908B48939B72CF375AA5E311A9F4DF@alice.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'linuxppc-dev@lists.ozlabs.org'" <linuxppc-dev@lists.ozlabs.org>
To: "'sandeep.kumar@freescale.com'" <sandeep.kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:60232 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757713Ab0DGKYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Apr 2010 06:24:09 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ioctl command is required for enabling hardware time stamping support
for network packets, see Documentation/networking/timestamping.txt. At the
moment nothing will be done for all requests that enable time stamping and
thus ERANGE will be returned.

Signed-off-by: Manfred Rudigier <manfred.rudigier@omicron.at>
---
 drivers/net/gianfar.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 080d1ce..309bab0 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -82,6 +82,7 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/in.h>
+#include <linux/net_tstamp.h>
 
 #include <asm/io.h>
 #include <asm/irq.h>
@@ -772,6 +773,38 @@ err_grp_init:
 	return err;
 }
 
+static int gfar_hwtstamp_ioctl(struct net_device *netdev,
+			struct ifreq *ifr, int cmd)
+{
+	struct hwtstamp_config config;
+
+	if (copy_from_user(&config, ifr->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+	case HWTSTAMP_TX_ON:
+		return -ERANGE;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
 /* Ioctl MII Interface */
 static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
@@ -780,6 +813,9 @@ static int gfar_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	if (!netif_running(dev))
 		return -EINVAL;
 
+	if (cmd == SIOCSHWTSTAMP)
+		return gfar_hwtstamp_ioctl(dev, rq, cmd);
+
 	if (!priv->phydev)
 		return -ENODEV;
 
-- 
1.6.3.3
