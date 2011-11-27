From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Mon, 28 Nov 2011 00:11:47 +0100
Message-ID: <20111127231147.GA1784@electric-eye.fr.zoreil.com>
References: <20111124044137.GA18262@elie.hsd1.il.comcast.net> <4ECFE7A7.5070300@wolke7.net> <20111125201936.GA26692@elie.hsd1.il.comcast.net> <1322253122.2550.3.camel@edumazet-laptop> <20111125222211.GA13719@electric-eye.fr.zoreil.com> <1322262357.2550.12.camel@edumazet-laptop> <20111126004447.GA14744@electric-eye.fr.zoreil.com> <1322280423.10212.3.camel@edumazet-laptop> <20111127092808.GE21635@elie.hsd1.il.comcast.net> <4ED2A573.1020807@wolke7.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Nieder <jrnieder@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Hayes Wang <hayeswang@realtek.com>
To: booster@wolke7.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51851 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab1K0XSC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 18:18:02 -0500
Content-Disposition: inline
In-Reply-To: <4ED2A573.1020807@wolke7.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

booster@wolke7.net <booster@wolke7.net> :
[...]
> Jonathan, I compiled a new kernel with the patch described above but the
> behavior is still the same. During high network load the link hangs:
> 
> [  195.332478] r8169 0000:02:00.0: eth0: link up
> [  222.517171] r8169 0000:02:00.0: eth0: link up
> [  222.908277] r8169 0000:02:00.0: eth0: link up
> [  223.508249] r8169 0000:02:00.0: eth0: link up

It does recover, doesn't it ?

> Is there a way to activate more driver debugging in the kernel ?

You can lower the delay in rtl8169_schedule_work (4) but it is akin
to papering over the issue.

You may try the stuff below in place of the current patch. I will not
be surprized if the link really hangs (no crash but no traffic).

Hayes, does the 8168c require something special to recover from Rx FIFO
overflow ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f06aa1..e937737 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -427,6 +427,7 @@ enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
 	PCSTimeout	= 0x4000,
+	RxFIFOEmpty	= 0x0200,
 	SWInt		= 0x0100,
 	TxDescUnavail	= 0x0080,
 	RxFIFOOver	= 0x0040,
@@ -5815,15 +5816,27 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		}
 
 		if (unlikely(status & RxFIFOOver)) {
+			int i;
+
 			switch (tp->mac_version) {
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
 				goto done;
 			/* Testers needed. */
+			case RTL_GIGA_MAC_VER_22:
+				for (i = 0; i < 4000000; i++) {
+					if (RTL_R16(IntrStatus) & RxFIFOEmpty) {
+						RTL_W16(IntrStatus, RxFIFOOver);
+						printk(KERN_INFO "FEmp %d\n", i);
+						break;
+					}
+					udelay(10);
+				}
+				if (i >= 4000000)
+					printk(KERN_ERR "no FEmp\n");
 			case RTL_GIGA_MAC_VER_17:
 			case RTL_GIGA_MAC_VER_19:
 			case RTL_GIGA_MAC_VER_20:
