From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix mask generation for nested attributes.
Date: Fri, 11 Sep 2015 18:37:40 -0700
Message-ID: <CAEP_g=-7uU4Q2rCw4YD2Hd=gucGPhPONW8mrW6J1MqhEUd7zeg@mail.gmail.com>
References: <1441935378-19986-1-git-send-email-jesse@nicira.com> <CALnjE+oAEk6J_NCq21QHXdX-y3kUxocuLgC8XAwWmpg+eyvHhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:33593 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752820AbbILBiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 21:38:02 -0400
Received: by lamp12 with SMTP id p12so56841377lam.0
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 18:38:00 -0700 (PDT)
In-Reply-To: <CALnjE+oAEk6J_NCq21QHXdX-y3kUxocuLgC8XAwWmpg+eyvHhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 9:04 AM, Pravin Shelar <pshelar@nicira.com> wrote:
> On Thu, Sep 10, 2015 at 6:36 PM, Jesse Gross <jesse@nicira.com> wrote:
>> Masks were added to OVS flows in a way that was backwards compatible
>> with userspace programs that did not generate masks. As a result, it is
>> possible that we may receive flows that do not have a mask and we need
>> to synthesize one.
>>
>> Generating a mask requires iterating over attributes and descending into
>> nested attributes. For each level we need to know the size to generate the
>> correct mask. We do this with a linked table of attribute types.
>>
>> Although the logic to handle these nested attributes was there in concept,
>> there are a number of bugs in practice. Examples include incomplete links
>> between tables, variable length attributes being treated as nested and
>> missing sanity checks.
>>
> Missing Fixes tag.

This isn't really fixing one commit, it's more something that has
degraded over time. I'm also not looking for this to go to stable
since I haven't actually heard reports of this causing a problem, it's
just something I saw by looking at the code.

> This patch adds white space space errors.
>
> ./scripts/checkpatch.pl
> 0001-openvswitch-Fix-mask-generation-for-nested-attribute.patch
>
> total: 15 errors, 19 warnings, 0 checks, 130 lines checked

Fixed, thanks.

>> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
>> index c92d6a2..83a6847 100644
>> --- a/net/openvswitch/flow_netlink.c
>> +++ b/net/openvswitch/flow_netlink.c
>> @@ -57,6 +57,7 @@ struct ovs_len_tbl {
>>  };
>>
>
> ...
>>         unsigned long opt_key_offset;
>>         struct vxlan_metadata opts;
>> -       int err;
>>
>>         BUILD_BUG_ON(sizeof(opts) > sizeof(match->key->tun_opts));
>>
>> -       err = nla_parse_nested(tb, OVS_VXLAN_EXT_MAX, a, vxlan_opt_policy);
>> -       if (err < 0)
>> -               return err;
>> -
>>         memset(&opts, 0, sizeof(opts));
>> +       nla_for_each_nested(a, attr, rem) {
>> +               int type = nla_type(a);
>>
>> -       if (tb[OVS_VXLAN_EXT_GBP])
>> -               opts.gbp = nla_get_u32(tb[OVS_VXLAN_EXT_GBP]);
>> +               if (type > OVS_VXLAN_EXT_MAX) {
>> +                        OVS_NLERR(log, "VXLAN extension %d out of range max %d",
>> +                                  type, OVS_VXLAN_EXT_MAX);
>> +                        return -EINVAL;
>> +                }
>> +
>> +                if (ovs_vxlan_ext_key_lens[type].len != nla_len(a) &&
>> +                    !(ovs_vxlan_ext_key_lens[type].len == OVS_ATTR_NESTED ||
>> +                      ovs_vxlan_ext_key_lens[type].len == OVS_ATTR_VARIABLE)) {
>
> ovs_vxlan_ext_key_lens types is never set to nested or variable len.
> so this would not true.

At the moment, it's true that it can't happen. However, I'd like to
avoid making assumptions like that in the code since it could make it
more likely that this type of problem is reintroduced in the future.
It's somewhat moot anyways after the introduction of a common helper
function.

>> +                        OVS_NLERR(log, "VXLAN extension %d has unexpected len %d expected %d",
>> +                                  type, nla_len(a), ovs_vxlan_ext_key_lens[type].len);
>> +                        return -EINVAL;
>> +                }
>> +
>> +                switch (type) {
>> +               case OVS_VXLAN_EXT_GBP:
>> +                       opts.gbp = nla_get_u32(a);
>> +                       break;
>> +               default:
>> +                        OVS_NLERR(log, "Unknown VXLAN extension attribute %d",
>> +                                  type);
>> +                        return -EINVAL;
>> +               }
>> +       }
>
> Need to check for remaining bytes in this attribute.

Added.

>> @@ -1923,7 +1951,8 @@ static int validate_set(const struct nlattr *a,
>>
>>         if (key_type > OVS_KEY_ATTR_MAX ||
>>             (ovs_key_lens[key_type].len != key_len &&
>> -            ovs_key_lens[key_type].len != OVS_ATTR_NESTED))
>> +            !(ovs_key_lens[key_type].len == OVS_ATTR_NESTED ||
>> +              ovs_key_lens[key_type].len == OVS_ATTR_VARIABLE)))
>
> Same check are done multiple times, It would be nice if we add helper
> function for this.

I agree it's better. I factored these out.

I'll send out a v2 shortly.
