From: Alan Ott <alan@signal11.us>
Subject: Re: RFC: mac802154 Packet Queueing and Slave Devices
Date: Fri, 22 Mar 2013 01:33:41 -0400
Message-ID: <514BED35.4050209@signal11.us>
References: <504D37A7.60109@signal11.us> <514B30BC.4040802@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:52795 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932084Ab3CVFdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 01:33:46 -0400
In-Reply-To: <514B30BC.4040802@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2013 12:09 PM, Alan Ott wrote:
> On 09/09/2012 08:43 PM, Alan Ott wrote:
>> Tony and I were recently talking about packet queueing on 802.15.4. What
>> currently happens (in net/mac802154/tx.c) is that each tx packet (skb)
>> is stuck on a work queue, and the worker function then sends each packet
>> to the hardware driver in order.
>>
>> The problem with this is that it defeats the netif flow control. The
>> networking layer thinks the packet is sent as soon as it's put on the
>> workqueue (because the function that queues it returns NETDEV_TX_OK to
>> the networking layer), and the workqueue can then get arbitrarily large
>> if an application tries to send a lot of data. (Tony has shown this with
>> iperf)
>>
> So I tried fixing this using netif_stop_queue() and netif_wake_queue(),
> the standard way. The flow control works, but I'm now losing packets.
>
> It happens like this:
>
> ipv6           -> 6lowpan   -> net core -> mac802154         -> hardware
>  single packet     fragment                 netif_stop_queue()
>                    fragment
>                    fragment
>                    fragment
>
>   Above: a single ipv6 packet is split into fragments by 6lowpan. Each
>   fragment is sent through the networking core where it ends up in
>   mac802154, which will call netif_stop_queue() and netif_wake_queue()
>   for flow control as packets are sent.
>
>
> The problem is that since many ieee802154 hardware devices can only hold
> one packet at a time in their tx buffer, netif_stop_queue() gets called
> after the first fragment. Since the 6lowpan code is trying to, in the
> above case, send 4 packets, the remaining 3 will get dropped when
> they're handed to the networking core (dev_queue_xmit()) when the queue
> is stopped.
>
> So as a solution, one could envision 6lowpan putting the fragments into
> a queue, and submitting one at a time, as the queue gets woken. The
> problem with this is that there's no way to get notification for when a
> queue is woken. I checked both ppp and ax25 (which would seem to have
> this same issue), and they both have a fragment queue, but they rely on
> external events (mostly unrelated to the queue being woken) to trigger
> sending packets from the queue (see calls to ax25_kick()). That seems
> hacky at best.
>
> A thread from pppoe[1] talks about what's a similar issue. The patch
> from that email was never merged. Even so, their solution seems a bit
> hacky too (because it would basically cause a kick to (in this case)
> 6lowpan, whenever an skb gets destroyed (ie: after it's sent). With the
> desire for 6lowpan to be a generic protocol[2], one would want it to be
> efficient on MAC layers which do support longer queues[3].
>
> What am I missing here? What's the right way to do this?
>
> Alan.
>
> [1] http://thread.gmane.org/gmane.linux.network/233089
> [2] There has been some discussion about using 6lowpan on Bluetooth
> low-energy.
> [3] There's also the case where 2 6lowpan instances are on attached to
> the same hardware, or where 6lowpan and raw are being used concurrently.

I guess the more condensed question is, as a protocol which generates
fragments, what's the right way to handle queue management from the device?

Alan.
