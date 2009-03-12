From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] igb: allow tx of pre-formatted vlan tagged packets
Date: Thu, 12 Mar 2009 13:51:19 -0700
Message-ID: <20090312135119.3a715480@nehalam>
References: <20090312202724.GA9876@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>
To: Arthur Jones <ajones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37362 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbZCLUvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2009 16:51:24 -0400
In-Reply-To: <20090312202724.GA9876@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Mar 2009 13:27:24 -0700
Arthur Jones <ajones@riverbed.com> wrote:

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
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  drivers/net/igb/igb_main.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)

That code in current igb driver (net-next-2.6) tree no longer has
the whole switch you are changing.



> diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
> index fddeece..99ba3a5 100644
> --- a/drivers/net/igb/igb_main.c
> +++ b/drivers/net/igb/igb_main.c
> @@ -2778,7 +2778,17 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
>  		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
>  
>  		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> -			switch (skb->protocol) {
> +			__be16 protocol;
> +
> +			if (skb->protocol == __constant_htons(ETH_P_8021Q)) {

Don't use __constant_htons() here, macro is smart enough to know when
value is const.

> +				const struct vlan_ethhdr *vhdr =
> +					(const struct vlan_ethhdr *) skb->data;
> +
> +				protocol = vhdr->h_vlan_encapsulated_proto;
> +			} else
> +				protocol = skb->protocol;
> +
> +			switch (protocol) {
>  			case __constant_htons(ETH_P_IP):
>  				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
>  				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
