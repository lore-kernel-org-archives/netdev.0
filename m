From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.29] datapath: Add basic MPLS support to kernel
Date: Tue, 21 May 2013 09:55:21 +0900
Message-ID: <20130521005519.GA14817@verge.net.au>
References: <1368774397-10700-1-git-send-email-horms@verge.net.au>
 <CAEP_g=8GefFzMPSE0EkaLSTNtPJYtgoOKMaV_hN1ckE-Qxhsog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59253 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755655Ab3EUAz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 20:55:26 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=8GefFzMPSE0EkaLSTNtPJYtgoOKMaV_hN1ckE-Qxhsog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 04:14:56PM -0700, Jesse Gross wrote:
> On Fri, May 17, 2013 at 12:06 AM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 0dac658..ac4423a 100644
> > --- a/datapath/actions.c
> > +++ b/datapath/actions.c
> > +/* The end of the mac header.
> > + *
> > + * For non-MPLS skbs this will correspond to the network header.
> > + * For MPLS skbs it will be berfore the network_header as the MPLS
> > + * label stack lies between the end of the mac header and the network
> > + * header. That is, for MPLS skbs the end of the mac header
> > + * is the top of the MPLS label stack.
> > + */
> > +static inline unsigned char *skb_mac_header_end(const struct sk_buff *skb)
> > +{
> > +       return skb_mac_header(skb) + skb->mac_len;
> > +}
> 
> This should either be moved into skbuff.h or given a name that makes
> it clear that it is a local function.

I think it is best to keep it local as it is not needed elsewhere at this
time. And its not clear to me that it will ever be needed elsewhere.
I have renamed it mac_header_end().

> > +static void set_ethertype(struct sk_buff *skb, __be16 ethertype)
> > +{
> > +       __be16 *skb_ethertype = get_ethertype(skb);
> > +       if (*skb_ethertype == ethertype)
> > +               return;
> > +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE) {
> > +               __be16 diff[] = { ~*skb_ethertype, ethertype };
> > +               skb->csum = ~csum_partial((char *)diff, sizeof(diff),
> > +                                         ~skb->csum);
> > +       }
> 
> Inside of OVS the Ethernet header is not covered by CHECKSUM_COMPLETE.

Thanks, I have removed the OVS_CSUM_COMPLETE code from set_ethertype()

