From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/4] Move execute_set_action to lib/odp-util.c
Date: Tue, 9 Apr 2013 08:17:14 -0700
Message-ID: <CAEP_g=_v8KbGbBHdR=z2PxRb-n3BHuZvvWZ4CW2bEe6n59enZg@mail.gmail.com>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
 <1365403431-18102-3-git-send-email-horms@verge.net.au> <CAEP_g=_JYu0m4G01osWCaMhu6ESdiryMQYvikfpuNNYj6dNn_A@mail.gmail.com>
 <20130409031119.GF11444@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:50887 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1762076Ab3DIPRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:17:35 -0400
Received: by mail-ob0-f199.google.com with SMTP id va7so14452245obc.6
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 08:17:34 -0700 (PDT)
In-Reply-To: <20130409031119.GF11444@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 8, 2013 at 8:11 PM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Apr 08, 2013 at 01:29:52PM -0700, Jesse Gross wrote:
>> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
>> > Move execute_set_action from lib/dpif-netedev.c to lib/odp-util.c
>> >
>> > This is in preparation for using execute_set_action()
>> > in lib/odp-util.c to handle recirculation/
>> >
>> > Signed-off-by: Simon Horman <horms@verge.net.au>
>> >
>> > ---
>> >
>> > packet.c might be a better place for execute_set_action()
>> > but I'm unsure if accessing struct ovs_key_ethernet would
>> > lead to a layering violation.
>>
>> I'd be tempted to just put this in it's own file.  As you say, it
>> doesn't really fit in either of the two existing ones.
>
> perhaps execute-action.c ?

Sure.

>>
>> > diff --git a/lib/odp-util.c b/lib/odp-util.c
>> > index e18e109..ad5873c 100644
>> > --- a/lib/odp-util.c
>> > +++ b/lib/odp-util.c
>> > @@ -2420,3 +2420,79 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
>> >      commit_set_priority_action(flow, base, odp_actions);
>> >      commit_set_skb_mark_action(flow, base, odp_actions);
>> >  }
>> > +
>> > +static void
>> > +dp_netdev_set_dl(struct ofpbuf *packet, const struct ovs_key_ethernet *eth_key)
>>
>> I think this function should be given a more generic name and possibly
>> moved to packet.c.
>
> Sure, how about eth_set_src_and_dst()

That sounds fine.

>> > +void
>> > +execute_set_action(struct ofpbuf *packet, const struct nlattr *a,
>> > +                   uint32_t *skb_mark)
>> > +{
>> > +    enum ovs_key_attr type = nl_attr_type(a);
>> > +    const struct ovs_key_ipv4 *ipv4_key;
>> > +    const struct ovs_key_ipv6 *ipv6_key;
>> > +    const struct ovs_key_tcp *tcp_key;
>> > +    const struct ovs_key_udp *udp_key;
>> > +
>> > +    switch (type) {
>> > +    case OVS_KEY_ATTR_PRIORITY:
>> > +    case OVS_KEY_ATTR_TUNNEL:
>> > +        /* not implemented */
>> > +        break;
>>
>> Don't we need to carry this information along as well similar to skb->mark?
>
> Most likely, sorry for missing that.
>
>> Also, is there a reason to not have the code for push/pop actions here as well?
>
> Good point.
>
> With that in mind perhaps execute_set_or_mpls_action() would
> be a good name for the function?

I'm not sure that this is specific to MPLS.  Won't we basically just
have the execute loop from dpif-netdev.c here?
