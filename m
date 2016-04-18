From: "Butler, Peter" <pbutler@sonusnet.com>
Subject: RE: Poorer networking performance in later kernels?
Date: Mon, 18 Apr 2016 11:27:59 +0000
Message-ID: <BY2PR0301MB1990F3095CFA07EBBE600F9DD66B0@BY2PR0301MB1990.namprd03.prod.outlook.com>
References: <SN1PR0301MB19987565B71A4688593A2CDBD6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <SN1PR0301MB19983946D7A38001E4B54D20D6680@SN1PR0301MB1998.namprd03.prod.outlook.com>
 <57116D21.8000807@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Rick Jones <rick.jones2@hpe.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0089.outbound.protection.outlook.com ([207.46.100.89]:61509
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751560AbcDRLn4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 07:43:56 -0400
In-Reply-To: <57116D21.8000807@hpe.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick

Thanks for the reply.

Here is some hardware information, as requested (the two systems are identical, and are communicating with one another over a 10GB full-duplex Ethernet backplane):

- processor type: Intel(R) Xeon(R) CPU C5528  @ 2.13GHz
- NIC: Intel 82599EB 10GB XAUI/BX4
- NIC driver: ixgbe version 4.2.1-k (part of 4.4.0 kernel)

As for the buffer sizes, those rather large ones work fine for us with the 3.4.2 kernel.  However, for the sake of being complete, I have re-tried the tests with the 'standard' 4.4.0 kernel parameters for all /proc/sys/net/* values, and the results still were extremely poor in comparison to the 3.4.2 kernel.

Our MTU is actually just the standard 1500 bytes, however the message size was chosen to mimic actual traffic which will be segmented.

I ran ethtool -k (indeed I checked all ethtool parameters, not just those via -k) and the only real difference I could find was in "large-receive-offload" which was ON in 3.4.2 but OFF in 4.4.0 - so I used ethtool to change this to match the 3.4.2 settings and re-ran the tests.  Didn't help :-(   It's possible of course that I have missed a parameter here or there in comparing the 3.4.2 setup to the 4.4.0 setup.  I also tried running the ethtool config with the latest and greatest ethtool version (4.5) on the 4.4.0 kernel, as compared to the old 3.1 version on our 3.4.2 kernel.

I performed the TCP_RR test as requested and in that case, the results are much more comparable.  The old kernel is still better, but now only around 10% better as opposed to 2-3x better.

However I still contend that the *_STREAM tests are giving us more pertinent data, since our product application is only getting 1/3 to 1/2 half of the performance on the 4.4.0 kernel, and this is the same thing I see when I use netperf to test.

One other note: I tried running our 3.4.2 and 4.4.0 kernels in a VM environment on my workstation, so as to take the 'real' production hardware out of the equation.  When I perform the tests in this setup the 3.4.2 and 4.4.0 kernels perform identically - just as you would expect.

Any other ideas?  What can I be missing here?

Peter




-----Original Message-----
From: Rick Jones [mailto:rick.jones2@hpe.com] 
Sent: April-15-16 6:37 PM
To: Butler, Peter <pbutler@sonusnet.com>; netdev@vger.kernel.org
Subject: Re: Poorer networking performance in later kernels?

On 04/15/2016 02:02 PM, Butler, Peter wrote:
> (Please keep me CC'd to all comments/responses)
>
> I've tried a kernel upgrade from 3.4.2 to 4.4.0 and see a marked drop 
> in networking performance.  Nothing was changed on the test systems, 
> other than the kernel itself (and kernel modules).  The identical 
> .config used to build the 3.4.2 kernel was brought over into the
> 4.4.0 kernel source tree, and any configuration differences (e.g. new 
> parameters, etc.) were taken as default values.
>
> The testing was performed on the same actual hardware for both kernel 
> versions (i.e. take the existing 3.4.2 physical setup, simply boot 
> into the (new) kernel and run the same test).  The netperf utility was 
> used for benchmarking and the testing was always performed on idle 
> systems.
>
> TCP testing yielded the following results, where the 4.4.0 kernel only 
> got about 1/2 of the throughput:
>

>        Recv     Send       Send                          Utilization       Service Demand
>        Socket   Socket     Message Elapsed               Send     Recv     Send    Recv
>        Size     Size       Size    Time       Throughput local    remote   local   remote
>        bytes    bytes      bytes   secs.      10^6bits/s % S      % S      us/KB   us/KB
>
> 3.4.2 13631488 13631488   8952    30.01      9370.29    10.14    6.50     0.709   0.454
> 4.4.0 13631488 13631488   8952    30.02      5314.03    9.14     14.31    1.127   1.765
>
> SCTP testing yielded the following results, where the 4.4.0 kernel only got about 1/3 of the throughput:
>
>        Recv     Send       Send                          Utilization       Service Demand
>        Socket   Socket     Message Elapsed               Send     Recv     Send    Recv
>        Size     Size       Size    Time       Throughput local    remote   local   remote
>        bytes    bytes      bytes   secs.      10^6bits/s  % S     % S      us/KB   us/KB
>
> 3.4.2 13631488 13631488   8952    30.00      2306.22    13.87    13.19    3.941   3.747
> 4.4.0 13631488 13631488   8952    30.01       882.74    16.86    19.14    12.516  14.210
>
> The same tests were performed a multitude of time, and are always 
> consistent (within a few percent).  I've also tried playing with 
> various run-time kernel parameters (/proc/sys/kernel/net/...) on the
> 4.4.0 kernel to alleviate the issue but have had no success at all.
>
> I'm at a loss as to what could possibly account for such a discrepancy...
>

I suspect I am not alone in being curious about the CPU(s) present in the systems and the model/whatnot of the NIC being used.  I'm also curious as to why you have what at first glance seem like absurdly large socket buffer sizes.

That said, it looks like you have some Really Big (tm) increases in service demand.  Many more CPU cycles being consumed per KB of data transferred.

Your message size makes me wonder if you were using a 9000 byte MTU.

Perhaps in the move from 3.4.2 to 4.4.0 you lost some or all of the stateless offloads for your NIC(s)?  Running ethtool -k <interface> on both ends under both kernels might be good.

Also, if you did have a 9000 byte MTU under 3.4.2 are you certain you still had it under 4.4.0?

It would (at least to me) also be interesting to run a TCP_RR test comparing the two kernels.  TCP_RR (at least with the default request/response size of one byte) doesn't really care about stateless offloads or MTUs and could show how much difference there is in basic path length (or I suppose in interrupt coalescing behaviour if the NIC in question has a mildly dodgy heuristic for such things).

happy benchmarking,

rick jones
