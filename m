From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: speedup tcp_fixup_rcvbuf()
Date: Thu, 16 May 2013 10:42:35 -0700
Message-ID: <51951A8B.8080801@hp.com>
References: <1368681955.3301.11.camel@edumazet-glaptop> <1697330.SmXeaasf9r@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:24080 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3EPRmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 13:42:37 -0400
In-Reply-To: <1697330.SmXeaasf9r@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2013 12:06 AM, Christoph Paasch wrote:
> just out of curiosity, how do you run 200 concurrent netperfs?
> Is there an option as in iperf (-P) ?
> I did not find anything like this in the netperf-code.

There is nothing like that in the netperf2 code.  Concurrent netperfs is 
handled outside of netperf itself via scripting.  There is some 
discussion of some different mechanisms in netperf to use in conjunction 
with that external scripting to mitigate issues of skew error:

http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance

My favorite these days is to use the interim results emitted when 
netperf is ./configure'd with --enable-demo , and reasonably 
synchronized clocks on the different systems running netperf, and then 
post-process them.  A single-system example of that being done is in 
doc/examples/runemomniaggdemo.sh , the results of which can be 
post-processed with doc/examples/post_proc.py .

I have used the interim results plus post processing mechanism as far 
out as 512ish concurrent netperfs running on 512ish systems targeting 
512ish other systems.  Apart from my innate lack of patience :) I don't 
believe there is much there to limit that mechanism scaling further. 
Perhaps others have already gone father.

I this specific situation where Eric was running 200 netperf TCP_CRR 
tests over loopback, if the difference from removing the loop was 
sufficiently large (and I'm guessing so based on the perf top output) 
then I would expect the difference to appear in service demand even for 
a single stream of TCP_CRR tests.

something like:

netperf -t TCP_CRR -c -i 30,3

before and after the change.  Perhaps use the -I option to request a 
narrower confidence interval than the default 5%  and use a longish 
per-iteration runtime (-l option) to help ensure hitting the confidence 
intervals.

happy benchmarking,

rick jones
