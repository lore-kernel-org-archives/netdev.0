From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH 2/2] drivers: add vpls support
Date: Fri, 11 Aug 2017 08:14:45 -0700
Message-ID: <CAJieiUjiDuhOeGZH9hMf4zTSKfkQ9bhzb9_XE9+5V1ZaDa_f2A@mail.gmail.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com> <20170811125547.GZ773745@eidolon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Amine Kherbouche <amine.kherbouche@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:36545 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753004AbdHKPOq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 11:14:46 -0400
Received: by mail-vk0-f48.google.com with SMTP id u133so14302678vke.3
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 08:14:46 -0700 (PDT)
In-Reply-To: <20170811125547.GZ773745@eidolon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 5:55 AM, David Lamparter <equinox@diac24.net> wrote:
> On Thu, Aug 10, 2017 at 10:28:37PM +0200, Amine Kherbouche wrote:
>> This commit introduces the support of VPLS virtual device, that allows
>> performing  L2VPN multipoint to multipoint communication over MPLS PSN.
>>
>> VPLS device encap received ethernet frame over mpls packet and send it the
>> output device, in the other direction, when receiving the right configured
>> mpls packet, the matched mpls route calls the handler vpls function,
>> then pulls out the mpls header and send it back the entry point via
>> netif_rx().
>>
>> Two functions, mpls_entry_encode() and mpls_output_possible() are
>> exported from mpls/internal.h to be able to use them inside vpls driver.
>>
>> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
>

[snip]

> [...]
>> +union vpls_nh {
>> +     struct in6_addr         addr6;
>> +     struct in_addr          addr;
>> +};
>> +
>> +struct vpls_dst {
>> +     struct net_device       *dev;
>> +     union vpls_nh           addr;
>> +     u32                     label_in, label_out;
>> +     u32                     id;
>> +     u16                     vlan_id;
>
> I looked at VLAN support and decided against it because the bridge layer
> can handle this perfectly fine by using the bridge's vlan support to tag
> a port's pvid.

yes, agreed. there is no need for vlan here. The bridge can be
configured with the required vlan
mapping on the vpls port.



>
>> +     u8                      via_table;
>> +     u8                      flags;
>> +     u8                      ttl;
>> +};
>
> [...]
>> +struct vpls_priv {
>> +     struct net              *encap_net;
>> +     struct vpls_dst         dst;
>> +};
>> +
>> +static struct nla_policy vpls_policy[IFLA_VPLS_MAX + 1] = {
>> +     [IFLA_VPLS_ID]          = { .type = NLA_U32 },
>> +     [IFLA_VPLS_IN_LABEL]    = { .type = NLA_U32 },
>> +     [IFLA_VPLS_OUT_LABEL]   = { .type = NLA_U32 },
>> +     [IFLA_VPLS_OIF]         = { .type = NLA_U32 },
>> +     [IFLA_VPLS_TTL]         = { .type = NLA_U8  },
>> +     [IFLA_VPLS_VLANID]      = { .type = NLA_U8 },
>> +     [IFLA_VPLS_NH]          = { .type = NLA_U32 },
>> +     [IFLA_VPLS_NH6]         = { .len = sizeof(struct in6_addr) },
>> +};
>
> The original patchset was point-to-multipoint in a single netdev, and
> had some starts on optimized multicast support (which, admittedly, is a
> bit of a fringe thing, but still.)
>

I had been thinking about this as a single netdevice as well...which
can work with
the bridge driver using per vlan dst_metadata infra (similar to vxlan
single device and per vlan - vxlan mapping).

Multiple netdevice with one per vlan-vpls-id will work as well... but
starting with a single netdev
will be better (helps with scaling).
