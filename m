From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Mon, 22 Sep 2008 11:04:25 +0400
Message-ID: <20080922070425.GA14572@2ka.mipt.ru>
References: <20080922044051.GA583@2ka.mipt.ru> <20080921.220605.129235191.davem@davemloft.net> <20080922054918.GA31099@2ka.mipt.ru> <20080921.235444.156373854.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:55518 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751165AbYIVHFM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 03:05:12 -0400
Content-Disposition: inline
In-Reply-To: <20080921.235444.156373854.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 11:54:44PM -0700, David Miller (davem@davemloft.net) wrote:
> > So effectively you are saying, that sendfile() is just a pure send(),
> > but with diferent arguments? I.e. it is not supposed to send the whole
> > data it points to, but as much as possible according to send() standard?
> 
> It already makes this, guess what happens when socket error occurs
> midstream during sendfile(), even for TCP?
> 
> First, we return length successfully sent.
> 
> User has to retry sendfile() call with remaining length, and at this
> point they will immediately get the socket error return value.
> 
> This was broken at one point and I remember applying the fix for this
> several years ago :-)

Well, still tcp errors are completely different from udp ones: the
former ony result in a real problem or interrupt/timeout in the simple
case. UDP adds 'it is too big to be transferred' one. And instead of
just send the previous frame and start new one, we return error so that
user could do the same with additional syscall.

> > Well, it may be a right or wrong decision, and in my opinion sendfile()
> > is very diferent than send() since it should require the whole data to
> > be sent, i.e. being like a loop of send()s, but since sendfile() is
> > effectively a very new approach, it could have different behaviour
> > rules.
> 
> It is in fact exactly and precisely like send().  It must even give
> the same error return semantics as other socket data transfer calls
> do.  See above.

That's the main difference on how you and me look at sendfile().

> The user has to have a resending loop _anyways_, in order to do
> correct error handling.
> 
> Nothing is gained from the proposal, really.  It can only harm application
> developers into thinking that segmentation over datagram sockets is not
> their responsibility, when it absolutely is.

Which basically means that sendfile() for udp is exactly send() of the
mapped data. And it is not about segmentation, since packets are
correctly segmented with this proposal: packet is rounded to the
submitted page. This is about optimization compared to send() of the
data. You basically draw a line, that with UDP it is impossible to do.

-- 
	Evgeniy Polyakov
