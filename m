From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] split NAPI from network device.
Date: Thu, 22 Feb 2007 03:18:58 -0800 (PST)
Message-ID: <20070222.031858.39163926.davem@davemloft.net>
References: <20061213154635.1f284bf6@dxpl.pdx.osdl.net>
	<20070220.213125.74747066.davem@davemloft.net>
	<1172100271.6792.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org, ebs@ebshome.net,
	linux-kernel@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35430
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750797AbXBVLTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:19:01 -0500
In-Reply-To: <1172100271.6792.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Feb 2007 10:24:31 +1100

> The device has a single interrupt though that interrupt at least can
> tell you which queues need servicing. It can't mask the interrupt per
> queue though, which is the main issue.

Right, which effectively turns it into a single interrupt
for multiple queues as far as NAPI is concerned.

> So while I think this scheme would work (the driver, ibm_emac, currently
> uses a fake net_device and that sort-of works, budget is set a CONFIG_*
> time though, I'm sure that can/needs to be improved), I've been
> wondering all along if I could do something smarter by doing some
> interrupt soft-disabling instead, though I have to get my head around
> properly kicking softirqs from task context (if I need to re-trigger
> from a enable_*() call occuring at task context).

If you cannot make use of it sanely in your driver, it's hard to
justify this patch just in the cleanup sense since it breaks
NAPI interfaces and makes driver maintainence harder than it would
need to be.

Whereas if it makes a straightforward implementation in drivers
like ibm_emac possible, this tends to tip things over the edge
such that we can justify the maintainence hassles to some extent.

I think the intention with these changes, is that you would
have a napi struct per-queue.  It would be embedded in some
private per-queue software state struct, and from which you
could also get to the device.  So you'd do the "container_of()"
bit a little bit differently at the beginning of your ->poll()
method.

This way you don't need the dummy netdevices.

Anyways, please let us know what you come up with once you get
a chance to investigate this.

Thanks!
