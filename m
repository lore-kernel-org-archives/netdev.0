From: Alan Ott <alan@signal11.us>
Subject: RFC: mac802154 Packet Queueing and Slave Devices
Date: Sun, 09 Sep 2012 20:43:19 -0400
Message-ID: <504D37A7.60109@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	slapin@ossfans.org, Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:38676 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755137Ab2IJAnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2012 20:43:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Tony and I were recently talking about packet queueing on 802.15.4. What
currently happens (in net/mac802154/tx.c) is that each tx packet (skb)
is stuck on a work queue, and the worker function then sends each packet
to the hardware driver in order.

The problem with this is that it defeats the netif flow control. The
networking layer thinks the packet is sent as soon as it's put on the
workqueue (because the function that queues it returns NETDEV_TX_OK to
the networking layer), and the workqueue can then get arbitrarily large
if an application tries to send a lot of data. (Tony has shown this with
iperf)

The way the 802.15.4 drivers are currently written, their xmit function
blocks until the hardware confirms the packet has been sent. Any
hardware queueing is either not done (at86rf230 and mrf24j40 (and other
non-mainline (yet) drivers)[1]), or is done completely in the firmware
side (as in serial.c (for Econotag), not in mainline yet).

Solution 1:
If we want to keep the driver interface this way (no queueing on the
driver side and each driver's .xmit() function blocks), then we should
call netif_stop_queue()/netif_wake_queue() on the mac802154-subsystem
side[2].

Solution 2:
If we instead want to move to a non-blocking .xmit() function, like
ethernet and wifi currently have, we should then push the
netif_*_queue() functions to the drivers. This has the added benefit of
increased efficiency for devices which have a hardware queue (like the
Econotag, which is managed by the serial.c driver), as netif_*_queue()
functions won't have to be turned on and off repeatedly.

Solution 2 is more invasive. Note that right now we can't add
netif_*_queue() functions to the drivers, because the drivers have no
way to get to the net_device pointer. That is a different, but related
problem, which we might as well get to now. Right now there is the idea
of hardware devices each having multiple virtual slave devices
(represented by mac802154_sub_if_data, net/mac802154/mac802154.h). These
slave devices each have a net_device pointer. The drivers only get a
pointer to the ieee802154_dev, which represents the physical hardware.
They get no net_device (and there's no way for them to get to a
net_device pointer because there are multiple net_devices (one for each
slave interface) which could be sending them data). One of the problems
here is that each of these slave interfaces can potentially (and by
design) be on a different channel, which seems to cause a major problem
since the hardware radio can only receive on a single channel at a time.

I propose implementation of solution #1 in the short term, in parallel
with discussion about the intent of slave devices what their intended
design goals were and how they can be made to work as designed (if
possible).

Alan.

[1] While I can't speak for all devices, the mrf24j40 has no hardware
queue (or, it has a single packet queue).
[2] netif_stop_queue() would go in mac802154_tx() and netif_wake_queue()
would go in mac802154_xmit_worker() once xmit() returns.
