From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][CORRECTED] atl1: fix vlan tag regression
Date: Fri, 31 Oct 2008 00:49:01 -0400
Message-ID: <490A8E3D.2010805@garzik.org>
References: <20081029160136.GA28446@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, jie.yang@atheros.com, ramon.casellas@cttc.es,
	netdev@vger.kernel.org, stable@kernel.org, jcliburn@gmail.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54201 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbYJaEtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:49:19 -0400
In-Reply-To: <20081029160136.GA28446@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> Commit 401c0aabec4b97320f962a0161a846d230a6f7aa introduced a regression
> in the atl1 driver by storing the VLAN tag in the wrong TX descriptor
> field.
> 
> This patch causes the VLAN tag to be stored in its proper location.
> 
> Tested-by: Ramon Casellas <ramon.casellas@cttc.es>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> Cc: stable@kernel.org
> ---
> 
> This patch also needs to be applied to 2.6.26.y and 2.6.27.y.
> 
>  drivers/net/atlx/atl1.c |    7 ++++---
>  drivers/net/atlx/atl1.h |    2 +-
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
> index e23ce77..f5edf7a 100644
> --- a/drivers/net/atlx/atl1.c
> +++ b/drivers/net/atlx/atl1.c
> @@ -2317,7 +2317,8 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, u16 count,
>  		if (tpd != ptpd)
>  			memcpy(tpd, ptpd, sizeof(struct tx_packet_desc));
>  		tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
> -		tpd->word2 = (cpu_to_le16(buffer_info->length) &
> +		tpd->word2 &= ~(TPD_BUFLEN_MASK << TPD_BUFLEN_SHIFT);
> +		tpd->word2 |= (cpu_to_le16(buffer_info->length) &
>  			TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIFT;
>  
>  		/*
> @@ -2426,8 +2427,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
>  		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
>  			((vlan_tag >> 9) & 0x8);
>  		ptpd->word3 |= 1 << TPD_INS_VL_TAG_SHIFT;
> -		ptpd->word3 |= (vlan_tag & TPD_VL_TAGGED_MASK) <<
> -			TPD_VL_TAGGED_SHIFT;
> +		ptpd->word2 |= (vlan_tag & TPD_VLANTAG_MASK) <<
> +			TPD_VLANTAG_SHIFT;
>  	}
>  
>  	tso = atl1_tso(adapter, skb, ptpd);
> diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
> index a5015b1..ffa73fc 100644
> --- a/drivers/net/atlx/atl1.h
> +++ b/drivers/net/atlx/atl1.h
> @@ -504,7 +504,7 @@ struct rx_free_desc {
>  #define TPD_PKTNT_MASK		0x0001
>  #define TPD_PKTINT_SHIFT	15
>  #define TPD_VLANTAG_MASK	0xFFFF
> -#define TPD_VLAN_SHIFT		16
> +#define TPD_VLANTAG_SHIFT	16
>  

applied


