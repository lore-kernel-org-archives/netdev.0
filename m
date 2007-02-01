From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] r8169: fix a race between PCI probe and dev_open
Date: Thu, 01 Feb 2007 08:04:58 -0500
Message-ID: <45C1E57A.40502@pobox.com>
References: <20070131213428.GA17534@electric-eye.fr.zoreil.com> <Pine.LNX.4.64.0701311655050.3632@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030809050508040200060008"
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>, Bernhard Walle <bwalle@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39374 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422852AbXBANFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 08:05:10 -0500
In-Reply-To: <Pine.LNX.4.64.0701311655050.3632@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030809050508040200060008
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Linus Torvalds wrote:
> 
> On Wed, 31 Jan 2007, Francois Romieu wrote:
> 
>> Call chain:
>> -> rtl8169_init_one
>>    -> register_netdev                  (dev_open starts to race...)
>>    -> rtl8169_init_phy
>>       -> rtl8169_set_speed
>>          -> tp->set_speed
>>          -> mod_timer(&tp->timer, ...) (if netif_running() is true)
>>
>> As netif_running() is true just before dev->open() is issued and the
>> timer is initialized during dev->open, mod_timer() meets an uninitialized
>> tp->timer and oopses.
> 
> Doesn't this basically mean that *any* use of "rtl8169_set_speed()" is 
> buggy?

No, just the first use, after which the one-time initialization occurs.


> Anyway, I'm going to wait for somebody smarter than me to ACK this patch. 
> Jeff?

I would rather have something more like the attached patch, which 
initializes the timer with the rest of the private-struct 
initialization.  Just like most other net drivers do.


And Herbert Xu wrote:
> Does rtl8169_init_phy need to occur after register_netdev? Normally
> register_netdev should be the very last thing in a probe routine.

Quite correct.



So... anybody wanna test my patch (didn't compile it, but it looks 
right) and confirm that it fixes things?

	Jeff





--------------030809050508040200060008
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 577babd..ce66b2a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1369,11 +1369,7 @@ static inline void rtl8169_request_timer(struct net_device *dev)
 	    (tp->phy_version >= RTL_GIGA_PHY_VER_H))
 		return;
 
-	init_timer(timer);
-	timer->expires = jiffies + RTL8169_PHY_TIMEOUT;
-	timer->data = (unsigned long)(dev);
-	timer->function = rtl8169_phy_timer;
-	add_timer(timer);
+	mod_timer(timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1686,6 +1682,10 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->mmio_addr = ioaddr;
 	tp->align = rtl_cfg_info[ent->driver_data].align;
 
+	init_timer(&tp->timer);
+	tp->timer.data = (unsigned long)(dev);
+	tp->timer.function = rtl8169_phy_timer;
+
 	spin_lock_init(&tp->lock);
 
 	rc = register_netdev(dev);

--------------030809050508040200060008--
