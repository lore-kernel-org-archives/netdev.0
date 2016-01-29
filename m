From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [RFC PATCH net-next 3/3] sctp: Add GSO support
Date: Fri, 29 Jan 2016 17:42:13 -0200
Message-ID: <20160129194213.GF6604@mrl.redhat.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <b4da9001ca69a7279f68b9cbd0f2a14839a269e6.1453913331.git.marcelo.leitner@gmail.com>
 <CAKgT0Ufaga3ki-0Dv58Lk-_gjo18FAcFfBobyWcWQgae+jsr+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>, marek@cloudflare.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>, pabeni@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	linux-sctp@vger.kernel.org, Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbcA2TmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2016 14:42:19 -0500
Content-Disposition: inline
In-Reply-To: <CAKgT0Ufaga3ki-0Dv58Lk-_gjo18FAcFfBobyWcWQgae+jsr+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 11:15:54AM -0800, Alexander Duyck wrote:
> On Wed, Jan 27, 2016 at 9:06 AM, Marcelo Ricardo Leitner
> <marcelo.leitner@gmail.com> wrote:
> > This patch enables SCTP to do GSO.
> >
> > SCTP has this pecualiarty that its packets cannot be just segmented to
> > (P)MTU. Its chunks must be contained in IP segments, padding respected.
> > So we can't just generate a big skb, set gso_size to the fragmentation
> > point and deliver it to IP layer.
> >
> > Instead, this patch proposes that SCTP build a skb as it would be if it
> > was received using GRO. That is, there will be a cover skb with the
> > headers (incluing SCTP one) and children ones containing the actual SCTP
> > chunks, already segmented in a way that respects SCTP RFCs and MTU.
> >
> > This way SCTP can benefit from GSO and instead of passing several
> > packets through the stack, it can pass a single large packet if there
> > are enough data queued and cwnd allows.
> >
> > Main points that need help:
> > - Usage of skb_gro_receive()
> >   It fits nicely in there and properly handles offsets/lens, though the
> >   name means another thing. If you agree with this usage, we can rename
> >   it to something like skb_coalesce
> >
> > - Checksum handling
> >   Why only packets with checksum offloaded can be GSOed? Most of the
> >   NICs doesn't support SCTP CRC offloading and this will nearly defeat
> >   this feature. If checksum is being computed in sw, it doesn't really
> >   matter if it's earlier or later, right?
> >   This patch hacks skb_needs_check() to allow using GSO with sw-computed
> >   checksums.
> >   Also the meaning of UNNECESSARY and NONE are quite foggy to me yet and
> >   its usage may be wrong.
> >
> > - gso_size = 1
> >   There is skb_is_gso() all over the stack and it basically checks for
> >   non-zero skb_shinfo(skb)->gso_size. Setting it to 1 is the hacky way I
> >   found to keep skb_is_gso() working while being able to signal to
> >   skb_segment() that it shouldn't use gso_size but instead the fragment
> >   sizes themselves. skb_segment() will mainly just unpack the skb then.
> 
> Instead of 1 why not use 0xFFFF?  It is a value that can never be used
> for a legitimate segment size since IP total length is a 16 bit value
> and includes the IP header in the size.

Just felt that 1 was unpractical. But perhaps with no hard restriction
like the one for 0xFFFF you said. I can replace it, 0xFFFF is better.

