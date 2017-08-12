From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH 2/2] drivers: add vpls support
Date: Sat, 12 Aug 2017 15:40:07 +0200
Message-ID: <0c3d6029-faa6-aa40-7db5-0970734868b8@6wind.com>
References: <1502396917-14848-1-git-send-email-amine.kherbouche@6wind.com>
 <1502396917-14848-3-git-send-email-amine.kherbouche@6wind.com>
 <20170811125547.GZ773745@eidolon>
 <CAJieiUjiDuhOeGZH9hMf4zTSKfkQ9bhzb9_XE9+5V1ZaDa_f2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:33018 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdHLNkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 09:40:10 -0400
Received: by mail-wr0-f174.google.com with SMTP id c22so6099719wrb.0
        for <netdev@vger.kernel.org>; Sat, 12 Aug 2017 06:40:10 -0700 (PDT)
In-Reply-To: <CAJieiUjiDuhOeGZH9hMf4zTSKfkQ9bhzb9_XE9+5V1ZaDa_f2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/08/2017 17:14, Roopa Prabhu wrote:
> On Fri, Aug 11, 2017 at 5:55 AM, David Lamparter <equinox@diac24.net> wrote:
>> On Thu, Aug 10, 2017 at 10:28:37PM +0200, Amine Kherbouche wrote:
>>> This commit introduces the support of VPLS virtual device, that allows
>>> performing  L2VPN multipoint to multipoint communication over MPLS PSN.
>>>
>>> VPLS device encap received ethernet frame over mpls packet and send it the
>>> output device, in the other direction, when receiving the right configured
>>> mpls packet, the matched mpls route calls the handler vpls function,
>>> then pulls out the mpls header and send it back the entry point via
>>> netif_rx().
>>>
>>> Two functions, mpls_entry_encode() and mpls_output_possible() are
>>> exported from mpls/internal.h to be able to use them inside vpls driver.
>>>
>>> Signed-off-by: Amine Kherbouche <amine.kherbouche@6wind.com>
> [snip]
>
>> [...]
>>> +union vpls_nh {
>>> +     struct in6_addr         addr6;
>>> +     struct in_addr          addr;
>>> +};
>>> +
>>> +struct vpls_dst {
>>> +     struct net_device       *dev;
>>> +     union vpls_nh           addr;
>>> +     u32                     label_in, label_out;
>>> +     u32                     id;
>>> +     u16                     vlan_id;
>> I looked at VLAN support and decided against it because the bridge layer
>> can handle this perfectly fine by using the bridge's vlan support to tag
>> a port's pvid.
> yes, agreed. there is no need for vlan here. The bridge can be
> configured with the required vlan
> mapping on the vpls port.
what if the output device cannot handle vlan encapsulation? because on my
example of configuration in the cover letter, I sent the vpls packets over
a simple physical net device (not a bridge nor a vlan port).
>
>
>>> +     u8                      via_table;
>>> +     u8                      flags;
>>> +     u8                      ttl;
>>> +};
>> [...]
>>> +struct vpls_priv {
>>> +     struct net              *encap_net;
>>> +     struct vpls_dst         dst;
>>> +};
>>> +
>>> +static struct nla_policy vpls_policy[IFLA_VPLS_MAX + 1] = {
>>> +     [IFLA_VPLS_ID]          = { .type = NLA_U32 },
>>> +     [IFLA_VPLS_IN_LABEL]    = { .type = NLA_U32 },
>>> +     [IFLA_VPLS_OUT_LABEL]   = { .type = NLA_U32 },
>>> +     [IFLA_VPLS_OIF]         = { .type = NLA_U32 },
>>> +     [IFLA_VPLS_TTL]         = { .type = NLA_U8  },
>>> +     [IFLA_VPLS_VLANID]      = { .type = NLA_U8 },
>>> +     [IFLA_VPLS_NH]          = { .type = NLA_U32 },
>>> +     [IFLA_VPLS_NH6]         = { .len = sizeof(struct in6_addr) },
>>> +};
>> The original patchset was point-to-multipoint in a single netdev, and
>> had some starts on optimized multicast support (which, admittedly, is a
>> bit of a fringe thing, but still.)
>>
> I had been thinking about this as a single netdevice as well...which
> can work with
> the bridge driver using per vlan dst_metadata infra (similar to vxlan
> single device and per vlan - vxlan mapping).
>
> Multiple netdevice with one per vlan-vpls-id will work as well... but
> starting with a single netdev
> will be better (helps with scaling).
That's why I added the vpls id, to have in the future many vpls tunnels with
a single device, so the vpls id let us keep tracking the device working like
the vni of vxlan. (vpls lwtunnels in the TODO list).
