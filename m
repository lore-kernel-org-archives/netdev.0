From: Joe Stringer <joe@ovn.org>
Subject: Re: [RFC net-next sample action optimization 3/3] openvswitch:
 Optimize sample action for the clone use cases
Date: Thu, 9 Mar 2017 11:46:00 -0800
Message-ID: <CAPWQB7F0XkHWkJ15N-ru83XBUkr2474yjmk0C_H1WErhELr+Ew@mail.gmail.com>
References: <1488932137-120383-1-git-send-email-azhou@ovn.org> <1488932137-120383-4-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, pravin shelar <pshelar@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:51385 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752986AbdCITq2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 14:46:28 -0500
Received: from mfilter30-d.gandi.net (mfilter30-d.gandi.net [217.70.178.161])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 04F5217209A
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:46:25 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter30-d.gandi.net (mfilter30-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Gy2PTdoxl0I3 for <netdev@vger.kernel.org>;
        Thu,  9 Mar 2017 20:46:22 +0100 (CET)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
        (Authenticated sender: joe@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 426D617209B
        for <netdev@vger.kernel.org>; Thu,  9 Mar 2017 20:46:22 +0100 (CET)
Received: by mail-qk0-f182.google.com with SMTP id 1so135957260qkl.3
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 11:46:22 -0800 (PST)
In-Reply-To: <1488932137-120383-4-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7 March 2017 at 16:15, Andy Zhou <azhou@ovn.org> wrote:
> With the introduction of open flow 'clone' action, the OVS user space
> can now translate the 'clone' action into kernel datapath 'sample'
> action, with 100% probability, to ensure that the clone semantics,
> which is that the packet seen by the clone action is the same as the
> packet seen by the action after clone, is faithfully carried out
> in the datapath.
>
> While the sample action in the datpath has the matching semantics,
> its implementation is only optimized for its original use.
> Specifically, there are two limitation: First, there is a 3 level of
> nesting restriction, enforced at the flow downloading time. This
> limit turns out to be too restrictive for the 'clone' use case.
> Second, the implementation avoid recursive call only if the sample
> action list has a single userspace action.
>
> The optimization implemented in this series removes the static
> nesting limit check, instead, implement the run time recursion limit
> check, and recursion avoidance similar to that of the 'recirc' action.
> This optimization solve both #1 and #2 issues above.
>
> Another optimization implemented is to avoid coping flow key as

*copying

> long as the actions enclosed does not change the flow key. The
> detection is performed only once at the flow downloading time.
>
> The third optimization implemented is to rewrite the action list
> at flow downloading time in order to save the fast path from parsing
> the sample action list in its original form repeatedly.

Whenever there is an enumeration (1, 2, 3; ..another..., third thing
implemented) in a commit message, I have to ask whether each "another
change..." should be a separate patch. It certainly makes it easier to
review.

I ran this through the OVS kernel tests and it's working correctly
from that point of view, but I didn't get a chance to dig in and
ensure for example, runtime behaviour of several nested
sample(actions(sample(actions(sample(actions(output)))))) handles
reasonably when it runs out of stack and deferred actions space. At a
high level though, this seems pretty straightforward.

Several comments below, thanks.

>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/actions.c      | 106 ++++++++++++++++++------------------
>  net/openvswitch/datapath.h     |   7 +++
>  net/openvswitch/flow_netlink.c | 118 ++++++++++++++++++++++++++++-------------
>  3 files changed, 140 insertions(+), 91 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 259aea9..2e8c372 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -930,71 +930,52 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
>  }
>
>  static int sample(struct datapath *dp, struct sk_buff *skb,
> -                 struct sw_flow_key *key, const struct nlattr *attr,
> -                 const struct nlattr *actions, int actions_len)
> +                 struct sw_flow_key *key, const struct nlattr *attr)
>  {
> -       const struct nlattr *acts_list = NULL;
> -       const struct nlattr *a;
> -       int rem;
> -       u32 cutlen = 0;
> -
> -       for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
> -                a = nla_next(a, &rem)) {
> -               u32 probability;
> -
> -               switch (nla_type(a)) {
> -               case OVS_SAMPLE_ATTR_PROBABILITY:
> -                       probability = nla_get_u32(a);
> -                       if (!probability || prandom_u32() > probability)
> -                               return 0;
> -                       break;
> -
> -               case OVS_SAMPLE_ATTR_ACTIONS:
> -                       acts_list = a;
> -                       break;
> -               }
> -       }
> +       struct nlattr *actions;
> +       struct nlattr *sample_arg;
> +       struct sw_flow_key *orig = key;
> +       int rem = nla_len(attr);
> +       int err = 0;
> +       const struct sample_arg *arg;
>
> -       rem = nla_len(acts_list);
> -       a = nla_data(acts_list);
> +       /* The first action is always 'OVS_SAMPLE_ATTR_AUX'. */

Is it? This is the only reference to OVS_SAMPLE_ATTR_AUX I can see.

> +       sample_arg = nla_data(attr);

We could do this in the parent call, like several other actions do.

<snip>

