From: Ingo Molnar <mingo@elte.hu>
Subject: [TCP bug] stuck distcc connections in latest -git
Date: Tue, 22 Jul 2008 13:21:33 +0200
Message-ID: <20080722112133.GA6575@elte.hu>
References: <20080720.104411.81744468.davem@davemloft.net> <20080721133059.GA30637@elte.hu> <20080721134506.GA27598@elte.hu> <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754660AbYGVLWK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080721184616.GA8442@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Ingo Molnar <mingo@elte.hu> wrote:

> ok, have updated the testboxes to your latest push.
> 
> Btw., otherwise the big networking pull held up pretty well on a 
> healthy range of testboxes i have, [...]

hm, the distcc TCP hangs are back:

Distcc client box (quad, 10.0.1.16) running v2.6.24:

 dione:~> netstat -nt | grep -vw TIME_WAIT | grep 3632
 tcp        0 250455 10.0.1.16:55559             10.0.1.19:3632              ESTABLISHED
 tcp        0 254743 10.0.1.16:56096             10.0.1.19:3632              ESTABLISHED
 tcp        0 219617 10.0.1.16:55674             10.0.1.19:3632              ESTABLISHED

              [ ^--- note the stuck send-queue ]

Distcc server box (16-way, 10.0.1.19) running very-latest:

 phoenix:~> netstat -nt | grep 10.0.1.16 | grep 3632 

 tcp        0      0 10.0.1.19:3632              10.0.1.16:55559             ESTABLISHED 
 tcp        0      0 10.0.1.19:3632              10.0.1.16:56096             ESTABLISHED 
 tcp        0      0 10.0.1.19:3632              10.0.1.16:55674             ESTABLISHED 

 tcp        0      0 10.0.1.19:3632              10.0.1.16:34411             ESTABLISHED 
 tcp        0      0 10.0.1.19:3632              10.0.1.16:51094             ESTABLISHED 
 tcp        0      0 10.0.1.19:3632              10.0.1.16:60787             ESTABLISHED 
 tcp        0      0 10.0.1.19:3632              10.0.1.16:50874             ESTABLISHED 

I.e. the client side send-queue is stuck in established state, server 
side thinks it's a proper established connection. Nobody makes any 
progress.

Also note the final 4 connections on the server side - those are not 
present on the client box.

The hung condition seemed permanent (i waited a couple of minutes).

Then i shut down the distccd on the server side, which propagated to the 
client:

 distcc[18496] (dcc_pump_sendfile) ERROR: sendfile failed: Broken pipe
 distcc[18496] (dcc_readx) ERROR: unexpected eof on fd4
 distcc[18496] (dcc_r_token_int) ERROR: read failed while waiting for token "DONE"
 distcc[18496] Warning: failed to distribute kernel/futex.c to ph/20, running locally instead

Server side lingered in FIN_WAIT2 a bit:

Proto Recv-Q Send-Q Local Address               Foreign Address             State
tcp        0      0 10.0.1.19:3632              10.0.1.16:56096             FIN_WAIT2
tcp        0      0 10.0.1.19:3632              10.0.1.16:55559             FIN_WAIT2

I retried the same build 10 times and it would not reproduce - so this 
again is a hard to reproduce condition. (and there's no chance to get a 
proper tcpdump either, at these traffic levels)

	Ingo
