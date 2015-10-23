From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 23 Oct 2015 07:13:47 -0700
Message-ID: <1445609627.22974.150.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com> <20151022044458.GP22011@ZenIV.linux.org.uk>
	 <20151022060304.GQ22011@ZenIV.linux.org.uk>
	 <201510220634.t9M6YJLD017883@room101.nl.oracle.com>
	 <20151022172146.GS22011@ZenIV.linux.org.uk>
	 <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <1445605340.22974.140.camel@edumazet-glaptop2.roam.corp.google.com>
	  <201510231320.t9NDKZv9017488@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
	Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33885 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbbJWONu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 10:13:50 -0400
Received: by padhk11 with SMTP id hk11so119822988pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 07:13:49 -0700 (PDT)
In-Reply-To: <201510231320.t9NDKZv9017488@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-23 at 15:20 +0200, Casper.Dik@oracle.com wrote:
> 
> >Yet another POSIX deficiency.
> >
> >When a server deals with 10,000,000+ socks, we absolutely do not care of
> >this requirement.
> >
> >O(log(n)) is still crazy if it involves O(log(n)) cache misses.
> 
> You miss the fire point of the algorithm; you *always* find an available 
> file descriptor in O(log(N)) (where N is the size of the table).
> 
> Does your algorithm guarantee that?

Its a simple bit map. Each cache line contains 64*8 = 512 bits. Lookup
is actually quite fast thanks to hardware prefetches. 

Main problem we had until recently was that we used to acquire fd table
lock 3 times per accept()/close() pair

This patch took care of the issue :

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8a81252b774b53e628a8a0fe18e2b8fc236d92cc

Then, adding a O_RANDOMFD flag (or O_DO_NOT_REQUIRE_POSIX_FD_RULES) is
helping a lot, as it allows us to pick a random starting point during
the bitmap search.

In practice, finding a slot in fd array is O(1) : one cache line miss
exactly.
