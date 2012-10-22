From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Mon, 22 Oct 2012 10:35:35 -0700
Message-ID: <508583E7.1090309@hp.com>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com> <5081E7A8.2080009@hp.com> <CAK3Ji116nZ79csrq9GJ7C5e3zLPJina1r2+VasdVRsdY7n+3ww@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Vimal <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:31809 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755015Ab2JVRfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 13:35:39 -0400
In-Reply-To: <CAK3Ji116nZ79csrq9GJ7C5e3zLPJina1r2+VasdVRsdY7n+3ww@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2012 05:51 PM, Vimal wrote:
> On 19 October 2012 16:52, Rick Jones <rick.jones2@hp.com> wrote:
>>
>> First some netperf/operational kinds of questions:
>>
>> Did it really take 20 concurrent netperf UDP_STREAM tests to get to those
>> rates?  And why UDP_STREAM rather than TCP_STREAM?
>
> Nope, even 1 netperf was sufficient.  Before I couldn't get TCP_STREAM
> to send small byte packets, but I checked my script now and I forgot
> to enable TCP_NODELAY + send buffer size (-s $size).
>
> With one tcp sender I am unable to reach the 1Gb/s limit (only
> ~100Mb/s) even with a lot of CPU to spare, which indicates that the
> test is limited by e2e latency.  With 10 connections, I could get only
> 800Mb/s, and with 20 connections it went to 1160Mb/s, which violates
> the 1Gb/s limit set.

Were you explicitly constraining the TCP socketbuffer/window via 
test-specific -s and -S options?  Or was this a system with little 
enough memory that the upper limit for the TCP socket/window autotuning 
wasn't the somewhat common, which would have been sufficient to cover a 
rather large RTT,  The results of the TCP_RR tests below suggest there 
was actually very little e2e latency... which suggests something else 
was holding-back the TCP performance.  Perhaps lost packets?

Or does this suggest the need for an htb_codel?-)  If your system can 
have rrdtool installed on it, and you are indeed using a contemporary 
version of netperf, you can run the bloat.sh script from doc/examples 
and get an idea of how much bufferbloat there is in the setup.

If you are using a "current" version of netperf, you can use the omni 
output selectors to have netperf emit the number of TCP retransmissions 
on the data connection during the test.  Otherwise, if the netperf tests 
are the only things running at the time, you can take a snapshot of 
netstat -s output before and after the test and run it through something 
like beforeafter, or the other script I keep forgetting the name of :(

>> Which reported throughput was used from the UDP_STREAM tests - send side or
>> receive side?
>
> Send side.

Given the nature of UDP and that netperf makes no attempt to compensate 
for that, it would be rather better to use receive-side throughout.  The 
receive side throughput is known to have made it through everything. 
The send side throughput is only that which didn't report an error in 
the sendto() call.  And lack of error on the sendto() call does not 
guarantee a successful transmission on the wire.  Even under Linux with 
intra-stack flow-control.

>> Is there much/any change in service demand on a netperf test?  That is what
>> is the service demand of a mumble_STREAM test running through the old HTB
>> versus the new HTB?  And/or the performance of a TCP_RR test (both
>> transactions per second and service demand per transaction) before vs after.
>>
>
> At 1Gb/s with just one TCP_STREAM:
> With old HTB:
> Sdem local: 0.548us/KB, Sdem remote: 1.426us/KB.
>
> With new HTB:
> Sdem local: 0.598us/KB, Sdem remote: 1.089us/KB.

Presumably the receive side service demand should have remained 
unaffected by the HTB changes.  That it changed by 40% suggests there 
wasn't actually all that much stability - at least not on the receive 
side.  Was there a large change in throughput for the single-stream?

That there was a 9% increase in sending service demand is a bit 
troubling, and at least slightly at odds with the little to no change in 
the sending service demand for the TCP_RR tests below.  I suppose that 
the "timing" nature of having things like small sends and TCP_NODELAY 
set can introduce too many variables.

One other way to skin the cat of "what does it do to sending service 
demand would be to stick with TCP_RR and walk-up the request size. 
Without a burst mode enabled, and just the one transaction in flight at 
one time, TCP_NODELAY on/off should be a don't care.  So, something 
along the lines of:

HDR="-P 1"
for r in 1 4 16 64 256 1024 4096 16384 65535
do
netperf $HDR -H <remote> -t TCP_RR -c -C -l 30 -- -r ${r},1
HDR="-P 0"
done

> TCP_RR: 1b req/response consumed very little bandwidth (~12Mb/s)

That is why, by default, it reports a transaction per second rate and 
not a bandwidth :)

> old HTB at 1Gb/s
> Sdem local: 14.738us/trans, Sdem remote: 11.485us/Tran, latency: 41.622us/Tran.
>
> new HTB at 1Gb/s
> Sdem local: 14.505us/trans, Sdem remote: 11.440us/Tran, latency: 41.709us/Tran.
>
> With multiple tests, these values are fairly stable. :)

Those do look like they were within the noise level.

Out of mostly idle curiousity, just what sort of system was being used 
for the testing?  CPU, bitness, memory etc.

happy benchmarking,

rick jones
