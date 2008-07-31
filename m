From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch 12/12] Configure out ethtool support
Date: Thu, 31 Jul 2008 22:17:01 +0400
Message-ID: <20080731181658.GA5294@2ka.mipt.ru>
References: <20080730.145727.07367670.davem@davemloft.net> <20080730151316.a4d76fe9.akpm@linux-foundation.org> <1217500776.3454.136.camel@pmac.infradead.org> <20080731.034737.154058020.davem@davemloft.net> <1217518591.3657.27.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwmw2@infradead.org,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	thomas.petazzoni@free-electrons.com, shemminger@vyatta.com,
	jeff@garzik.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:52145 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752921AbYGaSSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 14:18:25 -0400
Content-Disposition: inline
In-Reply-To: <1217518591.3657.27.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matt.

On Thu, Jul 31, 2008 at 10:36:31AM -0500, Matt Mackall (mpm@selenic.com) wrote:
> > I especially appreciate that you still haven't accepted the plain fact
> > that CONFIG_ETHTOOL needs to be selected by CONFIG_INET.
> 
> So far the following features have been mentioned as being critically
> dependent on ethtool:
> 
> - bridging
> - bonding
> - LRO
> - netfilter (really?)
> - IPv6 (really?)
> 
> And yet every single one of these is currently a config option, so your
> above statement is still looking awfully dubious. At this point I'd
> suggest that you've painted yourself into a corner where all these
> options must also actually be mandatory, but I'm afraid you might
> secretly want to do that anyway.

Things not are that simple. If your hardware happend to support
scatter-gather and tx checksumming, and you forgot to add a magic ifdef
into own embedded build of the driver, then sendfile() performance will
be awful. Even more: if you hardcoded negotiation bits into the driver
and happend to plug NIC to the wrong switch, you will have no-to-bad
performance. Even more: there are quite broken switches, which just
freeze the port after some tricky packets sent by nic (for example
several autonegotiation packets). Without ethtool you will not be able
to reset NIC. You will not be able to debug any hardware trouble and/or
set needed hardware bits. If embedded folks are so much care about size,
that they will hardcode all needed parameters for their own network into
the driver, then they can apply this patch on its own tree and do not
compile ethtools.

The only sane way to try to push something like this into the tree is
obviously turned on by default and with very much all needed config
options checked first. I agree with other poster, who recommened to put
a warning into the commented syscalls.


I can recommend another major part to be removed with the same approach
you use with ethtool: netlink. Webcam does not need to install route or
configure interface, it can do it via dhcp in kernel. Embedded folks can
also create a simple module, which will do the same with smaller
overhead. Then you can turn off direct-io and readahead. Webcam does not
need to have either. One can replace scheduler algorithms with something
small and trivial. Webcam should only have init and reading software.
Actually it can do it in init (I personally wrote embedded system, where
only init existed, which was a trivial shell with dozen of commands).
You can also trim block layer by half: embedded system should not be
able to configure device queues at all. Feel free to point to any
subsystem, and there are lots of such 'non-needed' from the fist view
things. But when some troubles start or feature needed, or behaviour is
not expected, uch embedded people start to scream, that everything is so
bad in Linux and it is not suitable and so on...

-- 
	Evgeniy Polyakov
