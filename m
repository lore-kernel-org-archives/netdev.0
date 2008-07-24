From: Ingo Molnar <mingo@elte.hu>
Subject: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 08:04:48 +0200
Message-ID: <20080724060448.GA10203@elte.hu>
References: <20080721182318.GA20940@elte.hu> <alpine.LFD.1.10.0807211131390.31863@woody.linux-foundation.org> <20080721184616.GA8442@elte.hu> <20080722112133.GA6575@elte.hu> <4885E482.5020502@davidnewall.com> <20080722135723.GA23077@elte.hu> <4885F496.3010305@davidnewall.com> <20080722153443.GB18757@elte.hu> <20080722211256.GB29189@1wt.eu> <20080723082643.GA992@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Newall <davidn@davidnewall.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:60966 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbYGXGFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 02:05:35 -0400
Content-Disposition: inline
In-Reply-To: <20080723082643.GA992@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> Alas, the problem has not reoccured since then - more than a thousand 
> kernel builds down the line. [...]

the permanently hug distcc kernel build bug triggered again, twice. 
First time it happened yesterday, i left it running overnight and it 
never recovered after a 14+ hours of wait.

It shows a similar pattern, 'ESTABLISHED' state on both sides, but the 
client-side is stuck and the server (running latest kernel) is seemingly 
clueless about that fact:

 client:

  Proto Recv-Q Send-Q Local Address       Foreign Address     State
  tcp        0 375450 10.0.1.16:39201     10.0.1.19:3632      ESTABLISHED

 server:

  Proto Recv-Q Send-Q Local Address       Foreign Address     State
  tcp        0      0 10.0.1.19:3632      10.0.1.16:39201     ESTABLISHED

i waited ~30 minutes in this second case.

the client (running 2.6.24) does periodic 120 seconds retransmits:

07:40:48.255452 IP dione.39201 > phoenix.distcc: . 1608:2144(536) ack 1 win 584007:40:48.255547 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
07:40:48.255564 IP dione.39201 > phoenix.distcc: . 67143:67679(536) ack 1 win 5840
07:40:48.255648 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
07:42:48.255440 IP dione.39201 > phoenix.distcc: . 2144:2680(536) ack 1 win 5840
07:42:48.255559 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
07:42:48.255570 IP dione.39201 > phoenix.distcc: . 67679:68215(536) ack 1 win 5840
07:42:48.255659 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
07:44:48.255436 IP dione.39201 > phoenix.distcc: . 2680:3216(536) ack 1 win 584007:44:48.255570 IP phoenix.distcc > dione.39201: . ack 3216 win 65535
07:44:48.255585 IP dione.39201 > phoenix.distcc: . 68215:68751(536) ack 1 win 5840
07:44:48.255669 IP phoenix.distcc > dione.39201: . ack 3216 win 65535

the server (running the latest kernel) responds:

07:40:47.551098 IP dione.39201 > phoenix.distcc: . 1072:1608(536) ack 1 win 584007:40:47.551141 IP phoenix.distcc > dione.39201: . ack 1608 win 65535
07:40:47.551204 IP dione.39201 > phoenix.distcc: . 66607:67143(536) ack 1 win 5840
07:40:47.551213 IP phoenix.distcc > dione.39201: . ack 1608 win 65535
07:42:47.570994 IP dione.39201 > phoenix.distcc: . 1608:2144(536) ack 1 win 584007:42:47.571027 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
07:42:47.571117 IP dione.39201 > phoenix.distcc: . 67143:67679(536) ack 1 win 5840
07:42:47.571127 IP phoenix.distcc > dione.39201: . ack 2144 win 65535
07:44:47.590901 IP dione.39201 > phoenix.distcc: . 2144:2680(536) ack 1 win 584007:44:47.590960 IP phoenix.distcc > dione.39201: . ack 2680 win 65535
07:44:47.591042 IP dione.39201 > phoenix.distcc: . 67679:68215(536) ack 1 win 5840
07:44:47.591054 IP phoenix.distcc > dione.39201: . ack 2680 win 65535

full client socket state:

 dione:~> grep $(printf "%X\n" 39201) /proc/net/tcp
   44: 1001000A:9921 1301000A:0E30 01 0005ABF2:00000000 01:00002B8A 
       00000000   500        0 63130083 2 ffff81000c762d00 120000 0 0 28 101

 [ a few minutes later ]

   44: 1001000A:9921 1301000A:0E30 01 0005A392:00000000 01:00002BF0 
       00000000   500        0 63130083 2 ffff81000c762d00 120000 0 0 32 101

 [ i.e. the tx queue did increase by 2144 bytes - 4x 536 bytes ]

full server socket state:

 phoenix:~> grep $(printf "%X\n" 39201) /proc/net/tcp
    6: 1301000A:0E30 1001000A:9921 01 00000000:00000000 00:00000000 
       00000000    99        0 728382 1 ffff88042d8db280 300 4 30 2 -1

 [ a few minutes later ]

    6: 1301000A:0E30 1001000A:9921 01 00000000:00000000 00:00000000 
       00000000    99        0 728382 1 ffff88042d8db280 300 4 30 2 -1

 [ i.e. no change - no pending packets ]

I've started a longer capture session as well - it seems the TCP stack 
is slowly cycling through retransmissions of 536-byte packets, with 
375450 bytes pending? At 120 seconds a pop that would be about 23 hours 
to make any progress on - but i'm not sure i interpreted that right. It 
all looks very weird.

The timestamps of the two boxes are synced up to within about 1 second:

  earth4:~> for N in dione phoenix; do ssh $N date; done
  Thu Jul 24 07:44:02 CEST 2008
  Thu Jul 24 07:44:02 CEST 2008

( but the two boxes are responding to each other fine, so ordering of 
  events is not a question here. )

Any other state you'd like to see before i continue with -tip testing? 

	Ingo
