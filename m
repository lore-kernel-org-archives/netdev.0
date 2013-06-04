From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v2.30] datapath: Add basic MPLS support to kernel
Date: Tue, 4 Jun 2013 14:49:37 -0700
Message-ID: <CAEP_g=9eTLngGeayomgfEFed06Xmr3vkr-wJuKNo_h_S_A+BOA@mail.gmail.com>
References: <1369365969-21604-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>,
	Jarno Rajahalme <jarno.rajahalme@nsn.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:46357 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751208Ab3FDVt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 17:49:59 -0400
Received: by mail-ie0-f179.google.com with SMTP id c13so1716565ieb.38
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 14:49:59 -0700 (PDT)
In-Reply-To: <1369365969-21604-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 23, 2013 at 8:26 PM, Simon Horman <horms@verge.net.au> wrote:
> diff --git a/datapath/actions.c b/datapath/actions.c
> index 0dac658..1704876 100644
> --- a/datapath/actions.c
> +++ b/datapath/actions.c
> +/* The end of the mac header.
> + *
> + * For non-MPLS skbs this will correspond to the network header.
> + * For MPLS skbs it will be berfore the network_header as the MPLS
> + * label stack lies between the end of the mac header and the network
> + * header. That is, for MPLS skbs the end of the mac header
> + * is the top of the MPLS label stack.
> + */
> +static inline unsigned char *mac_header_end(const struct sk_buff *skb)

I think there probably isn't a strong reason to mark this inline since
it's not in a header file.

> +static void set_ethertype(struct sk_buff *skb, __be16 ethertype)
> +{
> +       __be16 *skb_ethertype = get_ethertype(skb);
> +       if (*skb_ethertype == ethertype)
> +               return;

I would guess that the test to check for the existing EtherType is
probably not actually beneficial as an optimization.

> +static int pop_mpls(struct sk_buff *skb, const __be16 ethertype)
[...]
> +       set_ethertype(skb, ethertype);
> +       skb->protocol = ethertype;

I think setting skb->protocol here is potentially not correct in the
presence of vlans (and similarly in push_mpls).

> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index 42af315..841f545 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c
> -static int validate_and_copy_actions(const struct nlattr *attr,
> +#define MAX_ETH_TYPES 16 /* Arbitrary Limit */
> +
> +/* struct eth_types - possible eth types
> + * @types: provides storage for the possible eth types.
> + * @start: is the index of the first entry of types which is possible.
> + * @end: is the index of the last entry of types which is possible.
> + * @cursor: is the index of the entry which should be updated if an action
> + * changes the eth type.
> + *
> + * Due to the sample action there may be multiple possible eth types.
> + * In order to correctly validate actions all possible types are tracked
> + * and verified. This is done using struct eth_types.
> + *
> + * Initially start, end and cursor should be 0, and the first element of
> + * types should be set to the eth type of the flow.
> + *
> + * When an action changes the eth type then the values of start and end are
> + * updated to the value of cursor. The new type is stored at types[cursor].
> + *
> + * When entering a sample action the start and cursor values are saved. The
> + * value of start is then set to the value of end. And the value of cursor
> + * is set to the value of end plus one.
> + *
> + * When leaving a sample action the start and cursor values are restored to
> + * their saved values.
> + *
> + * An example follows.
> + *
> + * actions: pop_mpls(A),sample(pop_mpls(B)),sample(pop_mpls(C)),pop_mpls(D)
> + *
> + * 0. Initial state:
> + *     types = { original_eth_type }
> + *     start = end = cursor = 0;
> + *
> + * 1. pop_mpls(A)
> + *    a. Check types from start (0) to end (0) inclusive
> + *    b. Set start = end = cursor
> + *    c. Set types[cursor] = A
> + *    New state:
> + *     types = { A }
> + *     start = end = cursor = 0;
> + *
> + * 2. Enter first sample()
> + *    a. Save start and cursor
> + *    b. Set start = end
> + *    c. Set cursor = end + 1
> + *    New state:
> + *     types = { A }
> + *     start = end = 0;
> + *     cursor = 1;
> + *
> + * 3. pop_mpls(B)
> + *    a. Check types from start (0) to end (0) inclusive
> + *    b. Set start = end = cursor
> + *    c. Set types[cursor] = B
> + *    New state:
> + *     types = { A, B }
> + *     start = end = cursor = 1;
> + *
> + * 4. Leave first sample()
> + *    a. Restore start and cursor to the values when entering 2.
> + *    New state:
> + *     types = { A, B }
> + *     start = cursor = 0;
> + *     end = 1;
> + *
> + * 5. Enter second sample()
> + *    a. Save start and cursor
> + *    b. Set start = end
> + *    c. Set cursor = end + 1
> + *    New state:
> + *     types = { A, B }
> + *     start = end = 1;
> + *     cursor = 2;
> + *
> + * 6. pop_mpls(C)
> + *    a. Check types from start (1) to end (1) inclusive
> + *    b. Set start = end = cursor
> + *    c. Set types[cursor] = C
> + *    New state:
> + *     types = { A, B, C }
> + *     start = end = cursor = 2;

I'm not sure that the check is right here - won't this verify just
that B is correct but we could have either A or B?

> +struct eth_types {
> +       int start, end, cursor;
> +       __be16 types[SAMPLE_ACTION_DEPTH];

Should this be MAX_ETH_TYPES?

Otherwise, I think there is just the GSO changes to take advantage of
the new upstream capabilities and support for existing kernels.
