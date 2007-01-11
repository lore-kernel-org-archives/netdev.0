From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Thu, 11 Jan 2007 11:42:20 +0100
Message-ID: <20070111104220.GA3171@ff.dom.local>
References: <7d01f9f00701051103q3ee6ed35q9fd0f778a18061b8@mail.gmail.com> <20070109092602.GC1703@ff.dom.local> <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com> <20070109130220.GA4060@ff.dom.local> <7d01f9f00701090944o62f39fb4yfaa5449c2d2d010d@mail.gmail.com> <20070109200541.GA27089@xyzzy.farnsworth.org> <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com> <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:42257 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030255AbXAKKkY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 05:40:24 -0500
To: Thibaut VARENE <T-Bone@parisc-linux.org>
Content-Disposition: inline
In-Reply-To: <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 06:12:29PM +0100, Thibaut VARENE wrote:
> On 1/9/07, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> >On 1/9/07, Dale Farnsworth <dale@farnsworth.org> wrote:
> >>
> >> Thank you Thibaut.  Please try the following patch:
> >>
> >> From: Dale Farnsworth <dale@farnsworth.org>
> >>
> >> Reserve one unused descriptor in the TX ring
> >> to facilitate testing for when the ring is full.
> >
> >Dale,
> >
> >tried it and unfortunately:
> 
> Also, I don't know if you read that bit, but everytime I reboot the
> box immediately after a crash, the NIC gets a bogus (always the same
> it seems) MAC address, and I have to reboot one more time to get back
> to the "normal" MAC address.
> 
> Dunno if that hints anything though.

There is something in the code about MAC writing and saving
some config during initialization, so probably it's possible
if reinitialization was broken.

I tried to look more into the code and here are my (maybe
wrong) conclusions:

- It looks like something could be broken during tx descs
freeing or eth_tx_timeout_task. I compared the timeout code
with e100 and tg3 and have a feeling mv643xx_eth is doing 
less but I'm not able to estimate the importance of this.

- Such errors, IMHO, could be possible with races and not
enough locking, and btw. I think suspected function isn't
properly locked: mp->tx_desc_count in while condition isn't
protected at all. Below I attach a patch proposal but I'm
not sure some irq off or spin_lock isn't also needed
elswere. If it's only locking it would be suitable to do
the test with a kernel compiled without PREEMPT and SMP,
but if irqs nothing should change... 

Regards,
Jarek P.

PS: alas I didn't even check compiling - I had no time to
find all compile dependencies of this driver
---

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
---

diff -Nurp linux-2.6.20-rc4-/drivers/net/mv643xx_eth.c linux-2.6.20-rc4/drivers/net/mv643xx_eth.c
--- linux-2.6.20-rc4-/drivers/net/mv643xx_eth.c	2006-12-18 08:57:52.000000000 +0100
+++ linux-2.6.20-rc4/drivers/net/mv643xx_eth.c	2007-01-11 08:55:34.000000000 +0100
@@ -312,8 +312,8 @@ int mv643xx_eth_free_tx_descs(struct net
 	int count;
 	int released = 0;
 
+	spin_lock_irqsave(&mp->lock, flags);
 	while (mp->tx_desc_count > 0) {
-		spin_lock_irqsave(&mp->lock, flags);
 		tx_index = mp->tx_used_desc_q;
 		desc = &mp->p_tx_desc_area[tx_index];
 		cmd_sts = desc->cmd_sts;
@@ -348,8 +348,10 @@ int mv643xx_eth_free_tx_descs(struct net
 			dev_kfree_skb_irq(skb);
 
 		released = 1;
+		spin_lock_irqsave(&mp->lock, flags);
 	}
 
+	spin_unlock_irqrestore(&mp->lock, flags);
 	return released;
 }
 
