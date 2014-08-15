From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 16:23:43 -0700
Message-ID: <53EE967F.9090101@intel.com>
References: <53ECFDAB.5010701@intel.com>	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>	<53ED4354.9090904@intel.com>	<20140814.162024.2218312002979492106.davem@davemloft.net>	<53EE4023.6080902@intel.com>	<CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>	<53EE5B25.3040206@intel.com> <CA+mtBx-LZgnpWAf3Jn0htoga32UaMc-NAqURmXezmZmwg2oGRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Rick Jones <rick.jones2@hp.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56262 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138AbaHOXXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 19:23:46 -0400
In-Reply-To: <CA+mtBx-LZgnpWAf3Jn0htoga32UaMc-NAqURmXezmZmwg2oGRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2014 03:16 PM, Tom Herbert wrote:
> On Fri, Aug 15, 2014 at 12:10 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> On 08/15/2014 11:49 AM, Tom Herbert wrote:
>>> Alex, I tried to repro your problem running your script (on bnx2x).
>>> Didn't see see the issue and in fact ip_dest_check did not appear in
>>> top perf functions on perf. I assume this is more related to the
>>> steering configuration rather than the device (although flow director
>>> might be a fundamental difference).
>>>
>>
>> So the original script I put out had a typo.  It was supposed to run all
>> 60 at the same time, not one at a time.  So make sure you add an
>> ampersand to the end of the netperf command line if you run the test so
>> that it is 60 at once, not 60 in series.
>>
>> Also one other thing I had to do was disable tcp_autocork.  Without that
>> the test is a large packets test instead of a small packet test.
>>
> Okay, by running netperf in background, disabling autoconf, and
> turning off RPS/RFS I'm able to get ipv4_dst_check to come up in perf;
> but t's not nearly as bad as what you've reported though, only about
> 1.5%. When I applied path to move rt_genid to different cacheline
> ipv4_dst_check goes away (ipv4: move rt_genid to different cache
> line). Can you try this patch in your setup?

The issue doesn't occur for me until I start using netperf on both
sockets with the same IP address on both ends.  Then I see the dst
bouncing between the two nodes and the CPU utilization skyrockets.  If I
am only on one node the dst bouncing is tolerable as it doesn't go any
further than the LLC.

With your patch applied I see ipv4_dst_check drop off to 5% CPU
utilization from the 36% that it was.  However ip_rcv_finish has climbed
up to about 16% so it isn't as though much was saved.  It just pushed it
to the next item to hit in that cacheline.  Throughput was 2.5Gb/s with
100% CPU utilization on the receiver.

Even if the refcount issue is fixed the performance still suffers
compared to the low_latency path in my testing.  When I reverted the
refcount change the CPU utilization dropped from 100% to about 25%, but
that is still double the 12% I am seeing when tcp_low_latency is set.
That is one of the reasons why I am not all that interested in the ref
count fix as I am still likely going to have to work around other issues
in the prequeue path.

Another test I tried was to hack the nettest_bsd.c file in netperf to
perform a poll() based receive.  That resolved the issue and had all the
performance of the tcp_low_latency case.  I may see if I can work with
Rick to push something like that into netperf as I really would prefer
to avoid having to advise everyone on how to setup the sysctl for
tcp_low_latency.

Thanks,

Alex
