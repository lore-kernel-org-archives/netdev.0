From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 2/2 v2] sierra_net: fix issues with SYNC/RESTART
 messages and interrupt pipe setup
Date: Thu, 07 Feb 2013 15:09:41 -0600
Message-ID: <1360271381.2382.42.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318289.5370.19.camel@dcbw.foobar.com>
	 <1360176176.11742.16.camel@dcbw.foobar.com>
	 <2485224.kk5J89zEMM@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32130 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759027Ab3BGVJY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 16:09:24 -0500
In-Reply-To: <2485224.kk5J89zEMM@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 21:17 +0100, Oliver Neukum wrote:
> On Wednesday 06 February 2013 12:42:56 Dan Williams wrote:
> > As part of the initialization sequence, the driver sends a SYNC message
> > via the control pipe to the firmware, which appears to request a
> > firmware restart.  The firmware responds with an indication via the
> > interrupt pipe set up by usbnet.  If the driver does not receive a
> > RESTART indication within a certain amount of time, it will periodically
> > send additional SYNC messages until it receives the RESTART indication.
> > 
> > Unfortunately, the interrupt URB is only submitted while the netdev
> > is open, which is usually not the case during initialization, and thus
> > the firmware's RESTART indication is lost.  So the driver continues
> > sending SYNC messages, and eventually the firmware crashes when it
> > receives too many.  This leads to a wedged netdev.
> 
> If I understand this correctly we should stop the interrupt pipe once
> RESTART has been recieved. I am afraid this patch is a bit inefficient.

The firmware may send other indications to the host over the interrupt
pipe at any time, apparently.  However, I have not seen firmware send
these indications in practice, so maybe we can ignore this and do as you
suggest.

So how would you suggest to handle this given the constraints?

Basically, we need to allow sierra_net to submit dev->interrupt at
probe/bind and then after a period of time kill it when it's no longer
needed.  The problem is that if the interface is set IFF_UP right after
bind but before sierra_net has finished its SYNC/Restart dance, we need
to ensure that sierra_net doesn't kill the URB unconditionally.

One way to do this would be a new usbnet function to subdrivers could
call to submit the URB which would be a NOP if the URB was already
submitted.  It would be paired with a function to kill the URB which
would be a NOP if (URB already killed || (IFF_UP and subdriver has
status() hook)).  Kinda like refcounting the interrupt URB submission
but not.

Does that sound like a worthwhile approach?

Dan
