From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Thu, 06 Dec 2012 06:47:56 -0800
Message-ID: <1354805276.31222.803.camel@edumazet-glaptop>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
	 <1354699462.20888.207.camel@localhost>
	 <1354796760.20888.217.camel@localhost>
	 <20121206123248.GA24493@breakpoint.cc>
	 <1354802100.20888.242.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:36728 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423590Ab2LFOsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 09:48:00 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so2808642dak.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 06:47:59 -0800 (PST)
In-Reply-To: <1354802100.20888.242.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 14:55 +0100, Jesper Dangaard Brouer wrote:

> Perhaps.  But do note my bashing of the LRU list were wrong.  I planned
> to explain that in a separate mail, but basically I were causing a DoS
> attack with incomplete fragments on my self, because I had disabled
> Ethernet flow-control.  Which led me to some false assumptions on the
> LRU list behavior (sorry).
> 
> The LRU might be the correct solution after all.  If I enable Ethernet
> flow-control again, then I have a hard time "activating" the evictor
> code (with thresh 4M/3M) .  I'll need a separate DoS program, which can
> send incomplete fragments (in back-to-back bursts) to provoke the
> evictor and LRU.
> 
> My cheap DoS reproducer-hack is to disable Ethernet flow-control on only
> one interface (out of 3), to cause packet drops and the incomplete
> fragments. The current preliminary results is that the two other
> interfaces still gets packets through, we don't get the zero throughput
> situation.
>  Two interfaces and no DoS: 15342 Mbit/s
>  Three interfaces and DoS:   7355 Mbit/s
> 
> The reduction might look big, but you have to take into account, that
> "activating" the evictor code, is also causing scalability issues of its
> own (which could account for the performance drop it self).

I would try removing the LRU, but keeping the age information (jiffie of
last valid frag received on one inet_frag_queue)

The eviction would be a function of the current memory used for the
frags (percpu_counter for good SMP scalability), divided by the max
allowed size, and ipfrag_time.

Under load, we would evict inet_frag_queue before the ipfrag_time timer,
without necessarily having to scan whole frags, only the ones we find in
the bucket we need to parse anyway (and lock)

The whole idea of a full garbage collect under softirq is not scalable,
as it locks a CPU in a non preemptible section for too long.
