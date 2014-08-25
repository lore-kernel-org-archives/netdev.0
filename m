From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 0/8] Fix TSO and checksum issues with non-accelerated vlan traffic.
Date: Mon, 25 Aug 2014 10:34:47 -0400
Message-ID: <1408977295-9162-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, Rasesh Mody <rmody@brocade.com>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	Chris Metcalf <cmetcalf@tilera.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:42488 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345AbaHYOfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:35:10 -0400
Received: by mail-qc0-f179.google.com with SMTP id m20so14015750qcx.10
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 07:35:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've recently ran across something rather interesting when testing vlans
from inside VMs.  In some scenarios I was getting awfull thruput.
Some debugging uncovered a very scary packet corruption.  I was
seeing packets that had original TSO length as IP total length
and their ip checksum was 0.  This was with e1000e driver.

A bit more debugging uncovered an assumption made by that driver
that skb->protocol will contain l3 protocol information.  This
was not the case in my setup since I manually turned off vlan
tx acceleration for the device.  This caused the driver to not
initialize the tso information correctly and resulted in
corrupt TSO frames on the wire.

I decided to do some auditing of the usage of skb->protocols
in the drivers.  Out of all the drivers, the included 8 appear
to be effected.  They all allow user to control vlan acceleration
settings, all support TSO on vlan devices, and all use
skb->protocol to decide how to encode TSO information.  Some
also have similar problems when initializing hw checksum information.
On such device, it is simple enough to reproduce the issue.
Simply turn off TX VLAN acceleration on the device, create a vlan,
and run you favorite network performance tool.

There is 1 driver I ran across that I belive will trigger a BUG
in the system when used with vlans.  That driver is tile/tilepro.c
I have not changed it in this patch set and would hope that
the maintainer has time to look at it.

V2: Fix i40ev using the wrong function name.  Full build.

Thanks
-vlad

Vladislav Yasevich (8):
  e1000e: Fix TSO with non-accelerated vlans
  e1000: Fix TSO for non-accelerated vlan traffic
  bna: Support TSO and partial checksum with non-accelerated vlans.
  ehea: Fix TSO and hw checksums with non-accelerated vlan packets.
  i40e: Fix TSO and hw checksums for non-accelerated vlan packets.
  i40evf: Fix TSO and hw checksums for non-accelerated vlan packets.
  mvneta: Fix TSO and checksum for non-acceleration vlan traffic
  qlge: Fix TSO for non-accelerated vlan traffic

 drivers/net/ethernet/brocade/bna/bnad.c       |  7 ++++---
 drivers/net/ethernet/ibm/ehea/ehea_main.c     |  2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c | 19 +++++++++++--------
 drivers/net/ethernet/intel/e1000e/netdev.c    | 21 +++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   |  2 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c |  2 +-
 drivers/net/ethernet/marvell/mvneta.c         |  7 ++++---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c  |  5 +++--
 8 files changed, 34 insertions(+), 31 deletions(-)

-- 
1.9.3
