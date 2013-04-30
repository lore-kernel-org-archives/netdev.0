From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 2/2] net: Loosen constraints for recalculating
 checksum in skb_segment()
Date: Tue, 30 Apr 2013 12:17:02 +0900
Message-ID: <20130430031701.GB26726@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
 <1366683556-4956-3-git-send-email-horms@verge.net.au>
 <CAEP_g=_nTah2xN2KHxBPtYQyFUWH+8frybGt1Zv=0Q9ButZH5w@mail.gmail.com>
 <20130425072623.GB7936@verge.net.au>
 <CAEP_g=94-Nsia9xCTwe0=2VnZgESZ6XHPJQ96FwrsgPTWEbiWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:45684 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab3D3DRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 23:17:05 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=94-Nsia9xCTwe0=2VnZgESZ6XHPJQ96FwrsgPTWEbiWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 01:01:44PM -0700, Jesse Gross wrote:
> On Thu, Apr 25, 2013 at 12:26 AM, Simon Horman <horms@verge.net.au> wrote:
> > On Tue, Apr 23, 2013 at 04:43:58PM -0700, Jesse Gross wrote:
> >> On Mon, Apr 22, 2013 at 7:19 PM, Simon Horman <horms@verge.net.au> wrote:
> >> > In the case where a non-MPLS GSO skb becomes an MPLS GSO skb, via
> >> > Open vSwitch's push MPLS action it is desirable to provide segmentation
> >> > in software. In this case the original protocol of the skb may have allowed
> >> > its checksumming to be offloaded but this may no longer be supported now
> >> > the skb is MPLS. Actually it seems to me that this is the likely case.
> >> >
> >> > In order to allow the checksum to be updated in this case loosen
> >> > the rules for recalculating the checksum on in skb_segment().
> >> >
> >> > N.B.: I must confess that I am a little unsure of the details of
> >> > the implementation of skb_checksum(). But I have observed that this
> >> > is necessary as skb_checksum() hits the following:

--,- s/skb_checksum/skb_segment/

> >> >
> >> >                 if (!hsize && i >= nfrags) {
> >> >                         ...
> >> >                         fskb = fskb->next;
> >> >                         ...
> >> >                 }
> >> >                 ...
> >> >                 if (fskb != skb_shinfo(skb)->frag_list)
> >> >                         ...
> >> >
> >> > Signed-off-by: Simon Horman <horms@verge.net.au>
> >>
> >> I'm surprised at the need for changes here since neither vlans nor
> >> tunneling protocols needed something similar. Do you know what is
> >> special about MPLS that is triggering this?
> >
> > After some testing I believe that the answer for GRE is, much to my
> > surprise, that it doesn't work without this patch. At least not for the
> > test case I have been using.
> >
> > To test GRE I set up a machine to receive IP packets and forward them over
> > a GRE (not TEB) tunnel created using the ip command. In that case I see
> > incorrect TCP checksums and then retransmissions when GSO segmentation
> > occurs.  A tcpdump is below.
> 
> Hmm, skb_segment() should be independent of protocol but I can see how
> this is a case that wouldn't get exercised frequently and therefore
> could have bugs. It seems like the case would be receiving a packet
> that gets merged using GRO and then imposing some kind of header (but
> not a single level of vlan since that is stored out of band).

Yes, that is what I think too.

> I think probably it's necessary to do some more careful analysis to make
> sure that this change is safe in all cases (or at least expand the commit
> message since it's not immediately obvious at the moment).

I will look over things a little more but I think that it is
correct so long as the calculation made by can_checksum_protocol(),
and the value of features passed to skb_segment() and in turn
can_checksum_protocol() is correct.

The reason is that in cases where can_checksum_protocol returns true
then this change will have no effect on the checksum calculation.
It is only in cases where it returns false that there may be an effect.
