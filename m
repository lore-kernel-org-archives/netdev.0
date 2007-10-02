From: lm@bitmover.com (Larry McVoy)
Subject: Re: tcp bw in 2.6
Date: Mon, 1 Oct 2007 17:59:18 -0700
Message-ID: <20071002005917.GB5480@bitmover.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com> <alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org> <20070929172639.GB7037@bitmover.com> <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.bitmover.com ([192.132.92.15]:42223 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751719AbXJBBaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 21:30:01 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 29, 2007 at 11:02:32AM -0700, Linus Torvalds wrote:
> On Sat, 29 Sep 2007, Larry McVoy wrote:
> > I haven't kept up on switch technology but in the past they were much
> > better than you are thinking.  The Kalpana switch that I had modified
> > to support vlans (invented by yours truly), did not store and forward,
> > it was cut through and could handle any load that was theoretically
> > possible within about 1%.
> 
> Hey, you may well be right. Maybe my assumptions about cutting corners are 
> just cynical and pessimistic. 

So I got a netgear switch and it works fine.  But my tests are busted.  
Catching netdev up, I'm trying to optimize traffic to a server that has
a gbit interface; I moved to a 24 port netgear that is all 10/100/1000
and I have a pile of clients to act as load generators.

I can do this on each of the clients 

	dd if=/dev/zero bs=1024000 | rsh work "dd of=/dev/null"

and that cranks up to about 47K packets/second which is about 70MB/sec.

One of my clients also has gigabit so I played around with just that
one and it (itanium running hpux w/ broadcom gigabit) can push the load
as well.  One weird thing is that it is dependent on the direction the
data is flowing.  If the hp is sending then I get 46MB/sec, if linux is
sending then I get 18MB/sec.  Weird.  Linux is debian, running 

    Linux work 2.6.18-5-k7 #1 SMP Thu Aug 30 02:52:31 UTC 2007 i686 

and dual e1000 cards:

    e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
    e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection

I wrote a tiny little program to try and emulate this and I can't get
it to do as well.  I've tracked it down, I think, to the read side.
The server sources, the client sinks, the server looks like:

11689 accept(3, {sa_family=AF_INET, sin_port=htons(49376), sin_addr=inet_addr("10.3.1.38")}, [16]) = 4
11689 setsockopt(4, SOL_SOCKET, SO_RCVBUF, [1048576], 4) = 0
11689 setsockopt(4, SOL_SOCKET, SO_SNDBUF, [1048576], 4) = 0
11689 clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7ddf708) = 11694
11689 close(4)                          = 0
11689 accept(3,  <unfinished ...>
11694 write(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1048576
11694 write(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1048576
11694 write(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1048576
11694 write(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1048576
...

but the client looks like

connect(3, {sa_family=AF_INET, sin_port=htons(31235), sin_addr=inet_addr("10.3.9.1")}, 16) = 0
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1448
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 1448
read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 1048576) = 2896

which I suspect may be the problem.

I played around with SO_RCVBUF/SO_SNDBUF and that didn't help.  So any ideas why
a simple dd piped through rsh is kicking my ass?  It must be something simple
but my test program is tiny and does nothing weird that I can see.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
