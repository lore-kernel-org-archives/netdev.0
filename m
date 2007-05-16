From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Work around 82571 completion timout on Pseries HW
Date: Wed, 16 May 2007 01:53:29 -0700
Message-ID: <20070516085329.29131.120.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wenxiong@us.ibm.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12027 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757804AbXEPPuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:50:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Our 82571 (first PCI-E hardware) causes P-Series hardware to throw
issues. Disabling PCI-E completion timeouts in our NIC resolves
the issue.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: Wen Xiong <wenxiong@us.ibm.com>
---

 drivers/net/e1000/e1000_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 49be393..830d851 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -819,6 +819,16 @@ e1000_reset(struct e1000_adapter *adapter)
 		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
 	}
 
+#if defined(CONFIG_PPC64) || defined(CONFIG_PPC)
+#define E1000_GCR_DISABLE_TIMEOUT_MECHANISM 0x80000000
+	if (adapter->hw.mac.type == e1000_82571) {
+		/* work around pSeries hardware by disabling timeouts */
+		u32 gcr = E1000_READ_REG(&adapter->hw, E1000_GCR);
+		gcr |= E1000_GCR_DISABLE_TIMEOUT_MECHANISM;
+		E1000_WRITE_REG(&adapter->hw, E1000_GCR, gcr);
+	}
+#endif
+
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
 	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
 
