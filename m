From: Andy Zhou <azhou@ovn.org>
Subject: Re: [net-next RFC 3/4] openvswitch: Add meter infrastructure
Date: Mon, 16 Oct 2017 00:05:03 -0700
Message-ID: <CABKoBm2T6-BgecNr4RRkvtW2+Z4dXBrFo=Wn2TpsX=J+HTuXtg@mail.gmail.com>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
 <1507847923-13612-4-git-send-email-azhou@ovn.org> <CAOrHB_Cc1cB7mYbYr+uDqsNusP=xALQAWZo=Mr+X9xzgepGFtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Joe Stringer <joe@ovn.org>, Greg Rose <gvrose8192@gmail.com>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:36406 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdJPHFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 03:05:48 -0400
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
        (Authenticated sender: azhou@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 538A61720BE
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 09:05:46 +0200 (CEST)
Received: by mail-pf0-f175.google.com with SMTP id b79so15157888pfk.5
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 00:05:46 -0700 (PDT)
In-Reply-To: <CAOrHB_Cc1cB7mYbYr+uDqsNusP=xALQAWZo=Mr+X9xzgepGFtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 13, 2017 at 5:12 PM, Pravin Shelar <pshelar@ovn.org> wrote:
> On Thu, Oct 12, 2017 at 3:38 PM, Andy Zhou <azhou@ovn.org> wrote:
>> OVS kernel datapath so far does not support Openflow meter action.
>> This is the first stab at adding kernel datapath meter support.
>> This implementation supports only drop band type.
>>
>> Signed-off-by: Andy Zhou <azhou@ovn.org>
>> ---
>>  net/openvswitch/Makefile   |   1 +
>>  net/openvswitch/datapath.c |  14 +-
>>  net/openvswitch/datapath.h |   3 +
>>  net/openvswitch/meter.c    | 611 +++++++++++++++++++++++++++++++++++++++++++++
>>  net/openvswitch/meter.h    |  54 ++++
>>  5 files changed, 681 insertions(+), 2 deletions(-)
>>  create mode 100644 net/openvswitch/meter.c
>>  create mode 100644 net/openvswitch/meter.h
>>
> ...
>
>> diff --git a/net/openvswitch/meter.c b/net/openvswitch/meter.c
>> new file mode 100644
>> index 000000000000..f24ebb5f7af4
>> --- /dev/null
>> +++ b/net/openvswitch/meter.c
>
> ....
> ....
>> +static int ovs_meter_cmd_features(struct sk_buff *skb, struct genl_info *info)
>> +{
>> +       struct datapath *dp;
>> +       struct ovs_header *ovs_header = info->userhdr;
>> +       struct sk_buff *reply;
>> +       struct ovs_header *ovs_reply_header;
>> +       struct nlattr *nla, *band_nla;
>> +       int err;
>> +
>> +       /* Check that the datapath exists */
>> +       ovs_lock();
>> +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>> +       ovs_unlock();
>> +       if (!dp)
>> +               return -ENODEV;
>> +
> why dp check is required for this API?
Is it possible for another core delete the dp, before ovs_lock()
returns? Then, in theory, get_dp() can
return NULL, no?
>
>> +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_FEATURES,
>> +                                         &ovs_reply_header);
>> +       if (!reply)
>> +               return PTR_ERR(reply);
>> +
>> +       if (nla_put_u32(reply, OVS_METER_ATTR_MAX_METERS, U32_MAX) ||
>> +           nla_put_u32(reply, OVS_METER_ATTR_MAX_BANDS, DP_MAX_BANDS))
>> +               goto nla_put_failure;
>> +
>> +       nla = nla_nest_start(reply, OVS_METER_ATTR_BANDS);
>> +       if (!nla)
>> +               goto nla_put_failure;
>> +
>> +       band_nla = nla_nest_start(reply, OVS_BAND_ATTR_UNSPEC);
>> +       if (!band_nla)
>> +               goto nla_put_failure;
>> +       /* Currently only DROP band type is supported. */
>> +       if (nla_put_u32(reply, OVS_BAND_ATTR_TYPE, OVS_METER_BAND_TYPE_DROP))
>> +               goto nla_put_failure;
>> +       nla_nest_end(reply, band_nla);
>> +       nla_nest_end(reply, nla);
>> +
>> +       genlmsg_end(reply, ovs_reply_header);
>> +       return genlmsg_reply(reply, info);
>> +
>> +nla_put_failure:
>> +       nlmsg_free(reply);
>> +       err = -EMSGSIZE;
>> +       return err;
>> +}
>> +
> ....
>
>> +static int ovs_meter_cmd_set(struct sk_buff *skb, struct genl_info *info)
>> +{
>> +       struct nlattr **a = info->attrs;
>> +       struct dp_meter *meter, *old_meter;
>> +       struct sk_buff *reply;
>> +       struct ovs_header *ovs_reply_header;
>> +       struct ovs_header *ovs_header = info->userhdr;
>> +       struct datapath *dp;
>> +       int err;
>> +       u32 meter_id;
>> +       bool failed;
>> +
>> +       meter = dp_meter_create(a);
>> +       if (IS_ERR_OR_NULL(meter))
>> +               return PTR_ERR(meter);
>> +
>> +       reply = ovs_meter_cmd_reply_start(info, OVS_METER_CMD_SET,
>> +                                         &ovs_reply_header);
>> +       if (IS_ERR(reply)) {
>> +               err = PTR_ERR(reply);
>> +               goto exit_free_meter;
>> +       }
>> +
>> +       ovs_lock();
>> +       dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
>> +       if (!dp) {
>> +               err = -ENODEV;
>> +               goto exit_unlock;
>> +       }
>> +
>> +       if (!a[OVS_METER_ATTR_ID]) {
>> +               err = -ENODEV;
>> +               goto exit_unlock;
>> +       }
>> +
>> +       meter_id = nla_get_u32(a[OVS_METER_ATTR_ID]);
>> +
>> +       /* Cannot fail after this. */
>> +       old_meter = lookup_meter(dp, meter_id);
>> +       attach_meter(dp, meter);
>> +       ovs_unlock();
>> +
> After the unlock, it is not safe to keep the ref to old_meter. better
> to release lock at the end. we could optimize it later if required.

I see a problem here: the old_meter has not been removed from the list before
unlock. The code should have been:

old_meter = lookup_meter(dp, meter_id);
detch_meter(dp, old_meter);
attach_meter(dp, meter);
ovs_unlock();

Do you still see a problem w.r.t. unlock() here? Once detch_meter() is called,
another thread should not have access to 'old_meter' any more. right?
>
>> +       /* Build response with the meter_id and stats from
>> +        * the old meter, if any.
>> +        */
>> +       failed = nla_put_u32(reply, OVS_METER_ATTR_ID, meter_id);
>> +       WARN_ON(failed);
>> +       if (old_meter) {
>> +               spin_lock_bh(&old_meter->lock);
>> +               if (old_meter->keep_stats) {
>> +                       err = ovs_meter_cmd_reply_stats(reply, meter_id,
>> +                                                       old_meter);
>> +                       WARN_ON(err);
>> +               }
>> +               spin_unlock_bh(&old_meter->lock);
>> +               ovs_meter_free(old_meter);
>> +       }
>> +
>> +       genlmsg_end(reply, ovs_reply_header);
>> +       return genlmsg_reply(reply, info);
>> +
>> +exit_unlock:
>> +       ovs_unlock();
>> +       nlmsg_free(reply);
>> +exit_free_meter:
>> +       kfree(meter);
>> +       return err;
>> +}
>> +
> ....
>
>> +bool ovs_meter_execute(struct datapath *dp, struct sk_buff *skb,
>> +                      struct sw_flow_key *key, u32 meter_id)
>> +{
>> +       struct dp_meter *meter;
>> +       struct dp_meter_band *band;
>> +       long long int now_ms = ktime_get_ns() / 1000 / 1000;
>> +       long long int long_delta_ms;
>> +       u32 delta_ms;
>> +       u32 cost;
>> +       int i, band_exceeded_max = -1;
>> +       u32 band_exceeded_rate = 0;
>> +
>> +       meter = lookup_meter(dp, meter_id);
>> +       /* Do not drop the packet when there is no meter. */
>> +       if (!meter)
>> +               return false;
>> +
>> +       /* Lock the meter while using it. */
>> +       spin_lock(&meter->lock);
>> +
>> +       long_delta_ms = (now_ms - meter->used); /* ms */
>> +
>> +       /* Make sure delta_ms will not be too large, so that bucket will not
>> +        * wrap around below.
>> +        */
>> +       delta_ms = (long_delta_ms > (long long int)meter->max_delta_t)
>> +                  ? meter->max_delta_t : (u32)long_delta_ms;
>> +
>> +       /* Update meter statistics.
>> +        */
>> +       meter->used = now_ms;
>> +       meter->stats.n_packets += 1;
>> +       meter->stats.n_bytes += skb->len;
>> +
>> +       /* Bucket rate is either in kilobits per second, or in packets per
>> +        * second.  We maintain the bucket in the units of either bits or
>> +        * 1/1000th of a packet, correspondingly.
>> +        * Then, when rate is multiplied with milliseconds, we get the
>> +        * bucket units:
>> +        * msec * kbps = bits, and
>> +        * msec * packets/sec = 1/1000 packets.
>> +        *
>> +        * 'cost' is the number of bucket units in this packet.
>> +        */
>> +       cost = (meter->kbps) ? skb->len * 8 : 1000;
>> +
>> +       /* Update all bands and find the one hit with the highest rate. */
>> +       for (i = 0; i < meter->n_bands; ++i) {
>> +               long long int max_bucket_size;
>> +
>> +               band = &meter->bands[i];
>> +               max_bucket_size = (band->burst_size + band->rate) * 1000;
>> +
>> +               band->bucket += delta_ms * band->rate;
>> +               if (band->bucket > max_bucket_size)
>> +                       band->bucket = max_bucket_size;
>> +
>> +               if (band->bucket >= cost) {
>> +                       band->bucket -= cost;
>> +               } else if (band->rate > band_exceeded_rate) {
>> +                       band_exceeded_rate = band->rate;
>> +                       band_exceeded_max = i;
>> +               }
>> +       }
>> +
>> +       spin_unlock(&meter->lock);
>> +
>> +       if (band_exceeded_max >= 0) {
>> +               /* Update band statistics. */
>> +               band = &meter->bands[band_exceeded_max];
>> +               band->stats.n_packets += 1;
>> +               band->stats.n_bytes += skb->len;
>> +
> Is it safe to do outside of the sipinlock?

Good catch, those should be covered by the same lock.  Will fix.
>
>> +               /* Drop band triggered, let the caller drop the 'skb'.  */
>> +               if (band->type == OVS_METER_BAND_TYPE_DROP)
>> +                       return true;
>> +       }
>> +
>> +       return false;
>> +}
>> +
