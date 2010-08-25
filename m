From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] tcp: select(writefds) don't hang up when a peer close connection
Date: Wed, 25 Aug 2010 11:05:48 +0900 (JST)
Message-ID: <20100825110049.F3C9.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:42640 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087Ab0HYCFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 22:05:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This issue come from ruby language community. Below test program
hang up when only run on Linux.

	% uname -mrsv
	Linux 2.6.26-2-486 #1 Sat Dec 26 08:37:39 UTC 2009 i686
	% ruby -rsocket -ve '
	BasicSocket.do_not_reverse_lookup = true
	serv = TCPServer.open("127.0.0.1", 0)
	s1 = TCPSocket.open("127.0.0.1", serv.addr[1])
	s2 = serv.accept
	s2.close
	s1.write("a") rescue p $!
	s1.write("a") rescue p $!
	Thread.new {
	  s1.write("a")
	}.join'
	ruby 1.9.3dev (2010-07-06 trunk 28554) [i686-linux]
	#<Errno::EPIPE: Broken pipe>
	[Hang Here]

FreeBSD, Solaris, Mac doesn't. because Ruby's write() method call
select() internally. and tcp_poll has a bug.

SUS defined 'ready for writing' of select() as following.

|  A descriptor shall be considered ready for writing when a call to an output
|  function with O_NONBLOCK clear would not block, whether or not the function
|  would transfer data successfully.

That said, EPIPE situation is clearly one of 'ready for writing'.

We don't have read-side issue because tcp_poll() already has read side
shutdown care.

|        if (sk->sk_shutdown & RCV_SHUTDOWN)
|                mask |= POLLIN | POLLRDNORM | POLLRDHUP;

So, Let's insert same logic in write side.

- reference url
  http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/31065
  http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-core/31068

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 net/ipv4/tcp.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 176e11a..2497e48 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -451,7 +451,8 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 				if (sk_stream_wspace(sk) >= sk_stream_min_wspace(sk))
 					mask |= POLLOUT | POLLWRNORM;
 			}
-		}
+		} else
+			mask |= POLLOUT | POLLWRNORM;
 
 		if (tp->urg_data & TCP_URG_VALID)
 			mask |= POLLPRI;
-- 
1.6.5.2



