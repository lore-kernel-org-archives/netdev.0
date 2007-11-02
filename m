From: Felix von Leitner <felix-linuxkernel@fefe.de>
Subject: Re: TCP_DEFER_ACCEPT issues
Date: Fri, 2 Nov 2007 23:19:12 +0100
Message-ID: <20071102221912.GB4354@codeblau.de>
References: <20071102013321.GA30893@codeblau.de> <472AD0AE.50106@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ioctl.codeblau.de ([80.190.240.67]:53943 "EHLO codeblau.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756438AbXKBWTN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 18:19:13 -0400
Content-Disposition: inline
In-Reply-To: <472AD0AE.50106@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus spake Eric Dumazet (dada1@cosmosbay.com):
> 1) Setting a timeout in a millisecond range (< 1000) is not very good 
> because some clients may need much more time to send your server the data 
> (very long distance). So a second granularity is OK.

I want millisecond accuracy for consistency.  select and poll have it,
we have a 1000 Hz timer, we should also expose that accuracy.  I don't
want to have sub second timeouts, in case you were wondering.

> 2) After timeout is elapsed, the server tcp stack has no socket associated 
> to your client attempt. So closing the server listening socket wont be able 
> to send RST. I agree a RST *should* be sent by the server once the timeout 
> is triggered.

I don't see any evidence for a timeout happening at all.
I passed 1 as argument to the setsockopt, so I'd expect a timeout to
happen pretty quickly.  There was no connection reset until I Ctrl-C'd
the server 15 minuets (!) laster.

> A typical tcpdump of what is happening for a tcp_defer_accept timeout of 20 
> seconds is :

> [1]08:52:47.480291 IP client.60930 > server.http: S 
> 2498995442:2498995442(0) win 5840 <mss 1460,sackOK,timestamp 2685904595 
> 0,nop,wscale 2>
> [2]08:52:47.480302 IP server.http > client.60930: S 
> 1173302644:1173302644(0) ack 2498995443 win 5840 <mss 1460>
> [3]08:52:47.481669 IP client.60930 > server.http: . ack 1 win 5840

> [4]08:52:50.757543 IP server.http > client.60930: S 
> 1173302644:1173302644(0) ack 2498995443 win 5840 <mss 1460>
> [5]08:52:50.758953 IP client.60930 > server.http: . ack 1 win 5840

> [6]08:52:56.760611 IP server.http > client.60930: S 
> 1173302644:1173302644(0) ack 2498995443 win 5840 <mss 1460>
> [7]08:52:56.761886 IP client.60930 > server.http: . ack 1 win 5840

> [8]08:53:08.771254 IP server.http > client.60930: S 
> 1173302644:1173302644(0) ack 2498995443 win 5840 <mss 1460>
> [9]08:53:08.772514 IP client.60930 > server.http: . ack 1 win 5840

> [10]08:53:32.782488 IP server.http > client.60930: S 
> 1173302644:1173302644(0) ack 2498995443 win 5840 <mss 1460>
> [11]08:53:32.783754 IP client.60930 > server.http: . ack 1 win 5840

> <a very long time, then client finally sends 2 bytes>

> [12]08:59:30.509097 IP client.60930 > server.http: P 1:3(2) ack 1 win 5840
> [13]08:59:30.509125 IP server.http > client.60930: R 
> 1173302645:1173302645(0) win 0

I see this, too.  If I connect and not send something, I expected the
kernel to drop the connection when the timeout is reached.  Nothing like
that happens.

> So TCP_DEFER_ACCEPT might send way more packets than needed.

Only in the face of attackers, and after the handshake.  I could live
with that.  If the timeout happened.

> We only should wait for the data coming from the client to be able to pass 
> the new socket to the listening application.

Yes.  And we should send a RST if no data is coming in within the
timeout, which is not happening for me (2.6.23).

Felix
