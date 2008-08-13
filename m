From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Wed, 13 Aug 2008 03:56:28 -0700 (PDT)
Message-ID: <20080813.035628.169565636.davem@davemloft.net>
References: <20080813095942.GA9145@martell.zuzino.mipt.ru>
	<20080813.032946.114949936.davem@davemloft.net>
	<19f34abd0808130344h65e793eare83c0f41cb1cfb8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com
To: vegard.nossum@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751951AbYHMK41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:56:27 -0400
In-Reply-To: <19f34abd0808130344h65e793eare83c0f41cb1cfb8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vegard Nossum" <vegard.nossum@gmail.com>
Date: Wed, 13 Aug 2008 12:44:46 +0200

> There must also be no BUG()s, WARN()s, other debugging facilities
> (spinlock debugging, lockdep, irqtrace, etc.) triggering which may
> call printk() inside the protected section. Can we really ensure this?
> For all drivers supporting netconsole?

For all drivers supporting netconsole?  Well yes, there will be some
bugs somewhere in some driver wrt. netconsole.  But that's life
and why we will constantly have something to fix in the kernel isn't
it?

But one thing is for sure, your deliriously dirty ->busy thing is
emphatically not the answer.

BTW, it seems the main reason this driver is susceptible to this
problem is that it doesn't handle link status events in it's
NAPI poll handler.  If it did that, you would have never seen
this deadlock.

The netpoll layer prevents recursion into the NAPI ->poll() handler.

Most drivers manage link state either in their NAPI ->poll() handler
or a periodic timer that samples the link state.  Both schemes
avoid this very issue.

