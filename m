From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/7] nfp: compile flower vxlan tunnel metadata
 match fields
Date: Tue, 26 Sep 2017 18:33:49 +0300
Message-ID: <CAJ3xEMhio5+5BK3p5mq=TvA8SzAvjSJm75mN0XiChdWkW3C89g@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <1506335021-32024-3-git-send-email-simon.horman@netronome.com>
 <CAJ3xEMgs2d7dcktHfvx_iry8tBy8XK8n6E5W7J0pYPer9Xz_Kg@mail.gmail.com>
 <CAK+XE=nSHn6FGTi0kcqi+mcaV3Lo8QANpqQ4z6uNcWE+M3Gngw@mail.gmail.com>
 <CAJ3xEMgmC+4V+Yr9PeO1wJ=ACBoPMTrasd7Joyx--F9PjV1yvg@mail.gmail.com> <CAK+XE=kBG9761tN6uC3ziiqP-jrAjLJ_3J7M-cyfKvTqHVBk7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: John Hurley <john.hurley@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:38271 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754194AbdIZPdu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:33:50 -0400
Received: by mail-oi0-f65.google.com with SMTP id s145so1660871oie.5
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:33:50 -0700 (PDT)
In-Reply-To: <CAK+XE=kBG9761tN6uC3ziiqP-jrAjLJ_3J7M-cyfKvTqHVBk7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 6:11 PM, John Hurley <john.hurley@netronome.com> wrote:
> On Tue, Sep 26, 2017 at 3:12 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Tue, Sep 26, 2017 at 4:58 PM, John Hurley <john.hurley@netronome.com> wrote:
>>> On Mon, Sep 25, 2017 at 7:35 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>>>> On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
>>>> <simon.horman@netronome.com> wrote:
>>>>> From: John Hurley <john.hurley@netronome.com>
>>>>>
>>>>> Compile ovs-tc flower vxlan metadata match fields for offloading. Only
>>>>
>>>> anything in the npf kernel bits has direct relation to ovs? what?
>>>>
>>>
>>> Sorry, this is a typo  and should refer to TC.
>>>
>>>>> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
>>>>> @@ -52,8 +52,25 @@
>>>>>          BIT(FLOW_DISSECTOR_KEY_PORTS) | \
>>>>>          BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) | \
>>>>>          BIT(FLOW_DISSECTOR_KEY_VLAN) | \
>>>>> +        BIT(FLOW_DISSECTOR_KEY_ENC_KEYID) | \
>>>>> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) | \
>>>>> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) | \
>>>>
>>>> this series takes care of IPv6 tunnels too?
>>>
>>> IPv6 is not included in this set.
>>> The reason the IPv6 bit is included here is to account for behavior we
>>> have noticed in TC flower.
>>> If, for example, I add a filter with the following match fields:
>>> 'protocol ip flower enc_src_ip 10.0.0.1 enc_dst_ip 10.0.0.2
>>> enc_dst_port 4789 enc_key_id 123'
>>> The 'used_keys' value in the dissector marks both IPv4 and IPv6 encap
>>> addresses as 'used'.
>>> I am not sure if this is a bug in TC or that we are expected to check
>>> the enc_control fields to determine if IPv4 or v6 addresses are used.
>>
>> you should have your code to check enc_control->addr_type to be
>> FLOW_DISSECTOR_KEY_IPV4_ADDRS or IPV6_ADDRS
>>
>>
>>> Including the IPv6 used_keys bit in our whitelist approach allows us
>>> to accept legitimate IPv4 tunnel rules in these situations.
>>
>> mmm can please take a look on fl_init_dissector() and tell me if you
>> see why FLOW_DISSECTOR_KEY_IPV6_ADDRS is set for ipv4 tunnels,
>> I am not sure.
>
>
> The fl_init_dissector uses the FL_KEY_SET_IF_MASKED macro to set an
> array of keys which are then translated to the used_keys values.
> The FL_KEY_SET_IF_MASKED takes a 'struct fl_flow_key' as input and
> checks if any mask bits are set in a particular field - if so it
> eventually marks it as used.
> In struct fl_flow_key, the encap ipv4 and ipv6 addresses are
> represented as a union of the 2.
> Therefore, if we have masked bits set for IPv4, they are also being
> set for the IPv6 field.

I see, do you consider it a bug?
