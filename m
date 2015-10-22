From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 22 Oct 2015 04:30:25 -0700
Message-ID: <1445513425.22974.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
	 <5627A37B.4090208@oracle.com> <20151021185104.GM22011@ZenIV.linux.org.uk>
	 <20151021.182955.1434243485706993231.davem@davemloft.net>
	 <5628636E.1020107@oracle.com>
	  <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alan Burlison <Alan.Burlison@oracle.com>,
	David Miller <davem@davemloft.net>, viro@ZenIV.linux.org.uk,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org
To: Casper.Dik@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33399 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbJVLa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 07:30:28 -0400
Received: by pabrc13 with SMTP id rc13so84756060pab.0
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 04:30:27 -0700 (PDT)
In-Reply-To: <201510220615.t9M6FL2d017592@room101.nl.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-10-22 at 08:15 +0200, Casper.Dik@oracle.com wrote:
> >It's been said that the current mechanisms in Linux & some BSD variants 
> >can be subject to races, and the behaviour exhibited doesn't conform to 
> >POSIX, for example requiring the use of shutdown() on unconnected 
> >sockets because close() doesn't kick off other threads accept()ing on 
> >the same fd. I'd be interested to hear if there's a better and more 
> >performant way of handling the situation that doesn't involve doing the 
> >sort of bookkeeping Casper described,.
> 
> Of course, the implementation is now around 18 years old; clearly a lot of 
> things have changed since then.
> 
> In the particular case of Linux close() on a socket, surely it must be 
> possible to detect at close that it is a listening socket and that you are 
> about to close the last reference; the kernel could then do the shutdown() 
> all by itself.

We absolutely do not _want_ to do this just so that linux becomes slower
to the point Solaris can compete, or you guys can avoid some work.

close(fd) is very far from knowing a file is a 'listener' or even a
'socket' without extra cache line misses.

To force a close of an accept() or whatever blocking socket related
system call a shutdown() makes a lot of sense.

This would have zero additional overhead for the fast path.
