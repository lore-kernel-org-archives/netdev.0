From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [BUG] znet.c sleeping function called from
	invalid context
Date: Wed, 07 Oct 2009 22:15:55 -0700 (PDT)
Message-ID: <20091007.221555.71697986.davem@davemloft.net>
References: <200910071847.38163.strakh@ispras.ru>
	<8bd0f97a0910071144k1d0bf30bv60656181edae8af7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, strakh-ufN2psIa012HXe+LvDLADg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        michael.hennerich-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <8bd0f97a0910071144k1d0bf30bv60656181edae8af7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier.adi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Wed, 7 Oct 2009 14:44:45 -0400

> On Wed, Oct 7, 2009 at 14:47, Alexander Strakh wrote:
>> =A0 =A0 =A0 =A0KERNEL_VERSION: 2.6.31
>> =A0 =A0 =A0 =A0DESCRIBE:
>> Driver drivers/net/znet.c might sleep in atomic context, because it calls
>> free_dma under claim_dma_lock:
>>
>> .drivers/net/znet.c:
>> =A0168 static int znet_request_resources (struct net_device *dev)
>> ...
>> =A0189 =A0 =A0 =A0 =A0flags =3D claim_dma_lock();
>> =A0190 =A0 =A0 =A0 =A0free_dma (znet->tx_dma);
>> =A0191 =A0 =A0 =A0 =A0release_dma_lock (flags);
>> ...
>>
>> Path to might_sleep macro from znet_request_resources:
>> 1. znet_request_resources calls free_dma at
>> arch/blackfin/kernel/bfin_dma_5xx.c:181
>> 2. free_dma calls arch/blackfin/kernel/bfin_dma_5xx.c:195
> =

> i dont think we need the dmalock mutex.  it's only used to protect
> read/writes to .chan_status, and that should be atomic already.
> -mike

I'm checking in the obvious fix to net-2.6, thanks for the report:

znet: Don't claim DMA lock around free_dma() calls.

It's not necessary and it's illegal too.

Reported-by: Alexander Strakh <strakh-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/net/znet.c |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index a0384b6..b423473 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -169,7 +169,6 @@ static void znet_tx_timeout (struct net_device *dev);
 static int znet_request_resources (struct net_device *dev)
 {
 	struct znet_private *znet =3D netdev_priv(dev);
-	unsigned long flags;
 =

 	if (request_irq (dev->irq, &znet_interrupt, 0, "ZNet", dev))
 		goto failed;
@@ -187,13 +186,9 @@ static int znet_request_resources (struct net_device *=
dev)
  free_sia:
 	release_region (znet->sia_base, znet->sia_size);
  free_tx_dma:
-	flags =3D claim_dma_lock();
 	free_dma (znet->tx_dma);
-	release_dma_lock (flags);
  free_rx_dma:
-	flags =3D claim_dma_lock();
 	free_dma (znet->rx_dma);
-	release_dma_lock (flags);
  free_irq:
 	free_irq (dev->irq, dev);
  failed:
@@ -203,14 +198,11 @@ static int znet_request_resources (struct net_device =
*dev)
 static void znet_release_resources (struct net_device *dev)
 {
 	struct znet_private *znet =3D netdev_priv(dev);
-	unsigned long flags;
 =

 	release_region (znet->sia_base, znet->sia_size);
 	release_region (dev->base_addr, znet->io_size);
-	flags =3D claim_dma_lock();
 	free_dma (znet->tx_dma);
 	free_dma (znet->rx_dma);
-	release_dma_lock (flags);
 	free_irq (dev->irq, dev);
 }
 =

-- =

1.6.4.4
