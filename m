From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCPportsfrom
	the host TCP port space.
Date: Mon, 20 Aug 2007 12:16:41 -0700
Message-ID: <46C9E899.9020609@hp.com>
References: <8A71B368A89016469F72CD08050AD334018E20BC@maui.asicdesigners.com>	<20070819.174017.77241227.davem@davemloft.net>	<8A71B368A89016469F72CD08050AD334018E20BE@maui.asicdesigners.com>	<20070819.180540.74750322.davem@davemloft.net>	<8A71B368A89016469F72CD08050AD334018E20C1@maui.asicdesigners.com>
	<p733aye1n39.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org,
	David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <p733aye1n39.fsf@bingen.suse.de>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> TSO is beneficial for the software again. The linux code currently
> takes several locks and does quite a few function calls for each 
> packet and using larger packets lowers this overhead. At least with
> 10GbE saving CPU cycles is still quite important.

Some quick netperf TCP_RR tests between a pair of dual-core rx6600's running 
2.6.23-rc3.  the NICs are dual-core e1000's connected back-to-back with the 
interrupt throttle disabled.  I like using TCP_RR to tickle path-length 
questions because it rarely runs into bandwidth limitations regardless of the 
link-type.

First, with TSO enabled on both sides, then with it disabled, netperf/netserver 
bound to the same CPU as takes interrupts, which is the "best" place to be for a 
TCP_RR test (although not always for a TCP_STREAM test...):

:~# netperf -T 1 -t TCP_RR -H 192.168.2.105 -I 99,1 -c -C
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.105 
(192.168.2.105) port 0 AF_INET : +/-0.5% @ 99% conf.  : first burst 0 : cpu bind
!!! WARNING
!!! Desired confidence was not achieved within the specified iterations.
!!! This implies that there was variability in the test environment that
!!! must be investigated before going further.
!!! Confidence intervals: Throughput      :  0.3%
!!!                       Local CPU util  : 39.3%
!!!                       Remote CPU util : 40.6%

Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      10.01   18611.32  20.96  22.35  22.522  24.017
16384  87380
:~# ethtool -K eth2 tso off
e1000: eth2: e1000_set_tso: TSO is Disabled
:~# netperf -T 1 -t TCP_RR -H 192.168.2.105 -I 99,1 -c -C
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.2.105 
(192.168.2.105) port 0 AF_INET : +/-0.5% @ 99% conf.  : first burst 0 : cpu bind
!!! WARNING
!!! Desired confidence was not achieved within the specified iterations.
!!! This implies that there was variability in the test environment that
!!! must be investigated before going further.
!!! Confidence intervals: Throughput      :  0.4%
!!!                       Local CPU util  : 21.0%
!!!                       Remote CPU util : 25.2%

Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      10.01   19812.51  17.81  17.19  17.983  17.358
16384  87380

While the confidence intervals for CPU util weren't hit, I suspect the 
differences in service demand were still real.  On throughput we are talking 
about +/- 0.2%, for CPU util we are talking about +/- 20% (percent not 
percentage points) in the first test and 12.5% in the second.

So, in broad handwaving terms, TSO increased the per-transaction service demand 
by something along the lines of (23.27 - 17.67)/17.67 or ~30% and the 
transaction rate decreased by ~6%.

rick jones
bitrate blindless is a constant concern
