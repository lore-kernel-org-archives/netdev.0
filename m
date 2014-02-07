From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Question about skb_flow_dissect() and 802.1q/802.1ad
Date: Fri, 07 Feb 2014 11:11:25 -0800
Message-ID: <1391800285.10160.62.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396838.WXqPOv9eKS@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergey Popovich <popovich_sergei@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:44420 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbaBGTL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 14:11:28 -0500
Received: by mail-pb0-f52.google.com with SMTP id jt11so3636926pbb.25
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 11:11:28 -0800 (PST)
In-Reply-To: <1396838.WXqPOv9eKS@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-07 at 20:44 +0200, Sergey Popovich wrote:
> Hello.
> 
> skb_flow_dissect() adds good code reuse for common task
> of finding information in protocol headers and used in various
> places.
> 
> One of such place since commit 32819dc183 (bonding: modify the old and add
> new xmit hash policies) is bonding interface.
> 
> My question is following:
> -------------------------
>   why network offset is used in skb_flow_dissector() when looking for 
>   802.1q/802.1ad header instead of skb->data?
> 
> At least affects stacked vlans setup on top of bonding interface (where not
> HW VLAN TX available, tag is put into skb in xmit path, and skb->protocol ==
> htons(ETH_P_8021Q). Bonding is setup on top of HW VLAN TX capable network
> interface (igb) with 802.3ad (LACP) mode and xmit_hash_policy encap2+3.
> 
> In this setup skb_flow_dissect() fails to get information from protocol headers
> encapsulated within inner vlan, probably because it uses network offset instead
> of skb->data.
> 

Check all callers of skb_flow_dissect() : 

skb->data not always point to what you think.

> Hashing is performed on layer 2 information as fallback when skb_flow_dissect()
> fails. Which affects packet distribution accross slaves.
> 
> However, stacked vlans on top of bonding interface was not working in the past,
> so commit 32819dc183 does not introduce regression. Furthermore starting from
> such one I expect stacked vlans on top of bonding to work in encap2+3 and
> encap3+4 xmit hash policies, as skb_flow_dissect() knowns about such
> encapsulations and should take case of them.
> 
> Simple patch, that seems to work for me listed below.


Well, all you need is to properly set network header before calling
skb_flow_dissect()

> 
> ---
>  net/core/flow_dissector.c |   17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index b4f9af8..7cdf13b 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -52,6 +52,7 @@ EXPORT_SYMBOL(skb_flow_get_ports);
>  bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
>  {
>  	int nhoff = skb_network_offset(skb);
> +	int vhoff = offsetof(struct vlan_ethhdr, h_vlan_TCI);
>  	u8 ip_proto;
>  	__be16 proto = skb->protocol;
>  
> @@ -91,15 +92,19 @@ ipv6:
>  	}
>  	case __constant_htons(ETH_P_8021AD):
>  	case __constant_htons(ETH_P_8021Q): {
> -		const struct vlan_hdr *vlan;
> -		struct vlan_hdr _vlan;
> +		const struct vlan_hdr *hdr;
> +		struct vlan_hdr _hdr;

Why changing nice variable names with not vlan ones ?

All is about headers. hdr and _hdr are vague.

>  
> -		vlan = skb_header_pointer(skb, nhoff, sizeof(_vlan), &_vlan);
> -		if (!vlan)
> +		BUILD_BUG_ON(sizeof(struct vlan_ethhdr) !=
> +			     offsetof(struct vlan_ethhdr, h_vlan_TCI) +
> +			     sizeof(*hdr));
> +
> +		hdr = skb_header_pointer(skb, vhoff, sizeof(_hdr), &_hdr);
> +		if (!hdr)
>  			return false;
>  
> -		proto = vlan->h_vlan_encapsulated_proto;
> -		nhoff += sizeof(*vlan);
> +		proto = hdr->h_vlan_encapsulated_proto;
> +		vhoff += sizeof(*hdr);
>  		goto again;
>  	}
>  	case __constant_htons(ETH_P_PPP_SES): {
