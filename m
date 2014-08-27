From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 13:53:55 -0700 (PDT)
Message-ID: <20140827.135355.312468204295431099.davem@davemloft.net>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
	<CA+mtBx-zqi0mzMynZrxfcfz7koLH+B4+kD6o9+DnS7N1ww16Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	hannes@stressinduktion.org, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbaH0Ux4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 16:53:56 -0400
In-Reply-To: <CA+mtBx-zqi0mzMynZrxfcfz7koLH+B4+kD6o9+DnS7N1ww16Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 27 Aug 2014 12:31:15 -0700

> On Wed, Aug 27, 2014 at 11:28 AM, Cong Wang <cwang@twopensource.com> wrote:
>> On Mon, Aug 25, 2014 at 4:34 PM, David Miller <davem@davemloft.net> wrote:
>>>
>>> Given Jesper's performance numbers, it's not the way to go.
>>>
>>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>>>
>>> This has several advantages:
>>>
>>> 1) Nearly trivial driver support, just protect the tail pointer
>>>    update with the skb->xmit_more check.
>>>
>>> 2) No extra indirect calls in the non-deferral cases.
>>>
>>
>> First of all, I missed your discussion at kernel summit.
>>
>> Second of all, I am not familiar with hardware NIC drivers.
>>
>> But for me, it looks like you are trying to pend some more packets
>> in a TX queue until the driver decides to flush them all in one shot.
>> So if that is true, doesn't this mean the latency of first packet pending
>> in this queue will increase and network traffic will be more bursty for
>> the receiver??
>>
> I suspect this won't be an big issue. The dequeue is still work
> conserving and BQL limit already ensures that HW queue doesn't drain
> completely when packets are pending in the qdisc-- I doubt this will
> increase BQL limits, but that should be verified. We might see some
> latency increase for a batch sent on an idle link (possible with
> GSO)-- if this is a concern we could arrange flush on sending packets
> on idle links.

That's also correct.

The issue to handle specially is the initial send on a TX queue which
is empty or close to being empty.

Probably we want some kind of exponential backoff type scheme, so
assuming we have an empty TX queue we'd trigger TX on the first
packet, then the third, then the 7th.  Assuming we had that many to
send at once.