> > - socket / gso max values
> >   usage of sk_setup_caps() still needs a review
> >
> > Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > ---
> >  include/linux/netdev_features.h |   7 +-
> >  include/linux/netdevice.h       |   1 +
> >  net/core/dev.c                  |   6 +-
> >  net/core/skbuff.c               |  12 +-
> >  net/ipv4/af_inet.c              |   1 +
> >  net/sctp/offload.c              |  53 +++++++
> >  net/sctp/output.c               | 338 +++++++++++++++++++++++++---------------
> >  net/sctp/socket.c               |   2 +
> >  8 files changed, 292 insertions(+), 128 deletions(-)
> >
> > diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
> > index d9654f0eecb3519383441afa6b131ff9a5898485..f678998841f1800e0f2fe416a79935197d4ed305 100644
> > --- a/include/linux/netdev_features.h
> > +++ b/include/linux/netdev_features.h
> > @@ -48,8 +48,9 @@ enum {
> >         NETIF_F_GSO_UDP_TUNNEL_BIT,     /* ... UDP TUNNEL with TSO */
> >         NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
> >         NETIF_F_GSO_TUNNEL_REMCSUM_BIT, /* ... TUNNEL with TSO & REMCSUM */
> > +       NETIF_F_GSO_SCTP_BIT,           /* ... SCTP fragmentation */
> >         /**/NETIF_F_GSO_LAST =          /* last bit, see GSO_MASK */
> > -               NETIF_F_GSO_TUNNEL_REMCSUM_BIT,
> > +               NETIF_F_GSO_SCTP_BIT,
> >
> >         NETIF_F_FCOE_CRC_BIT,           /* FCoE CRC32 */
> >         NETIF_F_SCTP_CRC_BIT,           /* SCTP checksum offload */
> > @@ -119,6 +120,7 @@ enum {
> >  #define NETIF_F_GSO_UDP_TUNNEL __NETIF_F(GSO_UDP_TUNNEL)
> >  #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
> >  #define NETIF_F_GSO_TUNNEL_REMCSUM __NETIF_F(GSO_TUNNEL_REMCSUM)
> > +#define NETIF_F_GSO_SCTP       __NETIF_F(GSO_SCTP)
> >  #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
> >  #define NETIF_F_HW_VLAN_STAG_RX        __NETIF_F(HW_VLAN_STAG_RX)
> >  #define NETIF_F_HW_VLAN_STAG_TX        __NETIF_F(HW_VLAN_STAG_TX)
> > @@ -144,7 +146,8 @@ enum {
> >
> >  /* List of features with software fallbacks. */
> >  #define NETIF_F_GSO_SOFTWARE   (NETIF_F_TSO | NETIF_F_TSO_ECN | \
> > -                                NETIF_F_TSO6 | NETIF_F_UFO)
> > +                                NETIF_F_TSO6 | NETIF_F_UFO | \
> > +                                NETIF_F_GSO_SCTP)
> >
> >  /* List of IP checksum features. Note that NETIF_F_ HW_CSUM should not be
> >   * set in features when NETIF_F_IP_CSUM or NETIF_F_IPV6_CSUM are set--
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 289c2314d76668b8357728382bb33d6828617458..ce14fab858bf96dd0f85aca237350c8d8317756e 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -3928,6 +3928,7 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
> >         BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
> >         BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
> >         BUILD_BUG_ON(SKB_GSO_TUNNEL_REMCSUM != (NETIF_F_GSO_TUNNEL_REMCSUM >> NETIF_F_GSO_SHIFT));
> > +       BUILD_BUG_ON(SKB_GSO_SCTP    != (NETIF_F_GSO_SCTP >> NETIF_F_GSO_SHIFT));
> >
> >         return (features & feature) == feature;
> >  }
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 8cba3d852f251c503b193823b71b27aaef3fb3ae..9583284086967c0746de5f553535e25e125714a5 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2680,7 +2680,11 @@ EXPORT_SYMBOL(skb_mac_gso_segment);
> >  static inline bool skb_needs_check(struct sk_buff *skb, bool tx_path)
> >  {
> >         if (tx_path)
> > -               return skb->ip_summed != CHECKSUM_PARTIAL;
> > +               /* FIXME: Why only packets with checksum offloading are
> > +                * supported for GSO?
> > +                */
> > +               return skb->ip_summed != CHECKSUM_PARTIAL &&
> > +                      skb->ip_summed != CHECKSUM_UNNECESSARY;
> >         else
> >                 return skb->ip_summed == CHECKSUM_NONE;
> >  }
> 
> Tom Herbert just got rid of the use of CHECKSUM_UNNECESSARY in the
> transmit path a little while ago.  Please don't reintroduce it.

Can you give me some pointers on that? I cannot find such change.
skb_needs_check() seems to be like that since beginning.

> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index 704b69682085dec77f3d0f990aaf0024afd705b9..96f223f8d769d2765fd64348830c76cb222906c8 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -3017,8 +3017,16 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
> >                 int size;
> >
> >                 len = head_skb->len - offset;
> > -               if (len > mss)
> > -                       len = mss;
> > +               if (len > mss) {
> > +                       /* FIXME: A define is surely welcomed, but maybe
> > +                        * shinfo->txflags is better for this flag, but
> > +                        * we need to expand it then
> > +                        */
> > +                       if (mss == 1)
> > +                               len = list_skb->len;
> > +                       else
> > +                               len = mss;
> > +               }
> >
> 
> Using 0xFFFF here as a flag with the MSS value would likely be much
> more readable.

Either way it will be replaced by a define/name instead.

