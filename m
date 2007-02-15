From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] Fabric7 VIOC driver source code
Date: Wed, 14 Feb 2007 22:43:18 -0800
Message-ID: <20070214224318.f9495001.akpm@linux-foundation.org>
References: <1170882460.6610.337.camel@rh234.mv.fabric7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>,
	Driver Support <driver-support@fabric7.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: schidambaram@fabric7.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36681 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbXBOGn2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 01:43:28 -0500
In-Reply-To: <1170882460.6610.337.camel@rh234.mv.fabric7.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Feb 2007 13:07:40 -0800 Sriram Chidambaram <schidambaram@fabric7.com> wrote:

> This patch provides the Fabric7 VIOC driver source code.
> This git mbox patch is built against 
> git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
>
> The patch can be pulled from
>ftp://ftp.fabric7.com/VIOC/Fabric7-VIOC-driver-patch.FEB-07-2007

For people wondering what this is, the documentation file is below.

I'll pull this driver into my queue so that it doesn't get lost and to give
people an opportunity to review it more easily.  From a quick peek, I'd
expect some changes to be needed: stylistic things, plus some suspicious
looking PCI-poking in vioc_irq.c.  But I didn't look at it at all closely.

The driver needed a bit of help to make it compile on ia64 (I haven't tried
any other architectures).  If it's simply not possible that this device
will ever be present on any non-x86 machines then perhaps we should
restrict it to those architectures at kernel configuration time.

But then, all the changes I made were good ones..







Overview
========

A Virtual Input-Output Controller (VIOC) is a PCI device that provides
10Gbps of I/O bandwidth that can be shared by up to 16 virtual network
interfaces (VNICs).  VIOC hardware supports several features such as
large frames, checksum offload, gathered send, MSI/MSI-X, bandwidth
control, interrupt mitigation, etc.

VNICs are provisioned to a host partition via an out-of-band interface
from the System Controller -- typically before the partition boots,
although they can be dynamically added or removed from a running
partition as well.

Each provisioned VNIC appears as an Ethernet netdevice to the host OS,
and maintains its own transmit ring in DMA memory.  VNICs are
configured to share up to 4 of total 16 receive rings and 1 of total
16 receive-completion rings in DMA memory.  VIOC hardware classifies
packets into receive rings based on size, allowing more efficient use
of DMA buffer memory.  The default, and recommended, configuration
uses groups of 'receive sets' (rxsets), each with 3 receive rings, a
receive completion ring, and a VIOC Rx interrupt.  The driver gives
each rxset a NAPI poll handler associated with a phantom (invisible)
netdevice, for concurrency.  VNICs are assigned to rxsets using a
simple modulus.

VIOC provides 4 interrupts in INTx mode: 2 for Rx, 1 for Tx, and 1 for
out-of-band messages from the System Controller and errors.  VIOC also
provides 19 MSI-X interrupts: 16 for Rx, 1 for Tx, 1 for out-of-band
messages from the System Controller, and 1 for error signalling from
the hardware.  The VIOC driver makes a determination whether MSI-X
functionality is supported and initializes interrupts accordingly.
[Note: The Linux kernel disables MSI-X for VIOCs on modules with AMD
8131, even if the device is on the HT link.]


Module loadable parameters
==========================

- poll_weight (default 8) - the number of received packets will be
  processed during one call into the NAPI poll handler.

- rx_intr_timeout (default 1) - hardware rx interrupt mitigation
  timer, in units of 5us.

- rx_intr_pkt_cnt (default 64) - hardware rx interrupt mitigation
  counter, in units of packets.

- tx_pkts_per_irq (default 64) - hardware tx interrupt mitigation
  counter, in units of packets.

- tx_pkts_per_bell (default 1) - the number of packets to enqueue on a
  transmit ring before issuing a doorbell to hardware.

Performance Tuning
==================

You may want to use the following sysctl settings to improve
performance.  [NOTE: To be re-checked]

# set in /etc/sysctl.conf

net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_sack = 0
net.ipv4.tcp_rmem = 10000000 10000000 10000000
net.ipv4.tcp_wmem = 10000000 10000000 10000000
net.ipv4.tcp_mem  = 10000000 10000000 10000000

net.core.rmem_max = 5242879
net.core.wmem_max = 5242879
net.core.rmem_default = 5242879
net.core.wmem_default = 5242879
net.core.optmem_max = 5242879
net.core.netdev_max_backlog = 100000

Out-of-band Communications with System Controller
=================================================

System operators can use the out-of-band facility to allow for remote
shutdown or reboot of the host partition.  Upon receiving such a
command, the VIOC driver executes "/sbin/reboot" or "/sbin/shutdown"
via the usermodehelper() call.

This same communications facility is used for dynamic VNIC
provisioning (plug in and out).

The VIOC driver also registers a callback with
register_reboot_notifier().  When the callback is executed, the driver
records the shutdown event and reason in a VIOC register to notify the
System Controller.



