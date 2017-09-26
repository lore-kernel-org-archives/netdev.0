From: John Hurley <john.hurley@netronome.com>
Subject: Re: [PATCH net-next 2/7] nfp: compile flower vxlan tunnel metadata
 match fields
Date: Tue, 26 Sep 2017 14:58:30 +0100
Message-ID: <CAK+XE=nSHn6FGTi0kcqi+mcaV3Lo8QANpqQ4z6uNcWE+M3Gngw@mail.gmail.com>
References: <1506335021-32024-1-git-send-email-simon.horman@netronome.com>
 <1506335021-32024-3-git-send-email-simon.horman@netronome.com> <CAJ3xEMgs2d7dcktHfvx_iry8tBy8XK8n6E5W7J0pYPer9Xz_Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Simon Horman <simon.horman@netronome.com>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        oss-drivers@netronome.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:46531 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968134AbdIZN6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 09:58:31 -0400
Received: by mail-wr0-f182.google.com with SMTP id o42so13319258wrb.3
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 06:58:31 -0700 (PDT)
In-Reply-To: <CAJ3xEMgs2d7dcktHfvx_iry8tBy8XK8n6E5W7J0pYPer9Xz_Kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 7:35 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Mon, Sep 25, 2017 at 1:23 PM, Simon Horman
> <simon.horman@netronome.com> wrote:
>> From: John Hurley <john.hurley@netronome.com>
>>
>> Compile ovs-tc flower vxlan metadata match fields for offloading. Only
>
> anything in the npf kernel bits has direct relation to ovs? what?
>

Sorry, this is a typo  and should refer to TC.

>> +++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
>> @@ -52,8 +52,25 @@
>>          BIT(FLOW_DISSECTOR_KEY_PORTS) | \
>>          BIT(FLOW_DISSECTOR_KEY_ETH_ADDRS) | \
>>          BIT(FLOW_DISSECTOR_KEY_VLAN) | \
>> +        BIT(FLOW_DISSECTOR_KEY_ENC_KEYID) | \
>> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV4_ADDRS) | \
>> +        BIT(FLOW_DISSECTOR_KEY_ENC_IPV6_ADDRS) | \
>
> this series takes care of IPv6 tunnels too?

IPv6 is not included in this set.
The reason the IPv6 bit is included here is to account for behavior we
have noticed in TC flower.
If, for example, I add a filter with the following match fields:
'protocol ip flower enc_src_ip 10.0.0.1 enc_dst_ip 10.0.0.2
enc_dst_port 4789 enc_key_id 123'
The 'used_keys' value in the dissector marks both IPv4 and IPv6 encap
addresses as 'used'.
I am not sure if this is a bug in TC or that we are expected to check
the enc_control fields to determine if IPv4 or v6 addresses are used.
Including the IPv6 used_keys bit in our whitelist approach allows us
to accept legitimate IPv4 tunnel rules in these situations.
If it is found to be IPv6 when the rule is parsed, it will be rejected here.
