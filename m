From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Thu, 14 Jul 2016 17:13:33 +0300
Message-ID: <20160714171333.00657367@pixies>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
	<20160709090020.GB2067@breakpoint.cc>
	<20160709153017.791f2607@halley>
	<20160709132230.GD2067@breakpoint.cc>
	<20160712085656.79f1c5fc@halley>
	<20160713170038.1d02eb2b@halley>
	<1468501927.1817077.666165049.62D074FE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:33655 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbcGNONk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 10:13:40 -0400
Received: by mail-lf0-f54.google.com with SMTP id b199so65162209lfe.0
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 07:13:39 -0700 (PDT)
In-Reply-To: <1468501927.1817077.666165049.62D074FE@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 14 Jul 2016 15:12:07 +0200, hannes@stressinduktion.org wrote:
> I liked the fact that setting IPSKB_FORWARDED was only contained in
> vxlan and as such wouldn't have as much impact. It was more logically
> easy to review for me actually.

I agree here. It is rather safe and to the point.

I'm trying to exaust other alternatives because it has one potential
drawback: the name IPSKB_FORWARDED suggests ipv4 forwarding had
happened. Indeed, current setters of IPSKB_FORWARDED are ip_forward and
ip_mr_forward.

If we set IPSKB_FORWARDED in iptunnel_xmit, with packet not being ipv4
forwarded (e.g. bridged from some ingress device to a tunnel device), it
presents a nuance whose impact is yet to be determined.

For example, what about a packet that gets encapsulated and sent to a
multicast destination? The condition controlling mc loop-back in
ip_mc_output is affected by the flag.

> > Which ensures only the following conditions go to the expensive
> > skb_gso_validate_mtu:
> > 
> > 1. IPSKB_FORWARDED is on
> > 2. IPSKB_FORWARDED is off, but sk exists and gso_size is untrusted.
> >    Meaning: we have a packet arriving from higher layers (sk is set)
> >    with a gso_size out of host's control.
> 
> When can this really happen? In general we don't want to refragment gso
> skb's and I think we can only make an exception for vxlan or udp.

When IPSKB_FORWARDED is off, we'll get SKB_GSO_DODGY if packet
originally arrived from tap/macvtap/packet and it did NOT pass ipv4
forwarding (e.g bridges: tap0 to eth0 bridge, or tap0 to vxlan0 bridge).

The rationale: in the SKB_GSO_DODGY cases, the gso_size is given by
the user's virtio-net header, which is not in kernel's control.

This exactly resembles the usecase: tap0 gives packets with gso_size
unsuitable for encapsulation and segmentation. I have no control on
the source that gives those packets.

If (1) it does not make sense, or (2) considered too broad-spectrum to
asses, then we can go with the safer IPSKB_FORWARDED approach.

Let me know.

Regards,
Shmulik
