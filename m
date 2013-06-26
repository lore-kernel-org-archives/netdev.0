From: Jim Baxter <jim_baxter@mentor.com>
Subject: Re: [PATCH net-next v1 1/1] net: fec: Add VLAN receive HW support.
Date: Wed, 26 Jun 2013 11:09:20 +0100
Message-ID: <51CABDD0.7050606@mentor.com>
References: <Jim Baxter <jim_baxter@mentor.com> <1372204524-27798-1-git-send-email-jim_baxter@mentor.com> <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Li Frank-B20596 <B20596@freescale.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Lucas Stach <l.stach@pengutronix.de>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Duan Fugang-B38611 <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:42541 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3FZKJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 06:09:25 -0400
In-Reply-To: <9848F2DB572E5649BA045B288BE08FBE014FE4E1@039-SN2MPN1-023.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/06/13 03:31, Duan Fugang-B38611 wrote:
> In addition,
> 	1.	enet IP support hw VLAN detect such as imx28-fec, imx6q-fec and mvf600-fec, so you can add the "BD_ENET_RX_VLAN " to those platform driver_data.
I have only tested it on the i.MX6, if someone wants to check it on the
imx28 later they can add it to that option.

> 	2.	Enable the VLAN tag extraction with "NETIF_F_HW_VLAN_CTAG_RX" feature in .ndo_fix_features, which is configured by user.
What do you mean by this, I am only enabling the VLAN code if
(ndev->features & NETIF_F_HW_VLAN_CTAG_RX) is set. I am pretty sure this
is set by

>   */
> -#define PKT_MAXBUF_SIZE		1518
> +#define PKT_MAXBUF_SIZE		1522
>  #define PKT_MINBUF_SIZE		64
> -#define PKT_MAXBLR_SIZE		1520
> +#define PKT_MAXBLR_SIZE		1540
> [Andy]Pls define the MAXBLR size to 1536, which is multiplied by 64
> 	 #define PKT_MAXBLR_SIZE         1536
I will change this.


> +			int payload_offset = (2 * ETH_ALEN);
>  			skb_reserve(skb, NET_IP_ALIGN);
>  			skb_put(skb, pkt_len - 4);	/* Make room */
> -			skb_copy_to_linear_data(skb, data, pkt_len - 4);
> +
> +			/* Extract the frame data without the VLAN header. */
> +			skb_copy_to_linear_data(skb, data, (2 * ETH_ALEN));
> +			if (vlan_packet_rcvd)
> +				payload_offset = (2 * ETH_ALEN) + VLAN_HLEN;
> +			skb_copy_to_linear_data_offset(skb, (2 * ETH_ALEN),
> +					data + payload_offset,
> +					pkt_len - 4 - (2 * ETH_ALEN));
> +
> [Andy] because the IP don't support HW VLAN tag extraction, it need sw to do it. It is ok for me. 
Yes it needs to be done in software as the Ethernet card only detects
the VLAN packet, doing it here is more efficient then the kernel doing it.


Thank you,
Jim
