From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipsec smp scalability and cpu use fairness (softirqs)
Date: Tue, 13 Aug 2013 13:56:52 +0200
Message-ID: <20130813115652.GE26773@secunet.com>
References: <20130812160142.71737a95@vostro>
 <CAKTPYJTVhvF=215eS0xriEdUyyCLaC+zzja4zPrG668ALzERyw@mail.gmail.com>
 <20130813092312.2493354e@vostro>
 <20130813074614.GM25511@secunet.com>
 <20130813105757.39fb0ab8@vostro>
 <20130813104548.GB26773@secunet.com>
 <20130813143325.364b4bab@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Collins <bsderandrew@gmail.com>, netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49971 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757368Ab3HML4y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Aug 2013 07:56:54 -0400
Content-Disposition: inline
In-Reply-To: <20130813143325.364b4bab@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 13, 2013 at 02:33:25PM +0300, Timo Teras wrote:
> 
> I've been now playing with pcrypt. It seems to not give significant
> boost in throughput. I've setup the cpumaps properly, and top says the
> work is distributed to appropriate kworkers, but for some reason
> throughput does not get any better. I've tested with iperf in both udp
> and tcp modes, with various amounts of threads.
> 
> Is there any more synchronization points for single SA that might limit
> throughput? I've been testing with auth hmac(sha1), enc cbc(aes) -
> according to metric the CPUs are still largely idle instead of
> processing more data for better throughput. aes-gcm (without pcrypt)
> achieves better throughput even saturating my test box links.
> 
> Any pointers what to test, or to pinpoint the bottleneck?
> 

The only pitfall that comes to my mind is that pcrypt must be
instantiated before inserting the states. Your /proc/crypto
should show something like:

name         : authenc(hmac(sha1),cbc(aes))
driver       : pcrypt(authenc(hmac(sha1-generic),cbc(aes-asm)))
module       : pcrypt
priority     : 2100
refcnt       : 1
selftest     : passed
type         : aead
async        : yes
blocksize    : 16
ivsize       : 16
maxauthsize  : 20
geniv        : <built-in>

pcrypt is now instantiated, e.g. all new IPsec states (that do
hmac-sha1, cbc-aes) will use it, adding new states increase the
refcount.

I'll do some tests with current net-next on my own tomorrow and let
you know about the results.
