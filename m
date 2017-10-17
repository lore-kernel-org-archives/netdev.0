From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next RFC 3/4] openvswitch: Add meter infrastructure
Date: Tue, 17 Oct 2017 00:40:27 -0700
Message-ID: <CABKoBm0N+5QdmVyddp5MeWnZctWh39m7ovr600zS74f419r8BA@mail.gmail.com>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
 <1507847923-13612-4-git-send-email-azhou@ovn.org> <CAOrHB_Cc1cB7mYbYr+uDqsNusP=xALQAWZo=Mr+X9xzgepGFtw@mail.gmail.com>
 <CABKoBm2T6-BgecNr4RRkvtW2+Z4dXBrFo=Wn2TpsX=J+HTuXtg@mail.gmail.com> <CAOrHB_B4JYQ84yMZNHzmbkkgk_R6jukpw=_kQ5S-R8qMq+++Rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:57721 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754265AbdJQHwH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:52:07 -0400
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net [217.70.183.195])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 6AED847E7C6
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 09:41:11 +0200 (CEST)
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
        (Authenticated sender: azhou@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id DACB1A80E9
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 09:41:09 +0200 (CEST)
Received: by mail-pf0-f173.google.com with SMTP id a8so753932pfc.0
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:41:09 -0700 (PDT)
In-Reply-To: <CAOrHB_B4JYQ84yMZNHzmbkkgk_R6jukpw=_kQ5S-R8qMq+++Rw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 10:49 AM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Mon, Oct 16, 2017 at 12:05 AM, Andy Zhou <azhou@ovn.org> wrote:
>> On Fri, Oct 13, 2017 at 5:12 PM, Pravin Shelar <pshelar@ovn.org> wrote:
>>> On Thu, Oct 12, 2017 at 3:38 PM, Andy Zhou <azhou@ovn.org> wrote:
>>>> OVS kernel datapath so far does not support Openflow meter action.
>>>> This is the first stab at adding kernel datapath meter support.
>>>> This implementation supports only drop band type.
>>>>
>>>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>>>> ---
>>>>  net/openvswitch/Makefile   |   1 +
>>>>  net/openvswitch/datapath.c |  14 +-
>>>>  net/openvswitch/datapath.h |   3 +
>>>>  net/openvswitch/meter.c    | 611 +++++++++++++++++++++++++++++++++++++++++++++
>>>>  net/openvswitch/meter.h    |  54 ++++
>>>>  5 files changed, 681 insertions(+), 2 deletions(-)
>>>>  create mode 100644 net/openvswitch/meter.c
>>>>  create mode 100644 net/openvswitch/meter.h
>>>>
>>> ...
>>>
>>>> diff --git a/net/openvswitch/meter.c b/net/openvswitch/meter.c
>>>> new file mode 100644
>>>> index 000000000000..f24ebb5f7af4
>>>> --- /dev/null
>>>> +++ b/net/openvswitch/meter.c
>>>
>>> ....
>>> ....
>>>> +static int ovs_meter_cmd_features(struct sk_buff *skb, struct genl_info *info)
>>>> +{
>>>> +       struct datapath *dp;
>>>> +       struct ovs_header *ovs_header = info->userhdr;
>>>> +       struct sk_buff *reply;
>>>> +       struct ovs_header *ovs_reply_header;
>>>> +       struct nlattr *nla, *band_nla;
>>>> +       int err;
>>>> +
>>>> +       /* Check that the datapath exists */
>>>> +       ovs_lock();
>>>> +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>>>> +       ovs_unlock();
>>>> +       if (!dp)
>>>> +               return -ENODEV;
>>>> +
>>> why dp check is required for this API?
>> Is it possible for another core delete the dp, before ovs_lock()
>> returns? Then, in theory, get_dp() can
>> return NULL, no?
>
> I do not see dp used anywhere in function. so the question was why is
> dp lookup done here?

Got it. I misunderstood. You are right, we don't need the dp pointer.
Just posted v2.

>
>>>
>>>> +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_FEATURES,
>>>> +                                         &ovs_reply_header);
>>>> +       if (!reply)
>>>> +               return PTR_ERR(reply);
>>>> +
>>>> +       if (nla_put_u32(reply, OVS_METER_ATTR_MAX_METERS, U32_MAX) ||
>>>> +           nla_put_u32(reply, OVS_METER_ATTR_MAX_BANDS, DP_MAX_BANDS))
>>>> +               goto nla_put_failure;
>>>> +
>>>> +       nla = nla_nest_start(reply, OVS_METER_ATTR_BANDS);
>>>> +       if (!nla)
>>>> +               goto nla_put_failure;
>>>> +
>>>> +       band_nla = nla_nest_start(reply, OVS_BAND_ATTR_UNSPEC);
>>>> +       if (!band_nla)
>>>> +               goto nla_put_failure;
>>>> +       /* Currently only DROP band type is supported. */
>>>> +       if (nla_put_u32(reply, OVS_BAND_ATTR_TYPE, OVS_METER_BAND_TYPE_DROP))
>>>> +               goto nla_put_failure;
>>>> +       nla_nest_end(reply, band_nla);
>>>> +       nla_nest_end(reply, nla);
>>>> +
>>>> +       genlmsg_end(reply, ovs_reply_header);
>>>> +       return genlmsg_reply(reply, info);
>>>> +
>>>> +nla_put_failure:
>>>> +       nlmsg_free(reply);
>>>> +       err = -EMSGSIZE;
>>>> +       return err;
>>>> +}
>>>> +
>>> ....
>>>
>>>> +static int ovs_meter_cmd_set(struct sk_buff *skb, struct genl_info *info)
>>>> +{
>>>> +       struct nlattr **a = info->attrs;
>>>> +       struct dp_meter *meter, *old_meter;
>>>> +       struct sk_buff *reply;
>>>> +       struct ovs_header *ovs_reply_header;
>>>> +       struct ovs_header *ovs_header = info->userhdr;
>>>> +       struct datapath *dp;
>>>> +       int err;
>>>> +       u32 meter_id;
>>>> +       bool failed;
>>>> +
>>>> +       meter = dp_meter_create(a);
>>>> +       if (IS_ERR_OR_NULL(meter))
>>>> +               return PTR_ERR(meter);
>>>> +
>>>> +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_SET,
>>>> +                                         &ovs_reply_header);
>>>> +       if (IS_ERR(reply)) {
>>>> +               err = PTR_ERR(reply);
>>>> +               goto exit_free_meter;
>>>> +       }
>>>> +
>>>> +       ovs_lock();
>>>> +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>>>> +       if (!dp) {
>>>> +               err = -ENODEV;
>>>> +               goto exit_unlock;
>>>> +       }
>>>> +
>>>> +       if (!a[OVS_METER_ATTR_ID]) {
>>>> +               err = -ENODEV;
>>>> +               goto exit_unlock;
>>>> +       }
>>>> +
>>>> +       meter_id = nla_get_u32(a[OVS_METER_ATTR_ID]);
>>>> +
>>>> +       /* Cannot fail after this. */
>>>> +       old_meter = lookup_meter(dp, meter_id);
>>>> +       attach_meter(dp, meter);
>>>> +       ovs_unlock();
>>>> +
>>> After the unlock, it is not safe to keep the ref to old_meter. better
>>> to release lock at the end. we could optimize it later if required.
>>
>> I see a problem here: the old_meter has not been removed from the list before
>> unlock. The code should have been:
>>
>> old_meter = lookup_meter(dp, meter_id);
>> detch_meter(dp, old_meter);
>> attach_meter(dp, meter);
>> ovs_unlock();
>>
>> Do you still see a problem w.r.t. unlock() here? Once detch_meter() is called,
>> another thread should not have access to 'old_meter' any more. right?
>
> looks good.
