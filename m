From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: bug: mutex_lock() in interrupt conntext via phy_stop() in
	gianfar
Date: Tue, 22 Jul 2008 22:59:11 +0200
Message-ID: <20080722205911.GA29840@Chamillionaire.breakpoint.cc>
References: <20080718121008.GA28871@Chamillionaire.breakpoint.cc> <1216681028.7559.993.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Sebastian Siewior <netdev@ml.breakpoint.cc>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:59275 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754700AbYGVU7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 16:59:18 -0400
Content-Disposition: inline
In-Reply-To: <1216681028.7559.993.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Nate Case | 2008-07-21 17:57:08 [-0500]:

>On Fri, 2008-07-18 at 14:10 +0200, Sebastian Siewior wrote:
>> Commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially sleeping]
>> changed the phydev->lock from spinlock into a mutex. Now, the following
>> code path got triggered while NFS was unavailable:
>> 
>[snip]
>> |[  194.864733] BUG: sleeping function called from invalid context at /home/bigeasy/git/linux-2.6-powerpc/kernel/mutex.c:87
>> |[  194.875529] in_atomic():1, irqs_disabled():0
>> |[  194.879805] Call Trace:
>> |[  194.882250] [c0383d90] [c0006dd8] show_stack+0x48/0x184 (unreliable)
>> |[  194.888649] [c0383db0] [c001e938] __might_sleep+0xe0/0xf4
>> |[  194.894069] [c0383dc0] [c025a43c] mutex_lock+0x24/0x3c
>> |[  194.899234] [c0383de0] [c019005c] phy_stop+0x20/0x70
>> |[  194.904234] [c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
>> |[  194.909305] [c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
>> |[  194.914638] [c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144
>
>Hmm..  I'm not sure what the best solution is to this.  Make the
>stop_gfar() call happen in a workqueue, and make a similar change to
>ucc_geth, fec_mpc52xx, and fs_enet? Modify phy_stop() to do the work in
>a workqueue conditionally if in interrupt context?  Between these two
>I'd lean toward the latter.
>
>Does anyone have any better ideas?
If I look at tg3.c than exactly this is done. Others call it only on
close(). I guess this depends very much on driver's logic :)
If nobody minds, than I would assume that tg3.c is a good example and I
would move the timout path into a workqueu.

Sebastian
