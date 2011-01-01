From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Sat, 01 Jan 2011 18:03:13 +0100
Message-ID: <1293901393.2535.49.camel@edumazet-laptop>
References: <1291536233.2806.102.camel@edumazet-laptop>
	 <20101205105528.49fa9a9f@xenia.leun.net>
	 <20101205114404.7c0cddc2@xenia.leun.net>
	 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	 <20101206203437.54b550e0@xenia.leun.net>
	 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	 <20101206222703.32fbe852@xenia.leun.net>
	 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	 <20101213224510.GB17400@mcarlson.broadcom.com>
	 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	 <20101214191500.GD19951@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesse Gross <jesse@nicira.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214191500.GD19951@mcarlson.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 14 d=C3=A9cembre 2010 =C3=A0 11:15 -0800, Matt Carlson a =C3=A9=
crit :

> Thanks for the comments Jesse.  Below is an updated patch.
>=20
> Michael, I'm wondering if the difference in behavior can be explained=
 by
> the presence or absence of management firmware.  Can you look at the
> driver sign-on messages in your syslogs for ASF[]?  I'm half expectin=
g
> the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]".  If you see
> this, and the below patch doesn't fix the problem, let me know.  I ha=
ve
> another test I'd like you to run.
>=20
> ----
>=20
> [PATCH] tg3: Use new VLAN code
>=20
> This patch pivots the tg3 driver to the new VLAN infrastructure.
> All references to vlgrp have been removed and all VLAN code is
> unconditionally active.
>=20
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> ---
>  drivers/net/tg3.c |   95 +++++--------------------------------------=
----------
>  drivers/net/tg3.h |    3 --
>  2 files changed, 9 insertions(+), 89 deletions(-)
>=20
> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> index 5faa87d..3682205 100644
> --- a/drivers/net/tg3.c
> +++ b/drivers/net/tg3.c
> @@ -60,12 +60,6 @@
>  #define BAR_0	0
>  #define BAR_2	2
> =20
> -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> -#define TG3_VLAN_TAG_USED 1
> -#else
> -#define TG3_VLAN_TAG_USED 0
> -#endif
> -
>  #include "tg3.h"
> =20
>  #define DRV_MODULE_NAME		"tg3"
> @@ -134,9 +128,6 @@
>  				 TG3_TX_RING_SIZE)
>  #define NEXT_TX(N)		(((N) + 1) & (TG3_TX_RING_SIZE - 1))
> =20
> -#define TG3_RX_DMA_ALIGN		16
> -#define TG3_RX_HEADROOM			ALIGN(VLAN_HLEN, TG3_RX_DMA_ALIGN)
> -
>  #define TG3_DMA_BYTE_ENAB		64
> =20
>  #define TG3_RX_STD_DMA_SZ		1536
> @@ -4725,8 +4716,6 @@ static int tg3_rx(struct tg3_napi *tnapi, int b=
udget)
>  		struct sk_buff *skb;
>  		dma_addr_t dma_addr;
>  		u32 opaque_key, desc_idx, *post_ptr;
> -		bool hw_vlan __maybe_unused =3D false;
> -		u16 vtag __maybe_unused =3D 0;
> =20
>  		desc_idx =3D desc->opaque & RXD_OPAQUE_INDEX_MASK;
>  		opaque_key =3D desc->opaque & RXD_OPAQUE_RING_MASK;
> @@ -4785,12 +4774,12 @@ static int tg3_rx(struct tg3_napi *tnapi, int=
 budget)
>  			tg3_recycle_rx(tnapi, tpr, opaque_key,
>  				       desc_idx, *post_ptr);
> =20
> -			copy_skb =3D netdev_alloc_skb(tp->dev, len + VLAN_HLEN +
> +			copy_skb =3D netdev_alloc_skb(tp->dev, len +
>  						    TG3_RAW_IP_ALIGN);
>  			if (copy_skb =3D=3D NULL)
>  				goto drop_it_no_recycle;
> =20
> -			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN + VLAN_HLEN);
> +			skb_reserve(copy_skb, TG3_RAW_IP_ALIGN);
>  			skb_put(copy_skb, len);
>  			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr, len, PCI_DMA_FROM=
DEVICE);
>  			skb_copy_from_linear_data(skb, copy_skb->data, len);
> @@ -4817,30 +4806,11 @@ static int tg3_rx(struct tg3_napi *tnapi, int=
 budget)
