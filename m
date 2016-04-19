From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 2/8] sfc: batch up RX delivery on EF10
Date: Tue, 19 Apr 2016 17:36:03 +0100
Message-ID: <57165E73.60402@solarflare.com>
References: <5716338E.4050003@solarflare.com>
 <57163404.2000507@solarflare.com>
 <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:27752 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932482AbcDSQgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 12:36:14 -0400
In-Reply-To: <1461077257.10638.185.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/16 15:47, Eric Dumazet wrote:
> On Tue, 2016-04-19 at 14:35 +0100, Edward Cree wrote:
>> Improves packet rate of 1-byte UDP receives by 10%.
> Sure, by adding yet another queue and extra latencies.
>
> If the switch delivered a high prio packet to your host right before a
> train of 60 low prio packets, this is not to allow us to wait the end of
> the train.
The length of the list is bounded by the NAPI budget, and the first packet
in the list is delayed only by the time it takes to read the RX descriptors
and turn them into SKBs.  This patch never causes us to wait in the hope
that more things will arrive to batch, that's entirely driven by interrupt
moderation.

And if the high prio packet comes at the _end_ of a train of low prio
packets, we get to it _faster_ this way because we get the train out of the
way quicker.

Are you suggesting we should check for 802.1p priorities, and have those
skip the list?

> We have to really invent something better, like a real pipeline, instead
> of hacks like this, adding complexity everywhere.
I'm not sure what you mean by 'a real pipeline' in this context, could you
elaborate?

> Have you tested this on cpus with tiny caches, like 32KB ?
I haven't.  Is the concern here that the first packet's headers (we read 128
bytes into the linear area) and/or skb will get pushed out of the dcache as
we process further packets?

At least for sfc, it's highly unlikely that these cards will be used in low-
powered systems.  For the more general case, I suppose the answer would be a
tunable to set the maximum length of the RX list to less than the NAPI budget.
Fundamentally this kind of batching is trading dcache usage for icache usage.


Incidentally, this patch is very similar to what Jesper proposed for mlx5 in
an RFC back in February: http://article.gmane.org/gmane.linux.network/397379
So I'm a little surprised this bit is controversial, though I'm not surprised
the rest of the series is ;)

-Ed
