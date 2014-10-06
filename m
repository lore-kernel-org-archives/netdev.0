From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/2] sunvnet: Packet processing in non-interrupt
 context.
Date: Mon, 6 Oct 2014 12:04:18 -0400
Message-ID: <20141006160418.GA3604@oracle.com>
References: <20141002201203.GA6001@oracle.com>
 <20141002.134346.2291749763304558513.davem@davemloft.net>
 <20141003144024.GA12448@oracle.com>
 <20141003.120802.1213573830649867131.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33288 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912AbaJFQE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 12:04:28 -0400
Content-Disposition: inline
In-Reply-To: <20141003.120802.1213573830649867131.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think you should be able to get rid of all of the in-driver
> locking in the fast paths.
> 
> NAPI ->poll() is non-reentrant, so all RX processing occurs
> strictly in a serialized environment.
> 
> Once you do TX reclaim in NAPI context, then all you have to do is
> take the generic netdev TX queue lock during the evaluation of whether
> to wakeup the TX queue or not.  Worst case you need to hold the
> TX netdev queue lock across the whole TX reclaim operation.
> 
> The VIO lock really ought to be entirely superfluous in the data
> paths.

A few clarifications, since there are more driver-examples using NAPI for
Rx than for Tx reclaim

so I can move the LDC_EVENT_RESET/LDC_EVENT_UP processing code into the 
napi callback, and that enables the removal of irqsave/restore for
vio.lock from vio_port_up at the least (I do this conditional on
in_softirq() so as to not perturb vdc code at the moment)

But there are still a lot of irqsaves at the ldc layer for the lp lock.
I dont know if these can/should be optimized out. 

I looked at tg3 for a template on how to use NAPI in the TX path
The analog of the tg3_poll_work->tg3_tx invocation is probably the
maybe_tx_wakeup call triggered from the Rx side vnet processing,
which, with NAPI happens naturally from softirq context (no need for
extra tasklet). 

Regarding rcu locking of port_list and the hash in struct vnet_port,
the thorn here is that vnet_set_rx_mode may end up allocating a
vnet_mcast_entry as part of __update_mc_list
(there may be a different bug here in that it assumes that the 
first entry is the switch_port, and this is the only switch_port)
I dont know of a simple way to avoid that (a rwlock just for this
function?!).

But we still need to hold the vio lock around the ldc_write 
(and also around dring write) in vnet_start_xmit, right?

--Sowmini
