From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 0/5] dynamic detection of gianfar TPIPA
Date: Thu, 10 Apr 2008 23:34:27 -0400
Message-ID: <20080411033427.GA28413@windriver.com>
References: <1207849922-2436-1-git-send-email-paul.gortmaker@windriver.com>
	<3F8109F5-F512-48CD-AD93-2C6B4164E5AA@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: scottwood@freescale.com, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <3F8109F5-F512-48CD-AD93-2C6B4164E5AA@freescale.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

In message: Re: [PATCH 0/5] dynamic detection of gianfar TPIPA
on 10/04/2008 Andy Fleming wrote:

>
> I may be missing something, but I don't think this quite right.
>
> If you have a PHY at 0x1f, this patchset will cause no PHY device to be 
> allocated for that address, and you'll actually end up assigning TBIPA to 
> be 0x1f again, since there's no PHY there.  Right?  Were you able to use 
> this code with a PHY at 0x1f?

I tested on several "normal" boards and on a board with the PHY @ 0x1f,
and it did what I expected it to do.  It was when I was testing on the
normal boards (8540MDS, 8360MDS, HPCN) that I observed we were showing
a PHY ID of 0x0 at 0x1f during the routine PHY scan, because the
autodetect code was skipping 0x1f even on those boards.  I backed out
all my patches and the situation was the same, hence why I decided to
skip IDs of either 0xffff or 0x0.


> I like the idea of passing around priv->mii_bus instead of regs, but I  
> think it won't work without becoming unnecessarily unwieldy.  The  
> problem is that the TBI PHY is not necessarily accessed through the same 
> bus as the PHY.  Each controller has its own TBI PHY, and that PHY can 
> only be accessed from *that* controller's MDIO bus.  So if you want to 
> configure TSEC2's TBI PHY, you use TSEC2's MDIO regs.  That's what 
> gfar_local_mdio_* allowed; they write the *local* controller's MDIO regs. 
>  It looks like this code sets up priv->mii_bus to point at the bus which 
> holds the PHY, but only TSEC0's bus (on most SoCs) is connected to actual 
> PHYs.  So you will only ever be able to configure the TBI PHY on TSEC0, 
> which will not allow any of the other TSECs to use an SGMII PHY.  Were 
> you able to use other TSECs to connect to an SGMII PHY?

Okay -- that explanation helps me understand the role of the *_local_*
variants -- it wasn't obvious to me that they were being used to jump
the device --> bus association and go right at MDIO bus of tsec0.  I
think this can still be handled sanely though -- we'd have to simply
say that if you wanted the bus of the TBI of the controller, you would
go at dev->priv->mii_bus, and if you wanted the bus of the PHY of the
controller, you'd go at dev->priv->phydev->bus.  I'd have to think a bit
to see if that would afford the same or similar cleanups, but the
distinction at least seems clearer to me now.

> We could still pass around an mii_bus reference, but this would require 
> creating an mii_bus instance for every single TSEC, which is a little 
> heavyweight when we just want to configure the TBI PHY once on startup.

Yep.  Is there any boards out there with more than 4 tsec?  I'd have
to go look at the size of mii_bus to see what the per bus cost is.

>
> After some thinking, I went ahead and implemented a patch which isn't  
> ideal, but should solve the problems your patches set out to solve.   
> I've sent it in a separate message.  If you have some systems with SGMII 
> and/or a PHY at 0x1f, please test this patch on them.  I don't currently 
> have either.

I'll go have a look.  I've only got the SBC8641D with the PHY @ 0x1f to
be the oddball guniea pig.

Paul.

>
> Andy
>
