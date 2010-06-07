From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] RX/close vcc race with solos/atmtcp/usbatm/he
Date: Mon, 07 Jun 2010 09:44:44 -0400
Message-ID: <201006071344.o57DiiCx018593@thirdoffive.cmf.nrl.navy.mil>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
Reply-To: chas3@users.sourceforge.net
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:51853 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530Ab0FGNuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:50:07 -0400
Reply-To: chas3@users.sourceforge.net
In-reply-to: <1274872584.20576.13579.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <1274872584.20576.13579.camel@macbook.infradead.org>,David Woodhouse
 writes:
>The problem is that the 'find_vcc' functions in these drivers are
>returning a vcc with the ATM_VF_READY bit cleared, because it's already
>in the process of being destroyed. If we fix that simple oversight,
>there's still a race condition because the socket can still be closed
>(and completely freed, afaict) between our call to find_vcc() and our
>call to vcc->push() in the RX tasklet.
...
>Can anyone see a better approach -- short of rewriting the whole ATM
>layer to make the locking saner?

vcc's are really sockets, so you could just increase the refcount --
sock_hold().  after you push the packet, drop the refcount, sock_put()
and hopefully things will be well.  however, i think the close routines
dont really expect this behavior so the card driver's vcc close might
need to be changed to wait around if the refcount on the vcc is > 1.
or perhaps the driver independent part needs to do this.

the he driver works around this issue by holding vcc_sklist_lock around
the find_vcc and ->push() which happen to occur in the same tasklet.
