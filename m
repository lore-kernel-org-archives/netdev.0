From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next RFC 4/4] openvswitch: Add meter action support
Date: Fri, 13 Oct 2017 17:13:00 -0700
Message-ID: <CAOrHB_AaUYb_s4Mp9gOBsH26P1CHcnEcLjPW8ZDeJxPCESP3pw@mail.gmail.com>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org> <1507847923-13612-5-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:55847 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdJNAND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 20:13:03 -0400
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D7118A80C7
        for <netdev@vger.kernel.org>; Sat, 14 Oct 2017 02:13:01 +0200 (CEST)
Received: by mail-wm0-f44.google.com with SMTP id m72so24150244wmc.1
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 17:13:01 -0700 (PDT)
In-Reply-To: <1507847923-13612-5-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 12, 2017 at 3:38 PM, Andy Zhou <azhou@ovn.org> wrote:
> Implements OVS kernel meter action support.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  include/uapi/linux/openvswitch.h |  1 +
>  net/openvswitch/actions.c        | 12 ++++++++++++
>  net/openvswitch/datapath.h       |  1 +
>  net/openvswitch/flow_netlink.c   |  6 ++++++
>  4 files changed, 20 insertions(+)
>
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 325049a129e4..11fe1a06cdd6 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -835,6 +835,7 @@ enum ovs_action_attr {
>         OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>         OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>         OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> +       OVS_ACTION_ATTR_METER,        /* u32 meter ID. */
>
>         __OVS_ACTION_ATTR_MAX,        /* Nothing past this will be accepted
>                                        * from userspace. */
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index a54a556fcdb5..4eb160ac5a27 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -1210,6 +1210,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>                 case OVS_ACTION_ATTR_POP_ETH:
>                         err = pop_eth(skb, key);
>                         break;
> +
> +               case OVS_ACTION_ATTR_METER:
> +                       if (ovs_meter_execute(dp, skb, key, nla_get_u32(a))) {
> +                               consume_skb(skb);
> +                               return 0;
> +                       }
>                 }
>
>                 if (unlikely(err)) {
> @@ -1341,6 +1347,12 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
>         err = do_execute_actions(dp, skb, key,
>                                  acts->actions, acts->actions_len);
>
> +       /* OVS action has dropped the packet, do not expose it
> +        * to the user.
> +        */
> +       if (err == -ENODATA)
> +               err = 0;
> +
I am not sure who is returning this error code?
