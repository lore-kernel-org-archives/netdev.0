From: Arjan van de Ven <arjan@infradead.org>
Subject: RE: [patch 3/3] Add tsi108 On Chip Ethernet device driver support
Date: Wed, 20 Sep 2006 10:45:57 +0200
Message-ID: <1158741958.2921.3.camel@laptopd505.fenrus.org>
References: <7EA18FDD2DC2154AA3BD6D2F22A62A0E2FB214@zch01exm23.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, jgarzik <jgarzik@pobox.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:30930 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1750821AbWITLbP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Sep 2006 07:31:15 -0400
To: Zang Roy-r61911 <tie-fei.zang@freescale.com>
In-Reply-To: <7EA18FDD2DC2154AA3BD6D2F22A62A0E2FB214@zch01exm23.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-09-19 at 15:39 +0800, Zang Roy-r61911 wrote:

> > 
> > > +		spin_unlock_irq(&phy_lock);
> > > +		msleep(10);
> > > +		spin_lock_irq(&phy_lock);
> > > +	}
> > 
> > hmm some places take phy_lock with disabling interrupts, while others
> > don't. I sort of fear "the others" may be buggy.... are you sure those
> > are ok?
> Could you interpret your comments in detail?
> Roy

Hi,

sorry for being unclear/too short in the review.

The phy_lock lock is sometimes taken as spin_lock() and sometimes as
spin_lock_irq(). It looks likes it can be used in interrupt context, in
which case the spin_lock_irq() version is correct and the places where
spin_lock() is used would be a deadlock bug (just think what happens if
the interrupt happens while spin_lock(&phy_lock) is helt, and the
spinlock then again tries to take the lock!)

If there is no way this lock is used in interrupt context, then the
spin_lock_irq() version is doing something which is not needed and also
a bit expensive; so could be optimized.

But my impression is that the _irq() is needed. Also, please consider
switching from spin_lock_irq() to spin_lock_irqsave() version instead;
spin_unlock_irq() has some side effects (interrupts get enabled
unconditionally) so it is generally safer to use
spin_lock_irqsave()/spin_unlock_irqrestore() API.

If you have more questions please do not hesitate to ask!

Greetings,
   Arjan van de Ven 
-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com

