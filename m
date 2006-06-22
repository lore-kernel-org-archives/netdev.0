From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 10/21] e1000: force register write flushes to circumvent broken platforms
Date: Wed, 21 Jun 2006 22:20:27 -0700
Message-ID: <20060622052027.25497.51513.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:52488 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932805AbWFVFO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:29 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A certain AMD64 bridge (8132) has an option to turn on write combining
which breaks our adapter. To circumvent this we need to flush every write.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c   |   24 ++++++++++++++++++++++--
 drivers/net/e1000/e1000_main.c |   18 +++++++++++-------
 2 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 3959039..749d621 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -705,8 +705,12 @@ e1000_init_hw(struct e1000_hw *hw)
     /* Zero out the Multicast HASH table */
     DEBUGOUT("Zeroing the MTA\n");
     mta_size = E1000_MC_TBL_SIZE;
-    for(i = 0; i < mta_size; i++)
+    for(i = 0; i < mta_size; i++) {
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
+        /* use write flush to prevent Memory Write Block (MWB) from
+         * occuring when accessing our register space */
+        E1000_WRITE_FLUSH(hw);
+    }
 
     /* Set the PCI priority bit correctly in the CTRL register.  This
      * determines if the adapter gives priority to receives, or if it
@@ -5106,7 +5110,9 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
     DEBUGOUT("Clearing RAR[1-15]\n");
     for(i = 1; i < rar_num; i++) {
         E1000_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
+        E1000_WRITE_FLUSH(hw);
         E1000_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
+        E1000_WRITE_FLUSH(hw);
     }
 }
 
@@ -5153,7 +5159,9 @@ e1000_mc_addr_list_update(struct e1000_h
 
     for(i = rar_used_count; i < num_rar_entry; i++) {
         E1000_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
+        E1000_WRITE_FLUSH(hw);
         E1000_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
+        E1000_WRITE_FLUSH(hw);
     }
 
     /* Clear the MTA */
@@ -5161,6 +5169,7 @@ e1000_mc_addr_list_update(struct e1000_h
     num_mta_entry = E1000_NUM_MTA_REGISTERS;
     for(i = 0; i < num_mta_entry; i++) {
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
+        E1000_WRITE_FLUSH(hw);
     }
 
     /* Add the new addresses */
@@ -5275,9 +5284,12 @@ e1000_mta_set(struct e1000_hw *hw,
     if((hw->mac_type == e1000_82544) && ((hash_reg & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, MTA, (hash_reg - 1));
         E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
+        E1000_WRITE_FLUSH(hw);
         E1000_WRITE_REG_ARRAY(hw, MTA, (hash_reg - 1), temp);
+        E1000_WRITE_FLUSH(hw);
     } else {
         E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
+        E1000_WRITE_FLUSH(hw);
     }
 }
 
@@ -5334,7 +5346,9 @@ e1000_rar_set(struct e1000_hw *hw,
     }
 
     E1000_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
+    E1000_WRITE_FLUSH(hw);
     E1000_WRITE_REG_ARRAY(hw, RA, ((index << 1) + 1), rar_high);
+    E1000_WRITE_FLUSH(hw);
 }
 
 /******************************************************************************
@@ -5354,9 +5368,12 @@ e1000_write_vfta(struct e1000_hw *hw,
     if((hw->mac_type == e1000_82544) && ((offset & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, VFTA, (offset - 1));
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
+        E1000_WRITE_FLUSH(hw);
         E1000_WRITE_REG_ARRAY(hw, VFTA, (offset - 1), temp);
+        E1000_WRITE_FLUSH(hw);
     } else {
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
+        E1000_WRITE_FLUSH(hw);
     }
 }
 
@@ -5392,6 +5409,7 @@ e1000_clear_vfta(struct e1000_hw *hw)
          * manageability unit */
         vfta_value = (offset == vfta_offset) ? vfta_bit_in_reg : 0;
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, vfta_value);
+        E1000_WRITE_FLUSH(hw);
     }
 }
 
@@ -6928,8 +6946,10 @@ e1000_mng_write_cmd_header(struct e1000_
 
     length >>= 2;
     /* The device driver writes the relevant command block into the ram area. */
-    for (i = 0; i < length; i++)
+    for (i = 0; i < length; i++) {
         E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((uint32_t *) hdr + i));
+        E1000_WRITE_FLUSH(hw);
+    }
 
     return E1000_SUCCESS;
 }
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c58fafd..c44ed6f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1370,11 +1370,11 @@ e1000_configure_tx(struct e1000_adapter 
 		tdba = adapter->tx_ring[0].dma;
 		tdlen = adapter->tx_ring[0].count *
 			sizeof(struct e1000_tx_desc);
-		E1000_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, TDBAH, (tdba >> 32));
 		E1000_WRITE_REG(hw, TDLEN, tdlen);
-		E1000_WRITE_REG(hw, TDH, 0);
+		E1000_WRITE_REG(hw, TDBAH, (tdba >> 32));
+		E1000_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
 		E1000_WRITE_REG(hw, TDT, 0);
+		E1000_WRITE_REG(hw, TDH, 0);
 		adapter->tx_ring[0].tdh = E1000_TDH;
 		adapter->tx_ring[0].tdt = E1000_TDT;
 		break;
@@ -1780,11 +1780,11 @@ e1000_configure_rx(struct e1000_adapter 
 	case 1:
 	default:
 		rdba = adapter->rx_ring[0].dma;
-		E1000_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
 		E1000_WRITE_REG(hw, RDLEN, rdlen);
-		E1000_WRITE_REG(hw, RDH, 0);
+		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
+		E1000_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
 		E1000_WRITE_REG(hw, RDT, 0);
+		E1000_WRITE_REG(hw, RDH, 0);
 		adapter->rx_ring[0].rdh = E1000_RDH;
 		adapter->rx_ring[0].rdt = E1000_RDT;
 		break;
@@ -2189,14 +2189,18 @@ e1000_set_multi(struct net_device *netde
 			mc_ptr = mc_ptr->next;
 		} else {
 			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
+			E1000_WRITE_FLUSH(hw);
 			E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) + 1, 0);
+			E1000_WRITE_FLUSH(hw);
 		}
 	}
 
 	/* clear the old settings from the multicast hash table */
 
-	for (i = 0; i < E1000_NUM_MTA_REGISTERS; i++)
+	for (i = 0; i < E1000_NUM_MTA_REGISTERS; i++) {
 		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
+		E1000_WRITE_FLUSH(hw);
+	}
 
 	/* load any remaining addresses into the hash table */
 



--
Auke Kok <auke-jan.h.kok@intel.com>
