From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Wed, 31 Dec 2008 12:38:24 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812311200570.3120@wrl-59.cs.helsinki.fi>
References: <20081230195858.GA23530@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33413 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbYLaKi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 05:38:27 -0500
In-Reply-To: <20081230195858.GA23530@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Dec 2008, Russell King wrote:

> While trying to access a website on a FC5 machine, I encountered what seemed
> to be excessive traffic without much progress.

And what kernel that would be, btw?

> tcpdumping the connection showed a permanent stream of acks from both ends
> of the connection.  Ben Hutchings suggested that 607bfbf might fix it, so
> I built 2.6.27.8 which has this fix in some 20 days ago.

Considering your dump, 607bfbf cannot do any change.

> After encountering
> other problems, a fix to lib/idr.c was applied.  This kernel seemed to be
> fine, until...
> 
> 19:47:32.062670 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: S 3543174870:3543174870(0) win 5840 <mss 1460,sackOK,timestamp 26999689 0,nop,wscale 6>
> 19:47:32.135812 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: S 3016012818:3016012818(0) ack 3543174871 win 8192 <mss 1276>
> 19:47:32.135837 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 1 win 5840
> 19:47:32.135899 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: P 1:644(643) ack 1 win 5840
> 19:47:32.167644 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 644 win 7073

Just for the record, the peer certainly shrinks window here, not
that it should affect us in bad way since we don't even get that far 
and the window opens more again in the later packet anyway...

> 19:47:32.174366 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: P 1:1190(1189) ack 644 win 7073
> 19:47:32.174414 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 1190 win 8323
> 19:47:32.174701 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . 644:3196(2552) ack 1190 win 8323
> 19:47:32.174720 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: P 3196:3216(20) ack 1190 win 8323
> 19:47:32.218718 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: P 1190:2215(1025) ack 1920 win 8932

Here the peer acks to 1920, this is likely last feedback we consider 
valid.

> 19:47:32.258402 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.285388 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701

It would be interesting to know if this segment gets discarded. It's most 
likely considered out-of-sequence for some reason because the response is
an immediate duplicate ack:

> 19:47:32.285397 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.320287 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.320300 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.353016 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.353022 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.382702 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.382712 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.404786 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.404793 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.446827 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.446835 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.451343 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . 1920:3196(1276) ack 2215 win 10701
> 19:47:32.480976 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.480984 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.530343 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.530356 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.554244 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.554251 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.582139 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.582146 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.613093 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.613121 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 
> and then it ploughs into ack-madness at as high a speed as the link can
> handle:
> 
> 19:47:32.634725 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.634753 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.654389 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.654408 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.674332 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.674339 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.692550 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.692555 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 19:47:32.712249 IP 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: . ack 3216 win 10701
> 19:47:32.712265 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . ack 2215 win 10701
> 
> which is the same thing as the FC5 kernel.  It took three attempts
> (killing off the browser and restarting it) to access the website.

I tried couple of times but got at perfectly working connection from 
here (that's so typical wrt. these bugs).

> The retransmission at 19:47:32.451343 looks like quite silly behaviour
> from the Linux kernel - the remote end has acked data up to 3216 but
> it's resending old data.
>
> Any ideas?

Most likely the latest acks are considered invalid for some reason.
...That perfectly explains why you get that retransmission there.

If you have the dump still at handy, could you add couple of -v -v for
tcpdump. It could be that the peer is using bogus seqnos in the
duplicate ACK but by default that's not visible for zero sized segs
(checked in tcp_validate_incoming in the 2.6.28.7 kernel).

...Grr, we seem to be lacking a mib for that seqno check failure.


-- 
 i.
