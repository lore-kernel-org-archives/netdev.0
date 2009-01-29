From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Wed, 28 Jan 2009 17:09:14 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50311 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753351AbZA2BJs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 20:09:48 -0500
In-Reply-To: <alpine.DEB.2.00.0901281858380.5048@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 28 Jan 2009, Parag Warudkar wrote:
>
> This is similar to the issue reported back in Jul 2007 - 
> http://kerneltrap.org/mailarchive/linux-kernel/2007/8/1/154073/thread 
> which was fixed with a patch to unconditionally save/restore pci config 
> space - that one is still in tg3.c.

In fact, the new PCI suspend/restore code should have made that 
unnecessary, since the PCI layer now makes sure that a save/restore is 
done even if the driver hadn't done it.

But at the same time, still having the driver do it certainly shouldn't 
have _hurt_ anything either. But it's quite possible that the tg3 thing is 
very sensitive to the exact order things happen in - there's a lot of 
comments about bugs in there ;)

> After resume tg3 complains that no firmware is running and eth0 is 
> non-existent. Rmmoding and modprobing tg3 again causes some timeouts and 
> errors from tg3 and the link still doesn't work.

That seems to imply that even the reset failed, which is interesting. 

But it also possibly means that the problem is not necessarily the driver 
itself, but some cached state that we keep around in "struct pci_dev" even 
across a module load/unload. 

For example, if we get the "dev->current_state" cache wrong, then we may 
not actually end up changing it when we should, because we think we 
already match the target state. I don't _think_ that is it, but that's the 
kind of thing that could happen.

Can you do a

	lspci -vvxxx -s [tg3-device]

before-and-after suspend? Is there some state that looks like it got 
corrupted?

			Linus
