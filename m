From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Wed, 11 May 2016 16:09:28 +0200
Message-ID: <20160511160928.27816400@griffin>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
	<1462347393-22354-5-git-send-email-simon.horman@netronome.com>
	<CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
	<20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
	<20160506112514.47f6e9dc@griffin>
	<20160509080420.GA4470@vergenet.net>
	<20160510140106.367936fb@griffin>
	<20160511015009.GB24436@vergenet.net>
	<20160511030632.GA24805@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932613AbcEKOJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 10:09:33 -0400
In-Reply-To: <20160511030632.GA24805@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 May 2016 12:06:35 +0900, Simon Horman wrote:
> Is this close to what you had in mind?

Yes but see below.

> @@ -739,17 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
>  	key->phy.skb_mark = skb->mark;
>  	ovs_ct_fill_key(skb, key);
>  	key->ovs_flow_hash = 0;
> -	key->phy.is_layer3 = is_layer3;
> +	key->phy.is_layer3 = (tun_info && skb->mac_len == 0);

Do we have to depend on tun_info? It would be nice to support all
ARPHRD_NONE interfaces, not just tunnels. The tun interface (from
the tuntap driver) comes to mind, for example.

> --- a/net/openvswitch/vport-netdev.c
> +++ b/net/openvswitch/vport-netdev.c
> @@ -60,7 +60,21 @@ static void netdev_port_receive(struct sk_buff *skb)
>  	if (vport->dev->type == ARPHRD_ETHER) {
>  		skb_push(skb, ETH_HLEN);
>  		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> +	} else if (vport->dev->type == ARPHRD_NONE) {
> +		if (skb->protocol == htons(ETH_P_TEB)) {
> +			struct ethhdr *eth = eth_hdr(skb);
> +
> +			if (unlikely(skb->len < ETH_HLEN))
> +				goto error;
> +
> +			skb->mac_len = ETH_HLEN;
> +			if (eth->h_proto == htons(ETH_P_8021Q))
> +				skb->mac_len += VLAN_HLEN;
> +		} else {
> +			skb->mac_len = 0;
> +		}

Without putting much thought into this, could this perhaps be left for
parse_ethertype (called from key_extract) to do?

Thanks,

 Jiri