> >                 hsize = skb_headlen(head_skb) - offset;
> >                 if (hsize < 0)
> > diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> > index 5c5db6636704daa0c49fc13e84b2c5b282a44ed3..ec1c779bb664d1399d74f2bd7016e30b648ce47d 100644
> > --- a/net/ipv4/af_inet.c
> > +++ b/net/ipv4/af_inet.c
> > @@ -1220,6 +1220,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
> >                        SKB_GSO_UDP_TUNNEL |
> >                        SKB_GSO_UDP_TUNNEL_CSUM |
> >                        SKB_GSO_TUNNEL_REMCSUM |
> > +                      SKB_GSO_SCTP |
> >                        0)))
> >                 goto out;
> >
> > diff --git a/net/sctp/offload.c b/net/sctp/offload.c
> > index 7080a6318da7110c1688dd0c5bb240356dbd0cd3..3b96035fa180a4e7195f7b6e7a8be7b97c8f8b26 100644
> > --- a/net/sctp/offload.c
> > +++ b/net/sctp/offload.c
> > @@ -36,8 +36,61 @@
> >  #include <net/sctp/checksum.h>
> >  #include <net/protocol.h>
> >
> > +static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
> > +{
> > +       skb->ip_summed = CHECKSUM_NONE;
> > +       return sctp_compute_cksum(skb, skb_transport_offset(skb));
> > +}
> > +
> 
> I really despise the naming of this bit here.  SCTP does not use a
> checksum.  It uses a CRC.  Please don't call this a checksum as it
> will just make the code really confusing.   I think the name should be
> something like gso_make_crc32c.

Agreed. SCTP code still references it as 'cksum'. I'll change that in
another patch.

> I think we need to address the CRC issues before we can really get
> into segmentation.  Specifically we need to be able to offload SCTP
> and FCoE in software since they both use the CHECKSUM_PARTIAL value
> and then we can start cleaning up more of this mess and move onto
> segmentation.

Hm? The mess on CRC issues here is caused by this patch alone. It's good
as it is today. And a good part of this mess is caused by trying to GSO
without offloading CRC too.

Or you mean that SCTP and FCoE should stop using CHECKSUM_* at all?

> > +static struct sk_buff *sctp_gso_segment(struct sk_buff *skb,
> > +                                       netdev_features_t features)
> > +{
> > +       struct sk_buff *segs = ERR_PTR(-EINVAL);
> > +       struct sctphdr *sh;
> > +
> > +       sh = sctp_hdr(skb);
> > +       if (!pskb_may_pull(skb, sizeof(*sh)))
> > +               goto out;
> > +
> > +       __skb_pull(skb, sizeof(*sh));
> > +
> > +       if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
> > +               /* Packet is from an untrusted source, reset gso_segs. */
> > +               int type = skb_shinfo(skb)->gso_type;
> > +
> > +               if (unlikely(type &
> > +                            ~(SKB_GSO_SCTP | SKB_GSO_DODGY |
> > +                              0) ||
> > +                            !(type & (SKB_GSO_SCTP))))
> > +                       goto out;
> > +
> > +               /* This should not happen as no NIC has SCTP GSO
> > +                * offloading, it's always via software and thus we
> > +                * won't send a large packet down the stack.
> > +                */
> > +               WARN_ONCE(1, "SCTP segmentation offloading to NICs is not supported.");
> > +               goto out;
> > +       }
> > +
> 
> So what you are going to end up needing here is some way to tell the
> hardware that you are doing the checksum no matter what.  There is no
> value in you computing a 1's compliment checksum for the payload if
> you aren't going to use it.  What you can probably do is just clear
> the standard checksum flags and then OR in NETIF_F_HW_CSUM if
> NETIF_F_SCTP_CRC is set and that should get skb_segment to skip
> offloading the checksum.

Interesting, ok

> One other bit that will make this more complicated is if we ever get
> around to supporting SCTP in tunnels.  Then we will need to sort out
> how things like remote checksum offload should impact SCTP, and how to
> deal with needing to compute both a CRC and 1's compliment checksum.
> What we would probably need to do is check for encap_hdr_csum and if
> it is set and we are doing SCTP then we would need to clear the
> NETIF_F_HW_CSUM, NETIF_F_IP_CSUM, and NETIF_F_IPV6_CSUM flags.

Yup. And that includes on storing pointers to where to store each of it.

> > +       segs = skb_segment(skb, features);
> > +       if (IS_ERR(segs))
> > +               goto out;
> > +
> > +       /* All that is left is update SCTP CRC if necessary */
> > +       for (skb = segs; skb; skb = skb->next) {
> > +               if (skb->ip_summed != CHECKSUM_PARTIAL) {
> > +                       sh = sctp_hdr(skb);
> > +                       sh->checksum = sctp_gso_make_checksum(skb);
> > +               }
> > +       }
> > +
> 
> Okay, so it looks like you are doing the right thing here and leaving
> this as CHECKSUM_PARTIAL.

Actually no then. sctp_gso_make_checksum() replaces it:
+static __le32 sctp_gso_make_checksum(struct sk_buff *skb)
+{
+       skb->ip_summed = CHECKSUM_NONE;
+       return sctp_compute_cksum(skb, skb_transport_offset(skb));

Why again would have to leave it as CHECKSUM_PARTIAL? IP header?

> > +out:
> > +       return segs;
> > +}
> > +
> >  static const struct net_offload sctp_offload = {
> >         .callbacks = {
> > +               .gso_segment = sctp_gso_segment,
> >         },
> >  };

Thanks,
Marcelo
