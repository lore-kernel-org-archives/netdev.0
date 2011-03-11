From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Thu, 10 Mar 2011 21:25:17 -0500
Message-ID: <20110310212517.cb8d14f0.billfink@mindspring.com>
References: <20110310002458.5a94f563.billfink@mindspring.com>
	<2049243270.17294.1299737824096.JavaMail.root@tahiti.vyatta.com>
	<20110310021751.2f5fb8bc.billfink@mindspring.com>
	<20110310085433.GA11953@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Injong Rhee <rhee@ncsu.edu>,
	David Miller <davem@davemloft.net>,
	xiyou wangcong <xiyou.wangcong@gmail.com>,
	netdev@vger.kernel.org, sangtae ha <sangtae.ha@gmail.com>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:43059 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753437Ab1CKCZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 21:25:33 -0500
In-Reply-To: <20110310085433.GA11953@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Mar 2011, Lucas Nussbaum wrote:

> On 10/03/11 at 02:17 -0500, Bill Fink wrote:
> > On Wed, 9 Mar 2011, Stephen Hemminger wrote:
> > 
> > > Bill what is the HZ in your kernel config.
> > > I am concerned hystart doesn't work well with HZ=100
> > 
> > HZ=1000
> > 
> > But I did have tcp_timestamps disabled.  Should I re-run
> > the tests with tcp_timestamps enabled?
> 
> I ran my tests with timestamps enabled and HZ=250. If you have the
> opportunity to run tests in the same config, it would be great. The
> HZ=250 vs HZ=1000 difference could explain why it's working.
> 
> However, enabling or disabling timestamps shouldn't make a difference,
> since the hystart code doesn't use TCP_CONG_RTT_STAMP.

I reran the same tests with HZ=250 and tcp_timestamps enabled.
BTW all my tests are with 9000-byte jumbo frames.  If you want,
I can also try them using standard 1500-byte Ethernet frames.

First on the 18 ms RTT path:

8 GB transfer across an 18 ms RTT path with autotuning and hystart:

i7test7% nuttcp -n8g -i1 192.168.1.23
  614.5625 MB /   1.00 sec = 5155.1383 Mbps     0 retrans
  824.2500 MB /   1.00 sec = 6914.5038 Mbps     0 retrans
  826.6875 MB /   1.00 sec = 6934.5632 Mbps     0 retrans
  831.5625 MB /   1.00 sec = 6975.7146 Mbps     0 retrans
  835.1875 MB /   1.00 sec = 7006.1867 Mbps     0 retrans
  844.8125 MB /   1.00 sec = 7086.7867 Mbps     0 retrans
  862.1250 MB /   1.00 sec = 7231.9274 Mbps     0 retrans
  886.5625 MB /   1.00 sec = 7437.0402 Mbps     0 retrans
  918.6875 MB /   1.00 sec = 7706.5633 Mbps     0 retrans

 8192.0000 MB /   9.80 sec = 7009.7460 Mbps 12 %TX 31 %RX 0 retrans 18.91 msRTT

Ramps up quickly to a little under 7 Gbps, then increases more
slowly to 7.7 Gbps, with no TCP retransmissions.  Actually performed
somewhat better than the HZ=1000 case.

8 GB transfer across an 18 ms RTT path with 40 MB socket buffer and hystart:

i7test7% nuttcp -n8g -i1 -w40m 192.168.1.23
  716.0000 MB /   1.00 sec = 6006.0812 Mbps     0 retrans
  864.5000 MB /   1.00 sec = 7251.9589 Mbps     0 retrans
  866.1250 MB /   1.00 sec = 7265.4596 Mbps     0 retrans
  871.1250 MB /   1.00 sec = 7307.7746 Mbps     0 retrans
  875.6250 MB /   1.00 sec = 7345.2308 Mbps     0 retrans
  886.1875 MB /   1.00 sec = 7433.8796 Mbps     0 retrans
  904.1250 MB /   1.00 sec = 7584.3654 Mbps     0 retrans
  929.1875 MB /   1.00 sec = 7794.4728 Mbps     0 retrans
  961.6250 MB /   1.00 sec = 8066.7839 Mbps     0 retrans

 8192.0000 MB /   9.34 sec = 7356.7856 Mbps 13 %TX 32 %RX 0 retrans 18.92 msRTT

Ramps up quickly to 7+ Gbps, then increases more slowly to 8+ Gbps,
with no TCP retransmissions.  Performed significantly worse than
the HZ=1000 case.

8 GB transfer across an 18 ms RTT path with autotuning and no hystart:

i7test7% nuttcp -n8g -i1 192.168.1.23
  850.8750 MB /   1.00 sec = 7137.3642 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.3396 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.5486 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.5883 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.0621 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.4396 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.5189 Mbps     0 retrans

 8192.0000 MB /   7.23 sec = 9499.4276 Mbps 17 %TX 40 %RX 0 retrans 18.95 msRTT