>  		}
> =20
>  		if (desc->type_flags & RXD_FLAG_VLAN &&
> -		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG)) {
> -			vtag =3D desc->err_vlan & RXD_VLAN_MASK;
> -#if TG3_VLAN_TAG_USED
> -			if (tp->vlgrp)
> -				hw_vlan =3D true;
> -			else
> -#endif
> -			{
> -				struct vlan_ethhdr *ve =3D (struct vlan_ethhdr *)
> -						    __skb_push(skb, VLAN_HLEN);
> -
> -				memmove(ve, skb->data + VLAN_HLEN,
> -					ETH_ALEN * 2);
> -				ve->h_vlan_proto =3D htons(ETH_P_8021Q);
> -				ve->h_vlan_TCI =3D htons(vtag);
> -			}
> -		}
> +		    !(tp->rx_mode & RX_MODE_KEEP_VLAN_TAG))
> +			__vlan_hwaccel_put_tag(skb,
> +					       desc->err_vlan & RXD_VLAN_MASK);
> =20
> -#if TG3_VLAN_TAG_USED
> -		if (hw_vlan)
> -			vlan_gro_receive(&tnapi->napi, tp->vlgrp, vtag, skb);
> -		else
> -#endif
> -			napi_gro_receive(&tnapi->napi, skb);
> +		napi_gro_receive(&tnapi->napi, skb);
> =20
>  		received++;
>  		budget--;
> @@ -5743,11 +5713,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_bu=
ff *skb,
>  		base_flags |=3D TXD_FLAG_TCPUDP_CSUM;
>  	}
> =20
> -#if TG3_VLAN_TAG_USED
>  	if (vlan_tx_tag_present(skb))
>  		base_flags |=3D (TXD_FLAG_VLAN |
>  			       (vlan_tx_tag_get(skb) << 16));
> -#endif
> =20
>  	len =3D skb_headlen(skb);
> =20
> @@ -5989,11 +5957,10 @@ static netdev_tx_t tg3_start_xmit_dma_bug(str=
uct sk_buff *skb,
>  			}
>  		}
>  	}
> -#if TG3_VLAN_TAG_USED
> +
>  	if (vlan_tx_tag_present(skb))
>  		base_flags |=3D (TXD_FLAG_VLAN |
>  			       (vlan_tx_tag_get(skb) << 16));
> -#endif
> =20
>  	if ((tp->tg3_flags3 & TG3_FLG3_USE_JUMBO_BDFLAG) &&
>  	    !mss && skb->len > VLAN_ETH_FRAME_LEN)
> @@ -9538,17 +9505,8 @@ static void __tg3_set_rx_mode(struct net_devic=
e *dev)
>  	/* When ASF is in use, we always keep the RX_MODE_KEEP_VLAN_TAG
>  	 * flag clear.
>  	 */
> -#if TG3_VLAN_TAG_USED
> -	if (!tp->vlgrp &&
> -	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
> -		rx_mode |=3D RX_MODE_KEEP_VLAN_TAG;
> -#else
> -	/* By definition, VLAN is disabled always in this
> -	 * case.
> -	 */
>  	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF))
>  		rx_mode |=3D RX_MODE_KEEP_VLAN_TAG;
> -#endif
> =20
>  	if (dev->flags & IFF_PROMISC) {
>  		/* Promiscuous mode. */
> @@ -11233,31 +11191,6 @@ static int tg3_ioctl(struct net_device *dev,=
 struct ifreq *ifr, int cmd)
>  	return -EOPNOTSUPP;
>  }
> =20
> -#if TG3_VLAN_TAG_USED
> -static void tg3_vlan_rx_register(struct net_device *dev, struct vlan=
_group *grp)
> -{
> -	struct tg3 *tp =3D netdev_priv(dev);
> -
> -	if (!netif_running(dev)) {
> -		tp->vlgrp =3D grp;
> -		return;
> -	}
> -
> -	tg3_netif_stop(tp);
> -
> -	tg3_full_lock(tp, 0);
> -
> -	tp->vlgrp =3D grp;
> -
> -	/* Update RX_MODE_KEEP_VLAN_TAG bit in RX_MODE register. */
> -	__tg3_set_rx_mode(dev);
> -
> -	tg3_netif_start(tp);
> -
> -	tg3_full_unlock(tp);
> -}
> -#endif
> -
>  static int tg3_get_coalesce(struct net_device *dev, struct ethtool_c=
oalesce *ec)
>  {
>  	struct tg3 *tp =3D netdev_priv(dev);
> @@ -13069,9 +13002,7 @@ static struct pci_dev * __devinit tg3_find_pe=
er(struct tg3 *);
> =20
>  static void inline vlan_features_add(struct net_device *dev, unsigne=
d long flags)
>  {
> -#if TG3_VLAN_TAG_USED
>  	dev->vlan_features |=3D flags;
> -#endif
>  }
> =20
>  static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
> @@ -13866,11 +13797,11 @@ static int __devinit tg3_get_invariants(str=
uct tg3 *tp)
>  	else
>  		tp->tg3_flags &=3D ~TG3_FLAG_POLL_SERDES;
> =20
> -	tp->rx_offset =3D NET_IP_ALIGN + TG3_RX_HEADROOM;
> +	tp->rx_offset =3D NET_IP_ALIGN;
>  	tp->rx_copy_thresh =3D TG3_RX_COPY_THRESHOLD;
>  	if (GET_ASIC_REV(tp->pci_chip_rev_id) =3D=3D ASIC_REV_5701 &&
>  	    (tp->tg3_flags & TG3_FLAG_PCIX_MODE) !=3D 0) {
> -		tp->rx_offset -=3D NET_IP_ALIGN;
> +		tp->rx_offset =3D 0;
>  #ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>  		tp->rx_copy_thresh =3D ~(u16)0;
>  #endif
> @@ -14634,9 +14565,6 @@ static const struct net_device_ops tg3_netdev=
_ops =3D {
>  	.ndo_do_ioctl		=3D tg3_ioctl,
>  	.ndo_tx_timeout		=3D tg3_tx_timeout,
>  	.ndo_change_mtu		=3D tg3_change_mtu,
> -#if TG3_VLAN_TAG_USED
> -	.ndo_vlan_rx_register	=3D tg3_vlan_rx_register,
> -#endif
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	=3D tg3_poll_controller,
>  #endif
> @@ -14653,9 +14581,6 @@ static const struct net_device_ops tg3_netdev=
_ops_dma_bug =3D {
>  	.ndo_do_ioctl		=3D tg3_ioctl,
>  	.ndo_tx_timeout		=3D tg3_tx_timeout,
>  	.ndo_change_mtu		=3D tg3_change_mtu,
> -#if TG3_VLAN_TAG_USED
> -	.ndo_vlan_rx_register	=3D tg3_vlan_rx_register,
> -#endif
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	.ndo_poll_controller	=3D tg3_poll_controller,
>  #endif
> @@ -14705,9 +14630,7 @@ static int __devinit tg3_init_one(struct pci_=
dev *pdev,
> =20
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> =20
> -#if TG3_VLAN_TAG_USED
>  	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> -#endif
> =20
>  	tp =3D netdev_priv(dev);
>  	tp->pdev =3D pdev;
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index d62c8d9..f528243 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2808,9 +2808,6 @@ struct tg3 {
>  	u32				rx_std_max_post;
>  	u32				rx_offset;
>  	u32				rx_pkt_map_sz;
> -#if TG3_VLAN_TAG_USED
> -	struct vlan_group		*vlgrp;
> -#endif
> =20
>=20
>  	/* begin "everything else" cacheline(s) section */


Hi Matt.

Any news on this patch ?

Without it, net-next-2.6 doesnt work for me on a vlan setup on top of
bonding.

(bond0 : eth1 & eth2, eth1 being bnx2, eth2 beging tg3)

ip link add link bond0 vlan.103 type vlan id 103
ip addr add 192.168.20.110/24 dev vlan.103
ip link set vlan.103 up


If active slave is eth1 (bnx2), everything works, but if active slave i=
s
eth2 (tg3), incoming tagged frames (on vlan 103) are lost.
