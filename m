From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 4/4] netxen: trivial register access cleanup
Date: Sat,  9 May 2009 01:02:30 -0700
Message-ID: <1241856150-4488-4-git-send-email-dhananjay@netxen.com>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48116 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751431AbZEIICb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 04:02:31 -0400
In-Reply-To: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary length parameter since it's always 4 bytes.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 86c9e78..42ffb82 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -914,17 +914,15 @@ netxen_nic_pci_change_crbwindow_128M(struct netxen_adapter *adapter, u32 wndw)
  * In: 'off' is offset from base in 128M pci map
  */
 static int
-netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter,
-		ulong *off, int len)
+netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter, ulong *off)
 {
-	unsigned long end = *off + len;
 	crb_128M_2M_sub_block_map_t *m;
 
 
 	if (*off >= NETXEN_CRB_MAX)
 		return -1;
 
-	if (*off >= NETXEN_PCI_CAMQM && (end <= NETXEN_PCI_CAMQM_2M_END)) {
+	if (*off >= NETXEN_PCI_CAMQM && (*off < NETXEN_PCI_CAMQM_2M_END)) {
 		*off = (*off - NETXEN_PCI_CAMQM) + NETXEN_PCI_CAMQM_2M_BASE +
 			(ulong)adapter->ahw.pci_base0;
 		return 0;
@@ -934,14 +932,13 @@ netxen_nic_pci_get_crb_addr_2M(struct netxen_adapter *adapter,
 		return -1;
 
 	*off -= NETXEN_PCI_CRBSPACE;
-	end = *off + len;
 
 	/*
 	 * Try direct map
 	 */
 	m = &crb_128M_2M_map[CRB_BLK(*off)].sub_block[CRB_SUBBLK(*off)];
 
-	if (m->valid && (m->start_128M <= *off) && (m->end_128M >= end)) {
+	if (m->valid && (m->start_128M <= *off) && (m->end_128M > *off)) {
 		*off = *off + m->start_2M - m->start_128M +
 			(ulong)adapter->ahw.pci_base0;
 		return 0;
@@ -1036,7 +1033,7 @@ netxen_nic_hw_write_wx_2M(struct netxen_adapter *adapter, ulong off, u32 data)
 	unsigned long flags = 0;
 	int rv;
 
-	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, 4);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off);
 
 	if (rv == -1) {
 		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
@@ -1066,7 +1063,7 @@ netxen_nic_hw_read_wx_2M(struct netxen_adapter *adapter, ulong off)
 	int rv;
 	u32 data;
 
-	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off, 4);
+	rv = netxen_nic_pci_get_crb_addr_2M(adapter, &off);
 
 	if (rv == -1) {
 		printk(KERN_ERR "%s: invalid offset: 0x%016lx\n",
-- 
1.6.0.2

