From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 2.6.17 0/9] NetXen: 1G/10G Ethernet Driver - patch for big-endian systems
Date: Thu, 24 Aug 2006 23:29:10 +0200
Message-ID: <200608242329.11165.mb@bu3sch.de>
References: <Pine.LNX.4.64.0608180713480.6875@dut39> <Pine.LNX.4.64.0608220038580.18115@dut46> <1156451811.13196.132.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Pradeep Dalvi <pradeep@netxen.com>, netdev@vger.kernel.org,
	"jeff@garzik.org" <jeff@garzik.org>,
	"sanjeev@netxen.com" <sanjeev@netxen.com>,
	"unmproj@linsyssoft.com" <unmproj@linsyssoft.com>,
	Rob Mapes <rob@netxen.com>, amitkale@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51908
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1422673AbWHXVaP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 17:30:15 -0400
To: wen xiong <wendyx@us.ibm.com>
In-Reply-To: <1156451811.13196.132.camel@wendyx.austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 August 2006 22:36, wen xiong wrote:
> 
> Hi All,
> 
> This patch brings the NetXen Ethernet driver to work on big-endian
> systems. I have tested this patch on difference platforms including
> little-endian and big-endian systems. The patch included:
> (1)transmit and receive descriptors endian issue fix.
> (2)MAC address endian issue fix.

Next time please inline the patch in the mail.

> diff -Nuar old/drivers/net/netxen/netxen_nic_hw.c
> new/drivers/net/netxen/netxen_nic_hw.c ---
> old/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 12:58:43.000000000 -0500
> +++ new/drivers/net/netxen/netxen_nic_hw.c	2006-08-23 13:15:19.000000000
> -0500 @@ -313,7 +313,8 @@
>  		}
>  	}
>  	CMD_DESC_TCP_HDR_OFFSET_WRT(desc, skb->h.raw - skb->data);
> -	desc->ip_hdr_offset = skb->nh.raw - skb->data;
> +	desc->length_tcp_hdr=cpu_to_le32(desc->length_tcp_hdr);
                           ^^^
spaces here, please.

> +	desc->ip_hdr_offset  = skb->nh.raw - skb->data;
                           ^^^^
That's one space too much ;) No need to change that line.

> @@ -832,9 +832,9 @@
>  					     rcv_desc->dma_size,
>  					     PCI_DMA_FROMDEVICE);
>  		/* make a rcv descriptor  */
> -		pdesc->reference_handle = __cpu_to_le16(buffer->ref_handle);
> -		pdesc->buffer_length = __cpu_to_le16(rcv_desc->dma_size);
> -		pdesc->addr_buffer = __cpu_to_le64(buffer->dma);
> +		pdesc->reference_handle = le16_to_cpu(buffer->ref_handle);

I think that should be cpu_to_le16()
(although they are technically equal..)

> +		pdesc->buffer_length = le16_to_cpu(rcv_desc->dma_size);

dito

> diff -Nuar old/drivers/net/netxen/netxen_nic_niu.c
> new/drivers/net/netxen/netxen_nic_niu.c ---
> old/drivers/net/netxen/netxen_nic_niu.c	2006-08-23 12:58:43.000000000 -0500
> +++ new/drivers/net/netxen/netxen_nic_niu.c	2006-08-23 13:15:19.000000000
> -0500 @@ -712,6 +712,7 @@
>  		return -EINVAL;
>
>  	memcpy(&temp, addr, 2);
> +	temp=cpu_to_le32(temp);

I think that should be:
	temp = le32_to_cpu(temp);

>  	temp <<= 16;
>  	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
>  				   &temp, 4))
> @@ -720,6 +721,7 @@
>  	temp = 0;
>
>  	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
> +	temp=cpu_to_le32(temp);

dito

>  	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
>  				   &temp, 4))
>  		return -EIO;
> @@ -760,7 +762,7 @@
>  long netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
>  					long port, netxen_niu_prom_mode_t mode)
>  {
> -	long reg;
> +	netxen_crbword_t reg;
>
>  	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
>  		return -EINVAL;

-- 
Greetings Michael.
