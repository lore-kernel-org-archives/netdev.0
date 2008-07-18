From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] tcp: do not promote SPLICE_F_NONBLOCK to socket O_NONBLOCK
Date: Fri, 18 Jul 2008 17:04:17 +0300
Message-ID: <200807181704.17211.opurdila@ixiacom.com>
References: <200807171633.49791.opurdila@ixiacom.com> <200807181418.59493.opurdila@ixiacom.com> <20080718122414.GA10688@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4108 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755345AbYGROGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 10:06:24 -0400
In-Reply-To: <20080718122414.GA10688@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 July 2008, Evgeniy Polyakov wrote:
>
> It will block in sending and/or other than network reading. With your
> patch if receiving socket was opened in blocking mode, than there is no
> way to finish splice-in until whole requested number of bytes are read.
> SPLICE_F_NONBLOCK is an extension, consider it like recv() with temporal
> non-blocking flag.
>

The way is see it, and API and documentation is written, SPLICE_F_NONBLOCK was 
added only for choosing to block or not block on the _pipe_, not on the other 
fd. 

And, IMHO, it should be kept that way. If we need to make certain splice 
operations non-blocking for the other file descriptor, then maybe we should 
add a separate flag for that. But, again IMHO, overloading SPLICE_F_NONBLOCK 
with responsabilities for both the pipe and the other file descriptor is 
wrong is at is taking the freedom from the application of controlling things. 

And when you do that, sooner or later you will run in a scenario which 
requires workarounds in the applications to bypass the API assumptions. 

> > Sorry, it was an unfortunate example :) This is not about not enough data
> > being available. Lets change the number of packets in the example with 20
> > instead of 16 (and keep the size to 17) - the splice call will still
> > block because of the pipe being full. The pipe can only hold PIPE_BUFFERS
> > packets (which is 16 currently).
>
> Why? It will read its data from 16 packets, then send them into another end
> of the pipe :)
>

splice will consume one packet at a time and will try to feed them in the 
pipe. Since the pipe can only hold 16 descriptors, on the 17th it will block. 

> You propose to change a very useful splice feature (actually you would just
> remove it at all with the same results for reading network path, since
> it is essentially what you did :) - not to block when it is possible.
>
> This kind of non-blocking mode was added for performance issues too:
> consider application which reads from the network and writes into the
> file, while there is no data in the socket it can write what was already
> read into any object attached to the given end of the pipe.

I have my doubts about the benefit of using the non-blocking operations only 
for some splice calls :) But to solve both issues the solution would be to 
add a separate non-blocking flag for the other file descriptor. Is that ok?

Thanks,
tavi
