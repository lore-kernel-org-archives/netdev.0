From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH V2 RFC 2/2] ixgbe: ixgbe_atr() compute
 l4_proto only if non-paged data has network/transport headers
Date: Mon, 17 Oct 2016 12:49:51 -0700
Message-ID: <CAKgT0UcGy_fD6HYxfzO_xoWOcB+Cjf38Qon8ZdWxyTNtzP7-=Q@mail.gmail.com>
References: <cover.1476724638.git.sowmini.varadhan@oracle.com>
 <ff985fc71358a90f7a97ca176abb96845852269e.1476724638.git.sowmini.varadhan@oracle.com>
 <CAKgT0Uee88Vh8aHDDzMBZojGjkEz_Po5AKq+6yJ2tVambzH8zw@mail.gmail.com> <20161017191804.GE15976@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33897 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757682AbcJQTtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:49:52 -0400
Received: by mail-it0-f65.google.com with SMTP id e203so4174928itc.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 12:49:52 -0700 (PDT)
In-Reply-To: <20161017191804.GE15976@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 17, 2016 at 12:18 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (10/17/16 11:15), Alexander Duyck wrote:
>> I would say you probably only need the first check here for skb->data
>> and could probably skip the second part.  You will be testing for
>> skb_tail_pointer in all the other tests you added so this check is
>> redundant anyway.
>>
>> Also you might want to go through and wrap these with unlikely() since
>> most of these are exception cases.
>
> Ok.. v3 will have this.
>
>> >         /* Currently only IPv4/IPv6 with TCP is supported */
>> >         switch (hdr.ipv4->version) {
>> >         case IPVERSION:
>> >                 /* access ihl as u8 to avoid unaligned access on ia64 */
>> >                 hlen = (hdr.network[0] & 0x0F) << 2;
>> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
>> > +                                           sizeof(struct tcphdr))
>> > +                       return;
>> >                 l4_proto = hdr.ipv4->protocol;
>> >                 break;
>> >         case 6:
>> >                 hlen = hdr.network - skb->data;
>> > +               if (skb_tail_pointer(skb) < hdr.network + hlen +
>> > +                                           sizeof(struct tcphdr))
>> > +                       return;
>> >                 l4_proto = ipv6_find_hdr(skb, &hlen, IPPROTO_TCP, NULL, NULL);
>> >                 hlen -= hdr.network - skb->data;
>> >                 break;
>>
>> I believe one more check is needed after this block to verify the TCP
>> header fields are present.
>>
>> So you probably need to add a check for "skb_tail_pointer(skb) <
>> (hdr.network + hlen + 20)".
>
> But isnt that the same thing as the checks before l4_proto computation above?

Sort of.  The problem is IPv6 can include extension headers and that
can totally mess with us.  So we need to do one more check to verify
that we have enough space for IPv6 w/ TCP which would be hdr.raw + 20
+ hlenl.

Thanks.

- Alex
