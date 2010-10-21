From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
 accleration.
Date: Thu, 21 Oct 2010 07:02:36 -0700
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429137@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
 <1287618974-4714-12-git-send-email-jesse@nicira.com>
 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hao Zheng" <hzheng@nicira.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Jesse Gross" <jesse@nicira.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2969 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758225Ab0JUOCt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 10:02:49 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE429135@SJEXCHCCR02.corp.ad.broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Vladislav Zolotarov
> Sent: Thursday, October 21, 2010 3:55 PM
> To: Jesse Gross; David Miller
> Cc: netdev@vger.kernel.org; Hao Zheng; Eilon Greenstein
> Subject: RE: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
> accleration.
> 
> 
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of Jesse Gross
> > Sent: Thursday, October 21, 2010 1:56 AM
> > To: David Miller
> > Cc: netdev@vger.kernel.org; Hao Zheng; Eilon Greenstein
> > Subject: [PATCH v2 11/14] bnx2x: Update bnx2x to use new vlan
> > accleration.
> >
> > From: Hao Zheng <hzheng@nicira.com>
> >
> > Make the bnx2x driver use the new vlan accleration model.
> >
> > Signed-off-by: Hao Zheng <hzheng@nicira.com>
> > Signed-off-by: Jesse Gross <jesse@nicira.com>
> > CC: Eilon Greenstein <eilong@broadcom.com>
> > ---
> >  drivers/net/bnx2x/bnx2x.h         |   10 ------
> >  drivers/net/bnx2x/bnx2x_cmn.c     |   60 +++++++--------------------
> --
> > --------
> >  drivers/net/bnx2x/bnx2x_ethtool.c |   33 ++++++++++----------
> >  drivers/net/bnx2x/bnx2x_main.c    |    8 -----
> >  4 files changed, 27 insertions(+), 84 deletions(-)
> >
> > diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
> > index 3bf236b..9571ecf 100644
> > --- a/drivers/net/bnx2x/bnx2x.h
> > +++ b/drivers/net/bnx2x/bnx2x.h
> > @@ -24,10 +24,6 @@
> >  #define DRV_MODULE_RELDATE      "2010/10/19"
> >  #define BNX2X_BC_VER            0x040200
> >
> > -#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
> > -#define BCM_VLAN			1
> > -#endif
> > -
> >  #define BNX2X_MULTI_QUEUE
> >
> >  #define BNX2X_NEW_NAPI
> > @@ -858,10 +854,6 @@ struct bnx2x {
> >
> >  	int			tx_ring_size;
> >
> > -#ifdef BCM_VLAN
> > -	struct vlan_group	*vlgrp;
> > -#endif
> > -
> >  	u32			rx_csum;
> >  	u32			rx_buf_size;
> >  /* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
> > @@ -925,8 +917,6 @@ struct bnx2x {
> >  #define NO_MCP_FLAG			0x100
> >  #define DISABLE_MSI_FLAG		0x200
> >  #define BP_NOMCP(bp)			(bp->flags & NO_MCP_FLAG)
> > -#define HW_VLAN_TX_FLAG			0x400
> > -#define HW_VLAN_RX_FLAG			0x800
> >  #define MF_FUNC_DIS			0x1000
> >
> >  	int			pf_num;	/* absolute PF number */
> > diff --git a/drivers/net/bnx2x/bnx2x_cmn.c
> > b/drivers/net/bnx2x/bnx2x_cmn.c
> > index 6905b2e..bc58375 100644
> > --- a/drivers/net/bnx2x/bnx2x_cmn.c
> > +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> > @@ -16,16 +16,13 @@
> >   */
> >
> >  #include <linux/etherdevice.h>
> > +#include <linux/if_vlan.h>
> >  #include <linux/ip.h>
> >  #include <net/ipv6.h>
> >  #include <net/ip6_checksum.h>
> >  #include <linux/firmware.h>
> >  #include "bnx2x_cmn.h"
> >
> > -#ifdef BCM_VLAN
> > -#include <linux/if_vlan.h>
> > -#endif
> > -
> >  #include "bnx2x_init.h"
> >
> >
> > @@ -346,13 +343,6 @@ static void bnx2x_tpa_stop(struct bnx2x *bp,
> > struct bnx2x_fastpath *fp,
> >  	if (likely(new_skb)) {
> >  		/* fix ip xsum and give it to the stack */
> >  		/* (no need to map the new skb) */
> > -#ifdef BCM_VLAN
> > -		int is_vlan_cqe =
> > -			(le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
> > -			 PARSING_FLAGS_VLAN);
> > -		int is_not_hwaccel_vlan_cqe =
> > -			(is_vlan_cqe && (!(bp->flags & HW_VLAN_RX_FLAG)));
> > -#endif
> >
> >  		prefetch(skb);
> >  		prefetch(((char *)(skb)) + L1_CACHE_BYTES);
> > @@ -377,28 +367,18 @@ static void bnx2x_tpa_stop(struct bnx2x *bp,
> > struct bnx2x_fastpath *fp,
> >  			struct iphdr *iph;
> >
> >  			iph = (struct iphdr *)skb->data;
> > -#ifdef BCM_VLAN
> > -			/* If there is no Rx VLAN offloading -
> > -			   take VLAN tag into an account */
> > -			if (unlikely(is_not_hwaccel_vlan_cqe))
> > -				iph = (struct iphdr *)((u8 *)iph + VLAN_HLEN);
> > -#endif
> >  			iph->check = 0;
> >  			iph->check = ip_fast_csum((u8 *)iph, iph->ihl);
> >  		}
> >
> >  		if (!bnx2x_fill_frag_skb(bp, fp, skb,
> >  					 &cqe->fast_path_cqe, cqe_idx)) {
> > -#ifdef BCM_VLAN
> > -			if ((bp->vlgrp != NULL) &&
> > -				(le16_to_cpu(cqe->fast_path_cqe.
> > -				pars_flags.flags) & PARSING_FLAGS_VLAN))
> > -				vlan_gro_receive(&fp->napi, bp->vlgrp,
> > +			if ((le16_to_cpu(cqe->fast_path_cqe.
> > +			    pars_flags.flags) & PARSING_FLAGS_VLAN))
> > +				__vlan_hwaccel_put_tag(skb,
> >  						 le16_to_cpu(cqe->fast_path_cqe.
> > -							     vlan_tag), skb);
> > -			else
> > -#endif
> > -				napi_gro_receive(&fp->napi, skb);
> > +							     vlan_tag));
> > +			napi_gro_receive(&fp->napi, skb);
> >  		} else {
> >  			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new
> > pages"
> >  			   " - dropping packet!\n");
> > @@ -633,15 +613,11 @@ reuse_rx:
> >
> >  		skb_record_rx_queue(skb, fp->index);
> >
> > -#ifdef BCM_VLAN
> > -		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
> > -		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
> > -		     PARSING_FLAGS_VLAN))
> > -			vlan_gro_receive(&fp->napi, bp->vlgrp,
> > -				le16_to_cpu(cqe->fast_path_cqe.vlan_tag), skb);
> > -		else
> > -#endif
> > -			napi_gro_receive(&fp->napi, skb);
> > +		if (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
> > +		     PARSING_FLAGS_VLAN)
> > +			__vlan_hwaccel_put_tag(skb,
> > +				le16_to_cpu(cqe->fast_path_cqe.vlan_tag));
> > +		napi_gro_receive(&fp->napi, skb);
> >
> >
> >  next_rx:
> > @@ -2025,14 +2001,12 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff
> > *skb, struct net_device *dev)
> >  	   "sending pkt %u @%p  next_idx %u  bd %u @%p\n",
> >  	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, tx_start_bd);
> >
> > -#ifdef BCM_VLAN
> >  	if (vlan_tx_tag_present(skb)) {
> >  		tx_start_bd->vlan_or_ethertype =
> >  		    cpu_to_le16(vlan_tx_tag_get(skb));
> >  		tx_start_bd->bd_flags.as_bitfield |=
> >  		    (X_ETH_OUTBAND_VLAN <<
> > ETH_TX_BD_FLAGS_VLAN_MODE_SHIFT);
> >  	} else
> > -#endif
> >  		tx_start_bd->vlan_or_ethertype = cpu_to_le16(pkt_prod);
> >
> >  	/* turn on parsing and get a BD */
> > @@ -2317,18 +2291,6 @@ void bnx2x_tx_timeout(struct net_device *dev)
> >  	schedule_delayed_work(&bp->reset_task, 0);
> >  }
> >
> > -#ifdef BCM_VLAN
> > -/* called with rtnl_lock */
> > -void bnx2x_vlan_rx_register(struct net_device *dev,
> > -				   struct vlan_group *vlgrp)
> > -{
> > -	struct bnx2x *bp = netdev_priv(dev);
> > -
> > -	bp->vlgrp = vlgrp;
> > -}
> > -
> > -#endif
> > -
> >  int bnx2x_suspend(struct pci_dev *pdev, pm_message_t state)
> >  {
> >  	struct net_device *dev = pci_get_drvdata(pdev);
> > diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c
> > b/drivers/net/bnx2x/bnx2x_ethtool.c
> > index 54fe061..daefef6 100644
> > --- a/drivers/net/bnx2x/bnx2x_ethtool.c
> > +++ b/drivers/net/bnx2x/bnx2x_ethtool.c
> > @@ -1117,35 +1117,34 @@ static int bnx2x_set_flags(struct net_device
> > *dev, u32 data)
> >  	int changed = 0;
> >  	int rc = 0;
> >
> > -	if (data & ~(ETH_FLAG_LRO | ETH_FLAG_RXHASH))
> > -		return -EINVAL;
> > -
> >  	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
> >  		printk(KERN_ERR "Handling parity error recovery. Try again
> > later\n");
> >  		return -EAGAIN;
> >  	}
> >
> > +	if (!(data & ETH_FLAG_RXVLAN))
> > +		return -EOPNOTSUPP;
> > +
> > +	if ((data & ETH_FLAG_LRO) && bp->rx_csum && bp->disable_tpa)
> > +		return -EINVAL;
> > +
> > +	rc = ethtool_op_set_flags(dev, data, ETH_FLAG_LRO |
> > ETH_FLAG_RXVLAN |
> > +					ETH_FLAG_TXVLAN | ETH_FLAG_RXHASH);
> > +	if (rc)
> > +		return rc;
> > +
> >  	/* TPA requires Rx CSUM offloading */
> >  	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
> > -		if (!bp->disable_tpa) {
> > -			if (!(dev->features & NETIF_F_LRO)) {
> > -				dev->features |= NETIF_F_LRO;
> > -				bp->flags |= TPA_ENABLE_FLAG;
> > -				changed = 1;
> > -			}
> > -		} else
> > -			rc = -EINVAL;
> > -	} else if (dev->features & NETIF_F_LRO) {
> > +		if (!(bp->flags & TPA_ENABLE_FLAG)) {
> > +			bp->flags |= TPA_ENABLE_FLAG;
> > +			changed = 1;
> > +		}
> > +	} else if (bp->flags & TPA_ENABLE_FLAG) {
> >  		dev->features &= ~NETIF_F_LRO;
> >  		bp->flags &= ~TPA_ENABLE_FLAG;
> >  		changed = 1;
> >  	}
> >
> > -	if (data & ETH_FLAG_RXHASH)
> > -		dev->features |= NETIF_F_RXHASH;
> > -	else
> > -		dev->features &= ~NETIF_F_RXHASH;
> > -
> >  	if (changed && netif_running(dev)) {
> >  		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
> >  		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
> > diff --git a/drivers/net/bnx2x/bnx2x_main.c
> > b/drivers/net/bnx2x/bnx2x_main.c
> > index f22e283..ff99a2f 100644
> > --- a/drivers/net/bnx2x/bnx2x_main.c
> > +++ b/drivers/net/bnx2x/bnx2x_main.c
> > @@ -2371,10 +2371,8 @@ static inline u16 bnx2x_get_cl_flags(struct
> > bnx2x *bp,
> >  	flags |= QUEUE_FLG_HC;
> >  	flags |= IS_MF(bp) ? QUEUE_FLG_OV : 0;
> >
> > -#ifdef BCM_VLAN
> >  	flags |= QUEUE_FLG_VLAN;
> >  	DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
> > -#endif
> >
> >  	if (!fp->disable_tpa)
> >  		flags |= QUEUE_FLG_TPA;
> > @@ -8630,9 +8628,6 @@ static const struct net_device_ops
> > bnx2x_netdev_ops = {
> >  	.ndo_do_ioctl		= bnx2x_ioctl,
> >  	.ndo_change_mtu		= bnx2x_change_mtu,
> >  	.ndo_tx_timeout		= bnx2x_tx_timeout,
> > -#ifdef BCM_VLAN
> > -	.ndo_vlan_rx_register	= bnx2x_vlan_rx_register,
> > -#endif
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  	.ndo_poll_controller	= poll_bnx2x,
> >  #endif
> > @@ -8764,9 +8759,7 @@ static int __devinit bnx2x_init_dev(struct
> > pci_dev *pdev,
> >  		dev->features |= NETIF_F_HIGHDMA;
> >  	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> >  	dev->features |= NETIF_F_TSO6;
> > -#ifdef BCM_VLAN
> >  	dev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
> > -	bp->flags |= (HW_VLAN_RX_FLAG | HW_VLAN_TX_FLAG);
> >
> >  	dev->vlan_features |= NETIF_F_SG;
> >  	dev->vlan_features |= NETIF_F_HW_CSUM;
> > @@ -8774,7 +8767,6 @@ static int __devinit bnx2x_init_dev(struct
> > pci_dev *pdev,
> >  		dev->vlan_features |= NETIF_F_HIGHDMA;
> >  	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
> >  	dev->vlan_features |= NETIF_F_TSO6;
> > -#endif
> >
> >  	/* get_port_hwinfo() will set prtad and mmds properly */
> >  	bp->mdio.prtad = MDIO_PRTAD_NONE;
> > --
> > 1.7.1
> 
> Guys, when I compiled the kernel with these patches without VLAN
> support (CONFIG_VLAN_8021Q is not set) and tried to send VLAN tagged
> frames from the remote side to the bnx2x interface the kernel panicked.
> 
> The stack trace got cut with the __netif_receive_skb() on top by the
> IPKVM and I'll have to connect a serial to get it all. But until I
> did that maybe somebody will have any ideas anyway...
> 
> It happens regardless there is HW RX VLAN stripping enabled or not.

When RX VLAN stripping is enabled we hit the BUG() in the 
vlan_hwaccel_do_receive().





> 
> Thanks,
> vlad
> 
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


