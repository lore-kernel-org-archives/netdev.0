From: Manuel Arostegui Ramirez <manuel@todo-linux.com>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Mon, 21 Jun 2004 15:56:20 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200406211556.20020.manuel@todo-linux.com>
References: <E1BcNzi-0000eh-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, davem@redhat.com,
	benh@kernel.crashing.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S266238AbUFUN5L@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	kernel@nn7.de (Soeren Sonnenburg)
In-Reply-To: <E1BcNzi-0000eh-00@gondolin.me.apana.org.au>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

El Lunes 21 Junio 2004 14:33, Herbert Xu escribi=F3:
> Soeren Sonnenburg <kernel@nn7.de> wrote:
> > When I have some ethernet connection and then do:
> >
> > ifconfig eth0 mtu 1300
> >
> > I get an immediate kernel panic (kernel 2.6.6) on a powerbook g4 15=
"
> > 1ghz.
> >
> > xmon trace (jpeg) is here: http://www.nn7.de/kernel/mtu1300.jpg  (u=
se a
> > webbrowser to view it as it is a redirect)
> >
> > this is 100% reproducable here so I hope it is more easy to fix.
>
> Does this patch fix your problems?
>
> Cheers,
> >
> >=3D=3D=3D=3D=3D drivers/net/sungem.c 1.56 vs edited =3D=3D=3D=3D=3D
> >--- 1.56/drivers/net/sungem.c   2004-06-19 17:16:13 +10:00
> >+++ edited/drivers/net/sungem.c 2004-06-21 22:28:40 +10:00
> >@@ -33,6 +33,7 @@
> > #include <linux/crc32.h>
> > #include <linux/random.h>
> > #include <linux/workqueue.h>
> >+#include <linux/if_vlan.h>
> >=20
> > #include <asm/system.h>
> > #include <asm/bitops.h>
> >@@ -742,7 +743,7 @@
> >                                       PCI_DMA_FROMDEVICE);
> >                        gp->rx_skbs[entry] =3D new_skb;
 > >                       new_skb->dev =3D gp->dev;
> >-                       skb_put(new_skb, (ETH_FRAME_LEN + RX_OFFSET)=
);
> >+                       skb_put(new_skb, (VLAN_ETH_FRAME_LEN + RX_OF=
=46SET));
> >                        rxd->buffer =3D cpu_to_le64(pci_map_page(gp-=
>pdev,
> >                                                               >=20
>virt_to_page(new_skb->data),
> >                                                               >=20
>offset_in_page(new_skb->data),
> >@@ -1482,6 +1483,9 @@
> >=20
> >        gem_clean_rings(gp);
> >=20
> >+       gp->rx_buf_sz =3D min(dev->mtu + ETH_HLEN + VLAN_HLEN,
> >+                           (unsigned)VLAN_ETH_FRAME_LEN);
> >+
> >        for (i =3D 0; i < RX_RING_SIZE; i++) {
> >                struct sk_buff *skb;
> >                struct gem_rxd *rxd =3D &gb->rxd[i];
> >@@ -1495,7 +1499,7 @@
> >=20
 > >               gp->rx_skbs[i] =3D skb;
 > >               skb->dev =3D dev;
> >-               skb_put(skb, (ETH_FRAME_LEN + RX_OFFSET));
> >+               skb_put(skb, (VLAN_ETH_FRAME_LEN + RX_OFFSET));
> >                dma_addr =3D pci_map_page(gp->pdev,
> >                                        virt_to_page(skb->data),
> >                                        offset_in_page(skb->data),
> >=3D=3D=3D=3D=3D drivers/net/sungem.h 1.14 vs edited =3D=3D=3D=3D=3D
> >--- 1.14/drivers/net/sungem.h   2004-01-26 18:03:59 +11:00
> >+++ edited/drivers/net/sungem.h 2004-06-21 22:24:46 +10:00
> >@@ -911,7 +911,7 @@
> >          (GP)->tx_old - (GP)->tx_new - 1)
=20
> > #define RX_OFFSET          2
> >-#define RX_BUF_ALLOC_SIZE(gp)  ((gp)->dev->mtu + 46 + RX_OFFSET + 6=
4)
> >+#define RX_BUF_ALLOC_SIZE(gp)  ((gp)->rx_buf_sz + 32 + RX_OFFSET + =
64)
> >=20
> > #define RX_COPY_THRESHOLD  256
> >=20
> >@@ -979,6 +979,7 @@
> >        int                     rx_fifo_sz;
> >        int                     rx_pause_off;
> >        int                     rx_pause_on;
> >+       int                     rx_buf_sz;
 > >       int                     mii_phy_addr;
 > >
> >        u32                     mac_rx_cfg;

I've had the same problem, like Soeren, but if i put MTU=3D1200 there i=
s not=20
kernel panic.
I'm going to patch my 2.6.6 with this patch, thanks Herbert.

Best regards
