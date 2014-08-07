From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 06 Aug 2014 19:03:10 -0700 (PDT)
Message-ID: <20140806.190310.2063368448518362055.davem@davemloft.net>
References: <CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com>
	<20140806.143213.1466007351572839621.davem@davemloft.net>
	<CA+FuTSdevrKsHCwfX4wwhz-1SxWONsO=bOnD0bjP=yaG+pU5kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	richardcochran@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45787 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120AbaHGCDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 22:03:13 -0400
In-Reply-To: <CA+FuTSdevrKsHCwfX4wwhz-1SxWONsO=bOnD0bjP=yaG+pU5kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 6 Aug 2014 20:59:30 -0400

>>>> but also that we're going to send multiple reports back to error
>>>> queue.
>>>
>>> I see. The optimization patch to queue timestamps without payload will
>>> mitigate that somewhat. I dropped that from the initial patchset, but
>>> will fix it up for net-next. It may also be possible to squash
>>> multiple timestamped packets on the errqueue together when they all
>>> have the same payload, resulting in a single (possibly no-payload)
>>> packet with repeating cmsgs IP_RECVERR and SCM_TIMESTAMPING. That
>>> would give O(1) overhead regardless of number of retransmits.
>>
>> We could attach a singly linked list of small sequence number cookies
>> to the SKB when it gets queued up.
> 
> To avoid queuing a clone of the skb for each timestamp with
> sock_queue_err_skb, only queue the first occurrence. Record
> subsequent (tstype, tstamp) tuples to the queued skb with
> matching tskey, and at ip_recv_error convert each into a cmsg?

The retransmit queue only contains the original transmit SKB(s).

So the only modification in tcp_clean_rtx_queue() is to walk the
list of timestamp sequence number cookies.

Actually I see what might be an existing problem... for example, the
leading data which is already ACK'd is trimmed from the front of the
SKB in the TSO code path of tcp_clean_rtx_queue().  And this data is
tossed before the __skb_tstamp_tx() invocation.

Hmmm...
