From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering	functionality
 to tfifo qdisc.
Date: Wed, 22 Oct 2008 19:32:02 +0200
Message-ID: <48FF6392.5000305@trash.net>
References: <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net> <20081017201210.GA2527@ami.dom.local> <20081021.163605.57275028.davem@davemloft.net> <20081021165129.422dd83f@extreme> <20081022053746.GA4178@ff.dom.local> <48FF4E38.9010806@trash.net> <20081022164925.GB2556@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58079 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757285AbYJVRcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 13:32:05 -0400
In-Reply-To: <20081022164925.GB2556@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Oct 22, 2008 at 06:00:56PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> If it's only this kind of usage we could export tfifo and let use this
>>> as a TBF's (etc.) leaf. Of course, this would require changes in those
>>> people scripts.
>> In that case we might as well teach them to use TBF as *parent*
>> of netem (and I'd vote to do that and kill requeue).
>>
>> But we can argue about this forever without any progress. The
>> question is simple - should we enforce a reasonable qdisc structure
>> and kill ->requeue or keep it around forever. Keep in mind that there
>> is no loss of functionality by using TBF as parent and that we
>> can do this gradually so users have a chance to fix their scripts,
>> should anyone really use TBF as inner qdisc.
>>
> 
> I'm not sure we think about the same: this tfifo idea doesn't need
> ->requeue() at all. This would go through TBF's or prio's (etc.)
> ->enqueue(), and only tfifo's ->enqueue(), if it's used as a leaf,
> checks the qdisc flag and can reorder.

I see. So both ways would work fine to get rid of requeue. The
flag doesn't seem to be necessary though since tfifo already
does reordering based on time_to_send.

> But if it's useless, no problem. I can redo this patch without this
> qdisc flag.

Well, you're doing the work, so you decide. I'm undecided myself,
the main issues I see are:

- we might have to reeducate users twice if we decide to enforce
   more structure later on

- a lot of other qdiscs still don't work as inner qdiscs of netem:

   - any reordering qdisc can cause stalls since netem_dequeue
     expects to get packets ordered by time_to_send. This means we
     can't use cbq, hfsc, htb, prio, sfq, leaving atm, dsmark, netem,
     red, gred, tbf and the fifos. I guess we can strike atm as
     "makes no sense" and dsmark as "obsolete since 10(?) years".

   - netem can't be used as inner qdisc since it would corrupt the
     skb's cb

So the usable inner qdiscs are: tbf, red, gred, *fifo. The fact
that over 50% of the qdiscs you could use can cause misbehaviour
and TBF, red and gred can be used as upper qdiscs without any loss
of functionality makes me think netem simply shouldn't be classful.

So actually I am decided :) I think netem shouldn't be classful.
