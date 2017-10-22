From: Sean Wang <sean.wang@mediatek.com>
Subject: RE: [PATCH 02/15] drivers, net, ethernet: convert
 mtk_eth.dma_refcnt from atomic_t to refcount_t
Date: Sun, 22 Oct 2017 12:06:39 +0800
Message-ID: <1508645199.29850.16.camel@mtkswgap22>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
         <1508484229-19706-3-git-send-email-elena.reshetova@intel.com>
         <1508486927.29850.12.camel@mtkswgap22>
         <2236FBA76BA1254E88B949DDB74E612B802B37EE@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-mediatek@lists.infradead.org"
        <linux-mediatek@lists.infradead.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "nbd@openwrt.org" <nbd@openwrt.org>,
        "john@phrozen.org" <john@phrozen.org>,
        "matthias.bgg@gmail.com" <matthias.bgg@gmail.com>,
        "yishaih@mellanox.com" <yishaih@mellanox.com>,
        "saeedm@mellanox.com" <saeedm@mellanox.com>,
        "matanb@mell
To: "Reshetova, Elena" <elena.reshetova@intel.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B802B37EE@IRSMSX102.ger.corp.intel.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-10-20 at 10:37 +0000, Reshetova, Elena wrote:
> > On Fri, 2017-10-20 at 10:23 +0300, Elena Reshetova wrote:
> > > atomic_t variables are currently used to implement reference
> > > counters with the following properties:
> > >  - counter is initialized to 1 using atomic_set()
> > >  - a resource is freed upon counter reaching zero
> > >  - once counter reaches zero, its further
> > >    increments aren't allowed
> > >  - counter schema uses basic atomic operations
> > >    (set, inc, inc_not_zero, dec_and_test, etc.)
> > >
> > > Such atomic variables should be converted to a newly provided
> > > refcount_t type and API that prevents accidental counter overflows
> > > and underflows. This is important since overflows and underflows
> > > can lead to use-after-free situation and be exploitable.
> > >
> > > The variable mtk_eth.dma_refcnt is used as pure reference counter.
> > > Convert it to refcount_t and fix up the operations.
> > >
> > > Suggested-by: Kees Cook <keescook@chromium.org>
> > > Reviewed-by: David Windsor <dwindsor@gmail.com>
> > > Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
> > > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > > ---
> > >  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 +++++---
> > >  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 +++-
> > >  2 files changed, 8 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> > b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> > > index 5e81a72..54adfd9 100644
> > > --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> > > +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> > > @@ -1817,7 +1817,7 @@ static int mtk_open(struct net_device *dev)
> > >  	struct mtk_eth *eth = mac->hw;
> > >
> > >  	/* we run 2 netdevs on the same dma ring so we only bring it up once
> > */
> > > -	if (!atomic_read(&eth->dma_refcnt)) {
> > > +	if (!refcount_read(&eth->dma_refcnt)) {
> > >  		int err = mtk_start_dma(eth);
> > >
> > >  		if (err)
> > > @@ -1827,8 +1827,10 @@ static int mtk_open(struct net_device *dev)
> > >  		napi_enable(&eth->rx_napi);
> > >  		mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
> > >  		mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
> > > +		refcount_set(&eth->dma_refcnt, 1);
> > 
> > the existing driver seems to have a missing initial atomic_set for the
> > eth->dma_refcnt.
> > 
> > >  	}
> > > -	atomic_inc(&eth->dma_refcnt);
> > > +	else
> > > +		refcount_inc(&eth->dma_refcnt);
> > >
> > 
> > how about add the initial refcount_set into probe handler, and keep
> > logic else unchanged ?
> 
> Sure, I guess you mean mtk_probe() function? I can move the refcount_set to be there
> and remove this change. 
> 
> Should I resend the modified patch to you (maybe then two of the ethernet patches)?
> 
> Best Regards,
> Elena.

The entire series has been applies to net-next, I think I can make the
follow-ups patches relative to your work. 
	
	Sean

> > 
> > >  	phy_start(dev->phydev);
> > >  	netif_start_queue(dev);
> > > @@ -1868,7 +1870,7 @@ static int mtk_stop(struct net_device *dev)
> > >  	phy_stop(dev->phydev);
> > >
> > >  	/* only shutdown DMA if this is the last user */
> > > -	if (!atomic_dec_and_test(&eth->dma_refcnt))
> > > +	if (!refcount_dec_and_test(&eth->dma_refcnt))
> > >  		return 0;
> > >
> > >  	mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
> > > diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> > b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> > > index 3d3c24a..a3af466 100644
> > > --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> > > +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> > > @@ -15,6 +15,8 @@
> > >  #ifndef MTK_ETH_H
> > >  #define MTK_ETH_H
> > >
> > > +#include <linux/refcount.h>
> > > +
> > >  #define MTK_QDMA_PAGE_SIZE	2048
> > >  #define	MTK_MAX_RX_LENGTH	1536
> > >  #define MTK_TX_DMA_BUF_LEN	0x3fff
> > > @@ -632,7 +634,7 @@ struct mtk_eth {
> > >  	struct regmap			*pctl;
> > >  	u32				chip_id;
> > >  	bool				hwlro;
> > > -	atomic_t			dma_refcnt;
> > > +	refcount_t			dma_refcnt;
> > >  	struct mtk_tx_ring		tx_ring;
> > >  	struct mtk_rx_ring
> > 	rx_ring[MTK_MAX_RX_RING_NUM];
> > >  	struct mtk_rx_ring		rx_ring_qdma;
> > 
> 


