From: Peter Turczak <pt@netconsequence.de>
Subject: Re: [PATCHv2] smsc: RFC: Workaround for problems with lan8710 phy auto MDI-X
Date: Fri, 7 Dec 2012 10:58:45 +0100
Message-ID: <43ADE5B7-CA05-4913-9696-EDC87863EBB4@netconsequence.de>
References: <8D7E9026-6276-452B-9E0C-AEB8CF38C9FD@netconsequence.de> <alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Otavio Salvador <otavio@ossystems.com.br>,
	Javier Martinez Canillas <javier@dowhile0.org>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Jiri Kosina <jkosina@suse.cz>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netconsequence.de ([85.214.40.104]:55382 "EHLO
	mx.netconsequence.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755679Ab2LGJ6r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 04:58:47 -0500
In-Reply-To: <alpine.LNX.2.00.1211301622110.25639@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 30, 2012, at 4:23 PM, Jiri Kosina <jkosina@suse.cz> wrote:

> I am not sure whether compile-time option for something like this is 
> appropriate. Kernel module parameter, perhaps?
> 
> Of course it'd be far better if faulty hardware can be autodetected in 
> runtime.
Thanks for the input. Currently only the symbol error counter seems to give 
a good indication that there might be a problem. So I suggest monitoring
the symbol error counter. When a certain amount of symbol errors per
poll interval is exceeded the auto MDI-X will be disabled.

BTW: is it okay to hook into read_status or should I use work queues?

Signed-off-by: Peter Turczak <pt@netconsequence.de>
---
drivers/net/phy/smsc.c  |   57 ++++++++++++++++++++++++++++++++++++++++++++++-
include/linux/smscphy.h |    7 +++++
2 files changed, 64 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
index 88e3991..0748266 100644
--- a/drivers/net/phy/smsc.c
+++ b/drivers/net/phy/smsc.c
@@ -24,6 +24,16 @@
#include <linux/netdevice.h>
#include <linux/smscphy.h>

+/* Maximum number of symbol errors between two lan8720_read_status calls. */
+#define LAN8720_MAX_SYM_ERR_CNT 100
+
+static struct phy_driver lan8710_driver;
+
+struct smsc_phy_private {
+	/* Keeps track of the number of the broken received packets */
+	int sym_err_count;
+};
+
static int smsc_phy_config_intr(struct phy_device *phydev)
{
	int rc = phy_write (phydev, MII_LAN83C185_IM,
@@ -58,6 +68,7 @@ static int smsc_phy_config_init(struct phy_device *phydev)

static int lan87xx_config_init(struct phy_device *phydev)
{
+	struct smsc_phy_private *privdata;
	/*
	 * Make sure the EDPWRDOWN bit is NOT set. Setting this bit on
	 * LAN8710/LAN8720 PHY causes the PHY to misbehave, likely due
@@ -79,6 +90,12 @@ static int lan87xx_config_init(struct phy_device *phydev)
	if (rc < 0)
		return rc;

+	privdata = kzalloc(sizeof(*privdata), GFP_KERNEL);
+	if (!privdata)
+		return -ENOMEM;
+
+	phydev->priv = privdata;
+
	return smsc_phy_ack_interrupt(phydev);
}

@@ -87,6 +104,44 @@ static int lan911x_config_init(struct phy_device *phydev)
	return smsc_phy_ack_interrupt(phydev);
}

+int lan8720_read_status(struct phy_device *phydev)
+{
+	int err_count, err_since_last, rc;
+	struct smsc_phy_private *priv = phydev->priv;
+
+	if (priv != NULL) {
+
+		err_count = phy_read(phydev, MII_LAN8710_SYM_ERR_CNT);
+		err_since_last = err_count - priv->sym_err_count;
+
+		if (err_since_last < 0)
+				err_since_last += 65535;
+
+		priv->sym_err_count = err_count;
+		if (err_since_last > LAN8720_MAX_SYM_ERR_CNT) {
+			rc = phy_read(phydev, MII_LAN8710_SCSI);
+
+			if (rc < 0)
+				return rc;
+
+			if (!(rc & MII_LAN8710_SCSI_AMDIXCTRL)) {
+
+				pr_warn("%s: Too may RX errors.",
+					phydev->bus->name);
+				pr_warn("Disabling MDI-X\n");
+
+				rc = phy_write(phydev, MII_LAN8710_SCSI,
+					rc | MII_LAN8710_SCSI_AMDIXCTRL);
+				}
+
+			if (rc < 0)
+				return rc;
+			}
+	}
+
+	return genphy_read_status(phydev);
+}
+
static struct phy_driver smsc_phy_driver[] = {
{
	.phy_id		= 0x0007c0a0, /* OUI=0x00800f, Model#=0x0a */
@@ -187,7 +242,7 @@ static struct phy_driver smsc_phy_driver[] = {

	/* basic functions */
	.config_aneg	= genphy_config_aneg,
-	.read_status	= genphy_read_status,
+	.read_status	= lan8720_read_status,
	.config_init	= lan87xx_config_init,

	/* IRQ related */
diff --git a/include/linux/smscphy.h b/include/linux/smscphy.h
index ce718cb..a0d3893 100644
--- a/include/linux/smscphy.h
+++ b/include/linux/smscphy.h
@@ -22,4 +22,11 @@
#define MII_LAN83C185_EDPWRDOWN (1 << 13) /* EDPWRDOWN */
#define MII_LAN83C185_ENERGYON  (1 << 1)  /* ENERGYON */

+#define MII_LAN8710_SCSI  27 /* Special Control/Status register */
+
+#define MII_LAN8710_SCSI_AMDIXCTRL (1<<15) /* Flag to disable Auto-MDIX */
+
+#define MII_LAN8710_SYM_ERR_CNT	26 /* Amount of invalid code symbols received */
+
+
#endif /* __LINUX_SMSCPHY_H__ */
-- 
1.7.0.4
