From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Convert to net_device_ops
Date: Sat, 28 Mar 2009 12:27:09 +0100
Message-ID: <OF13743B7F.C32B8685-ONC1257587.003E2ABA-C1257587.003EE8DA@transmode.se>
References: <OFA0B803BB.DEC93B9A-ONC1257583.0039CF3E-C1257583.003A55BA@transmode.se>	 <20090324.142209.234280606.davem@davemloft.net>
	 <OF603BDF0B.B740DD77-ONC1257583.007CAD9B-C1257583.007CFD35@transmode.se>
	 <20090324.154902.206324978.davem@davemloft.net>	 <OF4B79F4DE.4DC6DEA7-ONC1257583.007ECBEA-C1257583.007F2805@transmode.se> <ed82fe3e0903271150v34fc18cbua6bb7918a3a71c71@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: avorontsov@ru.mvista.com, David Miller <davem@davemloft.net>,
	leoli@freescale.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, timur.tabi@gmail.com
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:46430 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754127AbZC1L1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2009 07:27:13 -0400
In-Reply-To: <ed82fe3e0903271150v34fc18cbua6bb7918a3a71c71@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

timur.tabi@gmail.com wrote on 27/03/2009 19:50:30:

> 
> On Tue, Mar 24, 2009 at 6:08 PM, Joakim Tjernlund
> <Joakim.Tjernlund@transmode.se> wrote:
> 
> > +       .ndo_change_mtu         = eth_change_mtu,
> 
> I have an old patch for change_mtu support for ucc_geth which I've
> been meaning to push upstream.  This patch uses this function instead
> of eth_change_mtu():
> 
> +static int ucc_geth_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +   int max_rx_buf_length;
> +   struct ucc_geth_private *ugeth = netdev_priv(dev);
> +   int frame_size = new_mtu + 18;
> +   struct ucc_geth_info *ug_info;
> +   struct ucc_fast_info *uf_info;
> +
> +   if (ugeth->p_rx_glbl_pram) {
> +      printk("%s: Interface is active!\n", __FUNCTION__);
> +   } else {
> +
> +      ug_info = ugeth->ug_info;
> +      uf_info = &ug_info->uf_info;
> +
> +      if ((frame_size < 64) || (frame_size > JUMBO_FRAME_SIZE)) {
> +         printk(KERN_ERR "%s: Invalid MTU setting\n", dev->name);
> +         return -EINVAL;
> +      }
> +
> +      max_rx_buf_length =
> +          (frame_size & ~(UCC_GETH_MRBLR_ALIGNMENT - 1)) +
> +          UCC_GETH_MRBLR_ALIGNMENT;
> +
> +      ugeth->ug_info->uf_info.max_rx_buf_length = max_rx_buf_length;
> +      dev->mtu = new_mtu;
> +
> +      /* Set the max. rx buffer size (MRBLR) */
> +      uf_info->max_rx_buf_length = max_rx_buf_length;
> +
> +      /* set the max. frame length (MFLR) */
> +      ug_info->maxFrameLength = frame_size;
> +
> +      ugeth_info("%s: MTU = %d (frame size=%d)\n", dev->name,
> +             dev->mtu, frame_size);
> +   }
> +   return 0;
> +}
> 
> Do you think this is how it should be done?  I don't know enough about
> ucc_geth and MTUs to know off-hand.

Not quite so. I don't think you can support JUMBO frames with just one big 
RX buffer.
Also, maxframe & RX buffer should be somewhat bigger than the actual mtu 
so you can
support VLAN(4) and PPPOE(8) = 12 bytes.
You need to add 12 bytes to the default values too.

 Jocke 

