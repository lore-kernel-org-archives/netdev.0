From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 2/3] net/act_pedit: Support using offset relative
 to the conventional network headers
Date: Sun, 4 Dec 2016 23:55:43 +0200
Message-ID: <CAJ3xEMg0KjNSKeDwEEiA6SP+TyOYma_co6UBCb1=OPhpRF1HsA@mail.gmail.com>
References: <20161130090928.14816-1-amir@vadai.me> <20161130090928.14816-3-amir@vadai.me>
 <20161201.144114.648583754166260714.davem@davemloft.net> <20161202104029.GA7729@office.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@resnulli.us>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:36708 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcLDVzp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 16:55:45 -0500
Received: by mail-oi0-f65.google.com with SMTP id u15so34192750oie.3
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 13:55:45 -0800 (PST)
In-Reply-To: <20161202104029.GA7729@office.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 2, 2016 at 12:40 PM, Amir Vadai <amir@vadai.me> wrote:
> On Thu, Dec 01, 2016 at 02:41:14PM -0500, David Miller wrote:
>> From: Amir Vadai <amir@vadai.me>
>> Date: Wed, 30 Nov 2016 11:09:27 +0200

>> > +static int pedit_skb_hdr_offset(struct sk_buff *skb,
>> > +                           enum pedit_header_type htype, int *hoffset)
>> > +{
>> > +   int ret = -1;
>> > +
>> > +   switch (htype) {
>> > +   case PEDIT_HDR_TYPE_ETH:
>> > +           if (skb_mac_header_was_set(skb)) {
>> > +                   *hoffset = skb_mac_offset(skb);
>> > +                   ret = 0;
>> > +           }
>> > +           break;
>> > +   case PEDIT_HDR_TYPE_RAW:
>> > +   case PEDIT_HDR_TYPE_IP4:
>> > +   case PEDIT_HDR_TYPE_IP6:
>> > +           *hoffset = skb_network_offset(skb);
>> > +           ret = 0;
>> > +           break;
>> > +   case PEDIT_HDR_TYPE_TCP:
>> > +   case PEDIT_HDR_TYPE_UDP:
>> > +           if (skb_transport_header_was_set(skb)) {
>> > +                   *hoffset = skb_transport_offset(skb);
>> > +                   ret = 0;
>> > +           }
>> > +           break;
>> > +   };
>> > +
>> > +   return ret;
>> > +}
>> > +

>> The only distinction between the cases is "L2", "L3", and "L4".

>> Therefore I don't see any reason to break it down into IP4 vs. IP6 vs.
>> RAW, for example.  They all map to the same thing.

>> So why not just have PEDIT_HDR_TYPE_L2, PEDIT_HDR_TYPE_L3, and
>> PEDIT_HDR_TYPE_L4?  It definitely seems more straightforward
>> and cleaner that way.

> Yeh, is isn't by mistake. The next step will be to implement hardware
> offloading of the action, and for that we would like to keep the
> information about the specific header type.

Hi Dave,

I see that this patch is marked as "Changes Requested" @ your patchworks.

Just wanted to make a note as Amir explained here and as mentioned on
the change log, this was done in purpose, as heads up for HW offloads.
Typically HW APIs would let you do things also based on header type
they have parsed, etc, so that's why we added this small redundancy
e.g of IPv4/IPv6 header ID instead of network header ID - while SW
wise both IPv4/IPv6 are using the same code path, for HW offloads, the
HW driver could choose to use the IPv4/IPv6 header ID info.

Or.
