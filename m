From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC PATCH 0/4] net: Add port mirroring support to the kernel
Date: Tue, 15 Dec 2009 11:29:56 -0500
Message-ID: <20091215162956.GB18710@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58321 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760553AbZLOQaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 11:30:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	One of the features that many multi-port Networking devices offer as a
debug facility is port mirroring.  The Linux kernels currently offers this
feature in only a very limited fashion,  Frames can be mangled and resent out
various devices using netfilter rules, but the reach of those rules is limited,
as they are largely protocol specific.  Ebtables is an option, but it applies
only to devices in a bridge configuration.  I'd like to propose a solution which
is protocol agnostic, simple to configure, and always available to debug.  by
doing this we can offer the ability to capture frames on a tertiary device when
the system under test is too heavily loaded to support capturing the data on a
network card without adversely affecting the performance or behavior of the
system

My proposed solution is:

1) Insert tracepoints at the start of the receive path in the network stack
(netif_receive_skb) and at the end of the send path (dev_hard_start_xmit).  By
using tracepoints performance impact can be minimized when mirroring is not in
use, and it lets us avoid adding additional data to the net_device or sk_buff
structures in support of this feature.

2) Add mirroring code which hooks those tracepoints (when activated), and for
each frame sent or received, inspects a table of configured devices.  matching
the sent/received skb to each source skb in the table, the buffer is cloned to
each configured destination device and sent there as well

3) Add a sysfs attribute called mirror_to.  This file holds the names of devices
that the addressed device should mirror skbs to.  eg, this commmand:
echo -n eth1 > /sys/class/net/eth0/mirror_to
would cause all frames sent and received on eth0 to be sent out of eth1
likewise, this command:
echo -n -eth1 > /sys/class/net/eth0/mirror_to
would remove eth1 from the mirroring table

I've tested this code out here and it works fairly well.  I think there lots of
room for optimizations, but this is functional, and IMHO a good stake in the
ground from which incremental improvements can be made.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

