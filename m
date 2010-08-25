From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close
 connection
Date: Wed, 25 Aug 2010 15:34:24 -0700 (PDT)
Message-ID: <20100825.153424.246521475.davem@davemloft.net>
References: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: kosaki.motohiro@jp.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 25 Aug 2010 11:05:48 +0900 (JST)

> This issue come from ruby language community. Below test program
> hang up when only run on Linux.
> 
> 	% uname -mrsv
> 	Linux 2.6.26-2-486 #1 Sat Dec 26 08:37:39 UTC 2009 i686
> 	% ruby -rsocket -ve '
> 	BasicSocket.do_not_reverse_lookup = true
> 	serv = TCPServer.open("127.0.0.1", 0)
> 	s1 = TCPSocket.open("127.0.0.1", serv.addr[1])
> 	s2 = serv.accept
> 	s2.close
> 	s1.write("a") rescue p $!
> 	s1.write("a") rescue p $!
> 	Thread.new {
> 	  s1.write("a")
> 	}.join'
> 	ruby 1.9.3dev (2010-07-06 trunk 28554) [i686-linux]
> 	#<Errno::EPIPE: Broken pipe>
> 	[Hang Here]
> 
> FreeBSD, Solaris, Mac doesn't. because Ruby's write() method call
> select() internally. and tcp_poll has a bug.

In your opinion.

> SUS defined 'ready for writing' of select() as following.
> 
> |  A descriptor shall be considered ready for writing when a call to an output
> |  function with O_NONBLOCK clear would not block, whether or not the function
> |  would transfer data successfully.
> 
> That said, EPIPE situation is clearly one of 'ready for writing'.

How Linux should behave is defined by many things, and often it is
simply defined by how we've behaved for a very long time.  This is
because changing behavior can often break as many applications as it
can fix.  Standards don't necessarily tell us how we must behave,
since often is it impractical to follow their definions.

And in this case here, I call into question the behavior of Ruby and
the application from two perspectives:

1) Unlike all of the other conditions signalled by poll() this is
   one the application explicitly created and therefore knows about.

   If the application calls close() or shutdown() with the send flag
   set, IT KNOWS what is going to happen on a write() attempt.

2) Ruby and this script will have to deal with the past 13 years
   worth of Linux kernels.  Even if I were to apply this fix now
   it is not going to propagate onto a user's system any time soon.

   Many systems would never ever get this fix.

   Therefore it behooves Ruby and this script to make a very reasonable
   change, which is to track when close() or send shutdown() calls occur
   and behave appropriately on a write() call.

I'm therefore not applying this patch, because not only can applications
handle this properly with information they already have, the change has
the potential to break applications.
