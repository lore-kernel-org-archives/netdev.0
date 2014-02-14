From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Fri, 14 Feb 2014 10:34:56 -0800 (PST)
Message-ID: <alpine.LFD.2.03.1402141034180.25492@intel.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com> <52FC7D0C.1020601@mellanox.com> <CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com> <CAJZOPZKRiR-XZo1b9-TQG9ULpVhL31bTBD+4Z7T+ODZcPX_L2g@mail.gmail.com>
 <alpine.LFD.2.03.1402131600120.8285@intel.com> <CA+mtBx8qbLU3vgDjPQPtU47+FS9R7f24gYw5wE+yNC7DGg-E4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbaBNSRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 13:17:03 -0500
In-Reply-To: <CA+mtBx8qbLU3vgDjPQPtU47+FS9R7f24gYw5wE+yNC7DGg-E4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 13 Feb 2014, Tom Herbert wrote:

> >> > But even worse, is there a fundamental issue where udp4_csum_init is able
> >> > to change ip_summed to be CHECKSUM_UNNECESSARY (either check == 0
> >> > or ip_summed == CHECKSUM_UNNECESSARY) regardless of
> >> > skb->encapsulation, sending the packet into encap_rcv which could
> >> > ultimately incorrectly apply ip_summed on the inner TCP/UDP packet?
> >>
> >> By fundamental you mean performance issue or functionality issue (bug) or both?
> >>
> >
> > I would expect the check to be for ip_summed == CHECKSUM_UNNECESSARY. This
> > was the original thought behind commit:
> >
> > 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
> 
> It looks like udp4_csum_init turns CHECKSUM_COMPLETE and check==0 into
> CHECKSUM_UNNECESSARY which could bypass the checksum validation for
> the encapsulated packet. This would be a significant functionality
> bug. Unfortunately udp4_csum_init writes ip_summed without regard to
> encapsulation.
> 
> Seems like the logic in the UDP rcv path should be:
> 
> if ip_summed == CHECKSUM_COMPLETE, ensure this is same value when
> calling encap_rcv
> if ip_summed == CHECKSUM_UNNECESSARY && !skb->encap change to
> CHECKSUM_NONE before calling encap_rcv
> if ip_summed == CHECKSUM_UNNECESSARY && skb->encap ip_summed value is okay
> 
> In any case, we need to consider the orignal ip_summed value from the
> driver, not the one that udp4_csum_init (udp_gro or anywhere else in
> the path) would set.
> 
> Also, udp_gro_receive should be able to handle the case where
> ip_summed == CHECKSUM_UNNECESSARY and !skb->encapsulation, that will
> be very common scenario. Probably CHECKSUM_NONE also.
> 

Yes, I now see your point and totaly agree. Thanks.
