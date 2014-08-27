From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 0/2] Get rid of ndo_xmit_flush
Date: Wed, 27 Aug 2014 12:31:15 -0700
Message-ID: <CA+mtBx-zqi0mzMynZrxfcfz7koLH+B4+kD6o9+DnS7N1ww16Sw@mail.gmail.com>
References: <20140825.163458.1117073971092495452.davem@davemloft.net>
	<CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Daniel Borkmann <dborkman@redhat.com>, brouer@redhat.com
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:55200 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935182AbaH0TbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 15:31:16 -0400
Received: by mail-ig0-f174.google.com with SMTP id c1so6774753igq.13
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 12:31:15 -0700 (PDT)
In-Reply-To: <CAHA+R7MJX3Du8ggOo2GqGA4rXvY30YOpCFqS4PBN2ZNE=kwKuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2014 at 11:28 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Mon, Aug 25, 2014 at 4:34 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Given Jesper's performance numbers, it's not the way to go.
>>
>> Instead, go with a signalling scheme via new boolean skb->xmit_more.
>>
>> This has several advantages:
>>
>> 1) Nearly trivial driver support, just protect the tail pointer
>>    update with the skb->xmit_more check.
>>
>> 2) No extra indirect calls in the non-deferral cases.
>>
>
> First of all, I missed your discussion at kernel summit.
>
> Second of all, I am not familiar with hardware NIC drivers.
>
> But for me, it looks like you are trying to pend some more packets
> in a TX queue until the driver decides to flush them all in one shot.
> So if that is true, doesn't this mean the latency of first packet pending
> in this queue will increase and network traffic will be more bursty for
> the receiver??
>
I suspect this won't be an big issue. The dequeue is still work
conserving and BQL limit already ensures that HW queue doesn't drain
completely when packets are pending in the qdisc-- I doubt this will
increase BQL limits, but that should be verified. We might see some
latency increase for a batch sent on an idle link (possible with
GSO)-- if this is a concern we could arrange flush on sending packets
on idle links.

> Also, even if this is a cool feature in hardware driver, doesn't it make
> sense to allow users to disable it with ethtool?
>
> It looks like this is still WIP, since no one really sets ->xmit_more to 1
> in the code.
>
> Thanks.
