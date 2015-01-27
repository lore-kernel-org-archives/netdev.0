From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO
 segmentation if not set.
Date: Tue, 27 Jan 2015 14:47:38 +0100
Message-ID: <1422366458.13969.11.camel@stressinduktion.org>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
	 <1422283026-27832-2-git-send-email-vyasevic@redhat.com>
	 <1422326874.31046.239.camel@decadent.org.uk>
	 <20150127084208.GB21584@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	edumazet@google.com, Vladislav Yasevich <vyasevic@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:55556 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758265AbbA0Nrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 08:47:41 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 5239D2074D
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 08:47:40 -0500 (EST)
In-Reply-To: <20150127084208.GB21584@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-27 at 10:42 +0200, Michael S. Tsirkin wrote:
> On Tue, Jan 27, 2015 at 02:47:54AM +0000, Ben Hutchings wrote:
> > On Mon, 2015-01-26 at 09:37 -0500, Vladislav Yasevich wrote:
> > > If the IPv6 fragment id has not been set and we perform
> > > fragmentation due to UFO, select a new fragment id.
> > > When we store the fragment id into skb_shinfo, set the bit
> > > in the skb so we can re-use the selected id.
> > > This preserves the behavior of UFO packets generated on the
> > > host and solves the issue of id generation for packet sockets
> > > and tap/macvtap devices.
> > > 
> > > This patch moves ipv6_select_ident() back in to the header file.  
> > > It also provides the helper function that sets skb_shinfo() frag
> > > id and sets the bit.
> > > 
> > > It also makes sure that we select the fragment id when doing
> > > just gso validation, since it's possible for the packet to
> > > come from an untrusted source (VM) and be forwarded through
> > > a UFO enabled device which will expect the fragment id.
> > > 
> > > CC: Eric Dumazet <edumazet@google.com>
> > > Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> > > ---
> > >  include/linux/skbuff.h |  3 ++-
> > >  include/net/ipv6.h     |  2 ++
> > >  net/ipv6/ip6_output.c  |  4 ++--
> > >  net/ipv6/output_core.c |  9 ++++++++-
> > >  net/ipv6/udp_offload.c | 10 +++++++++-
> > >  5 files changed, 23 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > index 85ab7d7..3ad5203 100644
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -605,7 +605,8 @@ struct sk_buff {
> > >  	__u8			ipvs_property:1;
> > >  	__u8			inner_protocol_type:1;
> > >  	__u8			remcsum_offload:1;
> > > -	/* 3 or 5 bit hole */
> > > +	__u8			ufo_fragid_set:1;
> > [...]
> > 
> > Doesn't the flag belong in struct skb_shared_info, rather than struct
> > sk_buff?  Otherwise this looks fine.
> > 
> > Ben.
> 
> Hmm we seem to be out of tx flags.
> Maybe ip6_frag_id == 0 should mean "not set".

Maybe that is the best idea. Definitely the ufo_fragid_set bit should
move into the skb_shared_info area.

Thanks,
Hannes
