From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [net-next v2 3/4] openvswitch: Add meter infrastructure
Date: Wed, 18 Oct 2017 11:47:41 -0700
Message-ID: <CAOrHB_DBSxoxncBN1+DqcAPcpLABCA_8=h2af5XN7sVhL8Sezw@mail.gmail.com>
References: <1508225805-11613-1-git-send-email-azhou@ovn.org> <1508225805-11613-4-git-send-email-azhou@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Andy Zhou <azhou@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:59223 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdJRSro (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:47:44 -0400
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 166A0A80D0
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 20:47:42 +0200 (CEST)
Received: by mail-wm0-f45.google.com with SMTP id i124so11905333wmf.3
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:47:42 -0700 (PDT)
In-Reply-To: <1508225805-11613-4-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 12:36 AM, Andy Zhou <azhou@ovn.org> wrote:
> OVS kernel datapath so far does not support Openflow meter action.
> This is the first stab at adding kernel datapath meter support.
> This implementation supports only drop band type.
>
> Signed-off-by: Andy Zhou <azhou@ovn.org>
> ---
>  net/openvswitch/Makefile   |   1 +
>  net/openvswitch/datapath.c |  14 +-
>  net/openvswitch/datapath.h |   3 +
>  net/openvswitch/meter.c    | 604 +++++++++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/meter.h    |  54 ++++
>  5 files changed, 674 insertions(+), 2 deletions(-)
>  create mode 100644 net/openvswitch/meter.c
>  create mode 100644 net/openvswitch/meter.h
>
This patch mostly looks good. I have one comment below.

> +static int ovs_meter_cmd_set(struct sk_buff *skb, struct genl_info *info)
> +{
> +       struct nlattr **a = info->attrs;
> +       struct dp_meter *meter, *old_meter;
> +       struct sk_buff *reply;
> +       struct ovs_header *ovs_reply_header;
> +       struct ovs_header *ovs_header = info->userhdr;
> +       struct datapath *dp;
> +       int err;
> +       u32 meter_id;
> +       bool failed;
> +
> +       meter = dp_meter_create(a);
> +       if (IS_ERR_OR_NULL(meter))
> +               return PTR_ERR(meter);
> +
> +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_SET,
> +                                         &ovs_reply_header);
> +       if (IS_ERR(reply)) {
> +               err = PTR_ERR(reply);
> +               goto exit_free_meter;
> +       }
> +
> +       ovs_lock();
> +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
> +       if (!dp) {
> +               err = -ENODEV;
> +               goto exit_unlock;
> +       }
> +
> +       if (!a[OVS_METER_ATTR_ID]) {
> +               err = -ENODEV;
> +               goto exit_unlock;
> +       }
> +
> +       meter_id = nla_get_u32(a[OVS_METER_ATTR_ID]);
> +
> +       /* Cannot fail after this. */
> +       old_meter = lookup_meter(dp, meter_id);
I do not see RCU read lock taken here. This is not correctness issue
but it could cause RCU checker to spit out warning message. You could
do same trick that is done in get_dp() to avoid this issue.

Can you also test the code with rcu sparse check config option enabled?

Thanks.
