From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/4] e1000: fix panic on large frame receive when mtu=default
Date: Fri, 14 Jul 2006 16:29:48 -0700
Message-ID: <20060714232947.22378.30207.stgit@gitlost.site>
References: <20060714232452.22378.32866.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:11273 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1945911AbWGNXXE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 19:23:04 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060714232452.22378.32866.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A panic was reported when receiving 1522 size packets if using
the default MTU. we should set the initial rx buffer length to the
value that e1000changemtu sets so that we can receive any packet
that would not be dropped by LPE=0.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke.jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    3 +++
 drivers/net/e1000/e1000_main.c |    3 +--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index f411bbb..d304297 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -110,6 +110,9 @@ struct e1000_adapter;
 #define E1000_MIN_RXD                       80
 #define E1000_MAX_82544_RXD               4096
 
+/* this is the size past which hardware will drop packets when setting LPE=0 */
+#define MAXIMUM_ETHERNET_VLAN_SIZE 1522
+
 /* Supported Rx Buffer Sizes */
 #define E1000_RXBUFFER_128   128    /* Used for packet split */
 #define E1000_RXBUFFER_256   256    /* Used for packet split */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0074a3a..154acb2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1068,7 +1068,7 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
-	adapter->rx_buffer_len = MAXIMUM_ETHERNET_FRAME_SIZE;
+	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 	adapter->rx_ps_bsize0 = E1000_RXBUFFER_128;
 	hw->max_frame_size = netdev->mtu +
 			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
@@ -3148,7 +3148,6 @@ e1000_change_mtu(struct net_device *netd
 		adapter->rx_buffer_len = E1000_RXBUFFER_16384;
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
-#define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 	if (!adapter->hw.tbi_compatibility_on &&
 	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))



--
Auke Kok <auke-jan.h.kok@intel.com>
