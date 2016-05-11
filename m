From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Thu, 12 May 2016 07:46:52 +0900
Message-ID: <20160511224650.GA12481@penelope.isobedori.kobe.vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <CAOrHB_AMC4x=NnLTpGbXdW31Vp0f1R3VoaD9ksST5EesrdGsug@mail.gmail.com>
 <20160506055705.GA9276@penelope.isobedori.kobe.vergenet.net>
 <20160506112514.47f6e9dc@griffin>
 <20160509080420.GA4470@vergenet.net>
 <20160510140106.367936fb@griffin>
 <20160511015009.GB24436@vergenet.net>
 <20160511030632.GA24805@vergenet.net>
 <20160511160928.27816400@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33570 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbcEKWrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 18:47:02 -0400
Received: by mail-pf0-f181.google.com with SMTP id 206so23352595pfu.0
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 15:47:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160511160928.27816400@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 11, 2016 at 04:09:28PM +0200, Jiri Benc wrote:
> On Wed, 11 May 2016 12:06:35 +0900, Simon Horman wrote:
> > Is this close to what you had in mind?
> 
> Yes but see below.
> 
> > @@ -739,17 +729,17 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
> >  	key->phy.skb_mark = skb->mark;
> >  	ovs_ct_fill_key(skb, key);
> >  	key->ovs_flow_hash = 0;
> > -	key->phy.is_layer3 = is_layer3;
> > +	key->phy.is_layer3 = (tun_info && skb->mac_len == 0);
> 
> Do we have to depend on tun_info? It would be nice to support all
> ARPHRD_NONE interfaces, not just tunnels. The tun interface (from
> the tuntap driver) comes to mind, for example.

Yes, I think that should work. I was just being cautious.

Do you think it is safe to detect TEB based on skb->protocol regardless
of the presence of tun_info?

> > +++ b/net/openvswitch/vport-netdev.c
> > @@ -60,7 +60,21 @@ static void netdev_port_receive(struct sk_buff *skb)
> >  	if (vport->dev->type == ARPHRD_ETHER) {
> >  		skb_push(skb, ETH_HLEN);
> >  		skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
> > +	} else if (vport->dev->type == ARPHRD_NONE) {
> > +		if (skb->protocol == htons(ETH_P_TEB)) {
> > +			struct ethhdr *eth = eth_hdr(skb);
> > +
> > +			if (unlikely(skb->len < ETH_HLEN))
> > +				goto error;
> > +
> > +			skb->mac_len = ETH_HLEN;
> > +			if (eth->h_proto == htons(ETH_P_8021Q))
> > +				skb->mac_len += VLAN_HLEN;
> > +		} else {
> > +			skb->mac_len = 0;
> > +		}
> 
> Without putting much thought into this, could this perhaps be left for
> parse_ethertype (called from key_extract) to do?

I think I am confused.

I believe that key_extract() does already do all of the above (and more).

The purpose of the above change was to do this work here rather than
leaving it to parse_ethertype. This is because I was under the impression
that is what you were after. Specifically as a mechanism to avoid relying
on vport->dev->type in ovs_flow_key_extract.

If we can live with a bogus skb->mac_len value that is sufficient for
ovs_flow_key_extract.() and set correctly by key_extract() (which happens
anyway) we could do something like this:

	} else if (vport->dev->type == ARPHRD_NONE) {
		if (skb->protocol == htons(ETH_P_TEB))
			/* Ignores presence of VLAN but is sufficient for
			 * ovs_flow_key_extract() which then calls key_extract()
			 * which calculates skb->mac_len correctly. */
			skb->mac_len = ETH_HLEN; /* Ignores presence of VLAN */
		else
			skb->mac_len = 0;
	}


But perhaps I have missed the point somehow.
