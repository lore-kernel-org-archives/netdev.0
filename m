From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: RX/close vcc race with solos/atmtcp/usbatm/he
Date: Fri, 28 May 2010 14:33:22 +0100
Message-ID: <1275053602.4355.38.camel@macbook.infradead.org>
References: <1274872584.20576.13579.camel@macbook.infradead.org>
	 <20100528.034628.200383563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	nathan@traverse.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52183 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755888Ab0E1Nd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 09:33:28 -0400
In-Reply-To: <20100528.034628.200383563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-28 at 03:46 -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Wed, 26 May 2010 12:16:24 +0100
> 
> > Can anyone see a better approach -- short of rewriting the whole ATM
> > layer to make the locking saner?
> 
> There is no doubt in my mind that these VCC objects need to be
> refcounted when used like this.

Perhaps. Although in the general case they're tied to the 'struct sock'
and don't need to outlive it. These drivers which look up the VCC to
feed incoming packets to it are the only exception to that rule that I'm
aware of.

> The only other alternative is to make use of something like RCU.

I agree. In fact the use of tasklet_unlock_wait() in my patch is what I
settled on when I went looking for 'something like RCU' to solve this
particular case. I was _going_ to add RCU stuff, but realised that this
was sufficient.

In the close() path we clear the READY bit in the VCC, wait for the
tasklet to finish using it, and only then do we destroy the VCC.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

