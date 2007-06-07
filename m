From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 6 Jun 2007 20:47:12 -0400
Message-ID: <20070607004712.GE3304@havoc.gtf.org>
References: <1181168020.4064.46.camel@localhost> <20070606.153530.48530367.davem@davemloft.net> <1181172766.4064.83.camel@localhost> <20070606.165215.38711917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51324 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761426AbXFGArP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2007 20:47:15 -0400
Content-Disposition: inline
In-Reply-To: <20070606.165215.38711917.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2007 at 04:52:15PM -0700, David Miller wrote:
> For the locking is makes a ton of sense.
> 
> If you have sendmsg() calls going on N cpus, would you rather
> they:
> 
> 1) All queue up to the single netdev->tx_lock
> 
> or
> 
> 2) All take local per-hw-queue locks
> 
> to transmit the data they are sending?
> 
> I thought this was obvious... guess not :-)

Agreed ++

For my part, I definitely want to see parallel Tx as well as parallel Rx.
It's the only thing that makes sense for modern multi-core CPUs.

Two warnings flags are raised in my brain though:

1) you need (a) well-designed hardware _and_ (b) a smart driver writer
to avoid bottlenecking on internal driver locks.  As you can see we have
both (a) and (b) for tg3 ;-)  But it's up in the air whether a
multi-TX-queue scheme can be sanely locked internally on other hardware.

At the moment we have to hope Intel gets it right in their driver...


2) I fear that the getting-it-into-the-Tx-queue part will take some
thought in order to make this happen, too.  Just like you have the
SMP/SMT/Multi-core scheduler scheduling various resources, surely we
will want some smarts so that sockets are not bouncing wildly across
CPUs, absent other factors outside our control.

Otherwise you will negate a lot of the value of the nifty multi-TX-lock
driver API, by bouncing data across CPUs on each transmit anyway.

IOW, you will have to sanely fill each of the TX queues.

	Jeff



