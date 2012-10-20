From: Vimal <j.vimal@gmail.com>
Subject: Re: [PATCH] htb: improved accuracy at high rates
Date: Fri, 19 Oct 2012 17:51:24 -0700
Message-ID: <CAK3Ji116nZ79csrq9GJ7C5e3zLPJina1r2+VasdVRsdY7n+3ww@mail.gmail.com>
References: <1350685582-65334-1-git-send-email-j.vimal@gmail.com> <5081E7A8.2080009@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:45105 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755233Ab2JTAvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 20:51:45 -0400
Received: by mail-vc0-f174.google.com with SMTP id fk26so1135104vcb.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 17:51:44 -0700 (PDT)
In-Reply-To: <5081E7A8.2080009@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 October 2012 16:52, Rick Jones <rick.jones2@hp.com> wrote:
>
> First some netperf/operational kinds of questions:
>
> Did it really take 20 concurrent netperf UDP_STREAM tests to get to those
> rates?  And why UDP_STREAM rather than TCP_STREAM?

Nope, even 1 netperf was sufficient.  Before I couldn't get TCP_STREAM
to send small byte packets, but I checked my script now and I forgot
to enable TCP_NODELAY + send buffer size (-s $size).

With one tcp sender I am unable to reach the 1Gb/s limit (only
~100Mb/s) even with a lot of CPU to spare, which indicates that the
test is limited by e2e latency.  With 10 connections, I could get only
800Mb/s, and with 20 connections it went to 1160Mb/s, which violates
the 1Gb/s limit set.

> I couldn't recall if GSO did anything for UDP, so did some quick and dirty
> tests flipping GSO on and off on a 3.2.0 kernel, and the service demands
> didn't seem to change.  So, with 8000 bytes of user payload did HTB actually
> see 8000ish byte packets, or did it actually see a series of <= MTU sized IP
> datagram fragments?  Or did the NIC being used have UFO enabled?
>

UFO was enabled.  Now, I verified that the throughput was about the
same even with TCP, with TSO and by forcing send/recv buffer sizes to
8kB.

> Which reported throughput was used from the UDP_STREAM tests - send side or
> receive side?

Send side.

>
> Is there much/any change in service demand on a netperf test?  That is what
> is the service demand of a mumble_STREAM test running through the old HTB
> versus the new HTB?  And/or the performance of a TCP_RR test (both
> transactions per second and service demand per transaction) before vs after.
>

At 1Gb/s with just one TCP_STREAM:
With old HTB:
Sdem local: 0.548us/KB, Sdem remote: 1.426us/KB.

With new HTB:
Sdem local: 0.598us/KB, Sdem remote: 1.089us/KB.

TCP_RR: 1b req/response consumed very little bandwidth (~12Mb/s)
old HTB at 1Gb/s
Sdem local: 14.738us/trans, Sdem remote: 11.485us/Tran, latency: 41.622us/Tran.

new HTB at 1Gb/s
Sdem local: 14.505us/trans, Sdem remote: 11.440us/Tran, latency: 41.709us/Tran.

With multiple tests, these values are fairly stable. :)

thanks,
> happy benchmarking,
>
> rick jones

-- 
Vimal
