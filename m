From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [net-next PATCH V3-evictor] net: frag evictor, avoid killing warm frag queues
Date: Thu, 6 Dec 2012 13:29:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70E2@saturn3.aculab.com>
References: <1354319937.20109.285.camel@edumazet-glaptop> <20121204133007.20215.52566.stgit@dragon> <1354699462.20888.207.camel@localhost> <1354796760.20888.217.camel@localhost> <20121206123248.GA24493@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Thomas Graf" <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"Cong Wang" <amwang@redhat.com>,
	"Herbert Xu" <herbert@gondor.hengli.com.au>
To: "Florian Westphal" <fw@strlen.de>,
	"Jesper Dangaard Brouer" <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:44034 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755022Ab2LFNae convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 08:30:34 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30451-07 for <netdev@vger.kernel.org>;
 Thu,  6 Dec 2012 13:30:28 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20121206123248.GA24493@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Jesper Dangaard Brouer <jbrouer@redhat.com> wrote:
> > CPUs are fighting for the same LRU head (inet_frag_queue) element,
> > which is bad for scalability.  We could fix this by unlinking the
> > element once a CPU graps it, but it would require us to change a
> > read_lock to a write_lock, thus we might not gain much performance.
> >
> > I already (implicit) fix this is a later patch, where I'm moving the
> > LRU lists to be per CPU.  So, I don't know if it's worth fixing.
> 
> Do you think its worth trying to remove the lru list altogether and
> just evict from the hash in a round-robin fashion instead?

Round-robin will be the same as LRU under overload - so have the
same issues.
Random might be better - especially if IP datagrams for which
more than one in-sequence packet have been received are moved
to a second structure.
But you still need something to control the total memory use.

NFS/UDP is about the only thing that generates very large
IP datagrams - and no one in their right mind runs that
over non-local links.

For SMP you might hash to a small array of pointers (to fragments)
each having its own lock. Only evict items with the same hash.
Put the id in the array and you probably won't need to look at
the actual fragment (saving a cache miss) unless it is the one
you want.

	David
