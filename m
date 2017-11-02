From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next v2 3/4] openvswitch: Add meter infrastructure
Date: Thu, 2 Nov 2017 03:07:45 -0700
Message-ID: <CABKoBm3YuKo0n4upAXL4M=7rayi-ZY9Dbi5LC=WwNGB8az-X-w@mail.gmail.com>
References: <1508225805-11613-1-git-send-email-azhou@ovn.org>
 <1508225805-11613-4-git-send-email-azhou@ovn.org> <CAOrHB_DBSxoxncBN1+DqcAPcpLABCA_8=h2af5XN7sVhL8Sezw@mail.gmail.com>
 <CABKoBm1JdL3K=oG-xn7kc31t_CHM-EtnexQngoyrGQ8PUZitSg@mail.gmail.com> <CAOrHB_BPKKwGJzRaU1S_hNyQ=z27YV3hyWQc-C=J79dSua=_AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Greg Rose <gvrose8192@gmail.com>, Joe Stringer <joe@ovn.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54228 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdKBKIa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 06:08:30 -0400
Received: from mail-pg0-f47.google.com (mail-pg0-f47.google.com [74.125.83.47])
        (Authenticated sender: azhou@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id DE50FC5A82
        for <netdev@vger.kernel.org>; Thu,  2 Nov 2017 11:08:28 +0100 (CET)
Received: by mail-pg0-f47.google.com with SMTP id b192so4639477pga.2
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 03:08:28 -0700 (PDT)
In-Reply-To: <CAOrHB_BPKKwGJzRaU1S_hNyQ=z27YV3hyWQc-C=J79dSua=_AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 20, 2017 at 8:32 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Thu, Oct 19, 2017 at 5:58 PM, Andy Zhou <azhou@ovn.org> wrote:
>>
>> On Thu, Oct 19, 2017 at 02:47 Pravin Shelar <pshelar@ovn.org> wrote:
>>>
>>> On Tue, Oct 17, 2017 at 12:36 AM, Andy Zhou <azhou@ovn.org> wrote:
>>> > OVS kernel datapath so far does not support Openflow meter action.
>>> > This is the first stab at adding kernel datapath meter support.
>>> > This implementation supports only drop band type.
>>> >
>>> > Signed-off-by: Andy Zhou <azhou@ovn.org>
>>> > ---
>>> >  net/openvswitch/Makefile   |   1 +
>>> >  net/openvswitch/datapath.c |  14 +-
>>> >  net/openvswitch/datapath.h |   3 +
>>> >  net/openvswitch/meter.c    | 604
>>> > +++++++++++++++++++++++++++++++++++++++++++++
>>> >  net/openvswitch/meter.h    |  54 ++++
>>> >  5 files changed, 674 insertions(+), 2 deletions(-)
>>> >  create mode 100644 net/openvswitch/meter.c
>>> >  create mode 100644 net/openvswitch/meter.h
>>> >
>>> This patch mostly looks good. I have one comment below.
>>>
>>> > +static int ovs_meter_cmd_set(struct sk_buff *skb, struct genl_info
>>> > *info)
>>> > +{
>>> > +       struct nlattr **a = info->attrs;
>>> > +       struct dp_meter *meter, *old_meter;
>>> > +       struct sk_buff *reply;
>>> > +       struct ovs_header *ovs_reply_header;
>>> > +       struct ovs_header *ovs_header = info->userhdr;
>>> > +       struct datapath *dp;
>>> > +       int err;
>>> > +       u32 meter_id;
>>> > +       bool failed;
>>> > +
>>> > +       meter = dp_meter_create(a);
>>> > +       if (IS_ERR_OR_NULL(meter))
>>> > +               return PTR_ERR(meter);
>>> > +
>>> > +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_SET,
>>> > +                                         &ovs_reply_header);
>>> > +       if (IS_ERR(reply)) {
>>> > +               err = PTR_ERR(reply);
>>> > +               goto exit_free_meter;
>>> > +       }
>>> > +
>>> > +       ovs_lock();
>>> > +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>>> > +       if (!dp) {
>>> > +               err = -ENODEV;
>>> > +               goto exit_unlock;
>>> > +       }
>>> > +
>>> > +       if (!a[OVS_METER_ATTR_ID]) {
>>> > +               err = -ENODEV;
>>> > +               goto exit_unlock;
>>> > +       }
>>> > +
>>> > +       meter_id = nla_get_u32(a[OVS_METER_ATTR_ID]);
>>> > +
>>> > +       /* Cannot fail after this. */
>>> > +       old_meter = lookup_meter(dp, meter_id);
>>> I do not see RCU read lock taken here. This is not correctness issue
>>> but it could cause RCU checker to spit out warning message. You could
>>> do same trick that is done in get_dp() to avoid this issue.
>>
>> O.K.
>>>
>>>
>>>
>>> Can you also test the code with rcu sparse check config option enabled?
>>
>>
>> Do you mean to sparse compile with CONFIG_PROVE_LOCKING and
>> CONFIG_DENUG_OBJECTS_RCU_HEAD?
>
> You could use all following options simultaneously:
> CONFIG_PREEMPT
> CONFIG_DEBUG_PREEMPT
> CONFIG_DEBUG_SPINLOCK
> CONFIG_DEBUG_ATOMIC_SLEEP
> CONFIG_PROVE_RCU
> CONFIG_DEBUG_OBJECTS_RCU_HEAD

Thanks, I turned on those flags but did not get any error message. Do you
mind share the RCU checker message?
