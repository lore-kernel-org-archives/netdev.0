From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/3] cxgb4: ethtool forward error correction management support
Date: Thu, 27 Jul 2017 16:47:28 -0700
Message-ID: <1501199248-24695-4-git-send-email-roopa@cumulusnetworks.com>
References: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, kubakici@wp.pl, galp@mellanox.com,
        andrew@lunn.ch, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        jeffrey.t.kirsher@intel.com
To: davem@davemloft.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34664 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751767AbdG0Xrk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 19:47:40 -0400
Received: by mail-pg0-f51.google.com with SMTP id 123so103866699pgj.1
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 16:47:40 -0700 (PDT)
In-Reply-To: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 100 +++++++++++++++++++++
 1 file changed, 100 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 26eb00a..03f593e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -801,6 +801,104 @@ static int set_link_ksettings(struct net_device *dev,
 	return ret;
 }
 
+/* Translate the Firmware FEC value into the ethtool value. */
+static inline unsigned int fwcap_to_eth_fec(unsigned int fw_fec)
+{
+	unsigned int eth_fec = 0;
+
+	if (fw_fec & FW_PORT_CAP_FEC_RS)
+		eth_fec |= ETHTOOL_FEC_RS;
+	if (fw_fec & FW_PORT_CAP_FEC_BASER_RS)
+		eth_fec |= ETHTOOL_FEC_BASER;
+
+	/* if nothing is set, then FEC is off */
+	if (!eth_fec)
+		eth_fec = ETHTOOL_FEC_OFF;
+
+	return eth_fec;
+}
+
+/* Translate Common Code FEC value into ethtool value. */
+static inline unsigned int cc_to_eth_fec(unsigned int cc_fec)
+{
+	unsigned int eth_fec = 0;
+
+	if (cc_fec & FEC_AUTO)
+		eth_fec |= ETHTOOL_FEC_AUTO;
+	if (cc_fec & FEC_RS)
+		eth_fec |= ETHTOOL_FEC_RS;
+	if (cc_fec & FEC_BASER_RS)
+		eth_fec |= ETHTOOL_FEC_BASER;
+
+	/* if nothing is set, then FEC is off */
+	if (!eth_fec)
+		eth_fec = ETHTOOL_FEC_OFF;
+
+	return eth_fec;
+}
+
+/* Translate ethtool FEC value into Common Code value. */
+static inline unsigned int eth_to_cc_fec(unsigned int eth_fec)
+{
+	unsigned int cc_fec = 0;
+
+	if (eth_fec & ETHTOOL_FEC_OFF)
+		return cc_fec;
+
+	if (eth_fec & ETHTOOL_FEC_AUTO)
+		cc_fec |= FEC_AUTO;
+	if (eth_fec & ETHTOOL_FEC_RS)
+		cc_fec |= FEC_RS;
+	if (eth_fec & ETHTOOL_FEC_BASER)
+		cc_fec |= FEC_BASER_RS;
+
+	return cc_fec;
+}
+
+static int get_fecparam(struct net_device *dev, struct ethtool_fecparam *fec)
+{
+	const struct port_info *pi = netdev_priv(dev);
+	const struct link_config *lc = &pi->link_cfg;
+
+	/* Translate the Firmware FEC Support into the ethtool value.  We
+	 * always support IEEE 802.3 "automatic" selection of Link FEC type if
+	 * any FEC is supported.
+	 */
+	fec->fec = fwcap_to_eth_fec(lc->supported);
+	if (fec->fec != ETHTOOL_FEC_OFF)
+		fec->fec |= ETHTOOL_FEC_AUTO;
+
+	/* Translate the current internal FEC parameters into the
+	 * ethtool values.
+	 */
+	fec->active_fec = cc_to_eth_fec(lc->fec);
+
+	return 0;
+}
+
+static int set_fecparam(struct net_device *dev, struct ethtool_fecparam *fec)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct link_config *lc = &pi->link_cfg;
+	struct link_config old_lc;
+	int ret;
+
+	/* Save old Link Configuration in case the L1 Configure below
+	 * fails.
+	 */
+	old_lc = *lc;
+
+	/* Try to perform the L1 Configure and return the result of that
+	 * effort.  If it fails, revert the attempted change.
+	 */
+	lc->requested_fec = eth_to_cc_fec(fec->fec);
+	ret = t4_link_l1cfg(pi->adapter, pi->adapter->mbox,
+			    pi->tx_chan, lc);
+	if (ret)
+		*lc = old_lc;
+	return ret;
+}
+
 static void get_pauseparam(struct net_device *dev,
 			   struct ethtool_pauseparam *epause)
 {
@@ -1255,6 +1353,8 @@ static int get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_link_ksettings = get_link_ksettings,
 	.set_link_ksettings = set_link_ksettings,
+	.get_fecparam      = get_fecparam,
+	.set_fecparam      = set_fecparam,
 	.get_drvinfo       = get_drvinfo,
 	.get_msglevel      = get_msglevel,
 	.set_msglevel      = set_msglevel,
-- 
2.1.4
