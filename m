From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] ixgbe: fix gso type
Date: Wed, 06 Feb 2013 19:21:32 -0800
Message-ID: <1360207292.28557.49.camel@edumazet-glaptop>
References: <cover.1360191528.git.mst@redhat.com>
	 <76c44c70077f42302d7b079b29fd414205747af5.1360191528.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	bhutchings@solarflare.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:63496 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869Ab3BGDVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 22:21:36 -0500
In-Reply-To: <76c44c70077f42302d7b079b29fd414205747af5.1360191528.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-07 at 01:02 +0200, Michael S. Tsirkin wrote:
> ixgbe set gso_size but not gso_type. This leads to
> crashes in macvtap.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> I tested that this fixes the crash for me.  I am told on ixgbe LRO only
> triggers with TCP so checking protocol should be enough?
> 
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 396e280..9d01673 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1399,6 +1399,10 @@ static void ixgbe_set_rsc_gso_size(struct ixgbe_ring *ring,
>  	/* set gso_size to avoid messing up TCP MSS */
>  	skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->len - hdr_len),
>  						 IXGBE_CB(skb)->append_cnt);
> +	if (skb->protocol == ETH_P_IPV6)

Same problem here (skb->protocol == htons(ETH_P_IPV6))

> +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> +	else
> +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
>  }
>  
