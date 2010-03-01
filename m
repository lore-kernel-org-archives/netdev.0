From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] Setting processor affinity for network queues
Date: Mon, 01 Mar 2010 17:21:42 +0000
Message-ID: <1267464102.2092.136.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35037 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330Ab0CARVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 12:21:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With multiqueue network hardware or Receive/Transmit Packet Steering
(RPS/XPS) we can spread out network processing across multiple
processors.  The administrator should be able to control the number of
channels and the processor affinity of each.

By 'channel' I mean a bundle of:
- a wakeup (IRQ or IPI)
- a receive queue whose completions trigger the wakeup
- a transmit queue whose completions trigger the wakeup
- a NAPI instance scheduled by the wakeup, which handles the completions

Numbers of RX and TX queues used on a device do not have to match, but
ideally they should.  For generality, you can subsitute 'a receive
and/or a transmit queue' above.  At the hardware level the numbers of
queues could be different e.g. in the sfc driver a channel would be
associated with 1 hardware RX queue, 2 hardware TX queues (with and
without checksum offload) and 1 hardware event queue.

Currently we have a userspace interface for setting affinity of IRQs and
a convention for naming each channel's IRQ handler, but no such
interface for memory allocation.  For RX buffers this should not be a
problem since they are normally allocated as older buffers are
completed, in the NAPI context.  However, the DMA descriptor rings and
driver structures for a channel should also be allocated on the NUMA
node where NAPI processing is done.  Currently this allocation takes
place when a net device is created or when it is opened, before an
administrator has any opportunity to configure affinity.  Reallocation
will normally require a complete stop to network traffic (at least on
the affected queues) so it should not be done automatically when the
driver detects a change in IRQ affinity.  There needs to be an explicit
mechanism for changing it.

Devices using RPS will not generally be able to implement NUMA affinity
for RX buffer allocation, but there will be a similar issue of processor
selection for IPIs and NUMA node affinity for driver structures.  The
proposed interface for setting processor affinity should cover this, but
it is completely different from the IRQ affinity mechanism for hardware
multiqueue devices.  That seems undesirable.

Therefore I propose that:

1. Channels (or NAPI instances) should be exposed in sysfs.
2. Channels will have processor affinity, exposed read/write in sysfs.
Changing this triggers the networking core and driver to reallocate
associated structures if the processor affinity moved between NUMA
nodes, and triggers the driver to set IRQ affinity.
3. The networking core will set the initial affinity for each channel.
There may be global settings to control this.
4. Drivers should not set IRQ affinity.
5. irqbalanced should not set IRQ affinity for multiqueue network
devices.

(Most of this has been proposed already, but I'm trying to bring it all
together.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

