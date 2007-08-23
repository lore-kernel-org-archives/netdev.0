From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: New NAPI interface: netif_rx_reschedule not working
Date: Thu, 23 Aug 2007 18:21:25 +0200
Message-ID: <200708231821.25504.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>
To: David.Miller@dyn-9-152-217-48
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:20969 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbXHWQV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 12:21:27 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7NGLQre128880
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 16:21:26 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7NGLQ9q2285654
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 18:21:26 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7NGLPsh004363
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2007 18:21:26 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

when trying to get our driver working with the new interface, 
I found the following issue where I'm not sure how to solve it best:

netif_rx_reschedule() does not work when called after netif_rx_complete().
The problem is that netif_rx_reschedule currently adds the napi struct once 
more to the poll list. However, net_rx_action will add it to the poll list
as well (NAPI_STATE_SCHED set), so the device is scheduled twice. 
Next time netif_rx_complete is called for the second schedule, 
it will result in BUG() because NAPI_STATE_SCHED
is not set anymore (cleared by first netif_rx_complete()).

Modifying netif_rx_reschedule to only set NAPI_STATE_SCHED flag again
and not adding the device to the poll_list will not solve the problem entirely.

After netif_rx_complete() the driver activates the IRQs again. If
an IRQ is caught on a different CPU before netif_rx_reschedule is called,
we will have the napi device scheduled twice again... because
net_rx_action will schedule it and netif_rx_schedule as well
(add it to poll_list).

I think this is an issue that can even occur if you don't use
netif_rx_reschedule. Do I understand this correctly?

Thanks,
Jan-Bernd

