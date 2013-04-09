From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/4] Add packet recirculation
Date: Tue, 9 Apr 2013 08:44:02 -0700
Message-ID: <CAEP_g=-baZGttBowXKGdgKafxp9fkUrQ=44y562ZzfnOL-XaQg@mail.gmail.com>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
 <1365403431-18102-2-git-send-email-horms@verge.net.au> <CAEP_g=9nj24hZcA-czzuz3xaweATxRxmibuFaqODTSoPmRmHsw@mail.gmail.com>
 <20130409075024.GG11444@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Ben Pfaff <blp@nicira.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog134.obsmtp.com ([74.125.149.83]:40102 "HELO
	na3sys009aog134.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1762557Ab3DIPoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:44:23 -0400
Received: by mail-oa0-f70.google.com with SMTP id n12so42977539oag.5
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 08:44:22 -0700 (PDT)
In-Reply-To: <20130409075024.GG11444@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 9, 2013 at 12:50 AM, Simon Horman <horms@verge.net.au> wrote:
> On Mon, Apr 08, 2013 at 06:46:29PM -0700, Jesse Gross wrote:
>> On Sun, Apr 7, 2013 at 11:43 PM, Simon Horman <horms@verge.net.au> wrote:
>> > diff --git a/datapath/actions.c b/datapath/actions.c
>> > index e9634fe..7b0f022 100644
>> > --- a/datapath/actions.c
>> > +++ b/datapath/actions.c
>> > @@ -617,6 +617,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>> >                 case OVS_ACTION_ATTR_SAMPLE:
>> >                         err = sample(dp, skb, a);
>> >                         break;
>> > +
>> > +               case OVS_ACTION_ATTR_RECIRCULATE:
>> > +                       return 1;
>>
>> I think that if we've had a previous output action with the port
>> stored in prev_port then this will cause the packet to not actually be
>> output.
>
> I'm not so sure.
>
> I see something like this occurring:
>
> 1. Iteration of for loop for output action
>
>    switch (nla_type(a)) {
>    case OVS_ACTION_ATTR_OUTPUT:
>         prev_port = nla_get_u32(a);
>         break;
>         ...
>    }
>
> 2. Iteration of of for loop for next action, lets say its is recirculate
>
>    i. Output packet
>
>    if (prev_port != -1) {
>         do_output(dp, skb_clone(skb, GFP_ATOMIC), prev_port);
>         prev_port = -1;
>    }
>
>    ii. Return due to recirculate
>    switch (nla_type(a)) {
>    ...
>    case OVS_ACTION_ATTR_RECIRCULATE:
>            return 1;
>    }
>
>
> Am I missing something?

Sorry, you're right.

>> > @@ -901,6 +913,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
>> >                         skip_copy = true;
>> >                         break;
>> >
>> > +               case OVS_ACTION_ATTR_RECIRCULATE:
>> > +                       break;
>>
>> I think we might want to jump out the loop here to better model how
>> the actions are actually executed.
>
> Sure, perhaps something like this?
>
> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index ab39dd7..721a52c 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c
> @@ -914,7 +914,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
>                         break;
>
>                 case OVS_ACTION_ATTR_RECIRCULATE:
> -                       break;
> +                       goto out;
>
>                 default:
>                         return -EINVAL;
> @@ -926,6 +926,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
>                 }
>         }
>
> +out:
>         if (rem > 0)
>                 return -EINVAL;

Since this function is now both validating and copying I think this
will result in the recirculate action not being copied.

>> > diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
>> > index 47830c1..5129da1 100644
>> > --- a/ofproto/ofproto-dpif.c
>> > +++ b/ofproto/ofproto-dpif.c
>>
>> I'm still working on more detailed comments for this.  However, I'm
>> concerned about whether the behavior for revalidation and stats is
>> correct.
>
> I am a little concerned about that too.
> Perhaps Ben could look over it?

To rephrase, there are problems in both of those areas. Validation in
particular I don't think handles resubmitted facets and I believe that
stats on rules will be the sum of all resubmitted passes.

Both of these will likely significantly affect the data structures, so
please look into this before we go further. In general, I'd also like
to see patches that are standalone without needing follow on patches
to fix known problems (for example, the recirculation ID patches or
MPLS GSO) unless there is a good reason.
