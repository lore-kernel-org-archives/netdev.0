From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Mon, 07 Apr 2008 15:44:35 +0200
Message-ID: <47FA2543.1080609@trash.net>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net> <47EED247.50801@andyfurniss.entadsl.com> <47F22CF5.4080806@trash.net> <47F28758.1010401@andyfurniss.entadsl.com> <47F37139.9080303@andyfurniss.entadsl.com> <47F37E04.4010001@trash.net> <47F3B3C5.6000701@andyfurniss.entadsl.com> <47F6062E.9050804@andyfurniss.entadsl.com> <47F606D8.108@trash.net> <47F65EDE.3010507@andyfurniss.entadsl.com> <47F6794D.7070302@andyfurniss.entadsl.com> <47FA2509.8060303@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Corey Hickey <bugfood-ml@fatooh.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35598 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbYDGNoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2008 09:44:39 -0400
In-Reply-To: <47FA2509.8060303@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Furniss wrote:
> Andy Furniss wrote:
>> Andy Furniss wrote:
>>
>>> Looking at the sfq code it seems that enqueue doesn't init/zero allot 
>>> for a new flow unless it's the first and most of what I see fits with 
>>> this. 
>>
>>> But rarely it doesn't look like that's all there is to it.
>>
>> Actually it fits perfectly, so that is all there is to it. Dequeue 
>> dequeues first then checks allot so even if the allot is stuck at 
>> -20345 or something the flow will still get 1 packet per round which 
>> is what I've seen. I first thought it should have moved towards 0 like 
>> it does when it starts too high.
> 
> Seems like this change fixes it for me, though I since noticed that 
> requeue will need the same change as well.
> 
> --- sch_sfq.c.orig      2008-04-07 11:42:36.000000000 +0100
> +++ sch_sfq.c   2008-04-07 11:46:41.000000000 +0100
> @@ -317,6 +317,7 @@
>                         q->next[x] = q->next[q->tail];
>                         q->next[q->tail] = x;
>                         q->tail = x;
> +                       q->allot[x] = 0;


That might fix the symptom, but I don't think its correct.
As I said, you can't simply reset to zero since it might cause
unfairness of bursty flows against non-bursty flows.
