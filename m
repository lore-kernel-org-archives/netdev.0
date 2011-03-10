From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Thu, 10 Mar 2011 00:24:58 -0500
Message-ID: <20110310002458.5a94f563.billfink@mindspring.com>
References: <il4vur$3ka$1@dough.gmane.org>
	<20110308111011.GA27967@xanadu.blop.info>
	<4D764AAC.30302@ncsu.edu>
	<20110308.114346.48506864.davem@davemloft.net>
	<20110308152103.714f5f05@nehalam>
	<4D76D851.4050600@ncsu.edu>
	<20110309065319.GA23740@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Injong Rhee <rhee@ncsu.edu>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, sangtae.ha@gmail.com
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:52471 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750957Ab1CJFZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 00:25:05 -0500
In-Reply-To: <20110309065319.GA23740@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Mar 2011, Lucas Nussbaum wrote:

> On 08/03/11 at 20:30 -0500, Injong Rhee wrote:
> > Now, both tools can be wrong. But that is not catastrophic since
> > congestion avoidance can kick in to save the day. In a pipe where no
> > other flows are competing, then exiting slow start too early can
> > slow things down as the window can be still too small. But that is
> > in fact when delays are most reliable. So those tests that say bad
> > performance with hystart are in fact, where hystart is supposed to
> > perform well.
> 
> Hi,
> 
> In my setup, there is no congestion at all (except the buffer bloat).
> Without Hystart, transferring 8 Gb of data takes 9s, with CUBIC exiting
> slow start at ~2000 packets.
> With Hystart, transferring 8 Gb of data takes 19s, with CUBIC exiting
> slow start at ~20 packets.
> I don't think that this is "hystart performing well". We could just as
> well remove slow start completely, and only do congestion avoidance,
> then.
> 
> While I see the value in Hystart, it's clear that there are some flaws
> in the current implementation. It probably makes sense to disable
> hystart by default until those problems are fixed.

Here are some tests I performed across real networks, where
congestion is generally not an issue, with a 2.6.35 kernel on
the transmit side.

8 GB transfer across an 18 ms RTT path with autotuning and hystart:

i7test7% nuttcp -n8g -i1 192.168.1.23
  517.9375 MB /   1.00 sec = 4344.6096 Mbps     0 retrans
  688.4375 MB /   1.00 sec = 5775.1998 Mbps     0 retrans
  692.9375 MB /   1.00 sec = 5812.7462 Mbps     0 retrans
  698.0625 MB /   1.00 sec = 5855.8078 Mbps     0 retrans
  699.8750 MB /   1.00 sec = 5871.0123 Mbps     0 retrans
  710.5625 MB /   1.00 sec = 5960.5707 Mbps     0 retrans
  728.8125 MB /   1.00 sec = 6113.7652 Mbps     0 retrans
  751.3750 MB /   1.00 sec = 6302.9210 Mbps     0 retrans
  783.8750 MB /   1.00 sec = 6575.6201 Mbps     0 retrans
  825.1875 MB /   1.00 sec = 6921.8145 Mbps     0 retrans
  875.4375 MB /   1.00 sec = 7343.9811 Mbps     0 retrans

 8192.0000 MB /  11.26 sec = 6102.4718 Mbps 11 %TX 28 %RX 0 retrans 18.92 msRTT

Ramps up quickly to a little under 6 Gbps, then increases more
slowly to 7+ Gbps, with no TCP retransmissions.

8 GB transfer across an 18 ms RTT path with 40 MB socket buffer and hystart:

i7test7% nuttcp -n8g -w40m -i1 192.168.1.23
  970.0625 MB /   1.00 sec = 8136.8475 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9909.0045 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9908.6369 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.8747 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.0531 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9908.8153 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.0729 Mbps     0 retrans

 8192.0000 MB /   7.13 sec = 9633.5814 Mbps 17 %TX 42 %RX 0 retrans 18.91 msRTT

Quickly ramps up to full 10-GigE line rate, with no TCP retrans.

8 GB transfer across an 18 ms RTT path with autotuning and no hystart:

i7test7% nuttcp -n8g -i1 192.168.1.23
  845.4375 MB /   1.00 sec = 7091.5828 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9910.0134 Mbps     0 retrans
 1181.0625 MB /   1.00 sec = 9907.1830 Mbps     0 retrans
 1181.4375 MB /   1.00 sec = 9910.8936 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.1721 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.5774 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.6874 Mbps     0 retrans

 8192.0000 MB /   7.25 sec = 9484.4524 Mbps 18 %TX 41 %RX 0 retrans 18.92 msRTT

Also quickly ramps up to full 10-GigE line rate, with no TCP retrans.

