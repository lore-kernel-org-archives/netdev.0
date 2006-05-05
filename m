From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 1.3-rc1
Date: Fri, 5 May 2006 12:43:10 -0700
Message-ID: <20060505124310.1ff486f0@localhost.localdomain>
References: <1146667951.3056.25.camel@fc5test.deadmoose.com>
	<20060503120507.4558c675@localhost.localdomain>
	<445B626B.1070407@gentoo.org>
	<20060505173509.GK2757@cip.informatik.uni-erlangen.de>
	<20060505104536.2baefa5e@localhost.localdomain>
	<445B9C93.4070406@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>,
	Bill Hoover <bill@luminescent.com>,
	Bertrand Jacquin <beber@gna.org>, micheleschi@libero.it,
	netdev@vger.kernel.org, teppic74@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15017 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751750AbWEETn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 15:43:56 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <445B9C93.4070406@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 05 May 2006 19:42:27 +0100
Daniel Drake <dsd@gentoo.org> wrote:

> Stephen Hemminger wrote:
> > What is happening is that if there is a misconfiguration and irq routing
> > is messed up (ie edge trigged). The driver will degenerate to polling every 100ms.
> > If your system is this misconfigured, then ACPI or the BIOS needs to be fixed
> > and the driver really only needs to work well enough to get the bug report out ;-)
> 
> Ok, thanks for the explanation.
> 
> Can you give any hints as to how we can classify this misconfiguration? 
> Barry's system has a level triggered IRQ assigned to sky2, and that IRQ 
> is not shared:
> 
> http://bugs.gentoo.org/show_bug.cgi?id=132056#c3
> 
> I'm just looking for something I can take to the ACPI developers, other 
> than "its broken because Stephen said so" ;)

Try running idle_timeout=0 module parameter.  In that case there will be no
polling timer.  If it just hangs, then the problem is missed interrupt.

You could use this to see if you are getting irq's

--- sky2.orig/drivers/net/sky2.c
+++ sky2/drivers/net/sky2.c
@@ -2125,6 +2125,9 @@ static int sky2_poll(struct net_device *
 	int work_done = 0;
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
+	if (netif_msg_intr((struct sky2_port *) netdev_priv(dev0)))
+		printk(KERN_DEBUG PFX "poll status %#x\n", status);
+
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
 
@@ -2183,6 +2186,9 @@ static irqreturn_t sky2_intr(int irq, vo
 	if (status == 0 || status == ~0)
 		return IRQ_NONE;
 
+	if (netif_msg_intr((struct sky2_port *) netdev_priv(dev0)))
+		printk(KERN_DEBUG PFX "irq status %#x\n", status);
+
 	prefetch(&hw->st_le[hw->st_idx]);
 	if (likely(__netif_rx_schedule_prep(dev0)))
 		__netif_rx_schedule(dev0);
