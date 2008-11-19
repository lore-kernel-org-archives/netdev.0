From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netconsole: Disable softirqs in write_msg()
Date: Wed, 19 Nov 2008 02:10:45 -0800 (PST)
Message-ID: <20081119.021045.222679286.davem@davemloft.net>
References: <87y6zwwy5c.fsf@tac.ki.iif.hu>
	<20081119084106.GA6699@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mingo@elte.hu, johannes@sipsolutions.net,
	wferi@niif.hu, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752517AbYKSKKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 05:10:45 -0500
In-Reply-To: <20081119084106.GA6699@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 19 Nov 2008 08:41:06 +0000

> This report: http://marc.info/?l=linux-netdev&m=122599341430090&w=2
> shows local_bh_enable() is used in the wrong context (irqs disabled).
> It happens when a usual network path is called by netconsole, which
> simply turns off hardirqs around this all.

This backtrace call path is anything but "usual".

There is a UDP send, and a local_bh_enable() done there triggers
softirqs, which processes device (I would guess loopback, or
some non-NAPI device) backlog processing.

This triggers an input netfilter ipt_LOG rule, which triggers a
printk over netconsole.

netpoll finds the TX queue of the tg3 device (which is NAPI)
full, so it invokes ->poll() to try and free up some TX queue
space.

This in turn triggers a packet receive, which hits bridging netfilter,
which does a conntrack lookup, which does the BH disable/enable which
triggers the warning.

I mean, this is just a very crazy trace :-)

I see an easy way around this.  We should just punt on non-netpoll
RX packets that try to get processed during a netconsole ->poll()
run.

Wait a second, this is _supposed_ to be already happening.  Perhaps
the tests in netpoll_rx() are screwed up.

net/core/netpoll.c'd poll_one_napi() explicitly sets NETPOLL_RX_DROP
in npinfo->rx_flags as well as increment "trapped", and that is
supposed to make netpoll_rx() return non-zero which tells the caller
to ignore and drop all RX packets.

What isn't that happening?

netpoll_rx()'s test is:

	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
		return 0;

which looks perfectly fine.  npinfo will be non-NULL by definition
because we are doing netpoll for netconsole on this device, and
->rx_flags are non-zero by the above mentioned code.

So we get to __netpoll_rx() by the next bit of code.

	if (npinfo->rx_flags && __netpoll_rx(skb))
		ret = 1;

And __netpoll_rx() says:

	struct netpoll *np = npi->rx_np;

	if (!np)
		goto out;

this should trigger because a netpoll RX agent shouldn't be attached,
then:

out:
	if (atomic_read(&trapped)) {
		kfree_skb(skb);
		return 1;
	}

	return 0;

which should trigger because trapped is non-zero, thus we free the SKB
and return 1.

We need to figure out why this isn't working properly.  Maybe it's some
bug we fixed, or some weird change in the SUSE Xen mods this used has
applied.

I also took a quick look at 2.6.26.6 and I don't see any bugs in this
area there.
