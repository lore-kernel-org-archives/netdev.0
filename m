From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 6 Aug 2014 20:59:30 -0400
Message-ID: <CA+FuTSdevrKsHCwfX4wwhz-1SxWONsO=bOnD0bjP=yaG+pU5kQ@mail.gmail.com>
References: <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com>
 <1407335823.11943.10.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com> <20140806.143213.1466007351572839621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Network Development <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:60500 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbaHGBAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 21:00:01 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so3667389qge.18
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 18:00:00 -0700 (PDT)
In-Reply-To: <20140806.143213.1466007351572839621.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> but also that we're going to send multiple reports back to error
>>> queue.
>>
>> I see. The optimization patch to queue timestamps without payload will
>> mitigate that somewhat. I dropped that from the initial patchset, but
>> will fix it up for net-next. It may also be possible to squash
>> multiple timestamped packets on the errqueue together when they all
>> have the same payload, resulting in a single (possibly no-payload)
>> packet with repeating cmsgs IP_RECVERR and SCM_TIMESTAMPING. That
>> would give O(1) overhead regardless of number of retransmits.
>
> We could attach a singly linked list of small sequence number cookies
> to the SKB when it gets queued up.

To avoid queuing a clone of the skb for each timestamp with
sock_queue_err_skb, only queue the first occurrence. Record
subsequent (tstype, tstamp) tuples to the queued skb with
matching tskey, and at ip_recv_error convert each into a cmsg?

> Upon an ACK, we need only look at the entries at the front of the list
> until we see one past the cumulative ACK.
>
> There's a little bit of work to do when SKBs are coalesced or chopped
> up, but in return the timestamp indications the user gets will be very
> accurate.
