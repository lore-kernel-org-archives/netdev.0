From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29
Date: Thu, 16 Apr 2009 10:21:10 -0700
Message-ID: <49E76906.2060205@hp.com>
References: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:32350 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758097AbZDPRVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 13:21:13 -0400
In-Reply-To: <alpine.DEB.1.10.0904161151330.13531@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter wrote:
> The following are results of lantency measurements using udpping
> (available from http://gentwo.org/ll). It shows that significant latencies
> were added since 2.6.27. I surely wish we could get back to times below 90
> microseconds.
> 
> The tests were done over 1G ethernet using
> 09:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5754
> Gigabit Ethernet PCI Express (rev 02)
> 
> Results:
> 
>            2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
> 40 Bytes    89.50  90.75  89.61  91.51  91.89  99.17  99.80  99.34
> 400 Bytes   98.58 101.44  97.85  99.61 100.36 117.96 118.10 126.79
> 1400 Bytes 152.76 153.75 153.85	156.22 156.66 163.92 165.54 166.04
> 
> Compared to 2.6.22 2.6.23 2.6.24 2.6.25 2.6.26 2.6.27 2.6.28 2.6.29
> 40 Bytes            -1.4%  -0.1%  -2.2%  -2.6%  -9.8%  -10.3% -9.9%
> 400 Bytes           -2.8%   0.7%  -1.0%  -1.8% -16.4%  -16.5%-22.2%
> 1400 Bytes          -0.6%  -0.7%  -2.2%  -2.5%  -6.8%  -7.7%  -8.0%
> 
> I presented these numbers with some nice graphs at the Linux Collab Summit
> last week.
> 
> See
> http://www.kernel.org/pub/linux/kernel/people/christoph/collab-spring-2009/Collab-summit-2009-sf.pdf

Does udpping have a concept of service demand a la netperf?  That could help show 
how much was code bloat vs say some tweak to interrupt coalescing parameters in 
the NIC/driver.

[root@bl870c1 netperf2_trunk]# netperf -T 0 -c -C -t UDP_RR -H bl870c2.west -v 2
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to bl870c2.west 
(10.208.0.210) port 0 AF_INET : histogram : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

126976 126976 1       1      10.00   7550.46   2.33   2.41   24.721  25.551
126976 126976

Histogram of request/reponse times.
UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    1
HUNDRED_USEC  :    0: 75508:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_MSEC     :    0:    2:    0:    0:    0:    0:    0:    0:    0:    0
TEN_MSEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
 >100_SECS: 0
HIST_TOTAL:      75511

I guess one of these days I have to tweak netperf to be able to get latencies 
when doing bursts on the connection...

[root@bl870c1 netperf2_trunk]# ethtool -C eth0 rx-frames 1
[do the same on the other end]
[root@bl870c1 netperf2_trunk]# netperf -T 0 -c -C -t UDP_RR -H bl870c2.west -v 2
UDP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to bl870c2.west 
(10.208.0.210) port 0 AF_INET : histogram : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

126976 126976 1       1      10.00   11126.15   2.60   3.43   18.711  24.633
126976 126976

Histogram of request/reponse times.
UNIT_USEC     :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_USEC      :    0:    0:    0:    0:    0:    0:    0:   16: 71799: 38583
HUNDRED_USEC  :    0:  856:    8:    0:    0:    0:    0:    0:    0:    0
UNIT_MSEC     :    0:    1:    0:    0:    0:    0:    1:    0:    0:    0
TEN_MSEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
HUNDRED_MSEC  :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
UNIT_SEC      :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
TEN_SEC       :    0:    0:    0:    0:    0:    0:    0:    0:    0:    0
 >100_SECS: 0
HIST_TOTAL:      111264
