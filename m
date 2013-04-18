From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 22:26:55 +0200
Message-ID: <20130418202655.GD16841@virgo.local>
References: <1366303971.3205.62.camel@edumazet-glaptop>
 <20130418104510.3624457a@nehalam.linuxnetplumber.net>
 <1366308381.3205.66.camel@edumazet-glaptop>
 <20130418181949.GA10776@virgo.local>
 <1366313378.3205.75.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54174 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936377Ab3DRU1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 16:27:03 -0400
Content-Disposition: inline
In-Reply-To: <1366313378.3205.75.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet | 2013-04-18 12:29:38 [-0700]:

>I have no particular data for the initRTO change.
>
>Interesting thing is that we send a SYN-ACK for every SYN we receive.
>So if a client sends 4 SYN, we'll going to send 4 SYN-ACK, regardless of
>the time of last sent SYN-ACK...

I see, one question: should that not be addressed on the sender side? Trace
smells like a datacenter setup with a low RTT and a small init RTO where the
last-time-syn-ack-timestamp guard makes sense. Hopefully Yuchung's patch keep
networks with low bandwidth of a few kbits and a rtt > 1 seconds in mind.

>Here is an interesting study case.
>
>12:02:43.484175 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [S], seq 3414870221, win 14600, options [mss 1460,sackOK,TS val 4294775698 ecr 0,nop,wscale 6], length 0
>12:02:43.484201 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14218683 ecr 4294775698,no
>p,wscale 6], length 0
>12:02:44.884382 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14220084 ecr 4294775698,no
>p,wscale 6], length 0
>12:02:45.470224 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [S], seq 3414870221, win 14600, options [mss 1460,sackOK,TS val 4294776700 ecr 0,nop,wscale 6], length 0
>12:02:45.470252 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [S.], seq 3173332093, ack 3414870222, win 14480, options [mss 1460,sackOK,TS val 14220669 ecr 4294775698,no
>p,wscale 6], length 0
>12:02:46.762462 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 0
>12:02:46.762989 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 1:1449, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.763019 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 1449, win 272, options [nop,nop,TS val 14221962 ecr 4294777094], length 0
>12:02:46.775104 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 1449:2897, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.775138 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 2897, win 317, options [nop,nop,TS val 14221974 ecr 4294777094], length 0
>12:02:46.787215 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 2897:4345, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.787244 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 4345, win 362, options [nop,nop,TS val 14221986 ecr 4294777094], length 0
>12:02:46.799326 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 4345:5793, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.799357 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 5793, win 408, options [nop,nop,TS val 14221998 ecr 4294777094], length 0
>12:02:46.811438 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 5793:7241, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.811465 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 7241, win 453, options [nop,nop,TS val 14222010 ecr 4294777094], length 0
>12:02:46.823549 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [P.], seq 7241:8689, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.823575 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 8689, win 498, options [nop,nop,TS val 14222023 ecr 4294777094], length 0
>12:02:46.835662 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 8689:10137, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.835694 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 10137, win 543, options [nop,nop,TS val 14222035 ecr 4294777094], length 0
>12:02:46.847775 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 10137:11585, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.847801 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 11585, win 589, options [nop,nop,TS val 14222047 ecr 4294777094], length 0
>12:02:46.859889 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 11585:13033, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.859916 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 13033, win 634, options [nop,nop,TS val 14222059 ecr 4294777094], length 0
>12:02:46.871998 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], seq 13033:14481, ack 1, win 229, options [nop,nop,TS val 4294777094 ecr 14218683], length 1448
>12:02:46.872025 IP 7.7.7.84.51407 > 7.7.7.83.49489: Flags [.], ack 14481, win 660, options [nop,nop,TS val 14222071 ecr 4294777094], length 0
>12:02:49.362204 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294778499 ecr 14218683], length 0
>12:02:50.415265 IP 7.7.7.83.49489 > 7.7.7.84.51407: Flags [.], ack 1, win 229, options [nop,nop,TS val 4294779084 ecr 14218683], length 0
>
>We can see the last two packets in this trace being flagged as
>TCPSYNChallenge/TCPChallengeACK, because we react to the two extra
>SYN-ACK we receive, after queueing the first 10 packets of data.
