From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: [PATCH v2 0/6] Introduce pci_(request|release)_(mem|io)_regions
Date: Thu,  2 Jun 2016 09:30:28 +0200
Message-ID: <cover.1464795082.git.jthumshirn@suse.de>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Keith Busch <keith.busch@intel.com>, Jens Axboe <axboe@fb.com>,
	linux-nvme@lists.infradead.org,
	James Smart <james.smart@avagotech.com>,
	Dick Kennedy <dick.kennedy@avagotech.com>,
	"James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
	"Martin K. Petersen" <martin.petersen@oracle.com>,
	linux-scsi@vger.kernel.org,
	Frank Haverkamp <haver@linux.vnet.ibm.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
To: Bjorn Helgaas <bhelgaas@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch in this series introduces the following 4 helper functions to
the PCI core:

* pci_request_mem_regions()
* pci_request_io_regions()
* pci_release_mem_regions()
* pci_release_io_regions()

which encapsulate the request and release of a PCI device's memory or I/O
bars.

The subsequent patches convert the drivers, which use the
pci_request_selected_regions(pdev, 
	pci_select_bars(pdev, IORESOURCE_MEM), name); 
and similar pattern to use the new interface.

This was suggested by Christoph Hellwig in
http://lists.infradead.org/pipermail/linux-nvme/2016-May/004570.html and
tested on kernel v4.6 with NVMe.

The conversion of the drivers has been performed by the following coccinelle
spatch:
// IORESOURCE_MEM
@@
expression err, pdev, name;
@@

- err = pci_request_selected_regions(pdev, pci_select_bars(pdev, IORESOURCE_MEM), name);
+ err = pci_request_mem_regions(pdev, name);

@@
expression pdev;
@@
- pci_release_selected_regions(pdev, pci_select_bars(pdev, IORESOURCE_MEM));
+ pci_release_mem_regions(pdev);

@@
expression err, pdev, name;
identifier bars;
@@
- bars = pci_select_bars(pdev, IORESOURCE_MEM);
...
- err = pci_request_selected_regions(pdev, bars, name);
+ err = pci_request_mem_regions(pdev, name);

@@
expression pdev;
identifier bars;
@@
- bars = pci_select_bars(pdev, IORESOURCE_MEM);
...
- pci_release_selected_regions(pdev, bars);
+ pci_release_mem_regions(pdev);

// IORESOURCE_IO
@@
expression err, pdev, name;
@@

- err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
IORESOURCE_IO), name);
+ err = pci_request_io_regions(pdev, name);

@@
expression pdev;
@@
- pci_release_selected_regions(pdev, pci_select_bars(pdev, IORESOURCE_IO));
+ pci_release_io_regions(pdev);

@@
expression err, pdev, name;
identifier bars;
@@
- bars = pci_select_bars(pdev, IORESOURCE_IO);
...
- err = pci_request_selected_regions(pdev, bars, name);
+ err = pci_request_io_regions(pdev, name);

@@
expression pdev;
identifier bars;
@@
- bars = pci_select_bars(pdev, IORESOURCE_IO);
...
- pci_release_selected_regions(pdev, bars);
+ pci_release_io_regions(pdev);

Changes since v1:
* Fixed indendatoin in pci.h patch to not cross the 80 chars boundary.
* Split Ethernet patches into two, one for Atheros and one for Intel drivers.
* Correctly named lpfc patch.
* Converted init-path of lpfc driver as well.
* Added Reviewed-by tags were appropriate.

Johannes Thumshirn (6):
  PCI: Add helpers to request/release memory and I/O regions
  NVMe: Use pci_(request|release)_mem_regions
  lpfc: Use pci_(request|release)_mem_regions
  GenWQE: Use pci_(request|release)_mem_regions
  ethernet/intel: Use pci_(request|release)_mem_regions
  alx: Use pci_(request|release)_mem_regions

 drivers/misc/genwqe/card_base.c               | 13 +++++--------
 drivers/net/ethernet/atheros/alx/main.c       | 12 +++++-------
 drivers/net/ethernet/intel/e1000e/netdev.c    |  6 ++----
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c  | 11 +++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  9 +++------
 drivers/net/ethernet/intel/igb/igb_main.c     | 10 +++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  9 +++------
 drivers/nvme/host/pci.c                       | 10 +++-------
 drivers/scsi/lpfc/lpfc_init.c                 | 15 ++++----------
 include/linux/pci.h                           | 28 +++++++++++++++++++++++++++
 10 files changed, 59 insertions(+), 64 deletions(-)

Cc: Christoph Hellwig <hch@infradead.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Jens Axboe <axboe@fb.com>
Cc: linux-nvme@lists.infradead.org
Cc: James Smart <james.smart@avagotech.com>
Cc: Dick Kennedy <dick.kennedy@avagotech.com>
Cc: "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>
Cc: "Martin K. Petersen" <martin.petersen@oracle.com>
Cc: linux-scsi@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Frank Haverkamp <haver@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Jay Cliburn <jcliburn@gmail.com>
Cc: Chris Snook <chris.snook@gmail.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: intel-wired-lan@lists.osuosl.org
-- 
1.8.5.6
