From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Thu, 13 Feb 2014 16:04:02 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1402131600120.8285@intel.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com> <52FC7D0C.1020601@mellanox.com> <CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com> <CAJZOPZKRiR-XZo1b9-TQG9ULpVhL31bTBD+4Z7T+ODZcPX_L2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Herbert <therbert@google.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:49683 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751031AbaBMXpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 18:45:17 -0500
In-Reply-To: <CAJZOPZKRiR-XZo1b9-TQG9ULpVhL31bTBD+4Z7T+ODZcPX_L2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 13 Feb 2014, Or Gerlitz wrote:

> On Fri, Feb 14, 2014 at 12:27 AM, Tom Herbert <therbert@google.com> wrote:
> 
> >> [...] this is according to the conventions set by
> >> 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
> >> 6a674e9 net: Add support for hardware-offloaded encapsulation
> >> B/c after finalizing the GRO work and decapsulating, skb injected up into
> >> the TCP stack with ip_summed equals to CHECKSUM_NONE are rejected. If >> this assumption is wrong, maybe we can remove testing the ip_summed field
> >> here altogether?
> 
> > If I'm interpreting the semantics correctly, when skb->encapsulation
> > is set the ip_summed is valid for both the inner and outer header
> > (e.g. CHECKSUM_COMPLETE is always assumed okay for both layers). If
> > skb->encapsulation is not set then ip_summed is only valid for outer header.
> 
> Yep, I think this would be correct interpertation, Joseph, agree?

Agreed.

> 
> > So then the patch is broken in the case that encap is not set,
> > ip_summed is CHECKSUM_UNNECESSARY, csum == 0, and we need to
> > validate the inner checksum.
> 
> Just to make sure, by "the patch" you refer to your patch or the current code?
> 
> > But even worse, is there a fundamental issue where udp4_csum_init is able
> > to change ip_summed to be CHECKSUM_UNNECESSARY (either check == 0
> > or ip_summed == CHECKSUM_UNNECESSARY) regardless of
> > skb->encapsulation, sending the packet into encap_rcv which could
> > ultimately incorrectly apply ip_summed on the inner TCP/UDP packet?
> 
> By fundamental you mean performance issue or functionality issue (bug) or both?
> 

I would expect the check to be for ip_summed == CHECKSUM_UNNECESSARY. This 
was the original thought behind commit:

0afb166 vxlan: Add capability of Rx checksum offload for inner packet
