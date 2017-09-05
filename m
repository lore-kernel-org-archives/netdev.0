From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH net-next] net: cpsw: Don't handle SIOC[GS]HWTSTAMP when
 CPTS is disabled
Date: Tue, 5 Sep 2017 16:25:22 -0500
Message-ID: <c470bbf2-fadf-88ba-f944-f0b373d211ad@ti.com>
References: <20170830065055.419-1-stefan.sorensen@spectralink.com>
 <20170830.144745.947488279115809130.davem@davemloft.net>
 <20170831074807.3dbbt6qhqxdquipa@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <stefan.sorensen@spectralink.com>, <netdev@vger.kernel.org>,
        <linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:21146 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752625AbdIEVZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:25:28 -0400
In-Reply-To: <20170831074807.3dbbt6qhqxdquipa@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On 08/31/2017 02:48 AM, Richard Cochran wrote:
> On Wed, Aug 30, 2017 at 02:47:45PM -0700, David Miller wrote:
>> It should not be required to disable a Kconfig option just to get PHY
>> timestamping to work properly.
> 
> Well, if the MAC driver handles the ioctl and enables time stamping,
> then the PHY driver's time stamping remains disabled.  We don't have a
> way to choose PHY time stamping at run time.
>   
>> Rather, if the CPTS code returns -EOPNOTSUPP we should try to
>> fallthrough to the PHY library based methods.
> 
> I agree that it would be better for the core (rather than the
> individual drivers) to handle this case.

I'd like to clarify one thing here - what is the preferable time-stamping
device: PHY over MAC, or MAC over PHY? 
my understanding it's PHY and ethtool_get_ts_info() seems already implemented this way.

> 
> There are a few callers of .ndo_do_ioctl to consider.  Besides
> dev_ifsioc() there is at least vlan_dev_ioctl() that needs to handle
> the EOPNOTSUPP.

Sry, I've not tried to do solution in Net core, but below patch updates CPSW
driver to selected PHY time-stamping over MAC if supported without disabling CPTS in Kconfig
(at least it's expected to fix it) - not tested as I do not have HW with dp83640 phy.

-----------------------------------------------------------------------
>From 51347692087732320f2f5615030f5f36ed3c7724 Mon Sep 17 00:00:00 2001
From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Tue, 5 Sep 2017 15:24:44 -0500
Subject: [PATCH] net: ethernet: cpsw: allow phy timestamping over mac

Allow phy timestamping to be used over mac timestamping if supported.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 21 +++++++++++++++++----
 drivers/net/ethernet/ti/cpts.c |  2 ++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 95ac926..8831cb9 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -291,6 +291,10 @@ struct cpsw_ss_regs {
 #define CPSW_MAX_BLKS_TX_SHIFT		4
 #define CPSW_MAX_BLKS_RX		5
 
+#define HAS_PHY_TXTSTAMP(p) ((p) && (p)->drv && (p)->drv->txtstamp)
+#define HAS_PHY_TSTAMP(p) ((p) && (p)->drv && \
+	((p)->drv->rxtstamp || (p)->drv->rxtstamp))
+
 struct cpsw_host_regs {
 	u32	max_blks;
 	u32	blk_cnt;
@@ -1600,6 +1604,8 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
+	int slave_no = cpsw_slave_index(cpsw, priv);
+	struct phy_device *phy = cpsw->slaves[slave_no].phy;
 	struct cpts *cpts = cpsw->cpts;
 	struct netdev_queue *txq;
 	struct cpdma_chan *txch;
@@ -1611,8 +1617,9 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 		return NET_XMIT_DROP;
 	}
 
-	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-	    cpts_is_tx_enabled(cpts) && cpts_can_timestamp(cpts, skb))
+	if ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+	    cpts_can_timestamp(cpts, skb) &&
+	    (cpts_is_tx_enabled(cpts) || HAS_PHY_TXTSTAMP(phy)))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	q_idx = skb_get_queue_mapping(skb);
@@ -1810,20 +1817,26 @@ static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	struct cpsw_priv *priv = netdev_priv(dev);
 	struct cpsw_common *cpsw = priv->cpsw;
 	int slave_no = cpsw_slave_index(cpsw, priv);
+	struct phy_device *phy = cpsw->slaves[slave_no].phy;
+
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
+		if (HAS_PHY_TSTAMP(phy))
+			break;
 		return cpsw_hwtstamp_set(dev, req);
 	case SIOCGHWTSTAMP:
+		if (HAS_PHY_TSTAMP(phy))
+			break;
 		return cpsw_hwtstamp_get(dev, req);
 	}
 
-	if (!cpsw->slaves[slave_no].phy)
+	if (!phy)
 		return -EOPNOTSUPP;
-	return phy_mii_ioctl(cpsw->slaves[slave_no].phy, req, cmd);
+	return phy_mii_ioctl(phy, req, cmd);
 }
 
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index c2121d2..f257f54 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -421,6 +421,8 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 	u64 ns;
 	struct skb_shared_hwtstamps ssh;
 
+	if (!cpts->rx_enable)
+		return;
 	if (!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
 		return;
 	ns = cpts_find_ts(cpts, skb, CPTS_EV_TX);
-- 
2.10.1


-- 
regards,
-grygorii
