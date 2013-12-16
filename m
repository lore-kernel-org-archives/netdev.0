From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] tcp: use zero-window when free_space is low
Date: Mon, 16 Dec 2013 16:51:58 +0100
Message-ID: <20131216155158.GB3759@breakpoint.cc>
References: <1387192557-9816-1-git-send-email-fw@strlen.de>
 <1387201280.19078.223.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48237 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754651Ab3LPPwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:52:00 -0500
Content-Disposition: inline
In-Reply-To: <1387201280.19078.223.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

Hi Eric,

> On Mon, 2013-12-16 at 12:15 +0100, Florian Westphal wrote:
> > Currently the kernel tries to announce a zero window when free_space
> > is below the current receiver mss estimate.
> > 
> > When a sender is transmitting small packets, the receiver might be
> > unable to shrink the receive window, because
> > a) we cannot withdraw already-commited receive window, and,
> > b) we have to round the current rwin up to a multiple of the wscale factor,
> >    else we would shrink the current window.
> > 
> > This causes the receive buffer to fill up until the rmem limit is hit.
> > When this happens, we start dropping packets.
> 
> I do not really understand the issue.
> Do you have a packetdrill test to demonstrate it ?

I am a moron and forgot to stress one crucial bit of information:
_slow_reader_ (or a reader that doesn't read from socket at all!)

I am not very familiar with packetdrill, it would look something like

0.000 socket(..., SOCK_STREAM, IPPROTO_TCP) = 3
0.100...0.200 connect(3, ..., ...) = 0

0.100 > S 0:0(0) <mss 1460,sackOK,TS val 100 ecr 0,nop,wscale 7>
0.200 < S. 0:0(0) ack 1 win 32792 <mss 1460,sackOK,TS val 100 ecr 100,nop,wscale 7>
0.200 > . 1:1(0) ack 1 <nop,nop,TS val 100 ecr 100>

0.300 write(3, ..., 23) = 23
0.310 write(3, ..., 23) = 23
0.320 write(3, ..., 23) = 23
0.330 write(3, ..., 23) = 23
0.340 write(3, ..., 23) = 23
0.350 write(3, ..., 23) = 23
.. repeat indefinitely ..

Reproducer (non-packetdrill):

On server:
$ nc -l -p 12345
<suspend it: CTRL-Z>

Client:
#!/usr/bin/env python

import socket
import time

sock = socket.socket()
sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
sock.connect(("192.168.4.1", 12345));
while True:
   sock.send('A' * 23)
   time.sleep(0.005)

socket buffer on server-side will grow until tcp_rmem[2] is hit,
at which point the client rexmits data until -EDTIMEOUT.

Code flow on server side is:
tcp_data_queue -> tcp_try_rmem_schedule -> \
	tcp_prune_queue -> tcp_clamp_window()

tcp_clamp_window will then grow sk->sk_rcvbuf, up until it eventually
hits tcp_rmem[2]

Many thanks for looking into this Eric!
