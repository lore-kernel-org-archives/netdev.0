From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Handling device free after a packet is passed to the
 network stack
Date: Mon, 30 Mar 2015 15:41:32 -0700
Message-ID: <1427755292.25985.165.camel@edumazet-glaptop2.roam.corp.google.com>
References: <f3c7672edb978d520f12d72cb41d1e4d.squirrel@www.codeaurora.org>
	 <1427510968.25985.159.camel@edumazet-glaptop2.roam.corp.google.com>
	 <004401d06af4$94620280$bd260780$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33596 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbbC3Wlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 18:41:36 -0400
Received: by pacgg7 with SMTP id gg7so50952674pac.0
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 15:41:36 -0700 (PDT)
In-Reply-To: <004401d06af4$94620280$bd260780$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-30 at 08:19 -0600, Harout Hedeshian wrote:
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Eric Dumazet
> > Sent: Friday, March 27, 2015 8:49 PM
> > To: subashab@codeaurora.org
> > Cc: netdev@vger.kernel.org
> > Subject: Re: [RFC] Handling device free after a packet is passed to the
> > network stack
> > 
> > On Fri, 2015-03-27 at 19:57 +0000, subashab@codeaurora.org wrote:
> > > We have been coming across a couple of scenarios where the device is
> > > freed and the corresponding packets which were already queued up the
> > > stack encounter crashes when they find that contents of skb->dev are
> > > no longer valid.
> > >
> > > Specifically, we have observed an instance where a cpu hotplug occurs
> > > along with the network driver module unloading. When the packets are
> > > being queued up the stack using netif_rx_ni from dev_cpu_callback,
> > > get_rps_cpus crashes as it encounters invalid data at skb->dev since
> > > it would have been freed.
> > >
> > > We would like to know if the kernel provides some mechanisms to
> > > safeguard against such scenarios.
> > 
> > This is supposed to be handled in flush_backlog() (net/core/dev.c)
> 
> It looks like this only takes care of packets in the softnet_data
> queues (or am I missing something). Wouldn't we run into similar
> issues if the packet were stuck in, for example, TCP OFO socket queue
> (not sure if anything tries to access skb->dev after that)? Or perhaps
> some other queue which may later try to dereference skb->dev. 
>  

Then these packets wont reach dev. Stack already takes care of these
packets. They are in TCP queues, not yet associated with a device.

IP/neighbour stack wont associate a dead device to a TX packet.
> 
> It seems to me that the only way to be absolutely sure that there is
> no reference on this net_device would be to have the drivers
> dev_hold() before earch netif_rx/netif_rx_ni/netif_receive_skb; and
> then later have __kfree_skb() do a dev_put().
> 
> Of course, this approach has a number of issues:
> - 2 extra operations per packet
> - Anything holding onto an SKB can prevent a net_device from
> deregistering/freeing
> - requires skbs to have a valid dev before they can be freed (or we
> simply null check this field in __kfree_skb())


This is absolutely not needed. Existing infrastructure already is
supposed to take care of not holding a RX packet when a device is
dismantled. cpu backlog queues are supposed to be flushed and packet
dropped.

The only problem that my patch is solving is the joint event of cpu
hotplug and device dismantle.
