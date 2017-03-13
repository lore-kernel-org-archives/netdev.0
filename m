From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization 3/3] openvswitch: Optimize
 sample action for the clone use cases
Date: Mon, 13 Mar 2017 00:08:49 -0700
Message-ID: <CAOrHB_CNyhQM5wVJvYNQtE8+RKLAbPrjsrQtbGe-poHi+5AW+g@mail.gmail.com>
References: <1489193500-15260-1-git-send-email-azhou@ovn.org> <1489193500-15260-4-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:53672 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750801AbdCMHIz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:08:55 -0400
Received: from mfilter14-d.gandi.net (mfilter14-d.gandi.net [217.70.178.142])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 0BB7EFB8BC
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:08:53 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter14-d.gandi.net (mfilter14-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 7LJQ1VQv0RGp for <netdev@vger.kernel.org>;
        Mon, 13 Mar 2017 08:08:50 +0100 (CET)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id AC2C1FB8C1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:08:50 +0100 (CET)
Received: by mail-wm0-f45.google.com with SMTP id n11so32629770wma.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:08:50 -0700 (PDT)
In-Reply-To: <1489193500-15260-4-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 10, 2017 at 4:51 PM, Andy Zhou <azhou@ovn.org> wrote:
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
> The main optimization implemented in this series removes the static
> nesting limit check, instead, implement the run time recursion limit
> check, and recursion avoidance similar to that of the 'recirc' action.
> This optimization solve both #1 and #2 issues above.
>
> One related optimization attemps to avoid copying flow key as
> long as the actions enclosed does not change the flow key. The
> detection is performed only once at the flow downloading time.
>
> Another related optimization is to rewrite the action list
> at flow downloading time in order to save the fast path from parsing
> the sample action list in its original form repeatedly.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  include/uapi/linux/openvswitch.h |  13 ++++
>  net/openvswitch/actions.c        | 111 ++++++++++++++++++----------------
>  net/openvswitch/datapath.h       |   1 +
>  net/openvswitch/flow_netlink.c   | 126 ++++++++++++++++++++++++++++-----------
>  4 files changed, 162 insertions(+), 89 deletions(-)
>
....
...
>  static int sample(struct datapath *dp, struct sk_buff *skb,
>                   struct sw_flow_key *key, const struct nlattr *attr,
> -                 const struct nlattr *actions, int actions_len)
> +                 bool last)
>  {
> -       const struct nlattr *acts_list = NULL;
> -       const struct nlattr *a;
> -       int rem;
> -       u32 cutlen = 0;
> -
> -       for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
> -                a = nla_next(a, &rem)) {
> -               u32 probability;
> +       struct nlattr *actions;
> +       struct nlattr *sample_arg;
> +       struct sk_buff *clone_skb;
> +       struct sw_flow_key *orig = key;
> +       int rem = nla_len(attr);
> +       int err = 0;
> +       const struct sample_arg *arg;
>
> -               switch (nla_type(a)) {
> -               case OVS_SAMPLE_ATTR_PROBABILITY:
> -                       probability = nla_get_u32(a);
> -                       if (!probability || prandom_u32() > probability)
> -                               return 0;
> -                       break;
> +       /* The first action is always 'OVS_SAMPLE_ATTR_ARG'. */
> +       sample_arg = nla_data(attr);
> +       arg = nla_data(sample_arg);
> +       actions = nla_next(sample_arg, &rem);
>
> -               case OVS_SAMPLE_ATTR_ACTIONS:
> -                       acts_list = a;
> -                       break;
> -               }
> +       if ((arg->probability != U32_MAX) &&
> +               (!arg->probability || prandom_u32() > arg->probability)) {
> +               if (last)
> +                       consume_skb(skb);
To simplify let the existing code in do_execute_action() handle
freeing skb in this case.

> +               return 0;
>         }
>
> -       rem = nla_len(acts_list);
> -       a = nla_data(acts_list);
> -
> -       /* Actions list is empty, do nothing */
> -       if (unlikely(!rem))
> +       /* Unless the last action, Sample actions work on the skb clone.  */
> +       clone_skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
> +       if (!clone_skb) {
> +               /* Out of memory, skip this sample action.
> +                */
>                 return 0;
> +       }
>
> -       /* The only known usage of sample action is having a single user-space
> -        * action, or having a truncate action followed by a single user-space
> -        * action. Treat this usage as a special case.
> -        * The output_userspace() should clone the skb to be sent to the
> -        * user space. This skb will be consumed by its caller.
> +       /* In case the sample actions won't change 'key',
> +        * we can use key for the clone execution.
> +        * Otherwise, try to allocate a key from the
> +        * next recursion level of 'flow_keys'. If
> +        * successful, we can still execute the clone
> +        * actions  without deferring.
> +        *
> +        * Defer the sample action if the action recursion
> +        * limit has been reached.
>          */
> -       if (unlikely(nla_type(a) == OVS_ACTION_ATTR_TRUNC)) {
> -               struct ovs_action_trunc *trunc = nla_data(a);
> -
> -               if (skb->len > trunc->max_len)
> -                       cutlen = skb->len - trunc->max_len;
> -
> -               a = nla_next(a, &rem);
> +       if (!arg->exec) {
> +               __this_cpu_inc(exec_actions_level);
> +               key = clone_key(key);
>         }
>
> -       if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
> -                  nla_is_last(a, rem)))
> -               return output_userspace(dp, skb, key, a, actions,
> -                                       actions_len, cutlen);
> -
> -       skb = skb_clone(skb, GFP_ATOMIC);
> -       if (!skb)
> -               /* Skip the sample action when out of memory. */
> -               return 0;
> +       if (key) {
> +               err = do_execute_actions(dp, skb, key, actions, rem);
> +       } else if (!add_deferred_actions(skb, orig, actions, rem)) {
>
We can refactor this code to avoid duplicate code all actions
implementation. This way there could be single function dealing with
both defered action and key fifo arrays.

....
....
> diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
> index 1c6e937..d8d3953 100644
> --- a/net/openvswitch/datapath.h
> +++ b/net/openvswitch/datapath.h
> @@ -220,4 +220,5 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         if (logging_allowed && net_ratelimit())                 \
>                 pr_info("netlink: " fmt "\n", ##__VA_ARGS__);   \
>  } while (0)
> +
>  #endif /* datapath.h */

Extraneous whitespace change.

> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 6f5fa50..c8ac538 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
...
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
> +                       break;
> +
> +               case OVS_ACTION_ATTR_PUSH_MPLS:
> +               case OVS_ACTION_ATTR_POP_MPLS:
> +               case OVS_ACTION_ATTR_PUSH_VLAN:
> +               case OVS_ACTION_ATTR_POP_VLAN:
> +               case OVS_ACTION_ATTR_SET:
> +               case OVS_ACTION_ATTR_SET_MASKED:
> +               case OVS_ACTION_ATTR_HASH:
> +               case OVS_ACTION_ATTR_CT:
> +               case OVS_ACTION_ATTR_PUSH_ETH:
> +               case OVS_ACTION_ATTR_POP_ETH:
> +               default:
> +                       return true;
> +               }
> +       }
> +       return false;
> +}
> +
I am not sure if we can put sample or recirc in "may not change flow"
actions list. Consider following set of actions:
sample(sample(set-IP)),userpsace(),...
In this case the userspace action could recieve skb with inconsistent
flow due to preceding of set action nested in the sample action.

