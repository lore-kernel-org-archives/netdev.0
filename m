From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [ANNOUNCE] New driver vxge for Neterion's X3100 series 10 GbE PCIe
	adapter
Date: 14 Mar 2009 00:20:26 -0800
Message-ID: <1237018825.4966.412.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60407 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751638AbZCNHxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a release of a new network driver, "vxge", for our latest PCIe based
hardware - The X3100 10GbE Server/Storage Adapter. The X3100 ASIC supports 
four modes of operation, configurable via firmware -
	Single function mode
	Multi function	mode
	SRIOV mode
	MRIOV mode
	
The driver patches series will follow this email. This driver has undergone 
significant testing for the past six months in all four modes of operation,
and is very stable. We would appreciate the community review and comments
on this driver.
	
The modes, besides single function mode, are oriented towards Server
I/O virtualization and/or I/O sharing (see PCI SIG SR IOV and MR IOV
specs for reference), although they can be used on a single
non-virtualized server as well for instance, to run workloads that would
typically benefit from using separate network cards. In these scenarios,
X3100 can replace large number of GbE NICs without any system or network
changes (outside of L2 driver/hardware), while each physical NIC will be
able run up to 10 GbE instead of 1 GbE.

Major features include -
	Virtual ethernet bridge 
	Multiqueue enabled
	Service level guarantees per queue
	Dual port with integrated IEEE 802.3ad link aggregation
	Tcp/Udp/IP stateless offloads - 
		TCP/UDP/IPv4/IPv6 checksum offload, TSO.
	Large receive offload
	Receive traffic hashing
	MSI-X interrupts
	Multiple tx and rx queues with number of steering options

A note on the different modes of operation -

Single-function mode: From Linux stack perspective, the adapter is a
typical multi-queue 10GbE pci-e netdev interface (driven by the
submitted vxge driver).
 
Multi-function mode: From Linux stack perspective, the adapter is a
multi-function pci-e device where each function is a multi-queue pci-e
netdev interface. This mode has some applications in native Linux
environments, but it is primarily designed for use in hypervisors that
do not yet support SR IOV pci-e extensions. In fact, the functionality
in this mode is virtually identical to the SR IOV mode described below,
except SR IOV support in Linux is not required/expected. 

>From vxge driver perspective, each x3100 function is an independent NIC.
The functions share 10GbE link and pci-e bus, but hardly anything else
inside the ASIC. Features like independent hw reset, statistics,
bandwidth/priority allocation and guarantees, etc. are supported. Also,
typical L2 functions like LSO, interrupt moderation, etc are supported
independently on each function.

In other words, direct hardware access with x3100 doesnctions for Direct Hardware
	Access to different Guests or Servers - while keeping traditional
	privileged operations (VLAN membership, etc) under privileged domain
	control.
 
SR IOV mode: Once BIOS and/or OS support SR IOV pci-e extensions, from
Linux stack perspective the adapter will look like the multi-function
mode in #2 above. vxge driver will still think that each x3100 function
is an independent x3100 pci-e device.
 
MR IOV mode: This mode is designed to support sharing single pci-e 10GbE
device across multiple independent servers (see PCI SIG MR IOV spec
and/or presentations for reference). In PCI SIG terms, in this mode
the X3100 works as a shared IOV 10GbE endpoint that assumes the presence
of a pci-e switch. To the Linux stack on each server, the X3100 function
(assigned to the server by the pci-e switch) will look like a separate
X3100 adapter driven by the vxge driver.

The patch set consists of the the following files -

 Documentation/networking/vxge.txt |  476 +++
 MAINTAINERS                       |    7 +-
 drivers/net/Kconfig               |   18 +
 drivers/net/Makefile              |    1 +
 drivers/net/vxge/Makefile         |    9 +
 drivers/net/vxge/vxge-config.c    | 7576 +++++++++++++++++++++++++++++++++++++
 drivers/net/vxge/vxge-config.h    | 3323 ++++++++++++++++
 drivers/net/vxge/vxge-ethtool.c   | 1450 +++++++
 drivers/net/vxge/vxge-ethtool.h   |   73 +
 drivers/net/vxge/vxge-main.c      | 5204 +++++++++++++++++++++++++
 drivers/net/vxge/vxge-main.h      |  623 +++
 drivers/net/vxge/vxge-reg.h       | 5659 +++++++++++++++++++++++++++
 drivers/net/vxge/vxge-traffic.c   | 2969 +++++++++++++++
 drivers/net/vxge/vxge-traffic.h   | 2808 ++++++++++++++
 drivers/net/vxge/vxge-version.h   |   24 +
 include/linux/pci_ids.h           |    2 +
 16 files changed, 30220 insertions(+), 2 deletions(-)

Regards,

Ram Vepa

