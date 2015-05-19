From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Looking for a lost patch
Date: Tue, 19 May 2015 09:57:25 +0200
Message-ID: <20150519075724.GI8928@secunet.com>
References: <55538E1F.2020505@gmail.com>
 <20150518073809.GD8928@secunet.com>
 <555A0D0E.5040102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45052 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755203AbbESH5b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 03:57:31 -0400
Content-Disposition: inline
In-Reply-To: <555A0D0E.5040102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2015 at 09:02:22AM -0700, Alexander Duyck wrote:
> On 05/18/2015 12:38 AM, Steffen Klassert wrote:
> >On Wed, May 13, 2015 at 10:47:11AM -0700, Alexander Duyck wrote:
> >>So I am in the process of trying to do some work on VTI6 and in the
> >>process of doing so I am trying to setup an IPv4 VTI tunnel and I
> >>have come across what appears to be a lost patch.
> >>
> >>So in commit a32452366b72 ("vti4: Don't count header length twice.")
> >>the following change was made:
> >>
> >>diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> >>index 687ddef..cd62596 100644
> >>--- a/net/ipv4/ip_vti.c
> >>+++ b/net/ipv4/ip_vti.c
> >>@@ -349,7 +349,6 @@ static int vti_tunnel_init(struct net_device *dev)
> >>  	memcpy(dev->broadcast, &iph->daddr, 4);
> >>
> >>  	dev->type		= ARPHRD_TUNNEL;
> >>-	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
> >>  	dev->mtu		= ETH_DATA_LEN;
> >>  	dev->flags		= IFF_NOARP;
> >>  	dev->iflink		= 0;
> >>
> >>However in commit f895f0cfbb77 ("Merge branch 'master' of
> >>git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec") the
> >>change appears to have been undone as a result of a merge commit.
> >>
> >>I'm just wondering which is correct.  Should the hard_header_len be
> >>set or unset in vti_tunnel_init?  I ask because I have two kernels
> >>and one has the patch and one does not and I am seeing an MTU of
> >>1332 for a VTI tunnel without, and 1480 for a VTI tunnel with.
> >A MTU of 1332 is definitively wrong. Actually I think a vti
> >tunnel can have a MTU of 1500 because xfrm cares to calculate
> >a PMTU based on the used states. The MTU of 1480 is because
> >the generic ip_tunnel_bind_dev() assumes that an ip tunnel
> >has always the overhead of an additional ip header. On IPsec
> >this header is included in the PMTU calculation.
> 
> So if I understand correctly then is 1480 the correct MTU or should
> I be looking for some other value?

The MTU should be 1500. All the IPsec overhead is handled by PMTU
discovery, just like in the case we use IPsec without vti tunnels.
The IPv6 side of vti does it like that.

> 
> My initial though was to try and find the maximum overhead that can
> be generated for an IPv4/IPSec tunnel.  However it seems like there
> isn't any solid documentation anywhere on what the upper limit is.

There is no fixed upper limit on the overhead. The overhead also depends
on the used crypto algorithm (IV size, chiper block size, ICV size etc.).
That's why we handle this whith PMTU discovery. With this, each path
can have it's own MTU based on the configured xfrm_state.
