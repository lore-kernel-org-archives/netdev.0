From: Andy Fleming <afleming@FREESCALE.COM>
Subject: Re: Generic PHY lib vs. locking
Date: Thu, 28 Dec 2006 12:55:02 -0600
Message-ID: <34B0D342-2B8E-4BF8-A568-7071D3695FB0@freescale.com>
References: <1166760473.6673.85.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:47018 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011AbWL2Bcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Dec 2006 20:32:42 -0500
In-Reply-To: <1166760473.6673.85.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Dec 21, 2006, at 22:07, Benjamin Herrenschmidt wrote:

> Hi Andy !
>
> I've been looking at porting various drivers (EMAC, sungem,
> spider_net, ...) to the generic PHY stuff. However, I have one
> significant problem here.
>
> One of the things I've been trying to do lately with EMAC and that I
> plan to do with others, is to have the PHY polling entirely operate at
> task level (along with other "slow" parts of the network driver like
> timeout handling etc...).
>
> This makes a lot of locking easier, allowing to use mutexes instead of
> locks (less latencies), allowing to sleep waiting for MDIO  
> operations to
> complete, etc... it's generall all benefit.
>
> It's especially useful in a case like EMAC where several EMACs can  
> share
> MDIO lines, so we need exclusive access, and that might involve even a
> second layer of exclusion for access to the RGMII or ZMII layer.  
> mutexes
> are really the best approach for that sort of non-speed critical
> activities.


This sounds good to me.  It was an eventual goal, but I wasn't  
familiar enough with the non-spin-lock locking rules to confidently  
implement it.


>
> However, the generic PHY layer defeats that by it's heavy usage of
> spin_lock_bh and timer.
>
> One solution would be to change it to use a mutex instead of a lock as
> well, though that would change the requirements of where phy_start/ 
> stop
> can be called, and use a delayed work queue instead of a timer.
>
> I could do all of these changes provided everybody agrees, though I
> suppose all existing network drivers using that PHY layer might  
> need to
> be adapted. How many do we have nowadays ?


Great!  At last glance, only gianfar, fs_enet, and au1000_eth.  There  
are one or two others that haven't gone in, yet.  My hope is that  
your changes will not require any changes to the drivers, but I'll  
leave that to your discretion.


>
> Also, I see your comments about not calling flush_scheduled_work() in
> phy_stop() because of rtnl_lock()... What is the problem here ?
> dev_close() ?


Yup.  However, I think a reasonable solution was proposed.  The  
problem is that flush_scheduled_work() actually does all the  
scheduled work.  And if it happens with rtnl_lock() held, and some of  
the scheduled work grabs rtnl_lock(), we deadlock.  But another  
function was proposed, and I believe committed to the tree, which  
only deletes or does the work you own, and therefore lets you avoid  
that problem (assuming you know that your code doesn't grab such  
locks), and also lets you free memory.

Andy
