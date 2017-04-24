From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: add option to get information about
 timestamped packets
Date: Mon, 24 Apr 2017 11:18:13 -0400
Message-ID: <CAF=yD-+ErPH6Qb4y9TcAMi-7X+ebxW3epq3Zxch_vrt1r3gspQ@mail.gmail.com>
References: <20170412141737.5881-1-mlichvar@redhat.com> <20170412141737.5881-4-mlichvar@redhat.com>
 <CAF=yD-Lsbr7f7aPUsFF3gCtFdyR8yb1=VBPJGQuxv_JbrJud6Q@mail.gmail.com>
 <20170413151806.GA26613@localhost> <CAF=yD-+tJpY7XJrqxga=0_kn-FjS0M=yuu59m_ZRRrrcpJCbZw@mail.gmail.com>
 <20170424090043.GF8847@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33760 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1173272AbdDXPSz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 11:18:55 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so10497789qkh.0
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 08:18:54 -0700 (PDT)
In-Reply-To: <20170424090043.GF8847@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 24, 2017 at 5:00 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
> On Thu, Apr 13, 2017 at 12:16:09PM -0400, Willem de Bruijn wrote:
>> On Thu, Apr 13, 2017 at 11:18 AM, Miroslav Lichvar <mlichvar@redhat.com> wrote:
>> > On Thu, Apr 13, 2017 at 10:37:07AM -0400, Willem de Bruijn wrote:
>> >> Why is this L2 length needed?
>> >
>> > It's needed for incoming packets to allow converting of preamble
>> > timestamps to trailer timestamps.
>>
>> Receiving the mac length of a packet sounds like a feature independent
>> from timestamping.
>
> I agree, but so far nobody suggested another use for this information.
> Do you have any suggestions?
>
> The idea was that if it is useful only with HW timestamping, it would
> be better to save it only with the timestamp, so there is no
> performance impact in the more common case when HW timestamping is
> disabled. Am I overly cautious here?

The additional cost of a cmsg is zero for sockets that have no cmsg
enabled, due to

        if (inet->cmsg_flags)
                ip_cmsg_recv_offset(msg, sk, skb, sizeof(struct udphdr), off);

But you might be right that there are no uses outside the specific
timestamp requirement you have, so if you prefer to use a timestamp
option, I won't object further.

>> Either an ioctl similar to SIOCGIFMTU or, if it may
>> vary due to existince of vlan headers, a new independent cmsg at the
>> SOL_SOCKET layer.

The latter would require adding the SOL_SOCKET level cmsg processing
infra. It is simpler to just add it at the INET/INET6 levels.

> It's not just the VLAN headers. The length of the IP header may vary
> with IP options, so the offset of the UDP data in the packet cannot be
> assumed to be constant.

As well as tunnels.

> Now I'm wondering if it's actually necessary to save the original
> value of skb->mac_len + skb->len.

Computing it on recv if needed is definitely preferable to computing
on enqueue and storing in an intermediate variable.

> Would "skb->data - skb->head -
> skb->mac_header + skb->len" always work as the L2 length for received
> packets at the time when the cmsg is prepared?

(skb->data - skb->head) - skb->mac_header computes the length
of data before the mac, such as reserve? Do you mean skb->data -
skb->mac_header (or - skb_mac_offset(skb))?

> As for the original ifindex, it seems to me it does need to be saved
> to a new field since __netif_receive_skb_core() intentionally
> overwrites skb->skb_iif. What would be the best place for it, sk_buff
> or skb_shared_info?

Finding storage space on the receive path will not be easy.

One shortcut to avoid storing this information explicitly is to look up
the device from skb->napi_id.

> And would it really be acceptable to save it for all packets in
> __netif_receive_skb_core(), even when HW timestamping is disabled?
> Seeing how the code and the data structures were optimized over time,
> I have a feeling it would not be accepted.

Incurring this cost on all packets for such a rare edge case does sound
like a non-starter.

It can be called only if the netstamp_needed static key is enabled (false),
in __net_timestamp, though.
