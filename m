From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] 3c59x: fix incorrect use of spin_lock_bh in interrupts
Date: Fri, 25 Oct 2013 00:44:47 +0200
Message-ID: <20131024224447.GA27710@electric-eye.fr.zoreil.com>
References: <alpine.LRH.2.02.1310211950360.5325@file01.intranet.prod.int.rdu2.redhat.com>
 <20131022.025514.1611245390510932009.davem@davemloft.net>
 <alpine.LRH.2.02.1310221148010.29454@file01.intranet.prod.int.rdu2.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org
To: Mikulas Patocka <mpatocka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54726 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab3JXWo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 18:44:58 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1310221148010.29454@file01.intranet.prod.int.rdu2.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikulas Patocka <mpatocka@redhat.com> :
> On Tue, 22 Oct 2013, David Miller wrote:
[...]
> > vortex_down() does a lot of other things which are really dangerous
> > from an interrupt handler, such as del_timer_sync().
> > 
> > The real fix for this bug is to defer the vortex_error() work into
> > a workqueue, and thus process context, like every other driver does.
> 
> That del_timer_sync() could be skipped - if we reset the card, we don't 
> need to reinitialize the times. Do you see anything else there that 
> prevents the functions vortex_down and vortex_up from being called from an 
> interrupt?

Up to 1s busy wait loop in issue_and_wait.

window_{read / write} deadlock with vortex_tx_timeout.

Error recovery needs to be robust and you'd rather recover in a context
where you can be a real pig (MDIO usually is).

It is a common pattern in linux kernel ethernet drivers to reduce the irq
handler to a bare minimum and move real work to softirq (NAPI) context,
especially for rx and tx traffic, then to workqueues for rare or error
related stuff. Window locking may limit the opportunity for fast path
locks removal but the driver would -imho- still end simpler.

-- 
Ueimor
