From: Andy Fleming <afleming@freescale.com>
Subject: Re: phylib interrupt question
Date: Fri, 6 Jun 2008 12:11:38 -0500
Message-ID: <4B4372CF-7AE3-40B2-980D-4D65637E7382@freescale.com>
References: <OF401D8BC0.37350235-ONC1257460.005643D3-80257460.00589565@smsc.com>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:37300 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753699AbYFFRLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 13:11:50 -0400
In-Reply-To: <OF401D8BC0.37350235-ONC1257460.005643D3-80257460.00589565@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 6, 2008, at 11:07, steve.glendinning@smsc.com wrote:

> Hi everybody,
>
> I'm converting an ethernet driver to use phylib, and I have an  
> interrupt
> question.  My device is an integrated mac/phy, with the option to  
> disable
> the internal phy and use an external phy instead.  I've succesfully  
> used
> phylib in polling mode, but I'd like to convert this to be
> interrupt-driven if possible.
>
> When using the internal phy, it can raise interrupts via the mac (by
> setting a "phy interrupt" bit in the mac's interrupt status  
> register).  Is
> there a way of signalling this phy interrupt to phylib from my mac
> driver's isr?  Phylib seems to want to connect to a real irq?

Hm.  Looks like one of the features of Phylib got accidentally  
dropped.  However, it's a simple 2-line fix which I'm about to submit.

The Phylib supports *three* methods of link state detection:

1) The Phylib handles the irq.  To get this functionality, you set  
phydev->irq to the irq number.  Obviously, this doesn't work if your  
PHY is sending interrupts through your MAC's interrupt.  You don't  
want your MAC's interrupts disabled while the PHY is being managed!

2) The Phylib polls the PHY regularly.  To get this, you set phydev- 
 >irq to PHY_POLL.  Obvious deficiencies, but it's easiest

3) Something else handles the irq, and then tells the Phylib to check  
the state.  To get this, you set phydev->irq to PHY_IGNORE_INTERRUPT.   
Sadly, this requires that we not assume that !PHY_POLL is the same as  
option #1, which in 2 instances, we forgot to do.  I am sending a  
patch right after this to fix that.

Then, in your interrupt handler, you do something like this:

if (interrupt_cause & PHY_INTERRUPT) {
	err = phy_disable_interrupts(phydev);
	if (err)
		goto phy_err;

	mutex_lock(&phydev->lock);
	 if ((PHY_RUNNING == phydev->state) || (PHY_NOLINK == phydev->state))
		phydev->state = PHY_CHANGELINK;
	mutex_unlock(&phydev->lock);

	// clear PHY_INTERRUPT bit
}

This will tell the Phylib that an interrupt occurred, and it will read  
the link status in the normal fashion.

Clearly, you will be the first to blaze this trail, so let us know if  
there are any problems, since one of the goals was for phylib to  
support that functionality.

Andy
