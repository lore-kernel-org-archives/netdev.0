From: Alex Aizman <alex@neterion.com>
Subject: VJ Channel API - driver level (README)
Date: Tue, 02 May 2006 15:53:21 -0700
Message-ID: <4457E2E1.3030809@neterion.com>
References: <1145118379.2324.18.camel@localhost.localdomain> <4457CF53.7050000@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:29417 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S965016AbWEBWx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 May 2006 18:53:29 -0400
Received: from guinness.s2io.com (owa.neterion.com [72.1.205.136])
	by barracuda.mail.s2io.com (Spam Firewall) with ESMTP id 2AA6B2000329
	for <netdev@vger.kernel.org>; Tue,  2 May 2006 18:53:23 -0400 (EDT)
Received: from [10.16.16.76] ([10.16.16.76])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id k42MrMDr003073
	for <netdev@vger.kernel.org>; Tue, 2 May 2006 18:53:22 -0400 (EDT)
To: netdev@vger.kernel.org
In-Reply-To: <4457CF53.7050000@stud.feec.vutbr.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following "soaks" on our side for a couple months now... Noticed [1][2] and
thought it'd make sense to add it to the mix.

Contents
======

	* README (inlined below)
	* netdevice.h patch with the preliminary/draft driver-level API (next message).

Introduction
========

Van Jacobson's Net Channels presentation at LCA2006 is available at [3] and
further discussed, for instance, at [4].

Within this context we defined the following goals for our implementation:
1) There are separate transport-neutral hardware supported channels for
     transmit and receive traffic.
2) We are interested in a proof-of-concept, as well as an initial pass at a
     concrete API.

The API introduces the concept of a unidirectional "flow" that can be "bound"
to a specific hardware supported channel.  Within this framework TCP flow
is simply a special case where the transmit traffic flow is all the traffic
from a local TCP endpoint to a remote TCP endpoint and the receive
traffic flow is the exact opposite.

The API introduces - and is structured around - the following objects:

	* hardware channel - hw_channelh
	* kernel channel - kernel_channelh
	* receive flow - netdev_rx_flow

Note:
	More exactly, hw_channelh and kernel_channelh are opaque
	(void*) handles to the corresponding stateful and
	implementation-dependent objects. The rest of this text
	talks about channels and denotes handles - for shortness sake
	we'll now assume that the difference is clear enough.
	
Channels & Channel Handles
===================

Both the hardware and kernel channels (hw_channelh and kernel_channelh,
respectively) are strictly unidirectional. When a channel is opened it
is specified as a transmit or a receive channel. In order to create a
bi-directional send/receive channel there must be an additional API
which provides a higher level abstraction by using a pair
of uni-directional channels.

Hardware channel handle and kernel channel handle are opaque handles
designated to reference the corresponding stateful objects when used in an
appropriate context, i.e., driver and kernel, respectively.

Hardware channel handle (hw_channelh) is an opaque handles used to reference
the corresponding device driver-specific channel object. It is up to the
device driver developers to define the actual channel structures which work
best to their specific hardware. The API knows nothing about these except as
opaque pointers.

Similarly, kernel channel handle (kernel_channelh) is opaque, as far as
network drivers are concerned. There is a 1-to-1 correspondence between a
kernel channel and a hardware channel. This assists in separating domain
knowledge between the device driver and the kernel proper. It is assumed
that kernel developers will be able to make use of kernel_channelh by
casting it to the appropriate structure when, for instance, processing
frames received on a corresponding hardware channel (hw_channelh).

Receive Flow
=========

Receive flow (netdev_rx_flow) contains a criteria that allows to steer
a certain type of incoming packets (L2 frames, IP or UDP datagrams,
TCP segments, etc.) to a receive channel. For instance, a single channel
can be used to only receive traffic for a given MAC, or all traffic to TCP
port 80. Furthermore, several flows can be added (or more exactly, can be
"bound" via the corresponding bind_rx_hwchannel() API call) to the same
channel. This means, one can create a channel that accepts traffic for
destination MAC A and MAC B, or a channel used to transfer TCP packets with
destination port 80 and 8080, or a channel to for a number of TCP connections
defined by their respective 4-tuples.

For more discussion see Section "Neterion XFrame-II Specific Notes" below.

One can also assign a custom receive function to each separate receive channel.
If a callback function is specified, this function will be used to pass up
traffic instead of the netif_* API. This allows for a direct data path for
applications should they wish to use it.  This callback function is entirely
optional and must be set per channel. If the function pointer is NULL the
standard netif_* API is used.

With respect to receive flow binding sequence, the last channel
that is bound to a specific flow is the one that "wins", i.e., gets the
traffic. In general, sharing of channels in a consistent fashion and
tracking of receive flows is currently considered outside of the scope
of this API.

System Scalability ("The Big Picture")
========================

The API has its place in the entire picture that, as per Van Jacobson,
includes "channelized" application, "channelized" socket, and "channelized"
driver. It is meant to provide a mechanism, which, if used correctly,
will ultimately allow to achieve system-level per-CPU scalability.

It is outside the scope of this API to provide an interface to automatically
place a transmit channel and the user-space application using it onto a given
CPU. But if the transmitting application is in fact bound to a CPU, and if the
kernel socket is "channel-aware", and if this particular channel is always
used with the same CPU - if all of the above is true, then the ultimate goal
of scalability can be reached.

Similarly, on the inbound, the API can be used to:

	(1) channelize received traffic based on a number of available
	     receive flow classification mechanisms
	     (see netdev_hwchannel_rx_flow_e),

	(2) process the per-channel MSI/MSI-X on a given CPU
	     specified at channel open time (see open_rx_hwchannel()).

It's outside of scope of this particular API what happens with the packets
received on a given channel after netif_rx*() callback hands the over to the
stack.

Neterion XFrame-II Specific Note
=====================

The API is (an attempt of) a generalized kernel <=> driver interface.
This section talks about Xframe-specific restrictions. We are assuming that
other multi-channel capable network adapters might have adapter-specific
restrictions; the idea however is not to propagate those restrictions on the
level of API, if possible.

The XFrame-II adapter supports multiple receive traffic flow types.
However, it is not possible to mix the receive flow types
(netdev_hwchannel_rx_flow_e) with the current Xframe hardware. In other
words, one cannot use a single hardware channel to receive, for instance,
all TCP traffic for destination port 80 and all L2 traffic for destination MAC A.

References
=======

[1] http://www.spinics.net/lists/netdev/msg03584.html
[2] http://www.spinics.net/lists/netdev/msg03583.html
[3] http://www.lemis.com/grog/Documentation/vj/lca06vj.pdf
[4] http://vger.kernel.org/~davem/cgi-bin/blog.cgi/2006/01/27


Thanks!
Neterion Team.