Quickly ramps up to full 10-GigE line rate, with no TCP retrans.
Same performance as HZ=1000 case.

8 GB transfer across an 18 ms RTT path with 40 MB socket buffer and no hystart:

i7test7% nuttcp -n8g -i1 -w40m 192.168.1.23
  969.8125 MB /   1.00 sec = 8135.2793 Mbps     0 retrans
 1181.1250 MB /   1.00 sec = 9908.0541 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.1810 Mbps     0 retrans
 1181.3125 MB /   1.00 sec = 9909.9044 Mbps     0 retrans
 1181.2500 MB /   1.00 sec = 9909.0729 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.0532 Mbps     0 retrans
 1181.1875 MB /   1.00 sec = 9908.9549 Mbps     0 retrans

 8192.0000 MB /   7.15 sec = 9609.9893 Mbps 17 %TX 41 %RX 0 retrans 18.92 msRTT

Also quickly ramps up to full 10-GigE line rate, with no TCP retrans.
Same performance as HZ=1000 case.

Now trying the same type of tests across an 80 ms RTT path.

8 GB transfer across an 80 ms RTT path with autotuning and hystart:

i7test7% nuttcp -n8g -i1 192.168.1.18
   10.6250 MB /   1.00 sec =   89.1274 Mbps     0 retrans
  501.7500 MB /   1.00 sec = 4208.6979 Mbps     0 retrans
  872.9375 MB /   1.00 sec = 7323.2651 Mbps     0 retrans
  865.5000 MB /   1.00 sec = 7259.8901 Mbps     0 retrans
  854.9375 MB /   1.00 sec = 7172.0224 Mbps     0 retrans
  872.0000 MB /   1.00 sec = 7314.8735 Mbps     0 retrans
  866.6875 MB /   1.00 sec = 7270.3017 Mbps     0 retrans
  855.1250 MB /   1.00 sec = 7172.9354 Mbps     0 retrans
  868.7500 MB /   1.00 sec = 7288.1352 Mbps     0 retrans
  868.3750 MB /   1.00 sec = 7283.8238 Mbps     0 retrans

 8192.0000 MB /  10.99 sec = 6250.8745 Mbps 11 %TX 25 %RX 0 retrans 80.78 msRTT

Similar to the 20 ms RTT path, but achieving somewhat lower
performance levels, presumably due to the larger RTT.  Ramps
up fairly quickly to 7+ Gbps, then appears to stabilize at
that level, with no TCP retransmissions.  Somewhat better
performance than the HZ=1000 case.

8 GB transfer across an 80 ms RTT path with 100 MB socket buffer and hystart:

i7test7% nuttcp -n8g -i1 -w100m 192.168.1.18
  103.8125 MB /   1.00 sec =  870.8197 Mbps     0 retrans
 1071.6875 MB /   1.00 sec = 8989.8315 Mbps     0 retrans
 1089.6250 MB /   1.00 sec = 9140.6929 Mbps     0 retrans
 1093.4375 MB /   1.00 sec = 9172.4186 Mbps     0 retrans
 1095.1875 MB /   1.00 sec = 9187.1262 Mbps     0 retrans
 1094.7500 MB /   1.00 sec = 9183.3460 Mbps     0 retrans
 1097.8750 MB /   1.00 sec = 9208.9431 Mbps     0 retrans
 1103.9375 MB /   1.00 sec = 9261.2584 Mbps     0 retrans

 8192.0000 MB /   8.48 sec = 8102.4984 Mbps 15 %TX 38 %RX 0 retrans 80.81 msRTT

Quickly ramps up to 9 Gbps and then slowly increases further,
with no TCP retrans.  Basically same performance as HZ=1000 case.

8 GB transfer across an 80 ms RTT path with autotuning and no hystart:

i7test7% nuttcp -n8g -i1 192.168.1.18
   10.0000 MB /   1.00 sec =   83.8847 Mbps     0 retrans
  482.3125 MB /   1.00 sec = 4045.8172 Mbps     0 retrans
  863.2500 MB /   1.00 sec = 7241.4224 Mbps     0 retrans
  874.3750 MB /   1.00 sec = 7334.7304 Mbps     0 retrans
  855.0000 MB /   1.00 sec = 7172.3889 Mbps     0 retrans
  863.6250 MB /   1.00 sec = 7244.6840 Mbps     0 retrans
  875.0625 MB /   1.00 sec = 7340.5489 Mbps     0 retrans
  855.1875 MB /   1.00 sec = 7173.6390 Mbps     0 retrans
  863.8750 MB /   1.00 sec = 7246.9044 Mbps     0 retrans
  873.3125 MB /   1.00 sec = 7325.9788 Mbps     0 retrans

 8192.0000 MB /  10.99 sec = 6253.7478 Mbps 11 %TX 26 %RX 0 retrans 80.80 msRTT

Ramps up quickly to 7+ Gbps, then appears to stabilize at that
level, with no TCP retransmissions.  Performance is same as
with autotuning enabled, but less than using a manually set
100 MB socket buffer.  Same performance as HZ=1000 case.

