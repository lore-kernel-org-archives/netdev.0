From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next] openvswitch: Simplify do_execute_actions().
Date: Fri, 27 Jan 2017 12:42:27 -0800
Message-ID: <CAOrHB_C3C_pcPpS=TSvKD0pF8eKRZMVgCK6eNKfbJnT_-xs1xw@mail.gmail.com>
References: <1485408261-31999-1-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:58556 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdA0Um7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:42:59 -0500
Received: from mfilter18-d.gandi.net (mfilter18-d.gandi.net [217.70.178.146])
        by relay2-d.mail.gandi.net (Postfix) with ESMTP id B71A1C5A46
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 21:42:30 +0100 (CET)
Received: from relay2-d.mail.gandi.net ([IPv6:::ffff:217.70.183.194])
        by mfilter18-d.gandi.net (mfilter18-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id 3DNXdSUmlK9B for <netdev@vger.kernel.org>;
        Fri, 27 Jan 2017 21:42:29 +0100 (CET)
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id 1BAC2C5A44
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 21:42:28 +0100 (CET)
Received: by mail-io0-f169.google.com with SMTP id v96so69589599ioi.0
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:42:28 -0800 (PST)
In-Reply-To: <1485408261-31999-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 9:24 PM, Andy Zhou <azhou@ovn.org> wrote:
> do_execute_actions() implements a worthwhile optimization: in case
> an output action is the last action in an action list, skb_clone()
> can be avoided by outputing the current skb. However, the
> implementation is more complicated than necessary.  This patch
> simplify this logic.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/actions.c | 40 +++++++++++++++++++---------------------
>  1 file changed, 19 insertions(+), 21 deletions(-)
>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 514f7bc..3866608 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -830,6 +830,9 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
>  {
>         struct vport *vport = ovs_vport_rcu(dp, out_port);
>
> +       if (unlikely(!skb))
> +               return;
> +
Patch looks good to me. But I wanted to know if you considered moving
this check to do_execute_actions() in case skb-clone is done? This way
we can avoid this unlikely check from likely case :)


>         if (likely(vport)) {
>                 u16 mru = OVS_CB(skb)->mru;
>                 u32 cutlen = OVS_CB(skb)->cutlen;
> @@ -1141,12 +1144,6 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                               struct sw_flow_key *key,
>                               const struct nlattr *attr, int len)
>  {
> -       /* Every output action needs a separate clone of 'skb', but the common
> -        * case is just a single output action, so that doing a clone and
> -        * then freeing the original skbuff is wasteful.  So the following code
> -        * is slightly obscure just to avoid that.
> -        */
> -       int prev_port = -1;
>         const struct nlattr *a;
>         int rem;
>
> @@ -1154,20 +1151,25 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>              a = nla_next(a, &rem)) {
>                 int err = 0;
>
> -               if (unlikely(prev_port != -1)) {
> -                       struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
> +               switch (nla_type(a)) {
> +               case OVS_ACTION_ATTR_OUTPUT: {
> +                       int port = nla_get_u32(a);
>
> -                       if (out_skb)
> -                               do_output(dp, out_skb, prev_port, key);
> +                       /* Every output action needs a separate clone
> +                        * of 'skb', In case the output action is the
> +                        * last action, cloning can be avoided.
> +                        */
> +                       if (nla_is_last(a, rem)) {
> +                               do_output(dp, skb, port, key);
> +                               /* 'skb' has been used for output.
> +                                */
> +                               return 0;
> +                       }
>
> +                       do_output(dp, skb_clone(skb, GFP_ATOMIC), port, key);
>                         OVS_CB(skb)->cutlen = 0;
> -                       prev_port = -1;
> -               }
> -
> -               switch (nla_type(a)) {
> -               case OVS_ACTION_ATTR_OUTPUT:
> -                       prev_port = nla_get_u32(a);
>                         break;
> +               }
>
>                 case OVS_ACTION_ATTR_TRUNC: {
>                         struct ovs_action_trunc *trunc = nla_data(a);
