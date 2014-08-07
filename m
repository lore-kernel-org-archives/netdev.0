From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 6 Aug 2014 23:43:11 -0400
Message-ID: <CA+FuTSf27abEh0SjY80zX3DxMDL_h2Q_iL6gU2gaJypZXHDhOw@mail.gmail.com>
References: <CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com>
 <20140806.143213.1466007351572839621.davem@davemloft.net> <CA+FuTSdevrKsHCwfX4wwhz-1SxWONsO=bOnD0bjP=yaG+pU5kQ@mail.gmail.com>
 <20140806.190310.2063368448518362055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:51636 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756792AbaHGDnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 23:43:43 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so3409951qap.23
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 20:43:42 -0700 (PDT)
In-Reply-To: <20140806.190310.2063368448518362055.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 10:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Willem de Bruijn <willemb@google.com>
> Date: Wed, 6 Aug 2014 20:59:30 -0400
>
>>>>> but also that we're going to send multiple reports back to error
>>>>> queue.
>>>>
>>>> I see. The optimization patch to queue timestamps without payload will
>>>> mitigate that somewhat. I dropped that from the initial patchset, but
>>>> will fix it up for net-next. It may also be possible to squash
>>>> multiple timestamped packets on the errqueue together when they all
>>>> have the same payload, resulting in a single (possibly no-payload)
>>>> packet with repeating cmsgs IP_RECVERR and SCM_TIMESTAMPING. That
>>>> would give O(1) overhead regardless of number of retransmits.
>>>
>>> We could attach a singly linked list of small sequence number cookies
>>> to the SKB when it gets queued up.
>>
>> To avoid queuing a clone of the skb for each timestamp with
>> sock_queue_err_skb, only queue the first occurrence. Record
>> subsequent (tstype, tstamp) tuples to the queued skb with
>> matching tskey, and at ip_recv_error convert each into a cmsg?
>
> The retransmit queue only contains the original transmit SKB(s).
>
> So the only modification in tcp_clean_rtx_queue() is to walk the
> list of timestamp sequence number cookies.

I think I may have misunderstood the design. When are cookies
added to this list and what exactly do they record? Attach a
cookie to the SKB on each invocation of skb_tstamp_tx, instead
of cloning the SKB every time and queuing each clone onto
the errqueue. Build this list of cookies and flush them at once on
the final ACK timestamp? If so, then cookies record a timestamp
and -type, but all refer to the same skb_shinfo(skb)->tskey.

> Actually I see what might be an existing problem... for example, the
> leading data which is already ACK'd is trimmed from the front of the
> SKB in the TSO code path of tcp_clean_rtx_queue().  And this data is
> tossed before the __skb_tstamp_tx() invocation.
>
> Hmmm...

The break after tcp_tso_acked, when bytes have been trimmed off the
head. Yes, indeed. Maybe I can move the timestamp code before that, at
the top of the loop.. I'll take a closer look to verify.
