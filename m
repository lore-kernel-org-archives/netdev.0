From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCH net-next 3/3] sunvnet: Schedule maybe_tx_wakeup as a tasklet from ldc_rx path
Date: Tue, 12 Aug 2014 21:26:28 -0700
Message-ID: <163B73C6-95EF-4398-B399-ECD5B95F5EC8@oracle.com>
References: <20140812143531.GJ2404@oracle.com> <20140812.151352.2235795686370279748.davem@davemloft.net> <20140813015817.GA13600@oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35366 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaHME0e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 00:26:34 -0400
In-Reply-To: <20140813015817.GA13600@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Aug 12, 2014, at 6:58 PM, Sowmini Varadhan <sowmini.varadhan@oracle.com> wrote:

>> 
>> Please do not usurp vnet_tx_timeout() to handle queue waking.
>> 
>> It is hooked up to netdev_ops->ndo_tx_timeout() which is invoked when
>> the qdisc watchdog triggers after dev->watchdog_timeout time elapses
>> after the queue is stopped without a subsequent wake.
>> 
>> This method is a therefore executed after a hard timeout, meaning that
>> the device should probably be reset, whereas maybe_tx_wakeup() is
>> normal processing meant to drive the engine of TX flow control.
>> 
>> In the context of sunvnet, vnet_tx_timeout() should probably reset the
>> LDC channel(s) of the unresponsive peer(s).
> 
> yes, after a couple of days of reflection on the lingering issues in
> http://www.spinics.net/lists/sparclinux/msg12360.html
> I too was starting to arrive at  similar conclusions about 
> maybe_tx_wakeup vs vnet_tx_timeout.
> 
> First case 2 in the "todo" list (cannot send DRING_STOPPED):
> If we cannot send a vnet_send_ack() we should invoke ldc_disconnect() 
> for this peer.  The ldc_disconnect() will reset hs_state and flags 
> in the ldc_channel, so subsequent attempts to ldc_write() 
> (e.g., from vio_ldc_send()) will return -ENOTCONN. So, for
> that case, a subsequent vnet_start_xmit() would *not* netif_stop_queue(),
> but just drop the packet, reset the dring, and keep driving.
> 
> To recover the disconnected channel, the admin would need to (ldm) 
> unbind/bind the offender, identifiable by their mac address.
> And none of the other channels shold be affected (assuming
> inter-vnet-links is set to on)

We do not consider a peer which couldn't process LDC messages
as an offender but just a peer in a broken state. A peer could get
into this type of situation due to many different reasons for example
a hang or lockup in an entirely unrelated code or stuck in a debugger
or due to a bug in the sunvnet driver itself. Such a guest should be able
to recover when it is rebooted. Requiring an unbind/bind is not considered
a solution, we don't expect admins to perform unbind/bind unless they
are really trying to destroy the domain. Note, an unbind of a domain
causes the vnet device ports in all of the peer domains removed and
the bind brings back, which is a heavy hammer. What we really want
is an LDC reset which puts the LDC state in a clean state to allow
the peer to restart the handshake and establish communication again.
This can be accomplished either by rebooting the peer or unload/load the 
sunvnet driver in the peer domain. It could also automatically recover too.
You can see this as something similar to resetting a NIC when the
NIC h/w is locked up.  

>From what I read the ldc_disconect() code, it seems like it is reconfiguring
the queues, so I assume a reset event would re-enable the communication
fine, but I don't know for sure without testing this specific condition.

> 
> So for case 1 we could do something very similar- I haven't tried this yet,
> but here's what I'm thinking: vnet_start_xmit() should not do a
> netif_stop_queue.  Instead it should do a (new function) "vio_stop_queue()"
> which sets some (new) VIO_DR_FLOW_CONTROLLED  state in the vio_driver_state, 
> (or perhaps some flag bit in the ldc_channel?) and also marks a 
> (new) boolean is_flow_controlled state variable in the struct vnet 
> as TRUE.
> 
> The modified maybe_tx_wakeup would check is_flow_controlled on the vnet,
> and call a new vnet_wake_queue() to reset VIO_DR_FLOW_CONTROLLED
> if appropriate.
> 
> vnet_start_xmit should drop packets as long as VIO_DR_FLOW_CONTROLLED
> is set.
> 

One important point to keep in mind that packets to different peers shouldn't
be blocked by one blocked peer. Any flow controlling or dropping of the packets
needs to be done on a per-port basis.

-Raghuram
> The above sketch has a deficiency that it doesnt avoid packet drops
> at the net_device layer itself - packets that can't make it out because
> of FLOW_CONTROLLED will get dropped - I think the Qdisc code path
> deals better with the back-pressure. I dont know if there is a way
> to leverage that path and still avoid the head-of-line blocking due
> to one flow-controlled ldc_channel.
> 
> I'm a little hesitant to ldc_disconnect a peer from the vnet_start_xmit
> path- if we have a super-efficient Tx path, we dont want to
> reset things merely because the receiver can't keep up- we just want to
> flow-control the Tx? Whereas the inability to transmit a DRING_STOPPED
> from the Rx side is likely to be a more unusual situation (would need
> the peer to send a burst of packets and then not be prepared to do
> even a single ldc_read()!)?
> 
> thoughts? 
> 
> --Sowmini
