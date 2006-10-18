From: Stephen Hemminger <shemminger@osdl.org>
Subject: netpoll causes malformed protocol message
Date: Wed, 18 Oct 2006 15:49:15 -0700
Message-ID: <20061018154915.324900d6@freekitty>
References: <Pine.LNX.4.64.0610152043060.3962@g5.osdl.org>
	<20061017170147.08edc149@freekitty>
	<Pine.LNX.4.64.0610171712050.3962@g5.osdl.org>
	<20061017190321.0414fb38@dads-laptop>
	<Pine.LNX.4.64.0610172129320.3962@g5.osdl.org>
	<20061017214830.07cb89bb@dads-laptop>
	<Pine.LNX.4.64.0610180932500.3962@g5.osdl.org>
	<Pine.LNX.4.64.0610181002390.3962@g5.osdl.org>
	<Pine.LNX.4.64.0610181014230.3962@g5.osdl.org>
	<20061018125629.5f480ff7@dxpl.pdx.osdl.net>
	<Pine.LNX.4.64.0610181310040.3962@g5.osdl.org>
	<20061018144553.6a40e0a4@dxpl.pdx.osdl.net>
	<Pine.LNX.4.64.0610181501490.3962@g5.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26590 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423125AbWJRWu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 18:50:59 -0400
To: Linus Torvalds <torvalds@osdl.org>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610181501490.3962@g5.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that I know what this is, perhaps others should know.

> Linus Torvalds <torvalds@osdl.org> wrote:
>   
> > 
> > Since I've been re-testing the Apple Intel Mac Mini suspend/resume due to 
> > a USB problem, I thought I might as well see if this rings any bells..
> > 
> > On resume, networking does actually eventually work, but it takes a while 
> > before it gets going. The dmesg for the resume shows:
> > 
> > 	sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
> > 	protocol 0000 is buggy, dev eth0
> > 	protocol 0000 is buggy, dev eth0  
> 
> 


The packets created by netpoll trigger the check for bogus protocol
in net/core/dev.c if it gets busy enough to actually use the netpoll
tx queue.

I'll whip a fix, the skb should be setup better and it shouldn't call
different xmit paths for the queued/non-queued case. Follow on patch
to replace the roll your own skb queue's with the already there sk_buff_head
routines. Given the normal case is lots of small writes, probably
better to just have a character queue to cause coalescing.

The netpoll code is a step child it looks like and ignores using
standard code when it should.
