From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [REGRESSION, bisect] pci: cxgb4 probe fails after commit
 104daa71b3961434 ("PCI: Determine actual VPD size on first access")
Date: Tue, 12 Apr 2016 10:59:42 +0530
Message-ID: <20160412052939.GA2771@hari-Latitude-E5550>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, nirranjan@chelsio.com
To: bhelgaas@google.com, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:29797 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755951AbcDLF3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 01:29:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,


The following patch introduced a regression, causing cxgb4 driver to fail in
PCIe probe.

commit 104daa71b39614343929e1982170d5fcb0569bb5
Author: Hannes Reinecke <hare@suse.de>
Author: Hannes Reinecke <hare@suse.de>
Date:   Mon Feb 15 09:42:01 2016 +0100

    PCI: Determine actual VPD size on first access
    
    PCI-2.2 VPD entries have a maximum size of 32k, but might actually be
    smaller than that.  To figure out the actual size one has to read the VPD
    area until the 'end marker' is reached.
    
    Per spec, reading outside of the VPD space is "not allowed."  In practice,
    it may cause simple read errors or even crash the card.  To make matters
    worse not every PCI card implements this properly, leaving us with no 'end'
    marker or even completely invalid data.
    
    Try to determine the size of the VPD data when it's first accessed.  If no
    valid data can be read an I/O error will be returned when reading or
    writing the sysfs attribute.
    
    As the amount of VPD data is unknown initially the size of the sysfs
    attribute will always be set to '0'.
    
    [bhelgaas: changelog, use 0/1 (not false/true) for bitfield, tweak
    pci_vpd_pci22_read() error checking]
    Tested-by: Shane Seymour <shane.seymour@hpe.com>
    Tested-by: Babu Moger <babu.moger@oracle.com>
    Signed-off-by: Hannes Reinecke <hare@suse.de>
    Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
    Cc: Alexander Duyck <alexander.duyck@gmail.com>

The problem is stemming from the fact that the Chelsio adapters actually have
two VPD structures stored in the VPD.  An abbreviated on at Offset 0x0 and the
complete VPD at Offset 0x400.  The abbreviated one only contains the PN, SN and
EC Keywords, while the complete VPD contains those plus various adapter
constants contained in V0, V1, etc.  And it also contains the Base Ethernet MAC
Address in the "NA" Keyword which the cxgb4 driver needs when it can't contact
the adapter firmware.  (We don't have the "NA" Keywork in the VPD Structure at
Offset 0x0 because that's not an allowed VPD Keyword in the PCI-E 3.0
specification.)

  With the new code, the computed size of the VPD is 0x200 and so our efforts
to read the VPD at Offset 0x400 silently fails. We check the result of the
read looking for a signature 0x82 byte but we're checking against random stack
garbage.

  The end result is that the cxgb4 driver now fails the PCI-E Probe.

Thanks,
Hari
