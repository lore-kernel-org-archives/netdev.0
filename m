From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [Bug, PATCH and another Bug] Was: Fix refcounting problem with netif_rx_reschedule()
Date: Thu, 20 Sep 2007 10:40:33 +0530
Message-ID: <OF42EA8B8A.CAFE186B-ON6525735C.001BE132-6525735C.001C6EC0@in.ibm.com>
References: <200709191523.48874.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, general@lists.openfabrics.org,
	netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	rdreier@cisco.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from E23SMTP03.au.ibm.com ([202.81.18.172]:32917 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbXITFJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 01:09:18 -0400
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8K59GNb007202
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:09:16 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8K59GCv4546758
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:09:16 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8K57k1j001897
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 15:07:46 +1000
In-Reply-To: <200709191523.48874.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan-Bernd,

Jan-Bernd Themann <ossthema@de.ibm.com> wrote on 09/19/2007 06:53:48 PM:

> If I understood it right the problem you describe (quota update in
> __napi_schdule) can cause further problems when you choose the
> following numbers:
>
> CPU1: A. process 99 pkts
> CPU1: B. netif_rx_complete()
> CPU2: interrupt occures, netif_rx_schedule is called, net_rx_action
triggerd:
> CPU2: C. set quota = 100 (__napi_schedule)
> CPU2: D. call poll(), process 1 pkt
> CPU2: D.2 call netif_rx_complete() (quota not exeeded)
> CPU2: E. net_rx_action: set quota=99
> CPU1: F. net_rx_action: set qutoa=99 - 99 = 0
> CPU1: G. modify list (list_move_tail) altough netif_rx_complete has been
called
>
> Step G would fail as the device is not in the list due
> to netif_rx_complete. This case can occur for all
> devices running on an SMP system where interrupts are not pinned.

I think list_move should be ok whether device is on the list or not.
But it should not come to that code since work (99) != weight (100).
If work == weight, then driver would not have done complete, and the
next/prev would not be set to POISON.

I like the clean changes made by Dave to fix this, and will test it
today (if I can get my crashed system to come up).

Thanks,

- KK

