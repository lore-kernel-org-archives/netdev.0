From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Sun, 21 Sep 2008 23:54:44 -0700 (PDT)
Message-ID: <20080921.235444.156373854.davem@davemloft.net>
References: <20080922044051.GA583@2ka.mipt.ru>
	<20080921.220605.129235191.davem@davemloft.net>
	<20080922054918.GA31099@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34167
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751181AbYIVGy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 02:54:56 -0400
In-Reply-To: <20080922054918.GA31099@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 22 Sep 2008 09:49:20 +0400

> On Sun, Sep 21, 2008 at 10:06:05PM -0700, David Miller (davem@davemloft.net) wrote:
> > Because datagram sockets are completely different from stream sockets.
> > 
> > You program them differently, segmentation is made by the socket user
> > not within by the protocol itself.
> > 
> > sendfile() should behave in a way congruent to the other data transfer
> > APIs of the BSD socket layer.
> 
> So effectively you are saying, that sendfile() is just a pure send(),
> but with diferent arguments? I.e. it is not supposed to send the whole
> data it points to, but as much as possible according to send() standard?

It already makes this, guess what happens when socket error occurs
midstream during sendfile(), even for TCP?

First, we return length successfully sent.

User has to retry sendfile() call with remaining length, and at this
point they will immediately get the socket error return value.

This was broken at one point and I remember applying the fix for this
several years ago :-)

> Well, it may be a right or wrong decision, and in my opinion sendfile()
> is very diferent than send() since it should require the whole data to
> be sent, i.e. being like a loop of send()s, but since sendfile() is
> effectively a very new approach, it could have different behaviour
> rules.

It is in fact exactly and precisely like send().  It must even give
the same error return semantics as other socket data transfer calls
do.  See above.

The user has to have a resending loop _anyways_, in order to do
correct error handling.

Nothing is gained from the proposal, really.  It can only harm application
developers into thinking that segmentation over datagram sockets is not
their responsibility, when it absolutely is.
