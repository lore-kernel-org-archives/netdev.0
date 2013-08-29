From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Thu, 29 Aug 2013 13:26:17 -0700
Message-ID: <1377807977.8277.40.camel@edumazet-glaptop>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	 <1377491162.8828.116.camel@edumazet-glaptop>
	 <1377607592.8828.149.camel@edumazet-glaptop>
	 <20130829.155131.1753610025310087003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:44310 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756365Ab3H2U0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:26:19 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so924139pdi.27
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 13:26:19 -0700 (PDT)
In-Reply-To: <20130829.155131.1753610025310087003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-29 at 15:51 -0400, David Miller wrote:

> Applied, please post a new copy of your accompanying packet scheduler.
> 
> Thanks.

Thanks David.

I am a bit puzzled by the caching of srtt in tcp metrics. We ten to
cache bufferbloated values that are almost useless.

On this 50ms RTT link, the syn/synack rtt was correctly sampled at 51
jiffies, but tcp_init_metrics() finds a very high srtt cached from
previous tcp flow, which ended its life with a huge cwin=327/srtt=1468
because of bufferbloat.

Since the new connexion starts with IW10, the estimated rate is slightly
wrong for the first ~10 incoming acks, before ewma converges to the
right value...

[ 4544.656476] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 51 sack_rtt 4294967295
[ 4544.656482] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 51 srtt 0
[ 4544.656496] TCP: sk ffff88085825d180 cwnd 10 packets 0 rate 231680000/srtt 408
[ 4544.707045] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 50 sack_rtt 4294967295
[ 4544.707051] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 50 srtt 1468
[ 4544.707055] TCP: sk ffff88085825d180 cwnd 11 packets 9 rate 254848000/srtt 1335
[ 4544.707067] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 50 sack_rtt 4294967295
[ 4544.707069] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 50 srtt 1335
[ 4544.707071] TCP: sk ffff88085825d180 cwnd 12 packets 10 rate 278016000/srtt 1219
[ 4544.707694] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 51 sack_rtt 4294967295
[ 4544.707699] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 51 srtt 1219
[ 4544.707703] TCP: sk ffff88085825d180 cwnd 13 packets 11 rate 301184000/srtt 1118
[ 4544.708324] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 52 sack_rtt 4294967295
[ 4544.708330] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 52 srtt 1118
[ 4544.708333] TCP: sk ffff88085825d180 cwnd 14 packets 12 rate 324352000/srtt 1031
[ 4544.708846] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 52 sack_rtt 4294967295
[ 4544.708851] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 52 srtt 1031
[ 4544.708855] TCP: sk ffff88085825d180 cwnd 15 packets 13 rate 347520000/srtt 955
[ 4544.709521] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 53 sack_rtt 4294967295
[ 4544.709526] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 53 srtt 955
[ 4544.709530] TCP: sk ffff88085825d180 cwnd 16 packets 14 rate 370688000/srtt 889
[ 4544.710103] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 53 sack_rtt 4294967295
[ 4544.710108] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 53 srtt 889
[ 4544.710111] TCP: sk ffff88085825d180 cwnd 17 packets 15 rate 393856000/srtt 831
[ 4544.710683] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 54 sack_rtt 4294967295
[ 4544.710688] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 54 srtt 831
[ 4544.710691] TCP: sk ffff88085825d180 cwnd 18 packets 16 rate 417024000/srtt 782
[ 4544.711210] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 55 sack_rtt 4294967295
[ 4544.711215] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 55 srtt 782
[ 4544.711219] TCP: sk ffff88085825d180 cwnd 19 packets 17 rate 440192000/srtt 740
[ 4544.711868] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 55 sack_rtt 4294967295
[ 4544.711873] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 55 srtt 740
[ 4544.711876] TCP: sk ffff88085825d180 cwnd 20 packets 18 rate 463360000/srtt 703
[ 4544.757576] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 51 sack_rtt 4294967295
[ 4544.757581] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 51 srtt 703
[ 4544.757585] TCP: sk ffff88085825d180 cwnd 21 packets 19 rate 486528000/srtt 667
[ 4544.757595] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 51 sack_rtt 4294967295
[ 4544.757597] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 51 srtt 667
[ 4544.757610] TCP: sk ffff88085825d180 cwnd 22 packets 20 rate 509696000/srtt 635
[ 4544.773527] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 67 sack_rtt 4294967295
[ 4544.773533] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 67 srtt 635
[ 4544.773536] TCP: sk ffff88085825d180 cwnd 23 packets 21 rate 532864000/srtt 623
[ 4544.773548] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 67 sack_rtt 4294967295
[ 4544.773560] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 67 srtt 623
[ 4544.773562] TCP: sk ffff88085825d180 cwnd 24 packets 22 rate 556032000/srtt 613
[ 4544.778208] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 71 sack_rtt 4294967295
[ 4544.778213] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 71 srtt 613
[ 4544.778216] TCP: sk ffff88085825d180 cwnd 25 packets 23 rate 579200000/srtt 608
[ 4544.778237] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 71 sack_rtt 4294967295
[ 4544.778238] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 71 srtt 608
[ 4544.778240] TCP: sk ffff88085825d180 cwnd 26 packets 24 rate 602368000/srtt 603
[ 4544.782776] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 74 sack_rtt 4294967295
[ 4544.782781] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 74 srtt 603
[ 4544.782785] TCP: sk ffff88085825d180 cwnd 27 packets 25 rate 625536000/srtt 602
[ 4544.782795] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 74 sack_rtt 4294967295
[ 4544.782808] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 74 srtt 602
...
Typical bufferbloat at the end of transfert :

[ 4547.051521] TCP: sk ffff88085825d180 cwnd 327 packets 3 rate 7575936000/srtt 1581
[ 4547.052722] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 198 sack_rtt 4294967295
[ 4547.052726] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 198 srtt 1581
[ 4547.052729] TCP: sk ffff88085825d180 cwnd 327 packets 1 rate 7575936000/srtt 1582
[ 4547.053315] TCP: tcp_ack_update_rtt sk ffff88085825d180 seq_rtt 198 sack_rtt 4294967295
[ 4547.053318] TCP: tcp_rtt_estimator sk ffff88085825d180 mrtt 198 srtt 1582
[ 4547.053321] TCP: sk ffff88085825d180 cwnd 327 packets 0 rate 7575936000/srtt 1583

Maybe we could instead store a value corrected by the sk_pacing_rate

rate = (big_cwin * mss) / big_srtt

stored_rtt = rate / (big_cwin * mss)
