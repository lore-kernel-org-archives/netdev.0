From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH v2] datapath: Avoid using stack larger than 1024.
Date: Wed, 28 Jun 2017 13:35:57 -0700
Message-ID: <CAOrHB_CRhRRMCcspYysQrr1erAbKYv0EH-fHz+RXihUcOy8wzw@mail.gmail.com>
References: <1498616999-3035-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Greg Rose <gvrose8192@gmail.com>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:60105 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdF1UgG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 16:36:06 -0400
Received: from mfilter22-d.gandi.net (mfilter22-d.gandi.net [217.70.178.150])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id AAC4B1720B3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 22:35:59 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter22-d.gandi.net (mfilter22-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id aZ5kJk30fnS8 for <netdev@vger.kernel.org>;
        Wed, 28 Jun 2017 22:35:58 +0200 (CEST)
Received: from mail-wr0-f181.google.com (mail-wr0-f181.google.com [209.85.128.181])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 3A9F51720A3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 22:35:58 +0200 (CEST)
Received: by mail-wr0-f181.google.com with SMTP id 77so180036634wrb.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 13:35:58 -0700 (PDT)
In-Reply-To: <1498616999-3035-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 7:29 PM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
> When compiling OvS-master on 4.4.0-81 kernel,
> there is a warning:
>
>     CC [M]  /root/ovs/datapath/linux/datapath.o
>     /root/ovs/datapath/linux/datapath.c: In function
>     ‘ovs_flow_cmd_set’:
>     /root/ovs/datapath/linux/datapath.c:1221:1: warning:
>     the frame size of 1040 bytes is larger than 1024 bytes
>     [-Wframe-larger-than=]
>
> This patch factors out match-init and action-copy to avoid
> "Wframe-larger-than=1024" warning. Because mask is only
> used to get actions, we new a function to save some
> stack space.
>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
>  datapath/datapath.c | 73 ++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 50 insertions(+), 23 deletions(-)
>
> diff --git a/datapath/datapath.c b/datapath/datapath.c
> index c85029c..fdbe314 100644
> --- a/datapath/datapath.c
> +++ b/datapath/datapath.c
> @@ -1100,6 +1100,50 @@ static struct sw_flow_actions *get_flow_actions(struct net *net,
>         return acts;
>  }
>
> +/* Factor out match-init and action-copy to avoid
> + * "Wframe-larger-than=1024" warning. Because mask is only
> + * used to get actions, we new a function to save some
> + * stack space.
> + *
> + * If there are not key and action attrs, we return 0
> + * directly. In the case, the caller will also not use the
> + * match as before. If there is action attr, we try to get
> + * actions and save them to *acts.
> + * */
> +static int ovs_nla_init_match_and_action(struct net *net,
> +                                        struct sw_flow_match *match,
> +                                        struct sw_flow_key *key,
> +                                        struct nlattr **a,
> +                                        struct sw_flow_actions **acts,
> +                                        bool log)
> +{
> +       struct sw_flow_mask mask;
> +       int error = 0;
> +
> +       if (a[OVS_FLOW_ATTR_KEY]) {
> +               ovs_match_init(match, key, true, &mask);
> +               error = ovs_nla_get_match(net, match, a[OVS_FLOW_ATTR_KEY],
> +                                         a[OVS_FLOW_ATTR_MASK], log);
> +               if (error)
> +                       return error;
> +       }
> +
> +       if (a[OVS_FLOW_ATTR_ACTIONS]) {
> +               if (!a[OVS_FLOW_ATTR_KEY]) {
> +                       OVS_NLERR(log,
> +                                 "Flow key attribute not present in set flow.");
> +                       return -EINVAL;
> +               }
> +
> +               *acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], key,
> +                                        &mask, log);
> +               if (IS_ERR(*acts))
> +                       return PTR_ERR(*acts);
> +       }
> +
> +       return 0;
> +}
> +
>  static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>  {
>         struct net *net = sock_net(skb->sk);
> @@ -1107,7 +1151,6 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>         struct ovs_header *ovs_header = info->userhdr;
>         struct sw_flow_key key;
>         struct sw_flow *flow;
> -       struct sw_flow_mask mask;
>         struct sk_buff *reply = NULL;
>         struct datapath *dp;
>         struct sw_flow_actions *old_acts = NULL, *acts = NULL;
> @@ -1119,34 +1162,18 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>         bool ufid_present;
>
>         ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
> -       if (a[OVS_FLOW_ATTR_KEY]) {
> -               ovs_match_init(&match, &key, true, &mask);
> -               error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
> -                                         a[OVS_FLOW_ATTR_MASK], log);
> -       } else if (!ufid_present) {
> +       if (!a[OVS_FLOW_ATTR_KEY] && !ufid_present) {
>                 OVS_NLERR(log,
>                           "Flow set message rejected, Key attribute missing.");
> -               error = -EINVAL;
> +               return -EINVAL;
>         }
> +
> +       error = ovs_nla_init_match_and_action(net, &match, &key, a,
> +                                             &acts, log);
This looks good. But it is returning match object with dangling
reference to mask. It is fine for now as it is not referenced outside
of the function for now. But it is not pretty. We could reset the mask
pointer before returning from the function. and write comment
explaining it.
