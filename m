From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Fri, 05 Oct 2012 22:06:18 +0200
Message-ID: <1349467578.21172.178.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>  <506F23F6.1060704@hp.com>
	 <1349463634.21172.152.camel@edumazet-glaptop>  <506F368F.3070403@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61242 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754021Ab2JEUGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 16:06:24 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1133040bkc.19
        for <netdev@vger.kernel.org>; Fri, 05 Oct 2012 13:06:22 -0700 (PDT)
In-Reply-To: <506F368F.3070403@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-05 at 12:35 -0700, Rick Jones wrote:

> Just how much code path is there between NAPI and the socket?? (And I 
> guess just how much combining are you hoping for?)
> 

When GRO correctly works, you can save about 30% of cpu cycles, it
depends...

Doubling MAX_SKB_FRAGS (allowing 32+1 MSS per GRO skb instead of 16+1)
gives an improvement as well...

> > Lets say we allow no more than 1ms of delay in GRO,
> 
> OK.  That means we can ignore HPC and FSI because they wouldn't tolerate 
> that kind of added delay anyway.  I'm not sure if that also then 
> eliminates the networked storage types.
> 

I took this 1ms delay, but I never said it was a fixed value ;)

Also remember one thing, this is the _max_ delay in case your napi
handler is flooded. This almost never happen (tm)


> > this means we could have about 400 packets in the GRO queue (assuming
> > 1500 bytes packets)
> 
> How many flows are you going to have entering via that queue?  And just 
> how well "shuffled" will the segments of those flows be?  That is what 
> it all comes down to right?  How many (active) flows and how well 
> shuffled they are.  If the flows aren't well shuffled, you can get away 
> with a smallish coalescing context.  If they are perfectly shuffled and 
> greater in number than your delay allowance you get right back to square 
> with all the overhead of GRO attempts with none of the benefit.

Not sure what you mean by shuffle. We use a hash table to locate a flow,
but we also have a LRU list to get the packets ordered by their entry in
the 'GRO unit'.

If napi completes, all the LRU list content is flushed to IP stack.
( napi_gro_flush()) 

If napi doesnt complete, we would only flush 'too old' packets found in
the LRU.

Note: this selective flush can be called once per napi run from
net_rx_action(). Extra cost to get a somewhat precise timestamp
would be acceptable (one call to ktime_get() or get_cycles() every 64
packets)

This timestamp could be stored in napi->timestamp and done once per
n->poll(n, weight) call.

> 
> If the flow count is < 400 to allow a decent shot at a non-zero 
> combining rate on well shuffled flows with the 400 packet limit, then 
> that means each flow is >= 12.5 Mbit/s on average at 5 Gbit/s 
> aggregated.  And I think you then get two segments per flow aggregated 
> at a time.  Is that consistent with what you expect to be the 
> characteristics of the flows entering via that queue?

If a packet cant stay more than 1ms, then a flow sending less than 1000
packets per second wont benefit from GRO.

So yes, 12.5 Mbit/s would be the threshold.

By the way, when TCP timestamps are used, and hosts are linux machines
with HZ=1000, current GRO can not coalesce packets anyway because their
TCP options are different.

(So it would be not useful trying bigger sojourn time than 1ms)
