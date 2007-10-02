From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: tcp bw in 2.6
Date: Tue, 2 Oct 2007 14:56:00 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0710021424320.3579@woody.linux-foundation.org>
References: <20071002193304.GA31611@bitmover.com> <4702A1B6.5020505@psc.edu>
 <20071002201420.GE29944@bitmover.com>
 <20071002.164223.59654826.wscott@bitmover.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: lm@bitmover.com, jheffner@psc.edu, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org
To: Wayne Scott <wscott@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46510 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750941AbXJBV5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:57:00 -0400
In-Reply-To: <20071002.164223.59654826.wscott@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 2 Oct 2007, Wayne Scott wrote:
> 
> The slow set was done like this:
> 
>  on ia64:  netcat -l -p8888 > /dev/null
>  on work:  netcat ia64 8888 < /dev/zero

That sounds wrong. Larry claims the slow case is when the side that did 
"accept()" does the sending, the above has the listener just reading.

> The fast set was done like this:
> 
>  on work:  netcat -l -p8888 > /dev/null
>  on ia64:  netcat ia64 8888 < /dev/zero

This one is guaranteed wrong too, since you have the listener reading 
(fine), but the sener now doesn't go over the network at all, but sends to 
itself.

That said, let's assume that only your description was bogus, the TCP 
dumps themselves are ok. 

I find the window scaling differences interesting. This is the opening of 
the fast sequence from the receiver:

	13:35:13.929349 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: S 2592471184:2592471184(0) ack 3363219397 win 5792 <mss 1460,sackOK,timestamp 174966955 3714830794,nop,wscale 7>
	13:35:13.929702 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 1449 win 68 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929712 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 2897 win 91 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929724 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 4345 win 114 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929941 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 5793 win 136 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929951 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 7241 win 159 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929960 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 8689 win 181 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929970 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 10137 win 204 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929981 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 11585 win 227 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.929992 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 13033 win 249 <nop,nop,timestamp 174966955 3714830795>
	13:35:13.930331 IP 10.3.1.1.ddi-tcp-1 > 10.3.1.10.58415: . ack 14481 win 272 <nop,nop,timestamp 174966955 3714830795>
	 ...

ie we use a window scale of 7, and we started with a window of 5792 bytes, 
and after ten packets it has grown to 272<<7 (34816) bytes.

The slow case is 

	13:34:16.761034 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: S 3299922549:3299922549(0) ack 2548837296 win 5792 <mss 1460,sackOK,timestamp 3714772254 174952667,nop,wscale 2>
	13:34:16.761533 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 1449 win 2172 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.761553 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 2897 win 2896 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.761782 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 4345 win 3620 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.761908 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 5793 win 4344 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.761916 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 7241 win 5068 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.762157 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 8689 win 5792 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.762164 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 10137 win 6516 <nop,nop,timestamp 3714772255 174952667>
	13:34:16.762283 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 11585 win 7240 <nop,nop,timestamp 3714772256 174952667>
	13:34:16.762290 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 13033 win 7964 <nop,nop,timestamp 3714772256 174952667>
	13:34:16.762303 IP 10.3.1.10.ddi-tcp-1 > 10.3.1.1.49864: . ack 14481 win 8688 <nop,nop,timestamp 3714772256 174952667>
	...

so after the same ten packets, it too has grown to about the same 
size (8688<<2 = 34752 bytes). 

But the slow case has a smaller window scale, and it actually stops 
opening the window at that point: the window stays at 8688<<2 for a long 
time (and eventually grows to 9412<<2 and then 16652<<2 in the steady 
case, and is basically limited at that 66kB window size).

But the fast one that had a window scale of 7 can keep growing, and will 
do so quite aggressively. It grows the window to (1442<<7 = 180kB) in the 
first fifty packets.

But in your dump, it doesn't seem to be about who is listening and who is 
connecting. It seems to be about the fact that your machine 10.3.1.10 uses 
a window scale of 2, while 10.3.1.1 uses a scale of 7.

			Linus
