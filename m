From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 12:09:57 +1100
Message-ID: <20081009010957.GB6342@verge.net.au>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33384 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752818AbYJIBJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 21:09:59 -0400
Content-Disposition: inline
In-Reply-To: <48EC8FDD.5030507@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 12:47:57PM +0200, Martin Devera wrote:
>>> The algorithm samples queue states at deterministic but unregular
>>> intervals to see whose classes wants service and whose can lend.
>>>
>>> If you hold a packet outside, relevant class thinks that it is
>>> not backlogged - and if sampled at this time then the algorithm
>>> decides to lend classe's time.
>>
>> Right, but on the other hand I can't see any correction of these
>> times/tokens, so it seems this can't give us "right" results
>> anyway? E.g. with 100% requeuing (each packet requeued once) HTB
>> should think it "gave" the rate 2x higher than seen on the other
>> side - or I miss something?
>
> Yes, it is another problem - double acounting packet when requeued...
> Well, you are right, the number are not too supportive to this
> explanation...
> It seems that the first class didn't get its basic "rate", which
> is should be guaranteed.
>
> Simon, can you try to these things (separately):
> a/ increase quantum to the first class (say 10x)

Hi Martin,

Do you mean increase r2q ? If so, here are some results

r2q=10000 (original setting)
10194: 383950984bits/s 383Mbits/s
10197: 285071834bits/s 285Mbits/s
10196: 287241757bits/s 287Mbits/s
-----------------------------------
total: 956264576bits/s 956Mbits/s

r2q=25000
HTB: quantum of class 10012 is small. Consider r2q change.
HTB: quantum of class 10013 is small. Consider r2q change.
10194: 375149600bits/s 375Mbits/s
10197: 289728064bits/s 289Mbits/s
10196: 291783370bits/s 291Mbits/s
-----------------------------------
total: 956661034bits/s 956Mbits/s

r2q=50000
HTB: quantum of class 10012 is small. Consider r2q change.
HTB: quantum of class 10013 is small. Consider r2q change.
10194: 367905789bits/s 367Mbits/s
10197: 292223005bits/s 292Mbits/s
10196: 296510256bits/s 296Mbits/s
-----------------------------------
total: 956639050bits/s 956Mbits/s

r2q=100000
HTB: quantum of class 10011 is small. Consider r2q change.
HTB: quantum of class 10012 is small. Consider r2q change.
HTB: quantum of class 10013 is small. Consider r2q change.
10194: 367925416bits/s 367Mbits/s
10197: 293556834bits/s 293Mbits/s
10196: 295315384bits/s 295Mbits/s
-----------------------------------
total: 956797634bits/s 956Mbits/s

> b/ set ceil=rate on all three classes

This seems pretty close to the expected/ideal result.

10194: 496575074bits/s 496Mbits/s
10197:  96969861bits/s  96Mbits/s
10196:  96973002bits/s  96Mbits/s
-----------------------------------
total: 690517938bits/s 690Mbits/s


Kernel is net-next-2.6 071d7ab6649eb34a873a53e71635186e9117101d
("ipvs: Remove stray file left over from ipvs move"),
which is after Jarek's "pkt_sched: Update qdisc requeue stats in
dev_requeue_skb()" patch.

>
> The idea is to a/ make sure there is no requeue-related change
> to the drr pointer which could boost reqeued class,
> b/ to see whether priorized class has problems to send or
> other classes are sending even when they should not.
>
>>> Thus, from qdisc point, it is not good to keep a packet for
>>> more time out of the qdisc.
>>
>> Sure, the question is how much it's useful against associated
>> code complications and additional cpu usage.
>
> honestly, I'm not familiar with the new code. Can you tell me
> in short what is gso_skb and where the skb goes now if not requeued ?
>
> thanks, Martin

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

