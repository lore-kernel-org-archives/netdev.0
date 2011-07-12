From: Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
Subject: Re: [ath9k-devel] [PATCH v2 07/46] net/wireless: ath9k: fix DMA API
 usage
Date: Tue, 12 Jul 2011 20:32:04 +0100
Message-ID: <20110712193204.GB13413@linux-mips.org>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
 <280ad9176e6532f231e054b38b952b20580874c5.1310339688.git.mirq-linux@rere.qmqm.pl>
 <4E1BCF36.2010506@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jouni Malinen <jmalinen-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	ath9k-devel-juf53994utBLZpfksSYvnA@public.gmane.org,
	Vasanthakumar Thiagarajan <vasanth-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E1BCF36.2010506-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2011 at 12:36:06PM +0800, Felix Fietkau wrote:

> >diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wir=
eless/ath/ath9k/recv.c
> >index 70dc8ec..c5f46d5 100644
> >--- a/drivers/net/wireless/ath/ath9k/recv.c
> >+++ b/drivers/net/wireless/ath/ath9k/recv.c
> >@@ -684,15 +684,11 @@ static bool ath_edma_get_buffers(struct ath_so=
ftc *sc,
> >  	BUG_ON(!bf);
> >
> >  	dma_sync_single_for_cpu(sc->dev, bf->bf_buf_addr,
> >-				common->rx_bufsize, DMA_FROM_DEVICE);
> >+				common->rx_bufsize, DMA_BIDIRECTIONAL);
> >
> >  	ret =3D ath9k_hw_process_rxdesc_edma(ah, NULL, skb->data);
> >-	if (ret =3D=3D -EINPROGRESS) {
> >-		/*let device gain the buffer again*/
> >-		dma_sync_single_for_device(sc->dev, bf->bf_buf_addr,
> >-				common->rx_bufsize, DMA_FROM_DEVICE);
> >+	if (ret =3D=3D -EINPROGRESS)
> >  		return false;
> >-	}
> >
> >  	__skb_unlink(skb,&rx_edma->rx_fifo);
> >  	if (ret =3D=3D -EINVAL) {
> I have strong doubts about this change. On most MIPS devices,
> dma_sync_single_for_cpu is a no-op, whereas
> dma_sync_single_for_device flushes the cache range. With this
> change, the CPU could cache the DMA status part behind skb->data and
> that cache entry would not be flushed inbetween calls to this
> functions on the same buffer, likely leading to rx stalls.

The code was already broken before.  By the time dma_sync_single_for_cp=
u
and ath9k_hw_process_rxdesc_edma are called, the DMA engine may still b=
e
active in the buffer,  yet the driver is looking at it.

dma_sync_single_for_cpu() is part of changing the buffer ownership from
the device to the CPU.  When it is being called, DMA into the buffer sh=
ould
already have been completed ...  or else the shit may hit the jet engin=
e.

Imagine what would happen on a hypothetic cache architecture which does=
 not
have a dirty bit, that is which would have to write back every cache li=
ne -
even clean lines - to memory in order to evict it.  Corruption.

And don't argue with what the actual MIPS implementation of dma_sync_si=
ngle_-
for-{cpu,device} is doing.  It's meant to bee treated as a black box; t=
hat
abstraction is the whole point of the ABI.  And it seems the driver is =
also
being used on other architectures than MIPS =E2=80=A6

  Ralf
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
