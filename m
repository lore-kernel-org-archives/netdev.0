From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH v2 4/7] skbuff: introduce skb_gso_validate_mtu
Date: Tue, 31 May 2016 16:54:24 -0300
Message-ID: <20160531195424.GA29509@localhost.localdomain>
References: <cover.1464718103.git.marcelo.leitner@gmail.com>
 <e88d8905cf03bac8995be6d722f8b5abfc7afcc5.1464718103.git.marcelo.leitner@gmail.com>
 <CAKgT0UfZceZ9UuzWEYVsNUSSybv514mAaN+e_3AxsQO0K2bMMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@aculab.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbcEaTy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 15:54:29 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UfZceZ9UuzWEYVsNUSSybv514mAaN+e_3AxsQO0K2bMMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 31, 2016 at 12:07:54PM -0700, Alexander Duyck wrote:
> On Tue, May 31, 2016 at 11:55 AM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > skb_gso_network_seglen is not enough for checking fragment sizes if
> > skb is using GSO_BY_FRAGS as we have to check frag per frag.
> >
> > This patch introduces skb_gso_validate_mtu, based on the former, which
> > will wrap the use case inside it as all calls to skb_gso_network_seglen
> > were to validate if it fits on a given TMU, and improve the check.
> >
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > Tested-by: Xin Long <lucien.xin@gmail.com>
> > ---
> >  include/linux/skbuff.h |  1 +
> >  net/core/skbuff.c      | 31 +++++++++++++++++++++++++++++++
> >  net/ipv4/ip_forward.c  |  2 +-
> >  net/ipv4/ip_output.c   |  2 +-
> >  net/ipv6/ip6_output.c  |  2 +-
> >  net/mpls/af_mpls.c     |  2 +-
> >  6 files changed, 36 insertions(+), 4 deletions(-)
> >
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 1f713541cb2fc232cb0e8417232cb9942409c9fc..2109c2dc9767d454b2cd08696af039b6bcd1ace7 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -2992,6 +2992,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
> >  int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
> >  void skb_scrub_packet(struct sk_buff *skb, bool xnet);
> >  unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
> > +bool skb_gso_validate_mtu(const struct sk_buff *skb, unsigned int mtu);
> >  struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
> >  struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
> >  int skb_ensure_writable(struct sk_buff *skb, int write_len);
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 97c32c75e704af1f31b064e8f1e0475ff1505d67..5ca562b56ec39d39e1225d96547e242732518ffe 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -4392,6 +4392,37 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
> >  }
> >  EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
> >
> > +/**
> > + * skb_gso_validate_mtu - Return in case such skb fits a given MTU
> > + *
> > + * @skb: GSO skb
> > + *
> > + * skb_gso_validate_mtu validates if a given skb will fit a wanted MTU
> > + * once split.
> > + */
> > +bool skb_gso_validate_mtu(const struct sk_buff *skb, unsigned int mtu)
> > +{
> > +       const struct skb_shared_info *shinfo = skb_shinfo(skb);
> > +       const struct sk_buff *iter;
> > +       unsigned int hlen;
> > +
> > +       hlen = skb_gso_network_seglen(skb);
> > +
> > +       if (shinfo->gso_size != GSO_BY_FRAGS)
> > +               return hlen <= mtu;
> > +
> > +       /* Undo this so we can re-use header sizes */
> > +       hlen -= GSO_BY_FRAGS;
> 
> Isn't this just "hlen = 0"?  If so you could probably just remove this
> line and the references to hlen below and instead just loop through
> verifying skb_headlen() instead of adding a value that should be 0.

By when this func is called the frags lack any headers, this is how I
a ccount them.  So I expect it to be different than 0 in most of the
cases as it will contain the value of network header size, and it should
have contained the size of sctp header too. Now reviewing it, I should
have added a new check on skb_gso_transport_seglen() for sctp gso I
think. As in:

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5ca562b56ec3..fcc286b8b90c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4383,6 +4383,8 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
 			thlen += inner_tcp_hdrlen(skb);
 	} else if (likely(shinfo->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))) {
 		thlen = tcp_hdrlen(skb);
+	} else if (unlikely(shinfo->gso_type & SKB_GSO_SCTP)) {
+		thlen = sizeof(struct sctphdr);
 	}
 	/* UFO sets gso_size to the size of the fragmentation
 	 * payload, i.e. the size of the L4 (UDP) header is already

This chunk would be on 6th patch. (v3 will be needed due to this)

I can ignore that and recalculate it but this way (with -GSO_BY_FRAGS)
seemed cleaner as it reuses all that.

> > +       skb_walk_frags(skb, iter) {
> > +               if (hlen + skb_headlen(iter) > mtu)
> > +                       return false;
> > +       }
> > +
> > +       return true;
> > +}
> > +EXPORT_SYMBOL_GPL(skb_gso_validate_mtu);
> > +
> >  static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
> >  {
> >         if (skb_cow(skb, skb_headroom(skb)) < 0) {
> 
