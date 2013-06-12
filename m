From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] datapath: Add basic MPLS support to kernel
Date: Wed, 12 Jun 2013 15:35:26 +0900
Message-ID: <20130612063526.GA16477@verge.net.au>
References: <1370851669-32400-1-git-send-email-horms@verge.net.au>
 <CAEP_g=_rC9unxv13xvEL3fpC4i2p9rcSWMo4NOeHFWHsp36QRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Joe Stringer <joe@wand.net.nz>,
	Pravin Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:48579 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754178Ab3FLGfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 02:35:31 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=_rC9unxv13xvEL3fpC4i2p9rcSWMo4NOeHFWHsp36QRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 11, 2013 at 02:26:32PM -0700, Jesse Gross wrote:
> On Mon, Jun 10, 2013 at 1:07 AM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 0dac658..197811a 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > +static int push_mpls(struct sk_buff *skb,
> > +                    const struct ovs_action_push_mpls *mpls)
> > +{
> > +       __be32 *new_mpls_lse;
> > +       int err;
> > +
> > +       if (skb_cow_head(skb, MPLS_HLEN) < 0)
> > +               return -ENOMEM;
> > +
> > +       err = make_writable(skb, skb->mac_len);
> > +       if (unlikely(err))
> > +               return err;
> > +
> > +       skb_push(skb, MPLS_HLEN);
> > +       memmove(skb_mac_header(skb) - MPLS_HLEN, skb_mac_header(skb),
> > +               skb->mac_len);
> > +       skb_reset_mac_header(skb);
> > +
> > +       new_mpls_lse = (__be32 *)mac_header_end(skb);
> > +       *new_mpls_lse = mpls->mpls_lse;
> > +
> > +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +               skb->csum = csum_add(skb->csum, csum_partial(new_mpls_lse,
> > +                                                            MPLS_HLEN, 0));
> > +
> > +       /* If the skb was non-MPLS then record the original protocol
> > +        * in skb->inner_protocol. This is to allow GSO to perform
> > +        * segmentation of the inner-packet.
> > +        */
> > +       if (!eth_p_mpls(skb->protocol))
> > +               skb_set_inner_protocol(skb, skb->protocol);
> > +
> > +       set_ethertype(skb, mpls->mpls_ethertype);
> > +       if (!vlan_tx_tag_present(skb) && skb->protocol != htons(ETH_P_8021Q)) {
> > +               skb->protocol = mpls->mpls_ethertype;
> > +       }
> 
> I don't think you need to check for vlan_tx_tag_present here - when
> doing vlan offloading, skb->protocol reflects the packet as if there
> was no vlan tag there at all. Also, you shouldn't need the braces
> there.

Thanks, I didn't realise that was the relationship
between vlan_tx_tag_present() and skb->protocol.

> When looking at this, I had an additional thought: different versions
> of OpenFlow define the tag order differently and there is some limited
> flexibility in how they get applied. Obviously, we're assuming that
> vlans are applied before MPLS here. However, I'm not sure that is
> actually required and may even simplify things (for example, your MPLS
> GSO code doesn't do anything special with vlans and it should continue
> to just work either way). I'm hesitant to suggest changes at this
> point but it might actually make things cleaner and work with the
> general model that we already have.

Unsurprisingly I am also hesitant.

I'm not sure that my readings of the specs leads to different valid
orderings but if they are specified I am somewhat surprised.

I believe that we could get bogged down in discussing various
specifications without too much difficulty and at the risk of doing so I
will explain my interpretation of Open Flow 1.3.2.

Section 5.12 states:

"Newly pushed tags should always be inserted as the outermost tag in the
outermost valid location for that tag.".

And RFC 3032 MPLS Label Stack Encoding states in section 2.1:

"The label stack entries appear AFTER the data link layer headers, but
BEFORE any network layer headers.".

My reading is that the only valid location for an MPLS LSE to be pushed
is after the L2 header including any VLAN tags that may be present. And
that the only valid place to push any VLAN tags is after the L2 header,
that is, before the MPLS label stack if it is present.

Of course there may be other relevant RFCs that I have not examined.

> > diff --git a/datapath/datapath.c b/datapath/datapath.c
> > index 42af315..7e0e7a1 100644
> > --- a/datapath/datapath.c
> > +++ b/datapath/datapath.c
> > @@ -551,18 +551,132 @@ static inline void add_nested_action_end(struct sw_flow_actions *sfa, int st_off
> >         a->nla_len = sfa->actions_len - st_offset;
> >  }
> >
> > -static int validate_and_copy_actions(const struct nlattr *attr,
> > +#define MAX_ETH_TYPES 16 /* Arbitrary Limit */
> > +
> > +/* struct eth_types - possible eth types
> > + * @types: provides storage for the possible eth types.
> > + * @start: is the index of the first entry of types which is possible.
> > + * @end: is the index of the last entry of types which is possible.
> > + * @cursor: is the index of the entry which should be updated if an action
> > + * changes the eth type.
> > + *
> > + * Due to the sample action there may be multiple possible eth types.
> > + * In order to correctly validate actions all possible types are tracked
> > + * and verified. This is done using struct eth_types.
> > + *
> > + * Initially start, end and cursor should be 0, and the first element of
> > + * types should be set to the eth type of the flow.
> > + *
> > + * When an action changes the eth type then the values of start and end are
> > + * updated to the value of cursor. The new type is stored at types[cursor].
> > + *
> > + * When entering a sample action the start and cursor values are saved. The
> > + * value of cursor is set to the value of end plus one.
> > + *
> > + * When leaving a sample action the start and cursor values are restored to
> > + * their saved values.
> > + *
> > + * An example follows.
> > + *
> > + * actions: pop_mpls(A),sample(pop_mpls(B)),sample(pop_mpls(C)),pop_mpls(D)
> > + *
> > + * 0. Initial state:
> > + *     types = { original_eth_type }
> > + *     start = end = cursor = 0;
> > + *
> > + * 1. pop_mpls(A)
> > + *    a. Check types from start (0) to end (0) inclusive
> > + *       i.e. Check against original_eth_type
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = A
> > + *    New state:
> > + *     types = { A }
> > + *     start = end = cursor = 0;
> > + *
> > + * 2. Enter first sample()
> > + *    a. Save start and cursor
> > + *    b. Set cursor = end + 1
> > + *    New state:
> > + *     types = { A }
> > + *     start = end = 0;
> > + *     cursor = 1;
> > + *
> > + * 3. pop_mpls(B)
> > + *    a. Check types from start (0) to end (0)
> > + *       i.e: Check against A
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = B
> > + *    New state:
> > + *     types = { A, B }
> > + *     start = end = cursor = 1;
> > + *
> > + * 4. Leave first sample()
> > + *    a. Restore start and cursor to the values when entering 2.
> > + *    New state:
> > + *     types = { A, B }
> > + *     start = cursor = 0;
> > + *     end = 1;
> > + *
> > + * 5. Enter second sample()
> > + *    a. Save start and cursor
> > + *    b. Set cursor = end + 1
> > + *    New state:
> > + *     types = { A, B }
> > + *     start = 0;
> > + *     end = 1;
> > + *     cursor = 2;
> > + *
> > + * 6. pop_mpls(C)
> > + *    a. Check types from start (0) to end (1) inclusive
> > + *       i.e: Check against A and B
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = C
> > + *    New state:
> > + *     types = { A, B, C }
> > + *     start = end = cursor = 2;
> > + *
> > + * 7. Leave second sample()
> > + *    a. Restore start and cursor to the values when entering 5.
> > + *    New state:
> > + *     types = { A, B, C }
> > + *     start = cursor = 0;
> > + *     end = 2;
> > + *
> > + * 8. pop_mpls(D)
> > + *    a. Check types from start (0) to end (2) inclusive
> > + *       i.e: Check against A, B and C
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = D
> > + *    New state:
> > + *     types = { D } // Trailing entries of type are no longer used end = 0
> > + *     start = end = cursor = 0;
> > + */
> 
> The algorithm looks good to me now, thanks for working through it and
> for documenting it.

:)

> > +static int validate_and_copy_actions__(const struct nlattr *attr,
> > +                               const struct sw_flow_key *key, int depth,
> > +                               struct sw_flow_actions **sfa,
> > +                               struct eth_types *eth_types)
> [...]
> > +               case OVS_ACTION_ATTR_POP_MPLS: {
> > +                       size_t i;
> 
> size_t seems a little bit odd to me here, maybe just use an int?

Sure.

> 
> > +                       for (i = eth_types->start; i <= eth_types->end; i++)
> > +                               if (!eth_p_mpls(eth_types->types[i]))
> > +                                       return -EINVAL;
> > +
> > +                       /* Disallow subsequent L2.5+ set and mpls_pop actions
> > +                        * as there is no check here to ensure that the new
> > +                        * eth_type is valid and thus set actions could
> > +                        * write off the end of the packet or otherwise
> > +                        * corrupt it.
> > +                        *
> > +                        * Support for these actions that after mpls_pop
> > +                        * using packet recirculation is planned.
> > +                        * are planned to be supported using using packet
> > +                        * recirculation.
> 
> I think there is an editing error in the above comment.

Sorry about that, very embarrassing.

> > diff --git a/datapath/datapath.h b/datapath/datapath.h
> > index ad59a3a..e47493a 100644
> > --- a/datapath/datapath.h
> > +++ b/datapath/datapath.h
> > +#ifdef HAVE_INNER_PROTOCOL
> > +static inline void skb_set_inner_protocol(struct sk_buff *skb, __be16 ethertype)
> > +{
> > +       skb->inner_protocol = ethertype;
> > +}
> > +
> > +static inline __be16 skb_get_inner_protocol(struct sk_buff *skb)
> > +{
> > +       return skb->inner_protocol;
> > +}
> > +
> > +static inline bool kernel_supports_mpls_gso(void)
> > +{
> > +       return true;
> > +}
> > +#else
> > +static inline void skb_set_inner_protocol(struct sk_buff *skb, __be16 ethertype) {
> > +       OVS_CB(skb)->inner_protocol = ethertype;
> > +}
> > +
> > +static inline __be16 skb_get_inner_protocol(struct sk_buff *skb)
> > +{
> > +       return OVS_CB(skb)->inner_protocol;
> > +}
> > +
> > +static inline bool kernel_supports_mpls_gso(void)
> > +{
> > +       return false;
> > +}
> > +#endif
> 
> Can we move these functions compat.h, prefix them with ovs_, and make
> it clear that they are part of OVS and not skbuff.h?

Sure, we can make that so.

The reason that these functions were placed in datapath.h is that
it seemed quite convenient as OVS_CB() is defined there.

I believe that if we move the functions to compat.h then it
may need to include datapath.h which is currently not the case.
If that is not desirable perhaps the best way forwards would
be to create a new header file.

> > diff --git a/datapath/tunnel.c b/datapath/tunnel.c
> > index 8c93e18..2d870aa 100644
> > --- a/datapath/tunnel.c
> > +++ b/datapath/tunnel.c
> > @@ -150,6 +150,16 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
> >
> >         if (skb_is_gso(skb)) {
> >                 struct sk_buff *nskb;
> > +               __be16 mpls_protocol = htons(0);
> > +
> > +               /* Swap the protocol so we can reuse the existing
> > +                * skb_gso_segment() function to handle L3 GSO. We will
> > +                * restore this later. */
> > +               if (!kernel_supports_mpls_gso() && eth_p_mpls(skb->protocol) &&
> > +                   !eth_p_mpls(skb_get_inner_protocol(skb))) {
> > +                       mpls_protocol = skb->protocol;
> > +                       skb->protocol = skb_get_inner_protocol(skb);
> > +               }
> >
> >                 nskb = __skb_gso_segment(skb, 0, false);
> >                 if (IS_ERR(nskb)) {
> > @@ -159,6 +169,13 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
> >
> >                 consume_skb(skb);
> >                 skb = nskb;
> > +
> > +               if (mpls_protocol != htons(0)) {
> > +                       do {
> > +                               nskb->protocol = mpls_protocol;
> > +                               nskb = nskb->next;
> > +                       } while (nskb);
> > +               }
> >         } else if (get_ip_summed(skb) == OVS_CSUM_PARTIAL) {
> >                 /* Pages aren't locked and could change at any time.
> >                  * If this happens after we compute the checksum, the
> 
> Can we push this completely into the skb_gso_segment() compatibility
> code? It's both nicer and may make the interactions with the vlan code
> less confusing.

Yes, I think that should be possible.

> > diff --git a/datapath/vport-netdev.c b/datapath/vport-netdev.c
> > index 4e7342c..db3284f 100644
> > --- a/datapath/vport-netdev.c
> > +++ b/datapath/vport-netdev.c
> > @@ -309,8 +310,31 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >         skb->dev = netdev_vport->dev;
> >         forward_ip_summed(skb, true);
> >
> > +       vlan = mpls = false;
> > +
> > +       if (!kernel_supports_mpls_gso() && eth_p_mpls(skb->protocol) &&
> > +           !eth_p_mpls(skb_get_inner_protocol(skb)))
> > +               mpls = true;
> > +
> > +       /* If we are segmenting a VLAN packet, then we don't need to handle
> > +        * MPLS segmentation, because MPLS is part of the extended L2 header
> > +        * and the kernel already knows how to handle this. */
> >         if (vlan_tx_tag_present(skb) && !dev_supports_vlan_tx(skb->dev)) {
> > -               int features;
> > +               mpls = false;
> > +               vlan = true;
> > +       }
> 
> Don't we still need to save and restore the MPLS skb->protocol field
> even if we are also processing vlans?

In light of you comment above with regard to push_mpls() and pop_mpls()
setting skb->protocol in the presence of VLAN offloads, yes, I believe that
is correct.

> 
> > @@ -341,10 +376,14 @@ static int netdev_send(struct vport *vport, struct sk_buff *skb)
> >                                 nskb = skb->next;
> >                                 skb->next = NULL;
> >
> > -                               skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> > +                               if (vlan)
> > +                                       skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
> >                                 if (likely(skb)) {
> >                                         len += skb->len;
> > -                                       vlan_set_tci(skb, 0);
> > +                                       if (mpls)
> > +                                               skb->protocol = mpls_protocol;
> > +                                       if (vlan)
> > +                                               vlan_set_tci(skb, 0);
> >                                         dev_queue_xmit(skb);
> >                                 }
> 
> The order of setting the protocol field is different from the one
> below and I think this one isn't right because it means that the MPLS
> protocol can override the vlan.

Thanks, given my new understanding of the values of skb->protocol
may take in the presence of VLANs I believe you are correct.

> Pravin, can you take a look at this as well since you are working in
> the same area?
