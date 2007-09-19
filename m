From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: [Bug, PATCH and another Bug] Was: Fix refcounting problem with netif_rx_reschedule()
Date: Wed, 19 Sep 2007 15:23:48 +0200
Message-ID: <200709191523.48874.ossthema@de.ibm.com>
References: <20070919115403.19455.65941.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, rdreier@cisco.com,
	general@lists.openfabrics.org, Christoph Raisch <raisch@de.ibm.com>
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:47449 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759281AbXISNXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:23:52 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id l8JDNohh126714
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 13:23:50 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8JDNo8A2171028
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 15:23:50 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8JDNnsY000422
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 15:23:50 +0200
In-Reply-To: <20070919115403.19455.65941.sendpatchset@K50wks273871wss.in.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wednesday 19 September 2007 13:54, Krishna Kumar wrote:
> CPU#1: ipoib_poll(budget=100)
> {
> 	A. process 100 skbs
> 	B. netif_rx_complete()
> 	<Process unrelated interrupts; executes slower than steps C, D, E on
> 	 CPU#2>
> 	F. ib_req_notify_cq() (no missed completions, do nothing)
> 	G. return 100
> 	H. return to net_rx_action, quota=99, subtract 100, quota=-1, BUG.
> }
> 
> CPU#2: ipoib_ib_completion() : (starts and finishes entire line of execution
> 				*after* step B and *before* H executes).
> {
> 	C. New skb comes, call netif_rx_schedule; set quota=100
> 	D. do ipoib_poll(), process one skb, return work=1 to net_rx_action
> 	E. net_rx_action: set quota=99
> }

If I understood it right the problem you describe (quota update in 
__napi_schdule) can cause further problems when you choose the
following numbers:

CPU1: A. process 99 pkts
CPU1: B. netif_rx_complete()
CPU2: interrupt occures, netif_rx_schedule is called, net_rx_action triggerd:
CPU2: C. set quota = 100 (__napi_schedule)
CPU2: D. call poll(), process 1 pkt
CPU2: D.2 call netif_rx_complete() (quota not exeeded)
CPU2: E. net_rx_action: set quota=99
CPU1: F. net_rx_action: set qutoa=99 - 99 = 0
CPU1: G. modify list (list_move_tail) altough netif_rx_complete has been called

Step G would fail as the device is not in the list due 
to netif_rx_complete. This case can occur for all
devices running on an SMP system where interrupts are not pinned.

Regards,
Jan-Bernd

