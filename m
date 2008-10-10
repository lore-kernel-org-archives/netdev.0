From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/enic/vnic_cq.c
Date: Fri, 10 Oct 2008 11:58:49 -0700 (PDT)
Message-ID: <20081010.115849.215623604.davem@davemloft.net>
References: <adaabdcjrz8.fsf@cisco.com>
	<C514ED13.C7D0%sfeldma@nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, akpm@linux-foundation.org, mingo@elte.hu,
	netdev@vger.kernel.org
To: sfeldma@nuovasystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45233
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759520AbYJJS7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 14:59:13 -0400
In-Reply-To: <C514ED13.C7D0%sfeldma@nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@nuovasystems.com>
Date: Fri, 10 Oct 2008 11:29:23 -0700

> On 10/10/08 10:10 AM, "Roland Dreier" <rdreier@cisco.com> wrote:
> 
> > cc'ing Scott so we can make sure that this actually is atomic enough to
> > work with the enic hardware... (Scott, the context is that enic won't
> > build on any architecture that doesn't define writeq and readq, such as
> > 32-bit x86; however the definitions below make it possible that multiple
> > 32-bit writes will be interleaved, eg if an interrupt occurs between the
> > first writel and the second writel)
> 
> Yes, enic hw provides atomic read/write for 64-bit regs even if register is
> accessed with 32-bit read/writes.

Sure, and this is why 32-bit arch's don't provide readq/writeq implementations,
things are much more subtle here.

The hardware may allow 2 32-bit writes to a 64-bit register, but...

Are there potential problems when the register is half-way updated?

For example, consider a ring index where the upper and lower 32-bits
are actually significant.  If you change the top part and then the
bottom part, in the intermediate step there is an invalid state and
the card might try to access an invalid ring index.

Then also, of course, the driver itself has to make sure it does
enough locking to make sure a partial 64-bit update isn't interrupted
by a parallel one on another cpu to the same register but I'll assume
the driver takes care of that here :-)
