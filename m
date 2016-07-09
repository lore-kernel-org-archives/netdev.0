From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sat, 9 Jul 2016 11:00:20 +0200
Message-ID: <20160709090020.GB2067@breakpoint.cc>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc>
 <20160705170541.3f210675@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36030 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932860AbcGIJAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 05:00:30 -0400
Content-Disposition: inline
In-Reply-To: <20160705170541.3f210675@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:

[ CC 
> On Tue, 5 Jul 2016 15:03:27 +0200, fw@strlen.de wrote:
> > > The expected behavior in such a setup would be segmenting the skb first,
> > > and then fragmenting each segment according to dst mtu, and finally
> > > passing the resulting fragments to ip_finish_output2.
> > > 
> > > 'ip_finish_output_gso' already supports this "Slowpath" behavior,
> > > but it is only considered if IPSKB_FORWARDED is set.
> > > 
> > > However in the bridged case, IPSKB_FORWARDED is off, and the "Slowpath"
> > > behavior is not considered.
> > 
> > I placed this test there under the assumption that L2 bridges have
> > the same MTU on all bridge ports, so we'd only need to consider routing
> > case.
> 
> In our setups we have no control of VM mtu (which affects gso_size of
> packets arriving from tap), and no control of vxlan's underlay mtu.

:-(

> > How does work if e.g. 1460-sized udp packet arrives on tap0?
> > Do we fragment (possibly ignoring DF?)
> 
> A *non* gso udp packet arriving on tap0 is bridged to vxlan0 (assuming
> vxlan mtu is sufficient), and the original DF of the inner packet is
> preserved.
> 
> The skb gets vxlan-udp encapsulated, with outer IP header having DF=0
> (unless tun_flags & TUNNEL_DONT_FRAGMENT), and then, if skb->len > mtu,
> fragmented normally at the ip_finish_output --> ip_fragment code path.

I see.

> So on wire we have 2 frags of the vxlan datagram; they are reassembled
> at recepient ip stack of vxlan termination. Inner packet preserved.
> Not ideal, but works.
> 
> The issue is with GSO skbs arriving from tap, which eventually generates
> segments larger then the mtu, which are not transmitted on eth0:
> 
>   tap0 rx:  super packet, gso_size from user's virtio_net_hdr
>     ...
>     vxlan0 tx:  encaps the super packet
>       ...
>       ip_finish_output
>         ip_finish_output_gso
>           *NO* skb_gso_validate_mtu()     <--- problem here

We don't do this for ipv6 either since we're expected to send PKTOOBIG
error.

>             ip_finish_output2:  tx the encapsulated super packet on eth0
>               ...
>               validate_xmit_skb
>                 netif_needs_gso
>                   skb_gso_segment: segments inner payload according to
>                                    original gso_size,
>                                    leads to vxlan datagrams larger than mtu
>
> > How does it work for non-ip protocols?
> 
> The specific problem is with vxlan (or any other udp based tunnel)
> encapsulated GSOed packets.

If I understand correctly you have vxlan stacked on top of eth0, and tap
and vxlan in a bridge.

... and eth mtu smaller than bridge mtu.

I think that this is "working" by pure accident, and that better fix is
to set mtu values correctly so that when vxlan header is added we don't
exceed what can be handled by the real device (yes, I know you have
no control over this).

I am worried about this patch, skb_gso_validate_mtu is more costly than
the ->flags & FORWARD check; everyone pays this extra cost.

What about setting IPCB FORWARD flag in iptunnel_xmit if
skb->skb_iif != 0... instead?

Yet another possibility would be to reduce gso_size but that violates
gro/gso symmetry...

[ I tried to check rfc but seems rfc7348 simply declares that
  endpoints are not allowed to fragment so problem solved :-/ ]
