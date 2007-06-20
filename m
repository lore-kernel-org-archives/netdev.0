From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [-RT] multiple streams have degraded performance
Date: Wed, 20 Jun 2007 09:42:45 +0200
Message-ID: <1182325365.21117.9.camel@twins>
References: <200706182212.22633.vernux@us.ibm.com>
	 <200706192038.01054.vernux@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>,
	Ingo Molnar <mingo@elte.hu>, netdev <netdev@vger.kernel.org>
To: Vernon Mauery <vernux@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37627 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbXFTHnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 03:43:22 -0400
In-Reply-To: <200706192038.01054.vernux@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-19 at 20:38 -0700, Vernon Mauery wrote:
> On Monday 18 June 2007 10:12:21 pm Vernon Mauery wrote:
> > In looking at the performance characteristics of my network I found that
> > 2.6.21.5-rt15 suffers from degraded thoughput with multiple threads.  The
> > test that I did this with is simply invoking 1, 2, 4, and 8 instances of
> > netperf at a time and measuring the total throughput.  I have two 4-way
> > machines connected with 10GbE cards.  I tested several kernels (some older
> > and some newer) and found that the only thing in common was that with -RT
> > kernels the performance went down with concurrent streams.
> 
> I just tested this using lo instead of the 10GbE adapter.  I found similar 
> results.  Since this makes it reproducible by just about anybody (maybe the 
> only factor now is the number of CPUs), I have attached the script that I 
> test things with.
> 
> So with the script run like ./stream_test 127.0.0.1 on 2.6.21 and 
> 2.6.21.5-rt17 I got the following:
> 
> 2.6.21
> =======================
> default: 1 streams: Send at 2790.3 Mb/s, Receive at 2790.3 Mb/s
> default: 2 streams: Send at 4129.4 Mb/s, Receive at 4128.7 Mb/s
> default: 4 streams: Send at 7949.6 Mb/s, Receive at 7735.5 Mb/s
> default: 8 streams: Send at 7930.7 Mb/s, Receive at 7910.1 Mb/s
> 1Msock: 1 streams: Send at 2810.7 Mb/s, Receive at 2810.7 Mb/s
> 1Msock: 2 streams: Send at 4093.4 Mb/s, Receive at 4092.6 Mb/s
> 1Msock: 4 streams: Send at 7887.8 Mb/s, Receive at 7880.4 Mb/s
> 1Msock: 8 streams: Send at 8091.7 Mb/s, Receive at 8082.2 Mb/s
> 
> 2.6.21.5-rt17
> ======================
> default: 1 streams: Send at 938.2 Mb/s, Receive at 938.2 Mb/s
> default: 2 streams: Send at 1476.3 Mb/s, Receive at 1436.9 Mb/s
> default: 4 streams: Send at 1489.8 Mb/s, Receive at 1145.0 Mb/s
> default: 8 streams: Send at 1099.8 Mb/s, Receive at 1079.1 Mb/s
> 1Msock: 1 streams: Send at 921.4 Mb/s, Receive at 920.4 Mb/s
> 1Msock: 2 streams: Send at 1332.2 Mb/s, Receive at 1311.5 Mb/s
> 1Msock: 4 streams: Send at 1483.0 Mb/s, Receive at 1137.8 Mb/s
> 1Msock: 8 streams: Send at 1446.2 Mb/s, Receive at 1135.6 Mb/s

Unfortunately I do not have a 4-way machine, but a dual core was enough
to show the problem:

./stream_test 127.0.0.1

** default: 1 streams: Send at 268.9 Mb/s, Receive at 268.0 Mb/s
** default: 2 streams: Send at 448.7 Mb/s, Receive at 448.4 Mb/s
** default: 4 streams: Send at 438.7 Mb/s, Receive at 438.3 Mb/s
** default: 8 streams: Send at 352.7 Mb/s, Receive at 351.2 Mb/s

** 1Msock: 1 streams: Send at 207.4 Mb/s, Receive at 207.4 Mb/s
** 1Msock: 2 streams: Send at 450.0 Mb/s, Receive at 450.0 Mb/s
** 1Msock: 4 streams: Send at 444.9 Mb/s, Receive at 444.9 Mb/s
** 1Msock: 8 streams: Send at 351.4 Mb/s, Receive at 351.4 Mb/s


and lock_stat shows the following offender:

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                              class name    contentions   waittime-min   waittime-max waittime-total    con-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total    acq-bounces
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

                         udp_hash_lock-W:             1           1.58           1.58           1.58              1            163          0.100           4.38         184.44            110
                         udp_hash_lock-R:        539603           1.30        4848.34     7756821.91         539131       15095136           0.36         520.09    20404391.93       11527348
                         ---------------
                           udp_hash_lock         539603          [<ffffffff80468d63>] __udp4_lib_lookup+0x3c/0x10d
                           udp_hash_lock              1          [<ffffffff804686fe>] __udp_lib_get_port+0x2c/0x21a


Which makes perfect sense, in that r/w locks are degraded to regular
exclusive locks on -rt.

So I guess you're wanting to go help out with the RCU-ification of
whatever it is that this lock protects. :-)