> > +static int push_mpls(struct sk_buff *skb,
> > +                    const struct ovs_action_push_mpls *mpls)
> > +{
> > +       __be32 *new_mpls_lse;
> > +       int err;
> > +
> > +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +       if (unlikely(err))
> > +               return err;
> > +
> > +       skb_push(skb, MPLS_HLEN);
> 
> What happens if there isn't enough headroom?

Good point. How about this?

	if (unlikely(skb->data<skb->head))
		return -EINVAL;
	skb_push(skb, MPLS_HLEN);

> > +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> > +{
> > +       int err;
> > +
> > +       err = make_writable(skb, skb->mac_len + MPLS_HLEN);
> > +       if (unlikely(err))
> > +               return err;
> > +
> > +       if (get_ip_summed(skb) == OVS_CSUM_COMPLETE)
> > +               skb->csum = csum_sub(skb->csum,
> > +                                    csum_partial(skb_mac_header_end(skb),
> > +                                                 MPLS_HLEN, 0));
> > +
> > +       memmove(skb_mac_header(skb) + MPLS_HLEN, skb_mac_header(skb),
> > +               skb->mac_len);
> > +
> > +       skb_pull(skb, MPLS_HLEN);
> 
> You could use __skb_pull() here.

Thanks, I have changed skb_pull() to __skb_pull().

> >  /* remove VLAN header from packet and update csum accordingly. */
> >  static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
> >  {
> > @@ -115,6 +229,9 @@ static int push_vlan(struct sk_buff *skb, const struct ovs_action_push_vlan *vla
> >                 if (!__vlan_put_tag(skb, current_tag))
> >                         return -ENOMEM;
> >
> > +               /* update mac_len for skb_mac_header_end() */
> > +               skb_reset_mac_len(skb);
> 
> Doesn't this make us forget the start of the MPLS label stack?

Good point. I have updated this to:

		skb->mac_len += VLAN_HLEN;

I have also updated __pop_vlan_tci() to use:

		skb->mac_len -= VLAN_HLEN;

Instead of:

		skb_reset_mac_len(skb);


> > -/* Execute a list of actions against 'skb'. */
> > +/* Execute a list of actions against 'skb'.
> > + *
> > + * The stack depth is only tracked in the case of a non-MPLS packet
> > + * that becomes MPLS via an MPLS push action. The stack depth
> > + * is passed to do_output() in order to allow it to prepare the
> > + * skb for possible GSO segmentation. */
> 
> I don't think this comment applies any more.

Yes, sorry about that. I have removed the above change.

> > diff --git a/datapath/datapath.c b/datapath/datapath.c
> > index 42af315..3a1c203 100644
> > --- a/datapath/datapath.c
> > +++ b/datapath/datapath.c
> 
> It's not clear to that using the depth is actually sufficient to
> capture all possible combinations because the more common case is that
> actions are a list, not nested. For example, consider the following
> (invalid) action list on an IP input packet:
> 
> push_mpls, sample(pop_mpls), pop_mpls
> 
> I don't believe that this will be rejected since by the time we get to
> the second pop_mpls we will have forgotten about the sample action.

My intention when writing the code was that such a case would be rejected
as follows:

1. When the nested pop_mpls is validated the following call is
   made with depth = 1:

  eth_types_set(eth_types, depth, htons(0));

  This sets:
	eth_types->depth = 1
	eth_types[1] = htons(0);

2. When the second pop_mpls is validated the following
   is executed (with the fix that you suggested below):

   for (i = 0; i < eth_types->depth; i++)
	if (!eth_p_mpls(eth_types->types[i]))
		return -EINVAL;

   This will return -EINVAL due to the values of eth_type members set in 1.

> 
> > @@ -811,6 +869,35 @@ static int validate_and_copy_actions(const struct nlattr *attr,
> >                                 return -EINVAL;
> >                         break;
> >
> > +               case OVS_ACTION_ATTR_PUSH_MPLS: {
> > +                       const struct ovs_action_push_mpls *mpls = nla_data(a);
> > +                       if (!eth_p_mpls(mpls->mpls_ethertype))
> > +                               return -EINVAL;
> > +                       eth_types_set(eth_types, depth, mpls->mpls_ethertype);
> > +                       break;
> > +               }
> > +
> > +               case OVS_ACTION_ATTR_POP_MPLS: {
> > +                       size_t i;
> > +
> > +                       for (i = 0; i < eth_types->depth; i++)
> > +                               if (eth_types->types[i] != htons(ETH_P_IP))
> > +                                       return -EINVAL;
> 
> I think the check here should be for MPLS, not IP.

Thanks, I have changed the above check to:

					if (!eth_p_mpls(eth_types->types[i]))

> > diff --git a/datapath/flow.c b/datapath/flow.c
> > index 3ce926e..2a86f90 100644
> > --- a/datapath/flow.c
> > +++ b/datapath/flow.c
> > @@ -848,6 +880,9 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
> >         [OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
> >         [OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
> >         [OVS_KEY_ATTR_TUNNEL] = -1,
> > +
> > +       /* Not upstream. */
> > +       [OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
> 
> At this point, we can probably treat this patch as the point where the
> MPLS data structures are finalized and upstreamable. Therefore, this
> patch can move the attribute to a final location.

Thanks, I will squash the following incremental change into the next
posting of this patch.

diff --git a/datapath/flow.c b/datapath/flow.c
index 2a86f90..d67d6bf 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -880,8 +880,6 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ARP] = sizeof(struct ovs_key_arp),
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 	[OVS_KEY_ATTR_TUNNEL] = -1,
-
-	/* Not upstream. */
 	[OVS_KEY_ATTR_MPLS] = sizeof(struct ovs_key_mpls),
 };
 
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index e890fd8..d90f585 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -287,7 +287,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
 #endif
 
-	OVS_KEY_ATTR_MPLS = 62, /* array of struct ovs_key_mpls.
+	OVS_KEY_ATTR_MPLS,      /* array of struct ovs_key_mpls.
 				 * The implementation may restrict
 				 * the accepted length of the array. */
 	__OVS_KEY_ATTR_MAX
