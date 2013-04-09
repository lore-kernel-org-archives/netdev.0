From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 17:33:56 -0700
Message-ID: <1365467636.3887.67.camel@edumazet-glaptop>
References: <3505145.vfXt1x4t0P@sifl>
	 <20130408.171512.973275376690340387.davem@davemloft.net>
	 <2921619.mqaHl5PnPI@sifl>
	 <20130408.173325.1683493727549657170.davem@davemloft.net>
	 <51635573.7030706@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pmoore@redhat.com,
	netdev@vger.kernel.org, mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34592 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761641Ab3DIAd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 20:33:59 -0400
In-Reply-To: <51635573.7030706@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 16:40 -0700, Casey Schaufler wrote:

> OK, let's do the math.
> 
> First off, it's 4 bytes, not 8. It replaces the secmark.
> Your increased memory usage is going to be
> 
> 	4 bytes/packet *  M packets/second * N seconds
> 
> Where M is the rate at which you're processing packets and
> N is the length of time it takes to process a packet.
> 
> Let's pretend we have an embedded system that does nothing but send
> 128 byte packets on a 10Gb port. That's 10M packets/second. If it
> takes a full second to process a packet the overhead is 40MB for that
> second. I have it on good authority that packets can be processed
> in considerably less time than that. The real number is more like
> 0.05 seconds. That means your actual overhead is more like 1MB.
> 
> These are dumbed down calculations. I am not a memory usage expert.
> I am convinced that "real" calculations are going to get similar
> numbers. I am, of course, willing to be swayed by evidence that I
> am wrong.
> 
> Compare that to the overhead associated with using CIPSO on packets
> that never leave the box.

Maths are not that simple, and its not about size of sk_buff, since the
number of in-flight skb should be quite small.

Its the time to init this memory for _every_ packet.

sizeof(sk_buff) is 0xf8, very close to cross the 256 bytes limit.

Add a single _byte_ and it becomes a matter of adding a _cache_ line,
and thats 25 % cost, assuming 64bytes cache lines.

So instead of processing 10M packets per second, we would process 9M
packets per second, or maybe less.

Yes, 256 bytes per sk_buff, this is the current insane situation.
(Not counting the struct skb_shared_info, adding at least one additional
cache line)