8 GB transfer across an 18 ms RTT path with 40 MB socket buffer and no hystart:

i7test7% nuttcp -n8g -w40m -i1 192.168.1.23
  969.8750 MB /   1.00 sec = 8135.6571 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.3990 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9908.9342 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.4098 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9908.8252 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.0630 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.3504 Mbps     0 retrans

 8192.0000 MB /   7.15 sec = 9611.8053 Mbps 18 %TX 42 %RX 0 retrans 18.95 msRTT

Basically the same as the case with 40 MB socket buffer and hystart enabled.

Now trying the same type of tests across an 80 ms RTT path.

8 GB transfer across an 80 ms RTT path with autotuning and hystart:

i7test7% nuttcp -n8g -i1 192.168.1.18
   11.3125 MB /   1.00 sec =   94.8954 Mbps     0 retrans
  441.5625 MB /   1.00 sec = 3704.1021 Mbps     0 retrans
  687.3750 MB /   1.00 sec = 5765.8657 Mbps     0 retrans
  715.5625 MB /   1.00 sec = 6002.6273 Mbps     0 retrans
  709.9375 MB /   1.00 sec = 5955.5958 Mbps     0 retrans
  691.3125 MB /   1.00 sec = 5799.0626 Mbps     0 retrans
  718.6250 MB /   1.00 sec = 6028.3538 Mbps     0 retrans
  718.0000 MB /   1.00 sec = 6023.0205 Mbps     0 retrans
  704.0000 MB /   1.00 sec = 5905.5387 Mbps     0 retrans
  733.3125 MB /   1.00 sec = 6151.4096 Mbps     0 retrans
  738.8750 MB /   1.00 sec = 6198.2381 Mbps     0 retrans
  731.8750 MB /   1.00 sec = 6139.3695 Mbps     0 retrans

 8192.0000 MB /  12.85 sec = 5348.9677 Mbps 10 %TX 23 %RX 0 retrans 80.81 msRTT

Similar to the 20 ms RTT path, but achieving somewhat lower
performance levels, presumably due to the larger RTT.  Ramps
up fairly quickly to a little under 6 Gbps, then increases
more slowly to 6+ Gbps, with no TCP retransmissions.

8 GB transfer across an 80 ms RTT path with 100 MB socket buffer and hystart:

i7test7% nuttcp -n8g -w100m -i1 192.168.1.18
  103.9375 MB /   1.00 sec =  871.8378 Mbps     0 retrans
 1086.5625 MB /   1.00 sec = 9114.6102 Mbps     0 retrans
 1106.6875 MB /   1.00 sec = 9283.5583 Mbps     0 retrans
 1109.3125 MB /   1.00 sec = 9305.5226 Mbps     0 retrans
 1111.1875 MB /   1.00 sec = 9321.9596 Mbps     0 retrans
 1112.8125 MB /   1.00 sec = 9334.8452 Mbps     0 retrans
 1113.6875 MB /   1.00 sec = 9341.6620 Mbps     0 retrans
 1120.2500 MB /   1.00 sec = 9398.0054 Mbps     0 retrans

 8192.0000 MB /   8.37 sec = 8207.2049 Mbps 16 %TX 38 %RX 0 retrans 80.81 msRTT

Quickly ramps up to 9+ Gbps and then slowly increases further,
with no TCP retrans.

8 GB transfer across an 80 ms RTT path with autotuning and no hystart:

i7test7% nuttcp -n8g -i1 192.168.1.18
   11.2500 MB /   1.00 sec =   94.3703 Mbps     0 retrans
  519.0625 MB /   1.00 sec = 4354.1596 Mbps     0 retrans
  861.2500 MB /   1.00 sec = 7224.7970 Mbps     0 retrans
  871.0000 MB /   1.00 sec = 7306.4191 Mbps     0 retrans
  860.7500 MB /   1.00 sec = 7220.4438 Mbps     0 retrans
  869.0625 MB /   1.00 sec = 7290.3340 Mbps     0 retrans
  863.4375 MB /   1.00 sec = 7242.7707 Mbps     0 retrans
  860.4375 MB /   1.00 sec = 7218.0606 Mbps     0 retrans
  875.5000 MB /   1.00 sec = 7344.3071 Mbps     0 retrans
  863.1875 MB /   1.00 sec = 7240.8257 Mbps     0 retrans

 8192.0000 MB /  10.98 sec = 6259.4379 Mbps 12 %TX 27 %RX 0 retrans 80.81 msRTT

Ramps up quickly to 7+ Gbps, then appears to stabilize at that
level, with no TCP retransmissions.  Performance is somewhat
better than with autotuning enabled, but less than using a
manually set 100 MB socket buffer.

