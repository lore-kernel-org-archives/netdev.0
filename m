From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 20 Aug 2013 09:39:12 +0300
Message-ID: <20130820093912.3dbb4377@vostro>
References: <20130812160142.71737a95@vostro>
	<CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
	<20130813092312.2493354e@vostro>
	<20130813074614.GM25511@secunet.com>
	<20130813105757.39fb0ab8@vostro>
	<20130813104548.GB26773@secunet.com>
	<20130813143325.364b4bab@vostro>
	<20130813115652.GE26773@secunet.com>
	<20130813154102.35739102@vostro>
	<20130820061914.GA26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36533 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab3HTGjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 02:39:21 -0400
Received: by mail-ee0-f46.google.com with SMTP id c13so9980eek.19
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 23:39:20 -0700 (PDT)
In-Reply-To: <20130820061914.GA26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Aug 2013 08:19:14 +0200
Steffen Klassert <steffen.klassert@secunet.com> wrote:

> On Tue, Aug 13, 2013 at 03:41:02PM +0300, Timo Teras wrote:
> > On Tue, 13 Aug 2013 13:56:52 +0200
> > Steffen Klassert <steffen.klassert@secunet.com> wrote:
> > 
> > > 
> > > I'll do some tests with current net-next on my own tomorrow and
> > > let you know about the results.
> > 
> > Yes, I've got pcrypt there. Apparently I had some of the cpu
> > bindings not right, so now it's looking a lot better. But it seems
> > that ksoftirqd on one of the CPUs becomes first bottleneck. I'll
> > try to figure out why.
> > 
> > Thanks on all the info so far, will continue experimenting here too.
> 
> Here are the promised test results:
> 
> I used my test boxes with two nodes (Intel Xeon X5550  @ 2.67GHz) and
> all cores utilized (16 logical cores). I did iperf box to box IPsec
> tunnel tests with the crypto algorithm:
> 
> pcrypt(authenc(hmac(sha1-ssse3),cbc(aes-asm)))
> 
> Throughput is at 1.70 Gbits/sec.
> 
> Same test without pcrypt, i.e. crypto algorithm:
> 
> authenc(hmac(sha1-ssse3),cbc(aes-asm))
> 
> Throughput is at 560 Mbits/sec.
> 
> Unfortunately I can't do forwarding tests, I have only two 10 Gbit
> NICs. Would be nice if I could get forwarding test results from
> somewhere.

I got basically the same results. (Managed to get 2.5 Gbit/s after some
cpumask experimenting.)

At this point it seems that one core cpu peaks at 100% softirq. It
seems to be the nic rx softirq. I am curious why it takes so much cpu,
because plain tcp at 10Gbit/s does not take much cpu at all. So even
though pcrypt is used, it seems it adds considerable overhead in
softirq rx path still. I wonder if it's the pcrypt do parallel
overhead or some generic ipsec/gre overhead; perhaps some locking thing.
I should profile it.

Thanks.
