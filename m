From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TSO packets automatic sizing
Date: Sat, 24 Aug 2013 11:56:34 -0700
Message-ID: <1377370594.8828.72.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Van Jacobson <vanj@google.com>,
	Tom Herbert <therbert@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:50798 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353Ab3HXS4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Aug 2013 14:56:36 -0400
Received: by mail-pa0-f44.google.com with SMTP id fz6so1905111pac.17
        for <netdev@vger.kernel.org>; Sat, 24 Aug 2013 11:56:35 -0700 (PDT)
In-Reply-To: <CADVnQymvQz67k1_f4rRJxPVUFWL=rM5vnT-ZO1VPSxN-E0uzDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-23 at 23:17 -0400, Neal Cardwell wrote:

> I love this! Can't wait to play with it.
> 

Totally agree ;)

> Rather than implicitly initializing sk_pacing_rate to 0, I'd suggest
> maybe initializing sk_pacing_rate to a value just high enough
> (TCP_INIT_CWND * mss / 1ms?) so that in the first transmit the
> connection can (as it does today) construct a single TSO jumbogram of
> TCP_INIT_CWND segments and send that in a single trip down through the
> stack. Hopefully this should keep CPU usage advantages of TSO for
> servers that spend most of their time sending replies that are 10MSS
> or less, while not making the on-the-wire behavior much burstier than
> it would be with the patch as it stands.
> 

Yes, this sounds an interesting idea. 

Problem is that if the application does a sendmsg( 1 Mbytes) right after
accept(), we'll cook 14KB TSO packets and are back to initial problem.

Quite frankly TSO advantage for servers sending replies that are 10MSS
or less is thin, because we spend most of cpu cycles in socket
setup/dismantle and ACK processing.

TSO is a win for sockets sending say more than 100KB, or even 1MB



> I am wondering about the aspect of the patch that sets sk_pacing_rate
> to 2x the current rate in tcp_rtt_estimator and then just has to
> divide by 2 again in tcp_xmit_size_goal(). It seems the 2x factor is
> natural in the packet scheduler context, but at first glance it feels
> to me like the multiplication by 2 should be an internal detail of the
> optional scheduler, not part of the sk_pacing_rate interface between
> the TCP and scheduling layer.

I would like to keep FQ as simple as possible, and let the transport
decide for appropriate strategy.

TCP should be the appropriate place to decide on precise delays between
packets. Packet scheduler will only execute the orders coming from TCP.

In this patch, I chose a 200% factor that is conservative enough to make
sure there will be no change in the ramp up. It can later be changed to
get finer control.

> 
> One thing I noticed: something about how the current patch shakes out
> causes a basic 10-MSS transfer to take an extra RTT, due to the last
> 2-segment packet having to wait for an ACK:
> 
> # cat iw10-base-case.pkt
> 0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
> 0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
> 0.000 bind(3, ..., ...) = 0
> 0.000 listen(3, 1) = 0
> 
> 0.100 < S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
> 0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
> 0.200 < . 1:1(0) ack 1 win 257
> 0.200 accept(3, ..., ...) = 4
> 
> 0.200 write(4, ..., 14600) = 14600
> 0.300 < . 1:1(0) ack 11681 win 257
> 
> ->
> 
> # ./packetdrill iw10-base-case.pkt
> 0.701287 cli > srv: S 0:0(0) win 32792 <mss 1460,sackOK,nop,nop,nop,wscale 7>
> 0.701367 srv > cli: S 2822928622:2822928622(0) ack 1 win 29200 <mss
> 1460,nop,nop,sackOK,nop,wscale 6>
> 0.801276 cli > srv: . ack 1 win 257
> 0.801365 srv > cli: . 1:2921(2920) ack 1 win 457
> 0.801376 srv > cli: . 2921:5841(2920) ack 1 win 457
> 0.801382 srv > cli: . 5841:8761(2920) ack 1 win 457
> 0.801386 srv > cli: . 8761:11681(2920) ack 1 win 457
> 0.901284 cli > srv: . ack 11681 win 257
> 0.901308 srv > cli: P 11681:14601(2920) ack 1 win 457
> 
> I'd try to isolate the exact cause, but it's a bit late in the evening
> for me to track this down at this point, and I'll be offline tomorrow.

