From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.30] datapath: Add basic MPLS support to kernel
Date: Fri, 7 Jun 2013 14:53:47 +0900
Message-ID: <20130607055347.GA14972@verge.net.au>
References: <1369365969-21604-1-git-send-email-horms@verge.net.au>
 <CAEP_g=9eTLngGeayomgfEFed06Xmr3vkr-wJuKNo_h_S_A+BOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46790 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771Ab3FGFxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jun 2013 01:53:50 -0400
Content-Disposition: inline
In-Reply-To: <CAEP_g=9eTLngGeayomgfEFed06Xmr3vkr-wJuKNo_h_S_A+BOA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CC Pravin B Shelar for GSO at the end of this email ]

On Tue, Jun 04, 2013 at 02:49:37PM -0700, Jesse Gross wrote:
> On Thu, May 23, 2013 at 8:26 PM, Simon Horman <horms@verge.net.au> wrote:
> > diff --git a/datapath/actions.c b/datapath/actions.c
> > index 0dac658..1704876 100644
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
> > +static inline unsigned char *mac_header_end(const struct sk_buff *skb)
> 
> I think there probably isn't a strong reason to mark this inline since
> it's not in a header file.

Thanks, I will remove inline.

> > +static void set_ethertype(struct sk_buff *skb, __be16 ethertype)
> > +{
> > +       __be16 *skb_ethertype = get_ethertype(skb);
> > +       if (*skb_ethertype == ethertype)
> > +               return;
> 
> I would guess that the test to check for the existing EtherType is
> probably not actually beneficial as an optimization.

True. I think it may have made more sense in the past.
Regardless, I will remove it.

> 
> > +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
> [...]
> > +       set_ethertype(skb, ethertype);
> > +       skb->protocol = ethertype;
> 
> I think setting skb->protocol here is potentially not correct in the
> presence of vlans (and similarly in push_mpls).

I think you are correct and it should only be set for non-VLAN packets.
I will change both pop_mpls() and push_mpls() to use something like:


	if (!vlan_tx_tag_present(skb) && skb->protocol != htons(ETH_P_8021Q)) {
		skb->protocol = ethertype;
	}

> > diff --git a/datapath/datapath.c b/datapath/datapath.c
> > index 42af315..841f545 100644
> > --- a/datapath/datapath.c
> > +++ b/datapath/datapath.c
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
> > + * value of start is then set to the value of end. And the value of cursor
> > + * is set to the value of end plus one.
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
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = A
> > + *    New state:
> > + *     types = { A }
> > + *     start = end = cursor = 0;
> > + *
> > + * 2. Enter first sample()
> > + *    a. Save start and cursor
> > + *    b. Set start = end
> > + *    c. Set cursor = end + 1
> > + *    New state:
> > + *     types = { A }
> > + *     start = end = 0;
> > + *     cursor = 1;
> > + *
> > + * 3. pop_mpls(B)
> > + *    a. Check types from start (0) to end (0) inclusive
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
> > + *    b. Set start = end
> > + *    c. Set cursor = end + 1
> > + *    New state:
> > + *     types = { A, B }
> > + *     start = end = 1;
> > + *     cursor = 2;
> > + *
> > + * 6. pop_mpls(C)
> > + *    a. Check types from start (1) to end (1) inclusive
> > + *    b. Set start = end = cursor
> > + *    c. Set types[cursor] = C
> > + *    New state:
> > + *     types = { A, B, C }
> > + *     start = end = cursor = 2;
> 
> I'm not sure that the check is right here - won't this verify just
> that B is correct but we could have either A or B?

Thanks, yes I believe you are correct.

I think that this can be resolved by tweaking the logic not to advance
start when entering a sample action. But still restoring it
to its original value when leaving a sample action, in case it was
advanced by nested actions.

> 
> > +struct eth_types {
> > +       int start, end, cursor;
> > +       __be16 types[SAMPLE_ACTION_DEPTH];
> 
> Should this be MAX_ETH_TYPES?

Yes, thanks for noticing that. I will fix it.

> Otherwise, I think there is just the GSO changes to take advantage of
> the new upstream capabilities and support for existing kernels.

Thanks. Joe Stringer and I have been working on GSO compatibility for MPLS.
I believe that we have something that works for non-tunnel cases.

I'm a little unsure what to do about the tunnel case, as Pravin is
currently conducting deep surgery there. But most likely it would be good
for us to write something that works for the current code, that is
handle_offloads(), and then Pravin can adapt it for his changes.
