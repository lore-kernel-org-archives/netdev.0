From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Who's allowed to set a skb destructor?
Date: 05 Jul 2007 12:08:27 +0200
Message-ID: <p733b032mec.fsf@bingen.suse.de>
References: <468B54A6.5090902@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37542 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753562AbXGEJNG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 05:13:06 -0400
In-Reply-To: <468B54A6.5090902@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <Brice.Goglin@ens-lyon.org> writes:

> I am trying to understand whether I can setup a skb destructor in my
> code (which is basically a protocol above dev_queue_xmit() and co). From
> what I see in many parts in the current kernel code, the "protocol" (I
> mean, the one who actually creates the skb) may setup a destructor.

The socket layer generally needs it for its own accounting.
Unless you never pass it up you can't use it.

> However, I also see some places where some low-level drivers might be
> using a destructor too , without apparently checking whether an upper
> layer already uses one. For instance, write_ofld_wr() in cxgb3/sge.c.

Likely a bug. Normally that should not slip past code review.

> found some old threads about adding support for multiple destructors but
> I don't see anything like this in the current kernel.
> 
> So, I'd like to have a clear statement about who's allowed to use a
> destructor :)

The traditional standpoint was that having your own large skb pools 
is not recommended because you won't interact well with the 
rest of the system running low on memory and you tieing up 
memory.

Essentially you would recreate all the problems traditional Unix
systems have with fixed size mbuf pools. Linux always used a more
dynamic and flexible allocate-only-as-you-need approach even when it
can have a little more overhead in managing IOMMUs etc.

These days there are shrinker callbacks that would in theory
allow you to handle this, but it would be likely still hard to implement
correctly.

-Andi
