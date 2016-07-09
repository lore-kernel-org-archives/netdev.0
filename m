From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sat, 9 Jul 2016 15:30:17 +0300
Message-ID: <20160709153017.791f2607@halley>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
	<20160705130327.GA10737@breakpoint.cc>
	<20160705170541.3f210675@pixies>
	<20160709090020.GB2067@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35206 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbcGIMa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 08:30:26 -0400
Received: by mail-wm0-f45.google.com with SMTP id f65so14588226wmi.0
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2016 05:30:25 -0700 (PDT)
In-Reply-To: <20160709090020.GB2067@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2016 11:00:20 +0200 Florian Westphal <fw@strlen.de> wrote:
> Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> > > How does work if e.g. 1460-sized udp packet arrives on tap0?
> > > Do we fragment (possibly ignoring DF?)  
> > 
> > A *non* gso udp packet arriving on tap0 is bridged to vxlan0 (assuming
> > vxlan mtu is sufficient), and the original DF of the inner packet is
> > preserved.
> > 
> > The skb gets vxlan-udp encapsulated, with outer IP header having DF=0
> > (unless tun_flags & TUNNEL_DONT_FRAGMENT), and then, if skb->len > mtu,
> > fragmented normally at the ip_finish_output --> ip_fragment code path.  
> 
> I see.
> 
> If I understand correctly you have vxlan stacked on top of eth0, and tap
> and vxlan in a bridge.
> 
> ... and eth mtu smaller than bridge mtu.
> 
> I think that this is "working" by pure accident, and that better fix is
> to set mtu values correctly so that when vxlan header is added we don't
> exceed what can be handled by the real device (yes, I know you have
> no control over this).

Let me elaborate a bit regarding the usecase.

Consider nested virtualization. The "host" is a VM which may run in
various different cloud deployments, thus the mtu of this virtual host's
eth0 varies (I've no control over it, nor should I have).

The "host" provides a virtual network for its Nested Guest VMs - the
users of the system.
They are provided with a virtual L2 network with an MTU of their choice
(usually 1500).

Forcing the users runtime varying restrictions on whatever MTUs they
can use in their virtual network (which depend on the current choice of
where the virtual "host" is deployed), means they are forced to alter
their application's setting, per deployment. This is a non solution.

This is why guests' MTUs nor host's eth0 MTU can be set.

We have the option of using user-space based UDP tunnel (instead of
kernel's vxlan or geneve). Aside the downsides not utilizing existing
protocols and implementations, this works well as the encapsulated guest
packets are sent over a standard UDP socket via sendmsg.
As such, these datagrams may get fragmented (in deployments where host's
eth0 mtu is too small), and reassembled at the remote tunnel
termination's ip stack.

Regradless the use-case, there's currently an incosistency in kernel's
behavior:

Consider:

   VM
  eth0  # 1500 mtu; any virtual/emulated NIC that supports TSO
   .
   .
+---------------HOST-+
|  .   __br0__       |
|  .  /       \      |
| tap0       vxlan0  |
|(1500)      (1500)  |
|              .     |
|              .     |
|             eth0   |
|            (1200)  |
+--------------------+

1. If VM disables TSO, it sends 1500-sized IP packets down eth0,
   the frames arrive on tap0, bridged, get encapsulated by vxlan0, and
   the vxlan datagram is then fragmented (as any local datagram would
   have) by ip_finish_output on eth0.

2. If VM enables TSO, we have have a superpacket arriving at tap0
   with total length of say 10000 bytes, with gso_size 1460.
   The superpacket gets encapsulated by vxlan0.
   Finally upon eth0's validate_xmit_skb, the packet is udp-tunnel-segmented
   according to original gso_size of 1460, creating encapsution
   datagrams bigger than eth0's mtu - which are eventually dropped on
   the wire.

This is simply inconsistent: The GSO path should align to the non-GSO
case.
Thus my suggestion: in this specific case, within ip_finish_output_gso,
segment the GSO skb first, then fragment each segment according to dst
mtu. This aligns the GSO vs non-GSO behavior.

> I am worried about this patch, skb_gso_validate_mtu is more costly than
> the ->flags & FORWARD check; everyone pays this extra cost.

I can get back with numbers regarding the impact on local traffic.

I'd appreciate any suggestion how to determine traffic is local OTHER
THAN testing IPSKB_FORWARDED; If we have such a way, there wouldn't be an
impact on local traffic.

> What about setting IPCB FORWARD flag in iptunnel_xmit if
> skb->skb_iif != 0... instead?

Can you please elaborate?

> Yet another possibility would be to reduce gso_size but that violates
> gro/gso symmetry...

We're experimenting this path as well. But as said, fixing the
incosistency above would still be valid.

> [ I tried to check rfc but seems rfc7348 simply declares that
>   endpoints are not allowed to fragment so problem solved :-/ ]

Funny, in Geneve it's only a "best practice" recommendadtion:
  https://tools.ietf.org/html/draft-ietf-nvo3-geneve-02
  section 4.1.1

I'm not keen on vxlan; any UDP based tunnel would do ;-)

Regards,
Shmulik
