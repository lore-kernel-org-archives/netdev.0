From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH] igb: allow tx of pre-formatted vlan tagged packets
Date: Thu, 12 Mar 2009 15:30:02 -0700
Message-ID: <49B98CEA.7010306@intel.com>
References: <20090312202724.GA9876@ajones-laptop.nbttech.com> <20090312213345.GA12653@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:3715 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753085AbZCLWaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 18:30:05 -0400
In-Reply-To: <20090312213345.GA12653@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have added a few comments inline.

Arthur Jones wrote:
> When the 82575 is fed 802.1q packets, it chokes with
> an error of the form:
> 
> igb 0000:08:00.1: partial checksum but proto=81
> 
> As the logic there was not smart enough to look into
> the vlan header to pick out the encapsulated protocol.
> 
> There are times when we'd like to send these packets
> out without having to configure a vlan on the interface.
> Here we check for the vlan tag and allow the packet to
> go out with the correct hardware checksum.
> 
> Thanks to Kand Ly <kand@riverbed.com> for discovering the
> issue and the coming up with a solution.  This patch is
> based upon his work.
> 
> Macro fixups from Stephen Hemminger <shemminger@vyatta.com>
> 
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  drivers/net/igb/igb_main.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index 78558f8..e4ef1f6 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -3017,7 +3017,17 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
>  		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
>  
>  		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> -			switch (skb->protocol) {
> +			__be16 protocol;
> +
> +			if (skb->protocol == cpu_to_be16(ETH_P_8021Q)) {
> +				const struct vlan_ethhdr *vhdr =
> +					(const struct vlan_ethhdr *) skb->data;
This should probably reference skb_mac_header(skb) instead of data in 
the event that data is an offset instead of a pointer.

> +
> +				protocol = vhdr->h_vlan_encapsulated_proto;
> +			} else
> +				protocol = skb->protocol;
> +
This else should have braces since the matching if was using braces.

> +			switch (protocol) {
>  			case cpu_to_be16(ETH_P_IP):
>  				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
>  				if (ip_hdr(skb)->protocol == IPPROTO_TCP)

Thanks,

Alex
