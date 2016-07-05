From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Tue, 5 Jul 2016 15:03:27 +0200
Message-ID: <20160705130327.GA10737@breakpoint.cc>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:56430 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932877AbcGENDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 09:03:36 -0400
Content-Disposition: inline
In-Reply-To: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> Given:
>  - tap0, vxlan0 enslaved under a bridge
>  - eth0 is the tunnel underlay having small mtu (e.g. 1400)
> 
> Assume GSO skbs arriving from tap0 having a gso_size as determined by
> user-provided virtio_net_hdr (e.g. 1460 corresponding to VM mtu of 1500).
> 
> After encapsulation these skbs have skb_gso_network_seglen that exceed
> underlay ip_skb_dst_mtu.
> 
> These skbs are accidentally passed to ip_finish_output2 AS IS; however
> each final segment (either segmented by validate_xmit_skb of eth0, or
> by eth0 hardware UFO) would be larger than eth0 mtu.
> As a result, those above-mtu segments get dropped on certain underlay
> networks.
> 
> The expected behavior in such a setup would be segmenting the skb first,
> and then fragmenting each segment according to dst mtu, and finally
> passing the resulting fragments to ip_finish_output2.
> 
> 'ip_finish_output_gso' already supports this "Slowpath" behavior,
> but it is only considered if IPSKB_FORWARDED is set.
> 
> However in the bridged case, IPSKB_FORWARDED is off, and the "Slowpath"
> behavior is not considered.

I placed this test there under the assumption that L2 bridges have
the same MTU on all bridge ports, so we'd only need to consider routing
case.

How does work if e.g. 1460-sized udp packet arrives on tap0?
Do we fragment (possibly ignoring DF?)

How does it work for non-ip protocols?

(Or did I misunderstand this setup...?)
