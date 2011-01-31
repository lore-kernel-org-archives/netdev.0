From: Jouni Malinen <j@w1.fi>
Subject: r8169 and unicast RX failing after suspend/resume
Date: Mon, 31 Jan 2011 16:16:32 +0200
Message-ID: <20110131141632.GA3981@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from w1.fi ([128.177.27.249]:36585 "EHLO
	jmalinen.user.openhosting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755858Ab1AaOZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 09:25:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like r8169 is not resetting its own MAC address properly in
suspend/resume with some hardware models. At least on my HP Pavilion dv5
laptop, the ethernet connection is lost every time after suspend/resume
sequence. I used to work around this by setting the card in promiscuous
mode in the past, but I finally got frustrated enough with that to take
a closer look at what is happening.

It looks like the card comes up otherwise just fine apart from unicast
RX not working. In other words, it has no problems sending out frames or
receiving broadcast frames. However, no unicast frames are received.
There are no clear error messages anywhere in the kernel debug log.

This started to look like a some kind of issue in configuring MAC
address based RX filter in the hardware and indeed, I was able to
recover from this state by just re-configuring the MAC address with
"ifconfig eth0 hw ether <own addr>" after suspend (this is without the
promiscuous mode workaround I used before). That seems to update
something in the hardware that fixes unicast RX and that needs to be
repeated after each suspend/resume cycle. The correct MAC address is
still maintained in the driver (e.g., ifconfig eth0 shows it after
resume), so this looks like just some reconfiguration of hardware is
missing from the resume path.

The card I have is identified in this way:

09:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
(10ec:8168)

r8169 Gigabit Ethernet driver 2 .3LK-NAPI loaded
eth0: RTL81 68c/8111c at 0xffffc90000060000, 00:1e:68:99:b9:3e, XID 1c4000c0 IRQ 45


The kernel is the current wireless-testing.git head (2.6.38-rc2-wl+) and
this issue has existed since I've got that laptop, so it does not look
like a regression.

Is this a known issue or is there some additional information that would
be needed to get this fixed? As far as I can tell, just running
set_mac_address after resume would be enough to fix the problem. I'm not
sure whether this is the best way of fixing this, but the patch below
seems to work at least with my laptop:

--- wireless-testing.orig/drivers/net/r8169.c	2011-01-31 16:09:41.000000000 +0200
+++ wireless-testing/drivers/net/r8169.c	2011-01-31 16:10:59.000000000 +0200
@@ -4901,6 +4901,7 @@ static int rtl8169_resume(struct device
 	struct rtl8169_private *tp = netdev_priv(dev);
 
 	rtl8169_init_phy(dev, tp);
+	rtl_rar_set(tp, dev->dev_addr);
 
 	if (netif_running(dev))
 		__rtl8169_resume(dev);

-- 
Jouni Malinen                                            PGP id EFC895FA