> @@ -1246,9 +1227,24 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                         err = execute_masked_set_action(skb, key, nla_data(a));
>                         break;
>
> -               case OVS_ACTION_ATTR_SAMPLE:
> -                       err = sample(dp, skb, key, a, attr, len);
> +               case OVS_ACTION_ATTR_SAMPLE: {
> +                       bool last = nla_is_last(a, rem);
> +                       struct sk_buff *clone_skb;
> +
> +                       clone_skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
> +
> +                       if (!clone_skb)
> +                               /* Out of memory, skip this sample action.
> +                                */

Should we ratelimited complain in this case?

> +                               break;
> +
> +                       err = sample(dp, clone_skb, key, a);
> +                       if (last)
> +                               return err;

Given that sample() doesn't guarantee it will free 'clone_skb', I
don't think this is safe.

> +
> +                       pr_err("executing sample");

Useful for debugging, but don't forget to drop for next version.

>                         break;
> +                       }

This bracket is typically aligned with the character of the beginning
of the 'case' that it applies to.

>
>                 case OVS_ACTION_ATTR_CT:
>                         if (!is_flow_key_valid(key)) {
> diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
> index 1c6e937..d7a6e803 100644
> --- a/net/openvswitch/datapath.h
> +++ b/net/openvswitch/datapath.h
> @@ -220,4 +220,11 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         if (logging_allowed && net_ratelimit())                 \
>                 pr_info("netlink: " fmt "\n", ##__VA_ARGS__);   \
>  } while (0)
> +
> +#define OVS_SAMPLE_ATTR_ARG  (OVS_ACTION_ATTR_MAX + 1)

This should be defined in include/uapi/linux/openvswitch.h, protected
by #ifdef __KERNEL__ like the other internal formats. While I don't
think it actually conflicts with any other internal action format,
these should be in one place so we don't end up accidentally using the
same enum twice.

> +struct sample_arg {
> +       bool exec;
> +       u32  probability;
> +};

Perhaps we should move this to either net/openvswitch/flow_netlink.h
or include/linux/openvswitch.h since it's only for consumption
internally by the kernel module?

> +
>  #endif /* datapath.h */
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 6f5fa50..0e7cf13 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (c) 2007-2014 Nicira, Inc.
> + * Copyright (c) 2007-2017 Nicira, Inc.
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of version 2 of the GNU General Public
> @@ -59,6 +59,39 @@ struct ovs_len_tbl {
>  #define OVS_ATTR_NESTED -1
>  #define OVS_ATTR_VARIABLE -2
>
> +static bool actions_may_change_flow(const struct nlattr *actions)
> +{
> +       struct nlattr *nla;
> +       int rem;
> +
> +       nla_for_each_nested(nla, actions, rem) {
> +               u16 action = nla_type(nla);
> +
> +               switch (action) {
> +               case OVS_ACTION_ATTR_OUTPUT:
> +               case OVS_ACTION_ATTR_RECIRC:
> +               case OVS_ACTION_ATTR_USERSPACE:
> +               case OVS_ACTION_ATTR_SAMPLE:
> +               case OVS_ACTION_ATTR_TRUNC:

Trunc doesn't change the flow, but if there's something like
sample(output,trunc),output() then I wouldn't expect the final output
to be truncated.

<snip>

> @@ -2621,39 +2670,36 @@ int ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
>         return err;
>  }
>
> -static int sample_action_to_attr(const struct nlattr *attr, struct sk_buff *skb)
> +static int sample_action_to_attr(const struct nlattr *attr,
> +                                struct sk_buff *skb)
>  {
> -       const struct nlattr *a;
> -       struct nlattr *start;
> -       int err = 0, rem;
> +       struct nlattr *start, *ac_start, *sample_arg;
> +       int err = 0, rem = nla_len(attr);
> +       const struct sample_arg *arg;
> +       struct nlattr *actions;
>
>         start = nla_nest_start(skb, OVS_ACTION_ATTR_SAMPLE);
>         if (!start)
>                 return -EMSGSIZE;
>
> -       nla_for_each_nested(a, attr, rem) {
> -               int type = nla_type(a);
> -               struct nlattr *st_sample;
> +       sample_arg = nla_data(attr);
> +       arg = nla_data(sample_arg);
> +       actions = nla_next(sample_arg, &rem);
>
> -               switch (type) {
> -               case OVS_SAMPLE_ATTR_PROBABILITY:
> -                       if (nla_put(skb, OVS_SAMPLE_ATTR_PROBABILITY,
> -                                   sizeof(u32), nla_data(a)))
> -                               return -EMSGSIZE;
> -                       break;
> -               case OVS_SAMPLE_ATTR_ACTIONS:
> -                       st_sample = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
> -                       if (!st_sample)
> -                               return -EMSGSIZE;
> -                       err = ovs_nla_put_actions(nla_data(a), nla_len(a), skb);
> -                       if (err)
> -                               return err;
> -                       nla_nest_end(skb, st_sample);
> -                       break;
> -               }
> -       }
> +       if (nla_put_u32(skb, OVS_SAMPLE_ATTR_PROBABILITY, arg->probability))
> +               return -EMSGSIZE;
>
> +       ac_start = nla_nest_start(skb, OVS_SAMPLE_ATTR_ACTIONS);
> +       if (!ac_start)
> +               return -EMSGSIZE;
> +
> +       err = ovs_nla_put_actions(actions, rem, skb);
> +       if (err)
> +               return err;

Shouldn't we nla_nest_cancel() when something fails in the middle of
nesting nla attributes? For example I believe that upcall will attempt
to serialize actions, but if actions don't fit in the buffer then
it'll just skip the actions and forward everything else.

> +
> +       nla_nest_end(skb, ac_start);
>         nla_nest_end(skb, start);
> +
>         return err;
>  }
>
> --
> 1.8.3.1
>