Interesting, but I do not see this on normal ethernet device (bnx2x in
the following traces)

Trying different min_tso_segs exhibits expected different behavior (10
first MSS (14480 bytes of payload) sent in the same ms, no need to wait
an ACK. (RTT = 50ms in this setup)

echo 1 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:40:35.333703 IP 10.246.17.83.50336 > 10.246.17.84.50267: S 3924987356:3924987356(0) win 29200 <mss 1460,sackOK,timestamp 64807623 0,nop,wscale 6>
10:40:35.383835 IP 10.246.17.84.50267 > 10.246.17.83.50336: S 151800535:151800535(0) ack 3924987357 win 28960 <mss 1460,sackOK,timestamp 137049930 64807623,nop,wscale 7>
10:40:35.383868 IP 10.246.17.83.50336 > 10.246.17.84.50267: . ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383936 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 1:1449(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383943 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 1449:2897(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383948 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 2897:4345(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383952 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 4345:5793(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383957 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 5793:7241(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383961 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 7241:8689(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383965 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 8689:10137(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383968 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 10137:11585(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383972 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 11585:13033(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.383975 IP 10.246.17.83.50336 > 10.246.17.84.50267: . 13033:14481(1448) ack 1 win 457 <nop,nop,timestamp 64807673 137049930>
10:40:35.434061 IP 10.246.17.84.50267 > 10.246.17.83.50336: . ack 1449 win 249 <nop,nop,timestamp 137049981 64807673>

echo 2 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:45:24.280183 IP 10.246.17.83.36666 > 10.246.17.84.40648: S 1657754774:1657754774(0) win 29200 <mss 1460,sackOK,timestamp 65096569 0,nop,wscale 6>
10:45:24.330302 IP 10.246.17.84.40648 > 10.246.17.83.36666: S 362153932:362153932(0) ack 1657754775 win 28960 <mss 1460,sackOK,timestamp 137338877 65096569,nop,wscale 7>
10:45:24.330384 IP 10.246.17.83.36666 > 10.246.17.84.40648: . ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.330477 IP 10.246.17.83.36666 > 10.246.17.84.40648: . 1:2897(2896) ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.330497 IP 10.246.17.83.36666 > 10.246.17.84.40648: . 2897:5793(2896) ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.330501 IP 10.246.17.83.36666 > 10.246.17.84.40648: . 5793:8689(2896) ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.330665 IP 10.246.17.83.36666 > 10.246.17.84.40648: . 8689:11585(2896) ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.330674 IP 10.246.17.83.36666 > 10.246.17.84.40648: . 11585:14481(2896) ack 1 win 457 <nop,nop,timestamp 65096620 137338877>
10:45:24.380592 IP 10.246.17.84.40648 > 10.246.17.83.36666: . ack 1449 win 249 <nop,nop,timestamp 137338927 65096620>

echo 3 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:48:51.558662 IP 10.246.17.83.44835 > 10.246.17.84.56145: S 2572155347:2572155347(0) win 29200 <mss 1460,sackOK,timestamp 65303848 0,nop,wscale 6>
10:48:51.608797 IP 10.246.17.84.56145 > 10.246.17.83.44835: S 2206641454:2206641454(0) ack 2572155348 win 28960 <mss 1460,sackOK,timestamp 137546155 65303848,nop,wscale 7>
10:48:51.608824 IP 10.246.17.83.44835 > 10.246.17.84.56145: . ack 1 win 457 <nop,nop,timestamp 65303898 137546155>
10:48:51.608901 IP 10.246.17.83.44835 > 10.246.17.84.56145: . 1:4345(4344) ack 1 win 457 <nop,nop,timestamp 65303898 137546155>
10:48:51.608911 IP 10.246.17.83.44835 > 10.246.17.84.56145: . 4345:8689(4344) ack 1 win 457 <nop,nop,timestamp 65303898 137546155>
10:48:51.608917 IP 10.246.17.83.44835 > 10.246.17.84.56145: . 8689:13033(4344) ack 1 win 457 <nop,nop,timestamp 65303898 137546155>
10:48:51.608927 IP 10.246.17.83.44835 > 10.246.17.84.56145: . 13033:14481(1448) ack 1 win 457 <nop,nop,timestamp 65303898 137546155>
10:48:51.659018 IP 10.246.17.84.56145 > 10.246.17.83.44835: . ack 1449 win 249 <nop,nop,timestamp 137546206 65303898>
10:48:51.659102 IP 10.246.17.83.44835 > 10.246.17.84.56145: . 14481:17377(2896) ack 1 win 457 <nop,nop,timestamp 65303948 137546206>
10:48:51.659019 IP 10.246.17.84.56145 > 10.246.17.83.44835: . ack 2897 win 272 <nop,nop,timestamp 137546206 65303898>
10:48:51.659113 IP 10.246.17.83.44835 > 10.246.17.84.56145: P 17377:18825(1448) ack 1 win 457 <nop,nop,timestamp 65303948 137546206>
10:48:51.659124 IP 10.246.17.84.56145 > 10.246.17.83.44835: . ack 4345 win 295 <nop,nop,timestamp 137546206 65303898>

echo 4 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:49:41.553016 IP 10.246.17.83.51499 > 10.246.17.84.37071: S 770187706:770187706(0) win 29200 <mss 1460,sackOK,timestamp 65353842 0,nop,wscale 6>
10:49:41.603149 IP 10.246.17.84.37071 > 10.246.17.83.51499: S 3342827191:3342827191(0) ack 770187707 win 28960 <mss 1460,sackOK,timestamp 137596150 65353842,nop,wscale 7>
10:49:41.603223 IP 10.246.17.83.51499 > 10.246.17.84.37071: . ack 1 win 457 <nop,nop,timestamp 65353892 137596150>
10:49:41.603307 IP 10.246.17.83.51499 > 10.246.17.84.37071: . 1:5793(5792) ack 1 win 457 <nop,nop,timestamp 65353893 137596150>
10:49:41.603317 IP 10.246.17.83.51499 > 10.246.17.84.37071: . 5793:11585(5792) ack 1 win 457 <nop,nop,timestamp 65353893 137596150>
10:49:41.603329 IP 10.246.17.83.51499 > 10.246.17.84.37071: . 11585:14481(2896) ack 1 win 457 <nop,nop,timestamp 65353893 137596150>
10:49:41.653448 IP 10.246.17.84.37071 > 10.246.17.83.51499: . ack 1449 win 249 <nop,nop,timestamp 137596200 65353893>
10:49:41.653531 IP 10.246.17.83.51499 > 10.246.17.84.37071: . 14481:17377(2896) ack 1 win 457 <nop,nop,timestamp 65353943 137596200>
10:49:41.653450 IP 10.246.17.84.37071 > 10.246.17.83.51499: . ack 2897 win 272 <nop,nop,timestamp 137596200 65353893>
10:49:41.653618 IP 10.246.17.83.51499 > 10.246.17.84.37071: . 17377:20273(2896) ack 1 win 457 <nop,nop,timestamp 65353943 137596200>

echo 5 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:50:33.626270 IP 10.246.17.83.52633 > 10.246.17.84.33693: S 1635294551:1635294551(0) win 29200 <mss 1460,sackOK,timestamp 65405916 0,nop,wscale 6>
10:50:33.676407 IP 10.246.17.84.33693 > 10.246.17.83.52633: S 1023650170:1023650170(0) ack 1635294552 win 28960 <mss 1460,sackOK,timestamp 137648223 65405916,nop,wscale 7>
10:50:33.676489 IP 10.246.17.83.52633 > 10.246.17.84.33693: . ack 1 win 457 <nop,nop,timestamp 65405966 137648223>
10:50:33.676571 IP 10.246.17.83.52633 > 10.246.17.84.33693: . 1:7241(7240) ack 1 win 457 <nop,nop,timestamp 65405966 137648223>
10:50:33.676578 IP 10.246.17.83.52633 > 10.246.17.84.33693: . 7241:14481(7240) ack 1 win 457 <nop,nop,timestamp 65405966 137648223>
10:50:33.726706 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 1449 win 249 <nop,nop,timestamp 137648273 65405966>
10:50:33.726707 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 2897 win 272 <nop,nop,timestamp 137648273 65405966>
10:50:33.726792 IP 10.246.17.83.52633 > 10.246.17.84.33693: . 14481:20273(5792) ack 1 win 457 <nop,nop,timestamp 65406016 137648273>
10:50:33.726781 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 4345 win 295 <nop,nop,timestamp 137648273 65405966>
10:50:33.726986 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 5793 win 317 <nop,nop,timestamp 137648274 65405966>
10:50:33.727101 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 7241 win 340 <nop,nop,timestamp 137648274 65405966>
10:50:33.727117 IP 10.246.17.83.52633 > 10.246.17.84.33693: P 20273:27513(7240) ack 1 win 457 <nop,nop,timestamp 65406016 137648274>
10:50:33.727258 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 8689 win 340 <nop,nop,timestamp 137648274 65405966>
10:50:33.727408 IP 10.246.17.84.33693 > 10.246.17.83.52633: . ack 10137 win 340 <nop,nop,timestamp 137648274 65405966>

echo 6 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:51:23.295063 IP 10.246.17.83.49096 > 10.246.17.84.43872: S 1841824181:1841824181(0) win 29200 <mss 1460,sackOK,timestamp 65455584 0,nop,wscale 6>
10:51:23.345207 IP 10.246.17.84.43872 > 10.246.17.83.49096: S 2837501410:2837501410(0) ack 1841824182 win 28960 <mss 1460,sackOK,timestamp 137697892 65455584,nop,wscale 7>
10:51:23.345237 IP 10.246.17.83.49096 > 10.246.17.84.43872: . ack 1 win 457 <nop,nop,timestamp 65455635 137697892>
10:51:23.345311 IP 10.246.17.83.49096 > 10.246.17.84.43872: . 1:8689(8688) ack 1 win 457 <nop,nop,timestamp 65455635 137697892>
10:51:23.345330 IP 10.246.17.83.49096 > 10.246.17.84.43872: . 8689:14481(5792) ack 1 win 457 <nop,nop,timestamp 65455635 137697892>
10:51:23.395453 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 1449 win 249 <nop,nop,timestamp 137697942 65455635>
10:51:23.395454 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 2897 win 272 <nop,nop,timestamp 137697942 65455635>
10:51:23.395544 IP 10.246.17.83.49096 > 10.246.17.84.43872: . 14481:20273(5792) ack 1 win 457 <nop,nop,timestamp 65455685 137697942>
10:51:23.395533 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 4345 win 295 <nop,nop,timestamp 137697942 65455635>
10:51:23.395631 IP 10.246.17.83.49096 > 10.246.17.84.43872: . 20273:23169(2896) ack 1 win 457 <nop,nop,timestamp 65455685 137697942>
10:51:23.395746 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 5793 win 317 <nop,nop,timestamp 137697942 65455635>
10:51:23.395854 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 7241 win 340 <nop,nop,timestamp 137697943 65455635>
10:51:23.396049 IP 10.246.17.84.43872 > 10.246.17.83.49096: . ack 8689 win 340 <nop,nop,timestamp 137697943 65455635>
10:51:23.396199 IP 10.246.17.83.49096 > 10.246.17.84.43872: P 23169:31857(8688) ack 1 win 457 <nop,nop,timestamp 65455685 137697943>

echo 7 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:51:58.219334 IP 10.246.17.83.58882 > 10.246.17.84.41983: S 3763353310:3763353310(0) win 29200 <mss 1460,sackOK,timestamp 65490509 0,nop,wscale 6>
10:51:58.269455 IP 10.246.17.84.41983 > 10.246.17.83.58882: S 1445588492:1445588492(0) ack 3763353311 win 28960 <mss 1460,sackOK,timestamp 137732816 65490509,nop,wscale 7>
10:51:58.269536 IP 10.246.17.83.58882 > 10.246.17.84.41983: . ack 1 win 457 <nop,nop,timestamp 65490559 137732816>
10:51:58.269634 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 1:10137(10136) ack 1 win 457 <nop,nop,timestamp 65490559 137732816>
10:51:58.269646 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 10137:14481(4344) ack 1 win 457 <nop,nop,timestamp 65490559 137732816>
10:51:58.319765 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 1449 win 249 <nop,nop,timestamp 137732866 65490559>
10:51:58.319846 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 14481:17377(2896) ack 1 win 457 <nop,nop,timestamp 65490609 137732866>
10:51:58.319767 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 2897 win 272 <nop,nop,timestamp 137732866 65490559>
10:51:58.319843 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 4345 win 295 <nop,nop,timestamp 137732867 65490559>
10:51:58.319911 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 17377:23169(5792) ack 1 win 457 <nop,nop,timestamp 65490609 137732867>
10:51:58.320068 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 5793 win 317 <nop,nop,timestamp 137732867 65490559>
10:51:58.320180 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 7241 win 340 <nop,nop,timestamp 137732867 65490559>
10:51:58.320287 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 8689 win 340 <nop,nop,timestamp 137732867 65490559>
10:51:58.320295 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 23169:31857(8688) ack 1 win 457 <nop,nop,timestamp 65490610 137732867>
10:51:58.320496 IP 10.246.17.84.41983 > 10.246.17.83.58882: . ack 10137 win 340 <nop,nop,timestamp 137732867 65490559>
10:51:58.320513 IP 10.246.17.83.58882 > 10.246.17.84.41983: . 31857:33305(1448) ack 1 win 457 <nop,nop,timestamp 65490610 137732867>

echo 8 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:52:50.398941 IP 10.246.17.83.32908 > 10.246.17.84.65099: S 678482142:678482142(0) win 29200 <mss 1460,sackOK,timestamp 65542688 0,nop,wscale 6>
10:52:50.449061 IP 10.246.17.84.65099 > 10.246.17.83.32908: S 3229813359:3229813359(0) ack 678482143 win 28960 <mss 1460,sackOK,timestamp 137784996 65542688,nop,wscale 7>
10:52:50.449146 IP 10.246.17.83.32908 > 10.246.17.84.65099: . ack 1 win 457 <nop,nop,timestamp 65542738 137784996>
10:52:50.449258 IP 10.246.17.83.32908 > 10.246.17.84.65099: . 1:11585(11584) ack 1 win 457 <nop,nop,timestamp 65542739 137784996>
10:52:50.449384 IP 10.246.17.83.32908 > 10.246.17.84.65099: . 11585:14481(2896) ack 1 win 457 <nop,nop,timestamp 65542739 137784996>
10:52:50.499379 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 1449 win 249 <nop,nop,timestamp 137785046 65542739>
10:52:50.499462 IP 10.246.17.83.32908 > 10.246.17.84.65099: . 14481:17377(2896) ack 1 win 457 <nop,nop,timestamp 65542789 137785046>
10:52:50.499381 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 2897 win 272 <nop,nop,timestamp 137785046 65542739>
10:52:50.499552 IP 10.246.17.83.32908 > 10.246.17.84.65099: . 17377:20273(2896) ack 1 win 457 <nop,nop,timestamp 65542789 137785046>
10:52:50.499552 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 4345 win 295 <nop,nop,timestamp 137785046 65542739>
10:52:50.499661 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 5793 win 317 <nop,nop,timestamp 137785046 65542739>
10:52:50.499806 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 7241 win 340 <nop,nop,timestamp 137785046 65542739>
10:52:50.499845 IP 10.246.17.83.32908 > 10.246.17.84.65099: . 20273:28961(8688) ack 1 win 457 <nop,nop,timestamp 65542789 137785046>
10:52:50.500006 IP 10.246.17.84.65099 > 10.246.17.83.32908: . ack 8689 win 340 <nop,nop,timestamp 137785047 65542739>

echo 9 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:53:31.504788 IP 10.246.17.83.59687 > 10.246.17.84.38716: S 1238515537:1238515537(0) win 29200 <mss 1460,sackOK,timestamp 65583794 0,nop,wscale 6>
10:53:31.554898 IP 10.246.17.84.38716 > 10.246.17.83.59687: S 667062900:667062900(0) ack 1238515538 win 28960 <mss 1460,sackOK,timestamp 137826102 65583794,nop,wscale 7>
10:53:31.554973 IP 10.246.17.83.59687 > 10.246.17.84.38716: . ack 1 win 457 <nop,nop,timestamp 65583844 137826102>
10:53:31.555050 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 1:13033(13032) ack 1 win 457 <nop,nop,timestamp 65583844 137826102>
10:53:31.555072 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 13033:14481(1448) ack 1 win 457 <nop,nop,timestamp 65583844 137826102>
10:53:31.605154 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 1449 win 249 <nop,nop,timestamp 137826152 65583844>
10:53:31.605235 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 14481:17377(2896) ack 1 win 457 <nop,nop,timestamp 65583895 137826152>
10:53:31.605156 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 2897 win 272 <nop,nop,timestamp 137826152 65583844>
10:53:31.605293 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 4345 win 295 <nop,nop,timestamp 137826152 65583844>
10:53:31.605325 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 17377:23169(5792) ack 1 win 457 <nop,nop,timestamp 65583895 137826152>
10:53:31.605461 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 5793 win 317 <nop,nop,timestamp 137826152 65583844>
10:53:31.605599 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 7241 win 340 <nop,nop,timestamp 137826152 65583844>
10:53:31.605750 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 8689 win 340 <nop,nop,timestamp 137826152 65583844>
10:53:31.605834 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 23169:31857(8688) ack 1 win 457 <nop,nop,timestamp 65583895 137826152>
10:53:31.605899 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 10137 win 340 <nop,nop,timestamp 137826153 65583844>
10:53:31.606055 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 11585 win 340 <nop,nop,timestamp 137826153 65583844>
10:53:31.606155 IP 10.246.17.83.59687 > 10.246.17.84.38716: . 31857:36201(4344) ack 1 win 457 <nop,nop,timestamp 65583895 137826153>
10:53:31.606157 IP 10.246.17.84.38716 > 10.246.17.83.59687: . ack 13033 win 340 <nop,nop,timestamp 137826153 65583844>

echo 10 >/proc/sys/net/ipv4/tcp_min_tso_segs

10:54:15.974831 IP 10.246.17.83.53733 > 10.246.17.84.34163: S 690526362:690526362(0) win 29200 <mss 1460,sackOK,timestamp 65628264 0,nop,wscale 6>
10:54:16.024978 IP 10.246.17.84.34163 > 10.246.17.83.53733: S 1914393851:1914393851(0) ack 690526363 win 28960 <mss 1460,sackOK,timestamp 137870572 65628264,nop,wscale 7>
10:54:16.025047 IP 10.246.17.83.53733 > 10.246.17.84.34163: . ack 1 win 457 <nop,nop,timestamp 65628314 137870572>
10:54:16.025132 IP 10.246.17.83.53733 > 10.246.17.84.34163: . 1:14481(14480) ack 1 win 457 <nop,nop,timestamp 65628314 137870572>
10:54:16.075247 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 1449 win 249 <nop,nop,timestamp 137870622 65628314>
10:54:16.075249 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 2897 win 272 <nop,nop,timestamp 137870622 65628314>
10:54:16.075334 IP 10.246.17.83.53733 > 10.246.17.84.34163: . 14481:20273(5792) ack 1 win 457 <nop,nop,timestamp 65628365 137870622>
10:54:16.075452 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 4345 win 295 <nop,nop,timestamp 137870622 65628314>
10:54:16.075570 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 5793 win 317 <nop,nop,timestamp 137870622 65628314>
10:54:16.075674 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 7241 win 340 <nop,nop,timestamp 137870622 65628314>
10:54:16.075698 IP 10.246.17.83.53733 > 10.246.17.84.34163: . 20273:28961(8688) ack 1 win 457 <nop,nop,timestamp 65628365 137870622>
10:54:16.075833 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 8689 win 340 <nop,nop,timestamp 137870622 65628314>
10:54:16.075990 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 10137 win 340 <nop,nop,timestamp 137870623 65628314>
10:54:16.076116 IP 10.246.17.83.53733 > 10.246.17.84.34163: . 28961:34753(5792) ack 1 win 457 <nop,nop,timestamp 65628365 137870623>
10:54:16.076096 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 11585 win 340 <nop,nop,timestamp 137870623 65628314>
10:54:16.076291 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 13033 win 340 <nop,nop,timestamp 137870623 65628314>
10:54:16.076435 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 14481 win 340 <nop,nop,timestamp 137870623 65628314>
10:54:16.125492 IP 10.246.17.84.34163 > 10.246.17.83.53733: . ack 15929 win 340 <nop,nop,timestamp 137870672 65628365>
10:54:16.125569 IP 10.246.17.83.53733 > 10.246.17.84.34163: . 34753:46337(11584) ack 1 win 457 <nop,nop,timestamp 65628415 137870672>
