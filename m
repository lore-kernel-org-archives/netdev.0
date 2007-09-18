From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Tue, 18 Sep 2007 19:57:14 +0200
Message-ID: <46F0117A.4060807@trash.net>
References: <46F0087A.3080104@redhat.com> <46F00B80.7050901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761516AbXIRSDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 14:03:55 -0400
In-Reply-To: <46F00B80.7050901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Chuck Ebbert wrote:
> 
>>Limit of 1 is forbidden, crashes with 2, works with 3:
>>
>>>From disassembling sch_sfq.ko it seems that it is on line 360 of sch_sfq.c:
>>    sch->qstats.backlog -= skb->len;
>>where "skb" is an invalid pointer:
> 
> 
> 
> Is it a NULL pointer or something random?


Never mind, I found the reason. When enqueuing the packet, sfq_enqueue
contains an off-by-one in the limit check (which IIRC is there for a
reason, but I can't remember right now) and drops the packet again.
dev_queue_xmit() calls qdisc_run() anyway and the empty qdisc is
dequeued, which is not handled by SFQ.

I see three possibilities to fix this (in my preferred order):

1) figure out why the off-by-one is there, if not needed remove
2) don't dequeue qdiscs even once if empty
3) check for NULL in sfq_dequeue

So I'll try to remeber why the off-by-one is there ..
