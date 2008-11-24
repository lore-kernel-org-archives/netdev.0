From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 14:17:32 +0100
Message-ID: <492AA96C.6000807@trash.net>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081124105345.GB13957@ff.dom.local> <492A9ACB.4050504@trash.net> <20081124123349.GA16755@ff.dom.local> <492AA058.9060302@trash.net> <20081124125150.GB16755@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63158 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbYKXNRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:17:43 -0500
In-Reply-To: <20081124125150.GB16755@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Nov 24, 2008 at 01:38:48PM +0100, Patrick McHardy wrote:
> ...
>> TBF with an inner DRR is fine. The other way around is broken
>> in the sense that the behaviour is undefined.
> 
> IMHO, this other way (e.g. a class with TBF per user), should work too.

The behaviour undefined, so what does "work too" mean in this context?

The main question is: what should be done with the class when it
throttles?

You suggest moving it to the end of the active list. Should its deficit
be recharged in that case? Possible no because it didn't send packets -
but then again it might have handed out *some* packets (less than the
deficit) before it started throttling. Both ways would introduce
unfairness.

What could be done without harming the algorithm is to treat throttled
classes as inactive until they become unthrottled again, meaning they
would be added to the end of the active list with a full deficit. But
we have no indication for specific classes, unthrottling simply triggers
another dequeue of the root, so the implementation would get quite
complicated, leaving alone the fact that each TBF would potentially
start its own watchdog, causing excessive wakeups.

And I don't see much use for this, what is the advantage over using
HTB or HFSC?

> BTW, since this "broken" config isn't very apparent, maybe you should
> add some warning?

Yes, but I don't want to add this to the ->dequeue() path. It belongs
in the ->init() path and we currently don't have enough information
in there.
