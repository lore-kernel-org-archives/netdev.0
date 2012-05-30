From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to
 mitigate SYN floods
Date: Wed, 30 May 2012 09:45:26 +0200
Message-ID: <1338363926.7747.55.camel@localhost>
References: <20120528115102.12068.79994.stgit@localhost.localdomain>
	 <20120528115226.12068.31850.stgit@localhost.localdomain>
	 <m2bol6lqxo.fsf@firstfloor.org> <1338360073.2760.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	opurdila@ixiacom.com,
	Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44346 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755961Ab2E3Hp6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2012 03:45:58 -0400
In-Reply-To: <1338360073.2760.81.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-05-30 at 08:41 +0200, Eric Dumazet wrote:
> On Tue, 2012-05-29 at 12:37 -0700, Andi Kleen wrote:
> 
> > So basically handling syncookie lockless? 
> > 
> > Makes sense. Syncookies is a bit obsolete these days of course, due
> > to the lack of options. But may be still useful for this.
> > 
> > Obviously you'll need to clean up the patch and support IPv6,
> > but the basic idea looks good to me.
> 
> Also TCP Fast Open should be a good way to make the SYN flood no more
> effective.

Sounds interesting, but TCP Fast Open is primarily concerned with
enabling data exchange during SYN establishment.  I don't see any
indication that they have implemented parallel SYN handling.

Implementing parallel SYN handling, should also benefit their work.
After studying this code path, I also see great performance benefit in
also optimizing the normal 3WHS on sock's in sk_state == LISTEN.
Perhaps we should split up the code path for LISTEN vs. ESTABLISHED, as
they are very entangled at the moment AFAIKS.

> Yuchung Cheng and Jerry Chu should upstream this code in a very near
> future.

Looking forward to see the code, and the fallout discussions, on
transferring data on SYN packets.


> Another way to mitigate SYN scalability issues before the full RCU
> solution I was cooking is to either :
> 
> 1) Use a hardware filter (like on Intel NICS) to force all SYN packets
> going to one queue (so that they are all serviced on one CPU)
> 
> 2) Tweak RPS (__skb_get_rxhash()) so that SYN packets rxhash is not
> dependent on src port/address, to get same effect (All SYN packets
> processed by one cpu). Note this only address the SYN flood problem, not
> the general 3WHS scalability one, since if real connection is
> established, the third packet (ACK from client) will have the 'real'
> rxhash and will be processed by another cpu.

I don't like the idea of overloading one CPU with SYN packets. As the
attacker can still cause a DoS on new connections.

My "unlocked" parallel SYN cookie approach, should favor established
connections, as they are allowed to run under a BH lock, and thus don't
let new SYN packets in (on this CPU), until the establish conn packet is
finished.  Unless I have misunderstood something... I think I have,
established connections have their own/seperate struck sock, and thus
this is another slock spinlock, right?. (Well let Eric bash me for
this ;-))

[...cut...]
