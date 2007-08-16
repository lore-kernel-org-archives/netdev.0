From: Rick Jones <rick.jones2@hp.com>
Subject: e1000 autotuning doesn't get along with itself
Date: Thu, 16 Aug 2007 12:42:00 -0700
Message-ID: <46C4A888.9090006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:59174 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbXHPTmR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 15:42:17 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel10.hp.com (Postfix) with ESMTP id 63C18342EF
	for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:42:06 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id MAA13934
	for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:42:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks -

I was trying to look at bonding vs discrete links and so put a couple dual-port 
e1000-driven NICs:

4a:01.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet 
Controller (rev 03)
         Subsystem: Hewlett-Packard Company HP Dual Port 1000Base-T [A9900A]

into a pair of 8 core systems running a 2.6.22.2 kernel.  This gave me:

hpcpc109:~/netperf2_trunk# ethtool -i eth2
driver: e1000
version: 7.3.20-k2-NAPI
firmware-version: N/A
bus-info: 0000:49:02.0

for the e1000 driver.  I connected the two systems back-to-back and started 
running some tests.  In the course of trying to look at something else 
(verifying the results reported by bwm-ng) I enabled demo-mode in netperf 
(./configure --enable-demo) and noticed a considerable oscillation.  I undid the 
bond and repeated the experiment with a discrete NIC:

hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D 1.0 -l 15
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.105 
(192.168.2.105) port 0 AF_INET : demo : first burst 0
Interim result: 10014.93 Trans/s over 1.00 seconds
Interim result: 10015.79 Trans/s over 1.00 seconds
Interim result: 10014.30 Trans/s over 1.00 seconds
Interim result: 10016.29 Trans/s over 1.00 seconds
Interim result: 10085.80 Trans/s over 1.00 seconds
Interim result: 17526.61 Trans/s over 1.00 seconds
Interim result: 20007.60 Trans/s over 1.00 seconds
Interim result: 19626.46 Trans/s over 1.02 seconds
Interim result: 10616.44 Trans/s over 1.85 seconds
Interim result: 10014.88 Trans/s over 1.06 seconds
Interim result: 10015.79 Trans/s over 1.00 seconds
Interim result: 10014.80 Trans/s over 1.00 seconds
Interim result: 10035.30 Trans/s over 1.00 seconds
Interim result: 13974.69 Trans/s over 1.00 seconds
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       15.00    12225.77
16384  87380

On a slightly informed whim I tried disabling the interrupt thottle on both 
sides (modprobe e1000 InterruptThrottleRate=0,0,0,0,0,0,0,0) and re-ran:

hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D 1.0 -l 
15TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.2.105 (192.168.2.105) port 0 AF_INET : demo : first burst 0
Interim result: 18673.68 Trans/s over 1.00 seconds
Interim result: 18685.01 Trans/s over 1.00 seconds
Interim result: 18682.30 Trans/s over 1.00 seconds
Interim result: 18681.05 Trans/s over 1.00 seconds
Interim result: 18680.25 Trans/s over 1.00 seconds
Interim result: 18742.44 Trans/s over 1.00 seconds
Interim result: 18739.45 Trans/s over 1.00 seconds
Interim result: 18723.52 Trans/s over 1.00 seconds
Interim result: 18736.53 Trans/s over 1.00 seconds
Interim result: 18737.61 Trans/s over 1.00 seconds
Interim result: 18744.76 Trans/s over 1.00 seconds
Interim result: 18728.54 Trans/s over 1.00 seconds
Interim result: 18738.91 Trans/s over 1.00 seconds
Interim result: 18735.53 Trans/s over 1.00 seconds
Interim result: 18741.03 Trans/s over 1.00 seconds
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       15.00    18717.94
16384  87380

and then just for grins I tried just disabling it on one side, leaving the other 
at defaults:

hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D 1.0 -l 
15TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.2.105 (192.168.2.105) port 0 AF_INET : demo : first burst 0
Interim result: 19980.84 Trans/s over 1.00 seconds
Interim result: 19997.60 Trans/s over 1.00 seconds
Interim result: 19995.60 Trans/s over 1.00 seconds
Interim result: 20002.60 Trans/s over 1.00 seconds
Interim result: 20011.58 Trans/s over 1.00 seconds
Interim result: 19985.66 Trans/s over 1.00 seconds
Interim result: 20002.60 Trans/s over 1.00 seconds
Interim result: 20010.58 Trans/s over 1.00 seconds
Interim result: 20012.60 Trans/s over 1.00 seconds
Interim result: 19993.63 Trans/s over 1.00 seconds
Interim result: 19979.63 Trans/s over 1.00 seconds
Interim result: 19991.58 Trans/s over 1.00 seconds
Interim result: 20011.60 Trans/s over 1.00 seconds
Interim result: 19948.84 Trans/s over 1.00 seconds
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       15.00    19990.14
16384  87380


It looks like the e1000 interrupt throttle autotuning works very nicely when the 
other side isn't doing any, but if the other side is also trying to autotune it 
doesn't seem to stablize.  At least not during a netperf TCP_RR test.

Does anyone else see this?  To try to eliminate netperf demo mode I re-ran 
without it and got the same end results.

rick jones
