From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] igb: set vf rlpml wasn't taking vlan tag into
	account
Date: Thu, 03 Sep 2009 17:49:33 -0700
Message-ID: <20090904004932.14537.49991.stgit@localhost.localdomain>
References: <20090904004828.14537.72187.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:49797 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754841AbZIDAtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:49:47 -0400
In-Reply-To: <20090904004828.14537.72187.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch updates things so that vlan tags are taken into account when
setting the receive large packet maximum length.  This allows the VF driver
to correctly receive full sized frames when vlans are enabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    1 +
 drivers/net/igb/igb_main.c |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index b2c98de..7126fea 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -70,6 +70,7 @@ struct vf_data_storage {
 	unsigned char vf_mac_addresses[ETH_ALEN];
 	u16 vf_mc_hashes[IGB_MAX_VF_MC_ENTRIES];
 	u16 num_vf_mc_hashes;
+	u16 vlans_enabled;
 	bool clear_to_send;
 };
 
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1d03fcb..90b0b1b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -154,6 +154,12 @@ static inline int igb_set_vf_rlpml(struct igb_adapter *adapter, int size,
 	struct e1000_hw *hw = &adapter->hw;
 	u32 vmolr;
 
+	/* if it isn't the PF check to see if VFs are enabled and
+	 * increase the size to support vlan tags */
+	if (vfn < adapter->vfs_allocated_count &&
+	    adapter->vf_data[vfn].vlans_enabled)
+		size += VLAN_TAG_SIZE;
+
 	vmolr = rd32(E1000_VMOLR(vfn));
 	vmolr &= ~E1000_VMOLR_RLPML_MASK;
 	vmolr |= size | E1000_VMOLR_LPE;
@@ -4006,6 +4012,8 @@ static void igb_clear_vf_vfta(struct igb_adapter *adapter, u32 vf)
 
 		wr32(E1000_VLVF(i), reg);
 	}
+
+	adapter->vf_data[vf].vlans_enabled = 0;
 }
 
 static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
@@ -4054,6 +4062,22 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 			reg |= vid;
 
 			wr32(E1000_VLVF(i), reg);
+
+			/* do not modify RLPML for PF devices */
+			if (vf >= adapter->vfs_allocated_count)
+				return 0;
+
+			if (!adapter->vf_data[vf].vlans_enabled) {
+				u32 size;
+				reg = rd32(E1000_VMOLR(vf));
+				size = reg & E1000_VMOLR_RLPML_MASK;
+				size += 4;
+				reg &= ~E1000_VMOLR_RLPML_MASK;
+				reg |= size;
+				wr32(E1000_VMOLR(vf), reg);
+			}
+			adapter->vf_data[vf].vlans_enabled++;
+
 			return 0;
 		}
 	} else {
@@ -4066,6 +4090,21 @@ static s32 igb_vlvf_set(struct igb_adapter *adapter, u32 vid, bool add, u32 vf)
 				igb_vfta_set(hw, vid, false);
 			}
 			wr32(E1000_VLVF(i), reg);
+
+			/* do not modify RLPML for PF devices */
+			if (vf >= adapter->vfs_allocated_count)
+				return 0;
+
+			adapter->vf_data[vf].vlans_enabled--;
+			if (!adapter->vf_data[vf].vlans_enabled) {
+				u32 size;
+				reg = rd32(E1000_VMOLR(vf));
+				size = reg & E1000_VMOLR_RLPML_MASK;
+				size -= 4;
+				reg &= ~E1000_VMOLR_RLPML_MASK;
+				reg |= size;
+				wr32(E1000_VMOLR(vf), reg);
+			}
 			return 0;
 		}
 	}

