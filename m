From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci
 field value
Date: Tue, 08 Jan 2013 12:04:52 -0800
Message-ID: <1357675492.18156.420.camel@edumazet-glaptop>
References: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
	 <1357671093-9605-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:45392 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab3AHUEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 15:04:55 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so537151pad.19
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 12:04:54 -0800 (PST)
In-Reply-To: <1357671093-9605-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-08 at 19:51 +0100, Daniel Borkmann wrote:
> VLAN packets that are locally injected through taps will loose their
> skb->vlan_tci value when they pass dev_hard_start_xmit and get looped
> back to a packet sniffer via dev_queue_xmit_nit. Besides others, this
> meta data is used in Linux socket filtering for VLANs. Tested with a
> VLAN ancillary ops filter.
> 
> Patch is based on a previous version by Jiri Pirko.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Ani Sinha <ani@aristanetworks.com>
> Cc: Jiri Pirko <jpirko@redhat.com>
> Reported-by: Paul Pearce <pearce@cs.berkeley.edu>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/core/dev.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 515473e..723dcd0 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1775,6 +1775,19 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
>  	struct packet_type *ptype;
>  	struct sk_buff *skb2 = NULL;
>  	struct packet_type *pt_prev = NULL;
> +	struct ethhdr *ehdr;
> +
> +	/* Network taps could make use of skb->vlan_tci, which got wiped
> +	 * out. Hence, we need to reset it correctly.
> +	 */
> +	skb_reset_mac_header(skb);
> +	ehdr = eth_hdr(skb);
> +
> +	if (ehdr->h_proto == __constant_htons(ETH_P_8021Q)) {
> +		skb2 = vlan_untag(skb);
> +		if (likely(skb2))
> +			skb = skb2;
> +	}
>  
>  	rcu_read_lock();
>  	list_for_each_entry_rcu(ptype, &ptype_all, list) {

This patch is wrong (it adds a leak), and not needed.

If a packet has no vlan_tci, its for a good reason.

We want sniffer see the packet content as is.