8 GB transfer across an 80 ms RTT path with 100 MB socket buffer and no hystart:

i7test7% nuttcp -n8g -w100m -i1 192.168.1.18
  102.8750 MB /   1.00 sec =  862.9487 Mbps     0 retrans
  522.8750 MB /   1.00 sec = 4386.2811 Mbps   414 retrans
  881.5625 MB /   1.00 sec = 7394.6534 Mbps     0 retrans
 1164.3125 MB /   1.00 sec = 9766.6682 Mbps     0 retrans
 1170.5625 MB /   1.00 sec = 9819.7042 Mbps     0 retrans
 1166.8125 MB /   1.00 sec = 9788.2067 Mbps     0 retrans
 1159.8750 MB /   1.00 sec = 9729.1530 Mbps     0 retrans
  811.1250 MB /   1.00 sec = 6804.8017 Mbps    21 retrans
   73.2500 MB /   1.00 sec =  614.4674 Mbps     0 retrans
  884.6250 MB /   1.00 sec = 7420.2900 Mbps     0 retrans

 8192.0000 MB /  10.34 sec = 6647.9394 Mbps 13 %TX 31 %RX 435 retrans 80.81 msRTT

Disabling hystart on a large RTT path does not seem to play nice with
a manually specified socket buffer, resulting in TCP retransmissions
that limit the effective network performance.

This is a repeatable but extremely variable phenomenon.

i7test7% nuttcp -n8g -w100m -i1 192.168.1.18
  103.7500 MB /   1.00 sec =  870.3015 Mbps     0 retrans
 1146.3750 MB /   1.00 sec = 9616.4520 Mbps     0 retrans
 1175.9375 MB /   1.00 sec = 9864.6070 Mbps     0 retrans
  615.6875 MB /   1.00 sec = 5164.7353 Mbps    21 retrans
  139.2500 MB /   1.00 sec = 1168.1253 Mbps     0 retrans
 1090.0625 MB /   1.00 sec = 9143.8053 Mbps     0 retrans
 1170.4375 MB /   1.00 sec = 9818.6654 Mbps     0 retrans
 1174.5625 MB /   1.00 sec = 9852.8754 Mbps     0 retrans
 1174.8750 MB /   1.00 sec = 9855.6052 Mbps     0 retrans

 8192.0000 MB /   9.42 sec = 7292.9879 Mbps 14 %TX 34 %RX 21 retrans 80.81 msRTT

And:

i7test7% nuttcp -n8g -w100m -i1 192.168.1.18
  102.8125 MB /   1.00 sec =  862.4227 Mbps     0 retrans
 1148.4375 MB /   1.00 sec = 9633.6860 Mbps     0 retrans
 1177.4375 MB /   1.00 sec = 9877.3086 Mbps     0 retrans
 1168.1250 MB /   1.00 sec = 9798.9133 Mbps    11 retrans
  133.1250 MB /   1.00 sec = 1116.7457 Mbps     0 retrans
  479.8750 MB /   1.00 sec = 4025.4631 Mbps     0 retrans
 1150.6875 MB /   1.00 sec = 9652.4830 Mbps     0 retrans
 1177.3125 MB /   1.00 sec = 9876.0624 Mbps     0 retrans
 1177.3750 MB /   1.00 sec = 9876.0139 Mbps     0 retrans
  320.2500 MB /   1.00 sec = 2686.6452 Mbps    19 retrans
   64.9375 MB /   1.00 sec =  544.7363 Mbps     0 retrans
   73.6250 MB /   1.00 sec =  617.6113 Mbps     0 retrans

 8192.0000 MB /  12.39 sec = 5545.7570 Mbps 12 %TX 26 %RX 30 retrans 80.80 msRTT

Re-enabling hystart immediately gives a clean test with no TCP retrans.

i7test7% nuttcp -n8g -w100m -i1 192.168.1.18
  103.8750 MB /   1.00 sec =  871.3353 Mbps     0 retrans
 1086.7500 MB /   1.00 sec = 9116.4474 Mbps     0 retrans
 1105.8125 MB /   1.00 sec = 9276.2276 Mbps     0 retrans
 1109.4375 MB /   1.00 sec = 9306.5339 Mbps     0 retrans
 1111.3125 MB /   1.00 sec = 9322.5327 Mbps     0 retrans
 1111.3750 MB /   1.00 sec = 9322.8053 Mbps     0 retrans
 1113.7500 MB /   1.00 sec = 9342.8962 Mbps     0 retrans
 1120.3125 MB /   1.00 sec = 9397.5711 Mbps     0 retrans

 8192.0000 MB /   8.38 sec = 8204.8394 Mbps 16 %TX 39 %RX 0 retrans 80.80 msRTT

						-Bill
