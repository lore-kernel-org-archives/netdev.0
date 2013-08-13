From: Timo Teras <timo.teras@iki.fi>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 15:41:02 +0300
Message-ID: <20130813154102.35739102@vostro>
References: <20130812160142.71737a95@vostro>
	<CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
	<20130813092312.2493354e@vostro>
	<20130813074614.GM25511@secunet.com>
	<20130813105757.39fb0ab8@vostro>
	<20130813104548.GB26773@secunet.com>
	<20130813143325.364b4bab@vostro>
	<20130813115652.GE26773@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:34864 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756770Ab3HMMlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 08:41:07 -0400
Received: by mail-ee0-f46.google.com with SMTP id c13so4137372eek.5
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 05:41:05 -0700 (PDT)
In-Reply-To: <20130813115652.GE26773@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Aug 2013 13:56:52 +0200
Steffen Klassert <steffen.klassert@secunet.com> wrote:

> On Tue, Aug 13, 2013 at 02:33:25PM +0300, Timo Teras wrote:
> > 
> > I've been now playing with pcrypt. It seems to not give significant
> > boost in throughput. I've setup the cpumaps properly, and top says
> > the work is distributed to appropriate kworkers, but for some reason
> > throughput does not get any better. I've tested with iperf in both
> > udp and tcp modes, with various amounts of threads.
> > 
> > Is there any more synchronization points for single SA that might
> > limit throughput? I've been testing with auth hmac(sha1), enc
> > cbc(aes) - according to metric the CPUs are still largely idle
> > instead of processing more data for better throughput. aes-gcm
> > (without pcrypt) achieves better throughput even saturating my test
> > box links.
> > 
> > Any pointers what to test, or to pinpoint the bottleneck?
> > 
> 
> The only pitfall that comes to my mind is that pcrypt must be
> instantiated before inserting the states. Your /proc/crypto
> should show something like:
> 
> name         : authenc(hmac(sha1),cbc(aes))
> driver       : pcrypt(authenc(hmac(sha1-generic),cbc(aes-asm)))
> module       : pcrypt
> priority     : 2100
> refcnt       : 1
> selftest     : passed
> type         : aead
> async        : yes
> blocksize    : 16
> ivsize       : 16
> maxauthsize  : 20
> geniv        : <built-in>
> 
> pcrypt is now instantiated, e.g. all new IPsec states (that do
> hmac-sha1, cbc-aes) will use it, adding new states increase the
> refcount.
> 
> I'll do some tests with current net-next on my own tomorrow and let
> you know about the results.

Yes, I've got pcrypt there. Apparently I had some of the cpu bindings
not right, so now it's looking a lot better. But it seems that
ksoftirqd on one of the CPUs becomes first bottleneck. I'll try to
figure out why.

Thanks on all the info so far, will continue experimenting here too.
