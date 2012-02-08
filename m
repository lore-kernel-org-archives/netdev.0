From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug#656331: RTL8168b/8111b with ASUS M2A-VM (SB600): Network device stays down after resume
Date: Wed, 8 Feb 2012 23:16:44 +0100
Message-ID: <20120208221644.GA25538@electric-eye.fr.zoreil.com>
References: <1326896138.29125.86.camel@mattotaupa> <1326899011.3271.3.camel@deadeye> <1326900763.29125.117.camel@mattotaupa> <1326901834.3271.8.camel@deadeye> <1328383563.20142.23.camel@mattotaupa> <20120205175730.GA23604@electric-eye.fr.zoreil.com> <1328714917.3483.21.camel@mattotaupa> <1328730429.3483.35.camel@mattotaupa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, 656331@bugs.debian.org,
	netdev@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Paul Menzel <pm.debian@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38326 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab2BHW2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 17:28:41 -0500
Content-Disposition: inline
In-Reply-To: <1328730429.3483.35.camel@mattotaupa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Menzel <pm.debian@googlemail.com> :
[forget runtime PM]
>         [18764.958557] r8169 0000:02:00.0: PME# disabled
>         [18781.998004] r8169 0000:02:00.0: eth0: link down
                     ^^
>         [18781.998024] r8169 0000:02:00.0: eth0: link down
                     ^^
Two link events within 20 us. /me wonders...

The datasheet states "[the PHYStatus] register is updated continuously at
maximum periods of 300us." but it is far from clear that the coherency
with the interrupt status register can be taken for granted. Hayes ?

Paul, can you try the hack below ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7a0c800..6daca05 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1278,6 +1278,7 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 {
 	unsigned long flags;
 
+	udelay(500);
 	spin_lock_irqsave(&tp->lock, flags);
 	if (tp->link_ok(ioaddr)) {
 		rtl_link_chg_patch(tp);
