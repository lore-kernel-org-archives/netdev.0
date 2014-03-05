From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v3 1/2] net: macb: Check DMA mappings for error
Date: Wed, 05 Mar 2014 23:25:17 +0000
Message-ID: <1394061917.2861.0.camel@deadeye.wl.decadent.org.uk>
References: <1393951600-26039-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MbNiiJsVZKY6odZERLd5"
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1393951600-26039-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-MbNiiJsVZKY6odZERLd5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-04 at 08:46 -0800, Soren Brinkmann wrote:
> With CONFIG_DMA_API_DEBUG enabled the following warning is printed:
>  WARNING: CPU: 0 PID: 619 at lib/dma-debug.c:1101 check_unmap+0x758/0x894=
()
>  macb e000b000.ethernet: DMA-API: device driver failed to check map error=
[device address=3D0x000000002d171c02] [size=3D322 bytes] [mapped as single]
>  Modules linked in:
>  CPU: 0 PID: 619 Comm: udhcpc Not tainted 3.14.0-rc3-xilinx-00219-gd158fc=
7f36a2 #63
>  [<c001516c>] (unwind_backtrace) from [<c0011df8>] (show_stack+0x10/0x14)
>  [<c0011df8>] (show_stack) from [<c03c7714>] (dump_stack+0x7c/0xc8)
>  [<c03c7714>] (dump_stack) from [<c00245cc>] (warn_slowpath_common+0x60/0=
x84)
>  [<c00245cc>] (warn_slowpath_common) from [<c0024670>] (warn_slowpath_fmt=
+0x2c/0x3c)
>  [<c0024670>] (warn_slowpath_fmt) from [<c0228244>] (check_unmap+0x758/0x=
894)
>  [<c0228244>] (check_unmap) from [<c0228588>] (debug_dma_unmap_page+0x64/=
0x70)
>  [<c0228588>] (debug_dma_unmap_page) from [<c02aba64>] (macb_interrupt+0x=
1f8/0x2dc)
>  [<c02aba64>] (macb_interrupt) from [<c006c6e4>] (handle_irq_event_percpu=
+0x2c/0x178)
>  [<c006c6e4>] (handle_irq_event_percpu) from [<c006c86c>] (handle_irq_eve=
nt+0x3c/0x5c)
>  [<c006c86c>] (handle_irq_event) from [<c006f548>] (handle_fasteoi_irq+0x=
b8/0x100)
>  [<c006f548>] (handle_fasteoi_irq) from [<c006c148>] (generic_handle_irq+=
0x20/0x30)
>  [<c006c148>] (generic_handle_irq) from [<c000f35c>] (handle_IRQ+0x64/0x8=
c)
>  [<c000f35c>] (handle_IRQ) from [<c0008528>] (gic_handle_irq+0x3c/0x60)
>  [<c0008528>] (gic_handle_irq) from [<c0012904>] (__irq_svc+0x44/0x78)
>  Exception stack(0xed197f60 to 0xed197fa8)
>  7f60: 00000134 60000013 bd94362e bd94362e be96b37c 00000014 fffffd72 000=
00122
>  7f80: c000ebe4 ed196000 00000000 00000011 c032c0d8 ed197fa8 c0064008 c00=
0ea20
>  7fa0: 60000013 ffffffff
>  [<c0012904>] (__irq_svc) from [<c000ea20>] (ret_fast_syscall+0x0/0x48)
>  ---[ end trace 478f921d0d542d1e ]---
>  Mapped at:
>   [<c0227184>] debug_dma_map_page+0x48/0x11c
>   [<c02aaca0>] macb_start_xmit+0x184/0x2a8
>   [<c03143c0>] dev_hard_start_xmit+0x334/0x470
>   [<c032c09c>] sch_direct_xmit+0x78/0x2f8
>   [<c0314814>] __dev_queue_xmit+0x318/0x708
>=20
> due to missing checks of the dma mapping. Add the appropriate checks to f=
ix
> this.
>=20
> Signed-off-by: Soren Brinkmann <soren.brinkmann@xilinx.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> v3:
>  - move tx_head pointer increment to after the DMA error check
> v2:
>  - unlock spinlock when mapping error is detected in start_xmit()
>  - use kfree_skb() instead of dev_kfree_skb in start_xmit()
> ---
>  drivers/net/ethernet/cadence/macb.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/c=
adence/macb.c
> index 3190d38e16fb..1f03e2041e86 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -632,11 +632,16 @@ static void gem_rx_refill(struct macb *bp)
>  					   "Unable to allocate sk_buff\n");
>  				break;
>  			}
> -			bp->rx_skbuff[entry] =3D skb;
> =20
>  			/* now fill corresponding descriptor entry */
>  			paddr =3D dma_map_single(&bp->pdev->dev, skb->data,
>  					       bp->rx_buffer_size, DMA_FROM_DEVICE);
> +			if (dma_mapping_error(&bp->pdev->dev, paddr)) {
> +				dev_kfree_skb(skb);
> +				break;
> +			}
> +
> +			bp->rx_skbuff[entry] =3D skb;
> =20
>  			if (entry =3D=3D RX_RING_SIZE - 1)
>  				paddr |=3D MACB_BIT(RX_WRAP);
> @@ -1036,11 +1041,15 @@ static int macb_start_xmit(struct sk_buff *skb, s=
truct net_device *dev)
>  	}
> =20
>  	entry =3D macb_tx_ring_wrap(bp->tx_head);
> -	bp->tx_head++;
>  	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
>  	mapping =3D dma_map_single(&bp->pdev->dev, skb->data,
>  				 len, DMA_TO_DEVICE);
> +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> +		kfree_skb(skb);
> +		goto unlock;
> +	}
> =20
> +	bp->tx_head++;
>  	tx_skb =3D &bp->tx_skb[entry];
>  	tx_skb->skb =3D skb;
>  	tx_skb->mapping =3D mapping;
> @@ -1066,6 +1075,7 @@ static int macb_start_xmit(struct sk_buff *skb, str=
uct net_device *dev)
>  	if (CIRC_SPACE(bp->tx_head, bp->tx_tail, TX_RING_SIZE) < 1)
>  		netif_stop_queue(dev);
> =20
> +unlock:
>  	spin_unlock_irqrestore(&bp->lock, flags);
> =20
>  	return NETDEV_TX_OK;

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-MbNiiJsVZKY6odZERLd5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUxeyXee/yOyVhhEJAQoxtxAAk80/QUDDa9JS/teeNC7HvktNpiwBOB4e
tv9m2BeY91lP2bF+z0xpfHddvn8e06koB2VqwAzd+4X1Rcm4xZLaEomA1NXHhBSY
3AF2DWW9XUZWvNZ1XQt91N6whOiLAcQUC0rbhptlYHmYc4YWtc/+eq+rqArBE5pf
RsMV6NsNdyCLnsMwRENyZTURTzi8hbSuZw+D6JFk6o43DN4/hh4m0e6t8wxu1RJq
2Eox2ylTb5MEv8HgcB9DmF97vQGK0fQjxOjO7z3X8EZhTThiNFCq1tuSxho1h9lo
DSKTCTKPpusaXr4x6dNcbHYFL7UQ8o4BBqofmEkQxEFZs16NMtYLoEi4eWAUl5zY
TLgaLlabKSgKb/MmLEpoSY3jMk72w24F90PI718d2f/E/dmOGo0YAlkZl7E/Xrik
JBGPdYg3FDrlZgyjr/j3s21/x74DopG5oSF6q1nOb7ClUsZ7LdmgqJW4XFyB/T5t
PsJUO2kjJgHswBuMr9+uBbMl6DLJJmaVs1GmDgajJZ5NtQSO/Qmpc21DV4qPBfjt
9VHfu79RWzlVoneQJyh3Orq6EIY6ov9pMXZ2bkJh2hYZ7LRrcsZ10uJ+vjtVma6H
K8DFqdPpFYFyaFVJvKyyCoE3Fd+f5hvmF8JAoiVA8ZNHR8M19OglXSxo6E+/7RFt
IUH8akvlKz4=
=NOER
-----END PGP SIGNATURE-----

--=-MbNiiJsVZKY6odZERLd5--
