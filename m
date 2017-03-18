From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next sample action optimization v3 4/4] Openvswitch:
 Refactor sample and recirc actions implementation
Date: Sat, 18 Mar 2017 12:22:39 -0700
Message-ID: <CAOrHB_B_Rd+kxKhq6n7gs=NF3nh5rk9YsQ2nNFfLLTk=o4o7ow@mail.gmail.com>
References: <1489704510-35975-1-git-send-email-azhou@ovn.org> <1489704510-35975-5-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:56892 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdCRTWo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Mar 2017 15:22:44 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id 134A51720A1
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 20:22:42 +0100 (CET)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id p8cxsaemLYw8 for <netdev@vger.kernel.org>;
        Sat, 18 Mar 2017 20:22:40 +0100 (CET)
Received: from mail-wr0-f170.google.com (mail-wr0-f170.google.com [209.85.128.170])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 9C3E4172098
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 20:22:40 +0100 (CET)
Received: by mail-wr0-f170.google.com with SMTP id u108so70044480wrb.3
        for <netdev@vger.kernel.org>; Sat, 18 Mar 2017 12:22:40 -0700 (PDT)
In-Reply-To: <1489704510-35975-5-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 16, 2017 at 3:48 PM, Andy Zhou <azhou@ovn.org> wrote:
> Added clone_execute() that both the sample and the recirc
> action implementation can use.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/actions.c | 175 ++++++++++++++++++++++++----------------------
>  1 file changed, 92 insertions(+), 83 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 3529f7b..e38fa7f 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -44,10 +44,6 @@
>  #include "conntrack.h"
>  #include "vport.h"
>
> -static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
> -                             struct sw_flow_key *key,
> -                             const struct nlattr *attr, int len);
> -
>  struct deferred_action {
>         struct sk_buff *skb;
>         const struct nlattr *actions;
> @@ -166,6 +162,12 @@ static bool is_flow_key_valid(const struct sw_flow_key *key)
>         return !(key->mac_proto & SW_FLOW_KEY_INVALID);
>  }
>
> +static int clone_execute(struct datapath *dp, struct sk_buff *skb,
> +                        struct sw_flow_key *key,
> +                        u32 recirc_id,
> +                        const struct nlattr *actions, int len,
> +                        bool last, bool clone_flow_key);
> +
With this function the diff stat looks much better.

...
...
> +/* Execute the actions on the clone of the packet. The effect of the
> + * execution does not affect the original 'skb' nor the original 'key'.
> + *
> + * The execution may be deferred in case the actions can not be executed
> + * immediately.
> + */
> +static int clone_execute(struct datapath *dp, struct sk_buff *skb,
> +                        struct sw_flow_key *key, u32 recirc_id,
> +                        const struct nlattr *actions, int len,
> +                        bool last, bool clone_flow_key)
> +{
> +       bool is_sample = actions;
Standard practice is use !! to convert pointer to boolean.
I think this function does not need to know about sample action. So we
can rename the boolean to have_actions or something similar.

> +       struct deferred_action *da;
> +       struct sw_flow_key *clone;
> +       int err = 0;
> +
> +       skb = last ? skb : skb_clone(skb, GFP_ATOMIC);
> +       if (!skb) {
> +               /* Out of memory, skip this action.
> +                */
> +               return 0;
> +       }
> +
> +       /* In case the sample actions won't change the 'key',
> +        * current key can be used directly to execute sample actions.
> +        * Otherwise, allocate a new key from the
> +        * next recursion level of 'flow_keys'. If
> +        * successful, execute the sample actions without
> +        * deferring.
> +        */
> +       if (is_sample && clone_flow_key)
> +               __this_cpu_inc(exec_actions_level);
> +
There is no need to increment actions level up here. it is only
required for do_execute_actions(). ovs_dp_process_packet() already
does it.


> +       clone = clone_flow_key ? clone_key(key) : key;
> +       if (clone) {
> +               if (is_sample) {
> +                       err = do_execute_actions(dp, skb, clone,
> +                                                actions, len);
> +               } else {
> +                       clone->recirc_id = recirc_id;
> +                       ovs_dp_process_packet(skb, clone);
> +               }
> +       }
wont this execute action twice, once here and again in deferred actions list?

> +
> +       if (is_sample && clone_flow_key)
> +               __this_cpu_dec(exec_actions_level);
> +
> +       /* Out of 'flow_keys' space. Defer them */
> +       da = add_deferred_actions(skb, key, actions, len);
> +       if (da) {
> +               if (!is_sample) {
> +                       key = &da->pkt_key;
> +                       key->recirc_id = recirc_id;
> +               }
> +       } else {
> +               /* Drop the SKB and log an error. */
> +               kfree_skb(skb);
> +
> +               if (net_ratelimit()) {
> +                       if (is_sample) {
> +                               pr_warn("%s: deferred action limit reached, drop sample action\n",
> +                                       ovs_dp_name(dp));
> +                       } else {
> +                               pr_warn("%s: deferred action limit reached, drop recirc action\n",
> +                                       ovs_dp_name(dp));
> +                       }
> +               }
> +       }
> +
> +       return err;
> +}
> +
>  static void process_deferred_actions(struct datapath *dp)
>  {
>         struct action_fifo *fifo = this_cpu_ptr(action_fifos);
> --
> 1.8.3.1
>