8 GB transfer across an 80 ms RTT path with 100 MB socket buffer and no hystart:

i7test7% nuttcp -n8g -i1 -w100m 192.168.1.18
  103.8125 MB /   1.00 sec =  870.7945 Mbps     0 retrans
 1148.4375 MB /   1.00 sec = 9633.6860 Mbps     0 retrans
 1176.9375 MB /   1.00 sec = 9872.7291 Mbps     0 retrans
 1088.1250 MB /   1.00 sec = 9127.4342 Mbps    39 retrans
  171.0625 MB /   1.00 sec = 1435.1370 Mbps     0 retrans
  901.0625 MB /   1.00 sec = 7558.3275 Mbps     0 retrans
 1160.0625 MB /   1.00 sec = 9731.1831 Mbps     0 retrans
 1172.5625 MB /   1.00 sec = 9836.5508 Mbps     0 retrans
 1085.0625 MB /   1.00 sec = 9101.2174 Mbps    31 retrans
  150.3750 MB /   1.00 sec = 1261.5908 Mbps     2 retrans
   28.1875 MB /   1.00 sec =  236.4544 Mbps     0 retrans

 8192.0000 MB /  11.31 sec = 6077.0651 Mbps 14 %TX 29 %RX 72 retrans 80.82 msRTT

As in the HZ=1000 case, disabling hystart on a large RTT path
does not seem to play nice with a manually specified socket buffer,
resulting in TCP retransmissions that limit the effective network
performance.  Performance seems similar to the HZ=1000 case.

This is a repeatable phenomenon, but didn't seem quite as
variable as in the HZ=1000 case (but probably need a larger
number of repetitions to draw any firm conclusions about that).

i7test7% nuttcp -n8g -i1 -w100m 192.168.1.18
  103.4375 MB /   1.00 sec =  867.6472 Mbps     0 retrans
 1143.0625 MB /   1.00 sec = 9589.1347 Mbps     0 retrans
  629.4375 MB /   1.00 sec = 5280.0886 Mbps    24 retrans
  164.8750 MB /   1.00 sec = 1383.0759 Mbps     0 retrans
 1121.6250 MB /   1.00 sec = 9408.7878 Mbps     0 retrans
 1168.1250 MB /   1.00 sec = 9799.0309 Mbps     0 retrans
 1167.5000 MB /   1.00 sec = 9793.5725 Mbps     0 retrans
 1165.9375 MB /   1.00 sec = 9780.0841 Mbps     0 retrans
  959.8750 MB /   1.00 sec = 8052.4902 Mbps     9 retrans
  568.1250 MB /   1.00 sec = 4765.8065 Mbps     0 retrans

 8192.0000 MB /  10.03 sec = 6852.2803 Mbps 13 %TX 32 %RX 33 retrans 80.81 msRTT

And:

i7test7% nuttcp -n8g -i1 -w100m 192.168.1.18
  103.8125 MB /   1.00 sec =  870.8241 Mbps     0 retrans
 1148.8125 MB /   1.00 sec = 9636.9570 Mbps     0 retrans
 1177.3750 MB /   1.00 sec = 9876.4287 Mbps     0 retrans
 1177.4375 MB /   1.00 sec = 9877.0024 Mbps     0 retrans
  693.5000 MB /   1.00 sec = 5817.6335 Mbps    36 retrans
  263.4375 MB /   1.00 sec = 2209.7701 Mbps     0 retrans
 1137.3125 MB /   1.00 sec = 9540.7263 Mbps     0 retrans
 1169.9375 MB /   1.00 sec = 9814.2354 Mbps     0 retrans
 1168.6875 MB /   1.00 sec = 9803.7005 Mbps     0 retrans

 8192.0000 MB /   9.21 sec = 7460.8789 Mbps 14 %TX 34 %RX 36 retrans 80.81 msRTT

Re-enabling hystart immediately gives a clean test with no TCP retrans.

i7test7% nuttcp -n8g -i1 -w100m 192.168.1.18
  103.8125 MB /   1.00 sec =  870.8075 Mbps     0 retrans
 1072.3125 MB /   1.00 sec = 8995.0653 Mbps     0 retrans
 1089.4375 MB /   1.00 sec = 9139.0926 Mbps     0 retrans
 1093.1875 MB /   1.00 sec = 9170.0646 Mbps     0 retrans
 1095.5625 MB /   1.00 sec = 9190.3914 Mbps     0 retrans
 1095.5000 MB /   1.00 sec = 9189.8303 Mbps     0 retrans
 1097.6875 MB /   1.00 sec = 9207.8952 Mbps     0 retrans
 1104.1875 MB /   1.00 sec = 9262.5405 Mbps     0 retrans

 8192.0000 MB /   8.48 sec = 8104.4831 Mbps 15 %TX 38 %RX 0 retrans 80.77 msRTT

						-Bill



Previous HZ=1000 tests (with tcp_timestamps disabled):

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
