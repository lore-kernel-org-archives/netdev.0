From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 4/5] jme: Adding mii-tool support
Date: Tue, 19 Oct 2010 08:10:43 +0800
Message-ID: <1287447044-24471-4-git-send-email-cooldavid@cooldavid.org>
References: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:49735 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953Ab0JSAU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 20:20:57 -0400
In-Reply-To: <1287447044-24471-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Adding mii-tool support for some distribution only have mii-tool
installed by default.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 095f899..c34c70f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2411,8 +2411,37 @@ jme_set_settings(struct net_device *netdev,
 	if (!rc) {
 		if (fdc)
 			jme_reset_link(jme);
-		set_bit(JME_FLAG_SSET, &jme->flags);
 		jme->old_ecmd = *ecmd;
+		set_bit(JME_FLAG_SSET, &jme->flags);
+	}
+
+	return rc;
+}
+
+static int
+jme_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
+{
+	int rc;
+	struct jme_adapter *jme = netdev_priv(netdev);
+	struct mii_ioctl_data *mii_data = if_mii(rq);
+	unsigned int duplex_chg;
+
+	if (cmd == SIOCSMIIREG) {
+		u16 val = mii_data->val_in;
+		if (!(val & (BMCR_RESET|BMCR_ANENABLE)) &&
+		    (val & BMCR_SPEED1000))
+			return -EINVAL;
+	}
+
+	spin_lock_bh(&jme->phy_lock);
+	rc = generic_mii_ioctl(&jme->mii_if, mii_data, cmd, &duplex_chg);
+	spin_unlock_bh(&jme->phy_lock);
+
+	if (!rc && (cmd == SIOCSMIIREG)) {
+		if (duplex_chg)
+			jme_reset_link(jme);
+		jme_get_settings(netdev, &jme->old_ecmd);
+		set_bit(JME_FLAG_SSET, &jme->flags);
 	}
 
 	return rc;
@@ -2692,6 +2721,7 @@ static const struct net_device_ops jme_netdev_ops = {
 	.ndo_open		= jme_open,
 	.ndo_stop		= jme_close,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= jme_ioctl,
 	.ndo_start_xmit		= jme_start_xmit,
 	.ndo_set_mac_address	= jme_set_macaddr,
 	.ndo_set_multicast_list	= jme_set_multi,
@@ -2883,6 +2913,8 @@ jme_init_one(struct pci_dev *pdev,
 		jme->mii_if.supports_gmii = true;
 	else
 		jme->mii_if.supports_gmii = false;
+	jme->mii_if.phy_id_mask = 0x1F;
+	jme->mii_if.reg_num_mask = 0x1F;
 	jme->mii_if.mdio_read = jme_mdio_read;
 	jme->mii_if.mdio_write = jme_mdio_write;
 
-- 
1.7.2.2

