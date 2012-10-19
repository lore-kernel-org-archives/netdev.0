From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Fri, 19 Oct 2012 16:52:08 -0700
Message-ID: <5081E7A8.2080009@hp.com>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Vimalkumar <j.vimal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:43560 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755193Ab2JSXwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 19:52:11 -0400
In-Reply-To: <1350685582-65334-1-git-send-email-j.vimal@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/19/2012 03:26 PM, Vimalkumar wrote:
> Current HTB (and TBF) uses rate table computed by
> the "tc" userspace program, which has the following
> issue:
>
> The rate table has 256 entries to map packet lengths
> to token (time units).  With TSO sized packets, the
> 256 entry granularity leads to loss/gain of rate,
> making the token bucket inaccurate.
>
> Thus, instead of relying on rate table, this patch
> explicitly computes the time and accounts for packet
> transmission times with nanosec granularity.
>
> This greatly improves accuracy of HTB with a wide
> range of packet sizes.
>
> Example:
>
> tc qdisc add dev $dev root handle 1: \
> 	htb default 1
>
> tc class add dev $dev classid 1:1 parent 1: \
> 	rate 1Gbit mtu 64k
>
> Ideally it should work with all intermediate sized
> packets as well, but...
>
> Test:
> for i in {1..20}; do
> 	(netperf -H $host -t UDP_STREAM -l 30 -- -m $size &);
> done
>
> With size=400 bytes: achieved rate ~600Mb/s
> With size=1000 bytes: achieved rate ~835Mb/s
> With size=8000 bytes: achieved rate ~1012Mb/s
>
> With new HTB, in all cases, we achieve ~1000Mb/s.

First some netperf/operational kinds of questions:

Did it really take 20 concurrent netperf UDP_STREAM tests to get to 
those rates?  And why UDP_STREAM rather than TCP_STREAM?

I couldn't recall if GSO did anything for UDP, so did some quick and 
dirty tests flipping GSO on and off on a 3.2.0 kernel, and the service 
demands didn't seem to change.  So, with 8000 bytes of user payload did 
HTB actually see 8000ish byte packets, or did it actually see a series 
of <= MTU sized IP datagram fragments?  Or did the NIC being used have 
UFO enabled?

Which reported throughput was used from the UDP_STREAM tests - send side 
or receive side?

Is there much/any change in service demand on a netperf test?  That is 
what is the service demand of a mumble_STREAM test running through the 
old HTB versus the new HTB?  And/or the performance of a TCP_RR test 
(both transactions per second and service demand per transaction) before 
vs after.

happy benchmarking,

rick jones
