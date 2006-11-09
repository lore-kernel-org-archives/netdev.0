From: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>
Subject: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow interrupt handler to disable receive interrupts at high bi-directional traffic
Date: Thu, 9 Nov 2006 19:52:30 +0530
Message-ID: <010C7BAE6783F34D9AC336EE5A01A08802BB30D7@dbde01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:63687 "EHLO bear.ext.ti.com")
	by vger.kernel.org with ESMTP id S966029AbWKIOW2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 09:22:28 -0500
Received: from dlep34.itg.ti.com ([157.170.170.115])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id kA9EMN5u026908
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 08:22:28 -0600
Received: from dlep95.itg.ti.com (localhost [127.0.0.1])
	by dlep34.itg.ti.com (8.13.7/8.13.7) with ESMTP id kA9EMNEa027063
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 08:22:23 -0600 (CST)
Received: from dbde01.ent.ti.com (localhost [127.0.0.1])
	by dlep95.itg.ti.com (8.13.7/8.13.7) with ESMTP id kA9EMJrI000506
	for <netdev@vger.kernel.org>; Thu, 9 Nov 2006 08:22:22 -0600 (CST)
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

I found an issue with Realtek 8139 driver (2.6.10 branch) at high
bi-directional traffic. On transmit timeout, driver's timeout callback
re-enables the receive interrupt. On the next receive interrupt, the ISR
disables the receive interrupt "only" when the receive poll task is not
active. But the poll task is actually active and hence it doesn't
disable the receive interrupt. So the ISR returns without clearing the
receive interrupt. This un-serviced receive interrupt brings the system
into hung state.

My understanding here is, on receive interrupt the ISR should disable
the receive interrupt irrespective of the polling task's state (active
or inactive). I changed the code (as shown below) and it works
perfectly. 

Is this a known issue? If so, is there a fix already available?

Also, we get frequent TX timeouts during high rate of traffic. What
could be the reason for this frequent TX timeouts?
 

--- old/8139too.c	2006-11-09 11:49:25.000000000 +0530
+++ new/8139too.c	2006-11-09 11:50:02.000000000 +0530
@@ -2200,8 +2200,8 @@
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
 	if (status & RxAckBits){
-		if (netif_rx_schedule_prep(dev)) {
 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
+		if (netif_rx_schedule_prep(dev)) {
 			__netif_rx_schedule (dev);
 		}
 	}


Thanks
Mansoor
