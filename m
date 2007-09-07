From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: new NAPI interface broken
Date: Fri, 7 Sep 2007 11:37:02 +0200
Message-ID: <200709071137.02801.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, themann@de.ibm.com,
	Christoph Raisch <raisch@de.ibm.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:51594 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965034AbXIGJhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 05:37:07 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id l879b5kT1140318
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 09:37:05 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l879b5TA2277628
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 11:37:05 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l879b47Q013688
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 11:37:05 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

I saw that you developed most of the new NAPI interface.
I already addressed this issue a while ago. Please correct me if I got
it wrong. I think there is still a serious problem with the NAPI
changes to make NAPI polling independent of struct net_device objects.
Its about the question who inserts and removes devices from the poll list.

netif_rx_schedule: sets NAPI_STATE_SCHED flag, insert device in poll list.
netif_rx_complete: clears NAPI_STATE_SCHED
netif_rx_reschedule: sets NAPI_STATE_SCHED, insert device in poll list.
net_rx_action: 
 -removes dev from poll list
 -calls poll function
 -adds dev to poll list if NAPI_STATE_SCHED still set

1) netif_rx_complete and netif_rx_reschedule don't work together
2) On SMP systems: after netif_rx_complete has been called on CPU1
   (+interruts enabled), netif_rx_schedule could be called on CPU2 
   (irq handler) before net_rx_action on CPU1 has checked NAPI_STATE_SCHED. 
   In that case the device would be added to poll lists of CPU1 and CPU2
   as net_rx_action would see NAPI_STATE_SCHED set.
   This must not happen. It will be caught when netif_rx_complete is
   called the second time (BUG() called)

This would mean we have a problem on all SMP machines right now.

If I got all this right then we probably need a further flag to tell
net_rx_action whether to poll again or to stop (with the possibility
that the device has been scheduled on a different CPU in between).
The "old" NAPI interface uses the return value of poll to determine
if the device has to be polled again or not. 
We can either switch back or in case we want to stick to
the new return value, we might have to add something similar to 
the NAPI_STATE_SCHED flag or a new parameter...

Regards,
Jan-Bernd
