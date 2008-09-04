From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH 1/1 net-2.6] s2io: enabling VLAN tag stripping at driver initialization
Date: Thu, 4 Sep 2008 17:00:01 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7704330523@nekter>
References: <48C01EDB.7020001@linux.vnet.ibm.com> <78C9135A3D2ECE4B8162EBDCE82CAD7704330496@nekter> <48C04AA6.1010808@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<jeff@garzik.org>, "Jay Vosburgh" <fubar@us.ibm.com>,
	"netdev" <netdev@vger.kernel.org>, "Lorandi" <rafaello@br.ibm.com>,
	"support" <support@neterion.com>
To: "Breno Leitao" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:16169 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbYIDVAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 17:00:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <48C04AA6.1010808@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Breno/Jeff,
This patch looks good.

Thanks,
Ram

> -----Original Message-----
> From: Breno Leitao [mailto:leitao@linux.vnet.ibm.com]
> Sent: Thursday, September 04, 2008 1:53 PM
> To: Ramkrishna Vepa
> Cc: Rastapur Santosh; Sivakumar Subramani; Sreenivasa Honnur;
> jeff@garzik.org; Jay Vosburgh; netdev; Lorandi
> Subject: Re: [PATCH 1/1 net-2.6] s2io: enabling VLAN tag stripping at
> driver initialization
> 
> Actually s2io has a bug in VLAN support. VLAN doesn't work except if
> you'd opened the interface in promiscuous mode before.
> This happens because VLAN tag stripping is not correctly marked as
> enabled at device startup
> 
> Also, the vlan_strip_flag field was moved to the private network
> structure.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> 
> ---
> 
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index a2b0730..1386d76 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -371,9 +371,6 @@ static void s2io_vlan_rx_register(struct
net_device
> *dev,
>  				flags[i]);
>  }
> 
> -/* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or
not
> */
> -static int vlan_strip_flag;
> -
>  /* Unregister the vlan */
>  static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned
long
> vid)
>  {
> @@ -2303,7 +2300,7 @@ static int start_nic(struct s2io_nic *nic)
>  		val64 = readq(&bar0->rx_pa_cfg);
>  		val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
>  		writeq(val64, &bar0->rx_pa_cfg);
> -		vlan_strip_flag = 0;
> +		nic->vlan_strip_flag = 0;
>  	}
> 
>  	/*
> @@ -5010,7 +5007,7 @@ static void s2io_set_multicast(struct net_device
> *dev)
>  			val64 = readq(&bar0->rx_pa_cfg);
>  			val64 &= ~RX_PA_CFG_STRIP_VLAN_TAG;
>  			writeq(val64, &bar0->rx_pa_cfg);
> -			vlan_strip_flag = 0;
> +			sp->vlan_strip_flag = 0;
>  		}
> 
>  		val64 = readq(&bar0->mac_cfg);
> @@ -5032,7 +5029,7 @@ static void s2io_set_multicast(struct net_device
> *dev)
>  			val64 = readq(&bar0->rx_pa_cfg);
>  			val64 |= RX_PA_CFG_STRIP_VLAN_TAG;
>  			writeq(val64, &bar0->rx_pa_cfg);
> -			vlan_strip_flag = 1;
> +			sp->vlan_strip_flag = 1;
>  		}
> 
>  		val64 = readq(&bar0->mac_cfg);
> @@ -8206,6 +8203,11 @@ s2io_init_nic(struct pci_dev *pdev, const
struct
> pci_device_id *pre)
>  	/* Initialize device name */
>  	sprintf(sp->name, "%s Neterion %s", dev->name,
sp->product_name);
> 
> +	if (vlan_tag_strip)
> +		sp->vlan_strip_flag = 1;
> +	else
> +		sp->vlan_strip_flag = 0;
> +
>  	/*
>  	 * Make Link state as off at this point, when the Link change
>  	 * interrupt comes the state will be automatically changed to
> @@ -8311,7 +8313,7 @@ static int check_L2_lro_capable(u8 *buffer,
struct
> iphdr **ip,
>  		 * If vlan stripping is disabled and the frame is VLAN
tagged,
>  		 * shift the offset by the VLAN header size bytes.
>  		 */
> -		if ((!vlan_strip_flag) &&
> +		if ((!sp->vlan_strip_flag) &&
>  			(rxdp->Control_1 & RXD_FRAME_VLAN_TAG))
>  			ip_off += HEADER_VLAN_SIZE;
>  	} else {
> @@ -8592,7 +8594,7 @@ static void queue_rx_frame(struct sk_buff *skb,
u16
> vlan_tag)
> 
>  	skb->protocol = eth_type_trans(skb, dev);
>  	if (sp->vlgrp && vlan_tag
> -		&& (vlan_strip_flag)) {
> +		&& (sp->vlan_strip_flag)) {
>  		/* Queueing the vlan frame to the upper layer */
>  		if (sp->config.napi)
>  			vlan_hwaccel_receive_skb(skb, sp->vlgrp,
vlan_tag);
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 6722a2f..55cb943 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -962,6 +962,7 @@ struct s2io_nic {
>  	int task_flag;
>  	unsigned long long start_time;
>  	struct vlan_group *vlgrp;
> +	int vlan_strip_flag;
>  #define MSIX_FLG                0xA5
>  	int num_entries;
>  	struct msix_entry *entries;