>  static void update_range(struct sw_flow_match *match,
>                          size_t offset, size_t size, bool is_mask)
>  {
....
> @@ -2056,20 +2091,32 @@ static int validate_and_copy_sample(struct net *net, const struct nlattr *attr,
>         start = add_nested_action_start(sfa, OVS_ACTION_ATTR_SAMPLE, log);
>         if (start < 0)
>                 return start;
> -       err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_PROBABILITY,
> -                                nla_data(probability), sizeof(u32), log);
> +
> +       /* When both skb and flow may be changed, put the sample
> +        * into a deferred fifo. On the other hand, if only skb
> +        * may be modified, the actions can be executed in place.
> +        *
> +        * Do this analysis at the flow installation time.
> +        * Set 'clone_action->exec' to true if the actions can be
> +        * executed without being deferred.
> +        *
> +        * If the sample is the last action, it can always be excuted
> +        * rather than deferred.
> +        */
> +       arg.exec = last || !actions_may_change_flow(actions);
> +       arg.probability = nla_get_u32(probability);
> +
> +       err = ovs_nla_add_action(sfa, OVS_SAMPLE_ATTR_ARG, &arg, sizeof(arg),
> +                                log);
>         if (err)
>                 return err;
> -       st_acts = add_nested_action_start(sfa, OVS_SAMPLE_ATTR_ACTIONS, log);
> -       if (st_acts < 0)
> -               return st_acts;
>
> -       err = __ovs_nla_copy_actions(net, actions, key, depth + 1, sfa,
> +       err = __ovs_nla_copy_actions(net, actions, key, depth, sfa,
>                                      eth_type, vlan_tci, log);

Since sample action `depth` is not tracked anymore during flow
install, we should remove the parameter and its limit from datapath.h.
...
