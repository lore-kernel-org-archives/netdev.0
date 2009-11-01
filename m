From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Sun, 1 Nov 2009 14:20:17 +0100
Message-ID: <20091101132017.GA2598@ami.dom.local>
References: <4ACD9255.4020008@gmail.com>
 <20091008090344.GA7409@ff.dom.local>
 <20091008120039.GA8691@ff.dom.local>
 <4AE87EEE.4020703@trash.net>
 <20091028212337.GA3218@ami.dom.local>
 <4AE9C4C3.9040503@trash.net>
 <20091029211543.GA3036@ami.dom.local>
 <4AEA1357.3090307@trash.net>
 <20091030100033.GA6150@ff.dom.local>
 <1257009952.9706.30.camel@HP1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:65457 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbZKANUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2009 08:20:25 -0500
Received: by bwz27 with SMTP id 27so5265493bwz.21
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2009 05:20:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1257009952.9706.30.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 31, 2009 at 10:25:52AM -0700, Michael Chan wrote:
> 
> On Fri, 2009-10-30 at 03:00 -0700, Jarek Poplawski wrote:
> > On Thu, Oct 29, 2009 at 11:12:39PM +0100, Patrick McHardy wrote:
...
> > > I currently can't see any purpose in decreasing num_tx_queues after
> > > registration instead of real_num_tx_queues.
> > 
> > I agree, but since Eric's example shows some drivers do it (almost)
> > like this, I'd prefer authors/maintainers answer this question.
> > 
> 
> We need the netdev and the private structure at the beginning of
> ->probe() to store values as we probe the device.  Later on in
> ->probe(), we'll know whether the device supports MSI-X and multiqueue.
> If we successfully enable MSI-X in ->ndo_open(), tx multiqueue will be
> used.
> 
> So if we can separate the allocation of the netdev and the private
> structure from the tx queues, we can allocate and set the exact number
> of num_tx_queues in ->ndo_open().

There is a question if we can predict in ->probe() MSI-X should be
successfully enabled in ->ndo_open() for probed hardware. If so,
then it could go e.g. like this:
->probe()
	...
	dev = alloc_etherdev_mq(sizeof(*bp), 1)
	...
	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
		realloc_netdev_mq(dev, TX_MAX_RINGS)
	register_netdev(dev)

->ndo_open()
	if (!enabled_MSI-X)
		/* something gone wrong but it's an exception */
		dev->real_num_tx_queues = 1

Otherwise, (re)allocation in ->ndo_open() would need to answer some
questions about reinitializing scheduler vs preserving qdisc stats
between opens.

Jarek P.
