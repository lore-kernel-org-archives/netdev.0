From: Lucas Stach <dev@lynxeye.de>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Tue, 29 Nov 2011 20:09:47 +0100
Message-ID: <1322593787.1642.6.camel@tellur>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km20343-01.keymachine.de ([84.19.182.79]:41284 "EHLO
	km20343-01.keymachine.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753699Ab1K2TJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 14:09:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[please cc me on every answer, I'm not subscribed to the list]

Hello Francois and others,

>Gerd, can you try the patch below ? It should match Haye's description.
>
>diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
>index 6f06aa1..97b5593 100644
>--- a/drivers/net/ethernet/realtek/r8169.c
>+++ b/drivers/net/ethernet/realtek/r8169.c
>@@ -4885,8 +4885,7 @@ static void rtl_hw_start_8168(struct net_device *dev)
> 	RTL_W16(IntrMitigate, 0x5151);
> 
> 	/* Work around for RxFIFO overflow. */
>-	if (tp->mac_version == RTL_GIGA_MAC_VER_11 ||
>-	    tp->mac_version == RTL_GIGA_MAC_VER_22) {
>+	if (tp->mac_version == RTL_GIGA_MAC_VER_11) {
> 		tp->intr_event |= RxFIFOOver | PCSTimeout;
> 		tp->intr_event &= ~RxOverflow;
> 	}
>@@ -5804,6 +5803,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
> 	 */
> 	status = RTL_R16(IntrStatus);
> 	while (status && status != 0xffff) {
>+		status &= ~tp->intr_event;
>+		if (!status)
>+			break;
>+
> 		handled = 1;
> 
> 		/* Handle all of the error cases first. These will reset
>@@ -5818,7 +5821,6 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
> 			switch (tp->mac_version) {
> 			/* Work around for rx fifo overflow */
> 			case RTL_GIGA_MAC_VER_11:
>-			case RTL_GIGA_MAC_VER_22:
> 			case RTL_GIGA_MAC_VER_26:
> 				netif_stop_queue(dev);
> 				rtl8169_tx_timeout(dev);
>@@ -5828,6 +5830,7 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
> 			case RTL_GIGA_MAC_VER_19:
> 			case RTL_GIGA_MAC_VER_20:
> 			case RTL_GIGA_MAC_VER_21:
>+			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_23:
 			case RTL_GIGA_MAC_VER_24:
 			case RTL_GIGA_MAC_VER_27:

I have tried the above patch in an attempt to solve my problem described
in message "Lockups with r8169 driver (Was: Hangs with Linux
3.2.0-rc3)", which are really similar to the problem described in this
thread.

The patch doesn't help, in fact it renders the ethernet adapter
unusable, as it is failing even the media detect (according to network
manager). I will gladly test any other patches you come up with.

Thanks,
Lucas
