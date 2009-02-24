From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: handle pci bar 0 mapping failure
Date: Tue, 24 Feb 2009 00:16:59 -0800
Message-ID: <1235463419-25146-3-git-send-email-dhananjay@netxen.com>
References: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48598 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752328AbZBXIRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2009 03:17:01 -0500
In-Reply-To: <1235463419-25146-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI bar 0 is used for memory mapped register access.
If ioremap fails (returns NULL), register access results
in crash.

Use pci_ioremap_bar() instead of ioremap(), the latter
fails on on 32 bit powerpc where pci resource address is
> 32 bits.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f425811..1308778 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -588,7 +588,12 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->pci_mem_read = netxen_nic_pci_mem_read_2M;
 		adapter->pci_mem_write = netxen_nic_pci_mem_write_2M;
 
-		mem_ptr0 = ioremap(mem_base, mem_len);
+		mem_ptr0 = pci_ioremap_bar(pdev, 0);
+		if (mem_ptr0 == NULL) {
+			dev_err(&pdev->dev, "failed to map PCI bar 0\n");
+			return -EIO;
+		}
+
 		pci_len0 = mem_len;
 		first_page_group_start = 0;
 		first_page_group_end   = 0;
-- 
1.6.0.2

