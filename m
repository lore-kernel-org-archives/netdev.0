From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 12:29:38 -0700
Message-ID: <1366313378.3205.75.camel@edumazet-glaptop>
References: <1366303971.3205.62.camel@edumazet-glaptop>
	 <20130418104510.3624457a@nehalam.linuxnetplumber.net>
	 <1366308381.3205.66.camel@edumazet-glaptop>
	 <20130418181949.GA10776@virgo.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:47697 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935794Ab3DRT3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 15:29:41 -0400
Received: by mail-pd0-f177.google.com with SMTP id u11so1732757pdi.8
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 12:29:41 -0700 (PDT)
In-Reply-To: <20130418181949.GA10776@virgo.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 20:19 +0200, Hagen Paul Pfeifer wrote:
> * Eric Dumazet | 2013-04-18 11:06:21 [-0700]:
> 
> >On Thu, 2013-04-18 at 10:45 -0700, Stephen Hemminger wrote:
> >> On Thu, 18 Apr 2013 09:52:51 -0700
> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> 
> >> > From: Eric Dumazet <edumazet@google.com>
> >> > 
> >> > Host queues (Qdisc + NIC) can hold packets so long that TCP can
> >> > eventually retransmit a packet before the first transmit even left
> >> > the host.
> 
> Just out of curiosity: do you see effects of commit 9ad7c049 (initRTO from
> 3secs to 1sec) and a long standing queue? (with no path metric, rtt in
> particular)
> 

I have no particular data for the initRTO change.

Interesting thing is that we send a SYN-ACK for every SYN we receive.
So if a client sends 4 SYN, we'll going to send 4 SYN-ACK, regardless of
the time of last sent SYN-ACK...

Here is an interesting study case.

12:02:43.484175 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [S], seq 3414870221, win 14600, options [mss 1460,sackOK,TS val 4294775698 ecr 0,nop,wscale 6], length 0
12:02:43.484201 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14218683 ecr 4294775698,no
p,wscale 6], length 0
12:02:44.884382 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14220084 ecr 4294775698,no
p,wscale 6], length 0
12:02:45.470224 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [S], seq 3414870221, win 14600, options [mss 1460,sackOK,TS val 4294776700 ecr 0,nop,wscale 6], length 0
12:02:45.470252 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14220669 ecr 4294775698,no
p,wscale 6], length 0
12:02:46.762462 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 0
12:02:46.762989 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 1:1449, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.763019 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 1449, win 272, options [nop,nop,TS val 14221962 ecr 4294777094], length 0
12:02:46.775104 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 1449:2897, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.775138 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 2897, win 317, options [nop,nop,TS val 14221974 ecr 4294777094], length 0
12:02:46.787215 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 2897:4345, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.787244 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 4345, win 362, options [nop,nop,TS val 14221986 ecr 4294777094], length 0
12:02:46.799326 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 4345:5793, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.799357 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 5793, win 408, options [nop,nop,TS val 14221998 ecr 4294777094], length 0
12:02:46.811438 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 5793:7241, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.811465 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 7241, win 453, options [nop,nop,TS val 14222010 ecr 4294777094], length 0
12:02:46.823549 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [P.], seq 7241:8689, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.823575 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 8689, win 498, options [nop,nop,TS val 14222023 ecr 4294777094], length 0
12:02:46.835662 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 8689:10137, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.835694 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 10137, win 543, options [nop,nop,TS val 14222035 ecr 4294777094], length 0
12:02:46.847775 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 10137:11585, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.847801 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 11585, win 589, options [nop,nop,TS val 14222047 ecr 4294777094], length 0
12:02:46.859889 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 11585:13033, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.859916 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 13033, win 634, options [nop,nop,TS val 14222059 ecr 4294777094], length 0
12:02:46.871998 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 13033:14481, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
12:02:46.872025 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 14481, win 660, options [nop,nop,TS val 14222071 ecr 4294777094], length 0
12:02:49.362204 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294778499 ecr 14218683], length 0
12:02:50.415265 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294779084 ecr 14218683], length 0

We can see the last two packets in this trace being flagged as
TCPSYNChallenge/TCPChallengeACK, because we react to the two extra
SYN-ACK we receive, after queueing the first 10 packets of data.
