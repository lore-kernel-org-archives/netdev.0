From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Mon, 30 Jul 2007 08:04:24 -0700
Message-ID: <ada7ioiszk7.fsf@cisco.com>
References: <20070725.013154.34764933.davem@davemloft.net>
	<ada1wesy2eh.fsf@cisco.com>
	<20070728.223206.112621083.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:60251 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036AbXG3PEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 11:04:44 -0400
In-Reply-To: <20070728.223206.112621083.davem@davemloft.net> (David Miller's message of "Sat, 28 Jul 2007 22:32:06 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > If you have a means in the device (like tg3, bnx2, e1000, and a score
 > of others do) to force the device to trigger a HW interrupt, that's
 > what you do if you detect that events are pending after re-enabling
 > interrupt in the ->poll() handler.

It is possible to trigger an interrupt for IPoIB I think but it will
lead to a fair bit of code, since one would have to do something like
a dummy send operation to generate an event that leads to the
interrupt.  I think this will be rather complex/ugly to implement
because we have to make sure we have space in the send queue to post
the send operation, etc.

 > Frankly I don't think the lock is a big deal and you need something
 > like it anyways typically.

If I understand this correctly, you're suggesting a spin_lock_irqsave()
around the netif_rx_complete() in the poll routine, and a
corresponding lock in the interrupt handler.  That seems like a pretty
big step backwards for performance to me.  Especially since in my
experience, fast machines handling full-MTU traffic often end up being
basically interrupt driven because they drain the RX ring too quickly
to stay in NAPI polling.  Yes, it's "only one more lock" but look at
the tricky smp_mb() usage that tg3, bnx2, etc have to avoid using a
spinlock...

IPoIB can cope but it really seems like an unfortunate feature of
these changes that we can't do something like what we have today,
which imposes no overhead unless an event actually lands in the race
window.

 - R.
