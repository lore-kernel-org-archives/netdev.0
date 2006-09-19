From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 17:37:27 -0700
Message-ID: <450F3BC7.4020603@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060904160045.GA15599@ms2.inr.ac.ru> <44FDBA04.3080104@hp.com>	<20060918.003938.26278728.davem@davemloft.net>	<450ED337.8000700@hp.com> <20060918204105.GA31333@ms2.inr.ac.ru>	<450F0EA5.2020109@hp.com> <20060918225123.GA22150@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alex@sectorb.msk.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:19387 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751979AbWISAha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 20:37:30 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060918225123.GA22150@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>Regardless, kudos for running the test.  The only thing missing is the 
>>-c and -C options to enable the CPU utilization measurements which will 
>>then give the service demand on a CPU time per transaction basis.  Or 
>>was this a UP system that was taken to CPU saturation?
> 
> 
> It is my notebook. :-) Of course, cpu consumption is 100%.
> (Actally, netperf shows 100.10 :-))

Gotta love the accuracy. :)

> 
> I will redo test on a real network. What range of -b should I test?
> 

I suppose that depends on your patience :) In theory, as you increase 
(eg double) the -b setting you should reach a point of diminishing 
returns wrt transaction rate.  If you see that, and see the service 
demand flattening-out I'd say it is probably time to stop.

I'm also not quite sure if "abc" needs to be disabled or not.

I do know that I left-out one very important netperf option.  The 
command line should be:

netperf -t TCP_RR -H foo -- -b N -D

where "-D" is added to set TCP_NODELAY.  Otherwise, the ratio of 
transactions to data segments is fubar.  That issue is also why I wonder 
about the setting of tcp_abc.

[I have this quixotic pipedream about being able to --enable-burst, set 
-D and say that the number of TCP segments exchanged on the network is 
2X the transaction count when request and response size are < MSS.  The 
raison d'etre for this pipe dream is maximizing PPS with TCP_RR tests 
without _having_ to have hundreds if not thousands of simultaneous 
netperfs/connections - say with just as many netperfs/connections as 
there are CPUs or threads/strands in the system. It was while trying to 
make this pipe dream a reality I first noticed that HP-UX 11i, which 
normally has a very nice ACK avoidance heuristic, would send an 
immediate ACK if it received back-to-back sub-MSS segments - thus 
ruining my pipe dream when it came to HP-UX testing.  Hapily, I noticed 
that "linux" didn't seem to be doing the same thing. Hence my tweaking 
when seeing this patch come along...]

>>What i'm thinking about isn't so much about the latency
> 
> 
> I understand.
> 
> Actually, I did those tests ages ago for a pure throughput case,
> when nothing goes in the opposite direction. I did not find a difference
> that time. And nobody even noticed that Linux sends ACKs _each_ small
> segment for unidirectional connections for all those years. :-)

Not everyone looks very closely (alas, sometimes myself included).

If all anyone does is look at throughput, until they CPU saturate they 
wouldn't notice.  Heck, before netperf and TCP_RR tests, and sadly even 
still today, most people just look at how fast a single-connection, 
unidirectional data transfer goes and leave it at that :(

Thankfully, the set of "most people" and "netdev" aren't completely 
overlapping.

rick jones
