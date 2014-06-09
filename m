From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: fixing TLP's FIN recovery
Date: Mon, 09 Jun 2014 11:33:12 -0700
Message-ID: <1402338792.3645.384.camel@edumazet-glaptop2.roam.corp.google.com>
References: <539319F6.2090907@cogentembedded.com>
	 <1402151680-11434-1-git-send-email-per.hurtig@kau.se>
	 <1402196305.3645.318.camel@edumazet-glaptop2.roam.corp.google.com>
	 <539413BA.7060903@kau.se>
	 <CAB_+Fg5=Z0wfaAZgUMXKttHKx9WoVLQv5ZqDeUQJmGA0LJTwPg@mail.gmail.com>
	 <5395B2FC.3070205@kau.se>
	 <1402324388.3645.359.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5395C7E9.4050406@kau.se>
	 <1402326259.3645.374.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5395D937.5060801@kau.se>
	 <1402330502.3645.378.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1402331047.3645.379.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>,
	Anna =?ISO-8859-1?Q?Brunstr=F6m?= <anna.brunstrom@kau.se>,
	mohammad.rajiullah@kau.se, Neal Cardwell <ncardwell@google.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Per Hurtig <per.hurtig@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:52539 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaFISdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 14:33:14 -0400
Received: by mail-pd0-f174.google.com with SMTP id r10so5104740pdi.19
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 11:33:13 -0700 (PDT)
In-Reply-To: <1402331047.3645.379.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-06-09 at 09:24 -0700, Eric Dumazet wrote:

> Hmm... We hit this point... This is embarrassing I guess.
> 
>        if (inet_csk(sk)->icsk_af_ops->rebuild_header(sk))
>                 return -EHOSTUNREACH; /* Routing failure or similar. */

False alarm. This was caused of route being dismantled at the end of the
test, and a dangling socket tried to retransmit.

The 25ms timer I had was caused by early retransmit (25 ms = RTT/4 in my
test), because only one packet was missing.

Following test runs fine, as 3 packets are missing.

// Establish a connection.
0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.000 setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
0.000 bind(3, ..., ...) = 0
0.000 listen(3, 1) = 0

0.100 < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
0.100 > S. 0:0(0) ack 1 <mss 1460,nop,nop,sackOK,nop,wscale 6>
0.200 < . 1:1(0) ack 1 win 257
0.200 accept(3, ..., ...) = 4

// Send 8 MSS.
0.200 write(4, ..., 8000) = 8000
+.000 > P. 1:8001(8000) ack 1
+.000   close(4) = 0
+.000 > F. 8001:8001(0) ack 1

// Receiver ACKs 5 packets
0.300 < . 1:1(0) ack 5001 win 257
// Check if TLP is triggering, even if last packet is a pure FIN
0.500 > F. 8001:8001(0) ack 1

0.610 < . 1:1(0) ack 5001 win 257 <sack 8001:8002,nop,nop>
0.610 > . 5001:6001(1000) ack 1
0.610 > . 6001:7001(1000) ack 1

0.710 < . 1:1(0) ack 7001 win 257 <sack 8001:8002,nop,nop>
0.710 > P. 7001:8001(1000) ack 1

0.810 < . 1:1(0) ack 8002 win 257
