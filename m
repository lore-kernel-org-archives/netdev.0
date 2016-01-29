From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 13:00:44 -0800
Message-ID: <CALx6S34+od6o69rHQzotJFXf7kziEuQUj=xH5VUWw+YpH4FjNg@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	<1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	mwdalton@google.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36006 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756793AbcA2VAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:00:45 -0500
Received: by mail-io0-f169.google.com with SMTP id g73so103159416ioe.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:00:45 -0800 (PST)
In-Reply-To: <1454093642.7627.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 29, 2016 at 10:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-29 at 10:33 -0800, Eric Dumazet wrote:
>> On Fri, 2016-01-29 at 13:06 -0500, Sowmini Varadhan wrote:
>> > There is an unaligned access at __skb_flow_dissect when it calls
>> > ip6_flowlabel() with the call stack
>> >
>> >   __skb_flow_dissect+0x2a8/0x87c
>> >   eth_get_headlen+0x5c/0xaxa4
>> >   ixgbe_clean_rx_irq+0x5cc/0xb20 [ixgbe]
>> >   ixgbe_poll+0x5a4/0x760 [ixgbe]
>> >   net_rx_action+0x13c/0x354
>> >     :
>> >
>> > Essentially, ixgbe_pull_tail() is trying to figure out how much
>> > to pull, in order to have an aligned buffer:
>> >
>> >         pull_len = eth_get_headlen(va, IXGBE_RX_HDR_SIZE);
>> >
>> >         /* align pull length to size of long to optimize memcpy performance */
>> >         skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>> >
>> > and seems like the unaligned access is unavoidable here (see comments
>> > in __skb_get_poff, for example).
>> >
>> > This (below) is what I came up with, to get rid of the unaligned access
>> > errors on sparc, Is there a better solution? (Not having access
>> > to struct ip6_hdr in this file made put_unaligned usage non-obvious)
>> >
>> >
>> > --- a/net/core/flow_dissector.c
>> > +++ b/net/core/flow_dissector.c
>> > @@ -102,6 +102,17 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int
>> >  }
>> >  EXPORT_SYMBOL(__skb_flow_get_ports);
>> >
>> > +static inline __be32 ip6_flowlabel_align(const u8 *hdr)
>> > +{
>> > +       union {
>> > +               __u8 w[4];
>> > +               __u32 flow;
>> > +       } ip6_flow;
>> > +
>> > +       memcpy(ip6_flow.w, hdr, 4);
>> > +       return (ip6_flow.flow & IPV6_FLOWLABEL_MASK);
>> > +}
>> > +
>> >  /**
>> >   * __skb_flow_dissect - extract the flow_keys struct and return it
>> >   * @skb: sk_buff to extract the flow from, can be NULL if the rest are specifie
>> > @@ -230,7 +241,7 @@ ipv6:
>> >                         key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
>> >                 }
>> >
>> > -               flow_label = ip6_flowlabel(iph);
>> > +               flow_label = ip6_flowlabel_align((const u8 *)iph);
>> >                 if (flow_label) {
>> >                         if (dissector_uses_key(flow_dissector,
>> >                                                FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
>> >
>> >
>>
>> Why ipv6 stack itself does not trigger the issue ?
>>
>> Maybe the driver itself does not properly align IP headers on sparc ?
>>
>> Make sure NET_IP_ALIGN is 2 on your build.
>>
>> Note that x86 does not care, but a driver should always align Ethernet
>> header to NET_IP_ALIGN, so that IP headers are aligned to 4 bytes
>> boundaries.
>
> Hmmm.... it seems that flow dissector can "support L2 GRE", leading to
> unaligned accesses since a header is 14 bytes (not multiple of 4)
>
> commit e1733de2243609073534cf56afb146a62af3c3d8
> Author: Michael Dalton <mwdalton@google.com>
> Date:   Mon Mar 11 06:52:28 2013 +0000
>
>     flow_dissector: support L2 GRE
>
>     Add support for L2 GRE tunnels, so that RPS can be more effective.
>
>
> Michael, do we still need this ?
>
> IP stacks in linux assume IP headers are always aligned to 4 bytes,
> so it means having a GRE header like this would align trap on some
> arches.
>
Doesn't every IP/VXLAN packet contains unaligned headers? Why don't
those create alignment issues (like when stack looks at addresses)?

>
>
>
>
>
>
>
>
