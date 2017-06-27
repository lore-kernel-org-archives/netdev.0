From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] datapath: Avoid using stack larger than 1024.
Date: Tue, 27 Jun 2017 14:19:38 -0700
Message-ID: <CAOrHB_AEsJNsUao9H-0u-dQndPqS5gfZV1tYNc2K_ex_6OAVSQ@mail.gmail.com>
References: <1498555249-112319-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:49676 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753583AbdF0VTm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 17:19:42 -0400
Received: from mfilter24-d.gandi.net (mfilter24-d.gandi.net [217.70.178.152])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 15F5841C090
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:19:41 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter24-d.gandi.net (mfilter24-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id WgnkadcSbvd6 for <netdev@vger.kernel.org>;
        Tue, 27 Jun 2017 23:19:39 +0200 (CEST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
        (Authenticated sender: pshelar@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id ABE3741C08B
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 23:19:39 +0200 (CEST)
Received: by mail-wm0-f49.google.com with SMTP id b184so39510781wme.1
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 14:19:39 -0700 (PDT)
In-Reply-To: <1498555249-112319-1-git-send-email-xiangxia.m.yue@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 27, 2017 at 2:20 AM, Tonghao Zhang <xiangxia.m.yue@gmail.com> wrote:
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
> This patch use kmalloc to malloc mem for sw_flow_mask and
> avoid using stack.
>
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
> ---
>  net/openvswitch/datapath.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index c85029c..da8cd68 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -1107,7 +1107,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>         struct ovs_header *ovs_header = info->userhdr;
>         struct sw_flow_key key;
>         struct sw_flow *flow;
> -       struct sw_flow_mask mask;
> +       struct sw_flow_mask *mask;
>         struct sk_buff *reply = NULL;
>         struct datapath *dp;
>         struct sw_flow_actions *old_acts = NULL, *acts = NULL;
> @@ -1120,7 +1120,11 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>
>         ufid_present = ovs_nla_get_ufid(&sfid, a[OVS_FLOW_ATTR_UFID], log);
>         if (a[OVS_FLOW_ATTR_KEY]) {
> -               ovs_match_init(&match, &key, true, &mask);
> +               mask = kmalloc(sizeof(struct sw_flow_mask), GFP_KERNEL);
> +               if (!mask)
> +                       return -ENOMEM;
> +
> +               ovs_match_init(&match, &key, true, mask);

Rather than allocating mask object and freeing it at the end, can you
factor out code which needs mask into new function to save some stack
space in this function?

>                 error = ovs_nla_get_match(net, &match, a[OVS_FLOW_ATTR_KEY],
>                                           a[OVS_FLOW_ATTR_MASK], log);
>         } else if (!ufid_present) {
> @@ -1141,7 +1145,7 @@ static int ovs_flow_cmd_set(struct sk_buff *skb, struct genl_info *info)
>                 }
>
>                 acts = get_flow_actions(net, a[OVS_FLOW_ATTR_ACTIONS], &key,
> -                                       &mask, log);
> +                                       mask, log);
>                 if (IS_ERR(acts)) {
>                         error = PTR_ERR(acts);
>                         goto error;
> @@ -1216,6 +1220,7 @@ err_unlock_ovs:
>  err_kfree_acts:
>         ovs_nla_free_flow_actions(acts);
>  error:
> +       kfree(mask);

mask free is missing in usual, no error case.
