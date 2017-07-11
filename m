From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] dpaa_eth: use correct device for DMA mapping API
Date: Tue, 11 Jul 2017 11:18:43 +0200
Message-ID: <CAK8P3a1GLQ1WVfbhzedkvfe573hnUwBMVCAeVaWiKPKDOK=Agg@mail.gmail.com>
References: <20170710151447.2814348-1-arnd@arndb.de> <AM5PR0402MB26915AF3D88700BD5EABB2DDECAE0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Christoph Hellwig <hch@lst.de>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Robin Murphy <robin.murphy@arm.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Camelia Alexandra Groza <camelia.groza@nxp.com>,
        Claudiu Manoil <claudiu.manoil@nxp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Madalin-cristian Bucur <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM5PR0402MB26915AF3D88700BD5EABB2DDECAE0@AM5PR0402MB2691.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 11, 2017 at 10:50 AM, Madalin-cristian Bucur
<madalin.bucur@nxp.com> wrote:

> Hi Arnd,
>
> Thanks for looking into this, I've tested your fix, it seems to need more work:
>
> [    0.894968]  platform: DMA map failed
> [    0.898627]  platform: DMA map failed
> [    0.902288]  platform: DMA map failed
> [    0.905947]  platform: DMA map failed
> [    0.909606]  platform: DMA map failed
> [    0.913265]  platform: DMA map failed

I see: the assignment ended up after the first use, so ->dev was still
NULL here.

This should fix the problem you saw here:

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index f7b0b928cd53..988c0212ce7e 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2650,6 +2650,8 @@ static int dpaa_eth_probe(struct platform_device *pdev)
  for (i = 0; i < DPAA_BPS_NUM; i++) {
  int err;

+ /* DMA operations are done on the platform-provided device */
+ dpaa_bps[i]->dev = dev->parent;
  dpaa_bps[i] = dpaa_bp_alloc(dev);
  if (IS_ERR(dpaa_bps[i]))
  return PTR_ERR(dpaa_bps[i]);
@@ -2657,8 +2659,6 @@ static int dpaa_eth_probe(struct platform_device *pdev)
  dpaa_bps[i]->raw_size = bpool_buffer_raw_size(i, DPAA_BPS_NUM);
  /* avoid runtime computations by keeping the usable size here */
  dpaa_bps[i]->size = dpaa_bp_size(dpaa_bps[i]->raw_size);
- /* DMA operations are done on the platform-provided device */
- dpaa_bps[i]->dev = dev->parent;

  err = dpaa_bp_alloc_pool(dpaa_bps[i]);
  if (err < 0) {

> @@ -2806,7 +2799,6 @@ static int dpaa_eth_probe(struct platform_device *pdev)
>                 dpaa_bps_free(priv);
>  bp_create_failed:
>  fq_probe_failed:
> -dev_mask_failed:
>  mac_probe_failed:
>                 dev_set_drvdata(dev, NULL);
>                 free_netdev(net_dev);
>
> I'll try to address your concern about performing the DMA mapping on a different
> device than the one set up by the platform code.

Thanks!

     Arnd
