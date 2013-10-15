From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 06/18] net: wireless: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:02 +0800
Message-ID: <1381837514-50660-7-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wrapper functions net_ratelimited_function() and net_XXX_ratelimited()
are called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/wireless/adm8211.c                |  5 ++-
 drivers/net/wireless/ath/carl9170/cmd.c       | 15 +++------
 drivers/net/wireless/ath/carl9170/phy.c       |  7 ++---
 drivers/net/wireless/ath/carl9170/rx.c        | 45 ++++++++-------------------
 drivers/net/wireless/ath/carl9170/usb.c       | 12 +++----
 drivers/net/wireless/hostap/hostap_80211_rx.c |  8 ++---
 drivers/net/wireless/hostap/hostap_80211_tx.c | 13 +++-----
 drivers/net/wireless/hostap/hostap_ap.c       |  6 ++--
 drivers/net/wireless/hostap/hostap_hw.c       | 17 +++-------
 drivers/net/wireless/iwlegacy/3945-mac.c      |  4 +--
 drivers/net/wireless/iwlegacy/4965-mac.c      |  6 ++--
 drivers/net/wireless/iwlwifi/pcie/rx.c        |  7 ++---
 drivers/net/wireless/libertas_tf/cmd.c        |  6 ++--
 drivers/net/wireless/mwl8k.c                  |  5 ++-
 drivers/net/wireless/orinoco/hermes.c         |  6 ++--
 drivers/net/wireless/orinoco/main.c           | 16 +++-------
 drivers/net/wireless/orinoco/orinoco_usb.c    |  3 +-
 drivers/net/wireless/p54/p54pci.c             |  6 ++--
 18 files changed, 61 insertions(+), 126 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f9a24e5..2fafb8a 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -374,9 +374,8 @@ static void adm8211_interrupt_rci(struct ieee80211_hw *dev)
 
 		pktlen = status & RDES0_STATUS_FL;
 		if (pktlen > RX_PKT_SIZE) {
-			if (net_ratelimit())
-				wiphy_debug(dev->wiphy, "frame too long (%d)\n",
-					    pktlen);
+			net_ratelimited_function(wiphy_debug, dev->wiphy,
+				"frame too long (%d)\n", pktlen);
 			pktlen = RX_PKT_SIZE;
 		}
 
diff --git a/drivers/net/wireless/ath/carl9170/cmd.c b/drivers/net/wireless/ath/carl9170/cmd.c
index 39a6387..3f13398 100644
--- a/drivers/net/wireless/ath/carl9170/cmd.c
+++ b/drivers/net/wireless/ath/carl9170/cmd.c
@@ -50,12 +50,9 @@ int carl9170_write_reg(struct ar9170 *ar, const u32 reg, const u32 val)
 
 	err = carl9170_exec_cmd(ar, CARL9170_CMD_WREG, sizeof(buf),
 				(u8 *) buf, 0, NULL);
-	if (err) {
-		if (net_ratelimit()) {
-			wiphy_err(ar->hw->wiphy, "writing reg %#x "
-				"(val %#x) failed (%d)\n", reg, val, err);
-		}
-	}
+	if (err)
+		net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+			"writing reg %#x (val %#x) failed (%d)\n", reg, val, err);
 	return err;
 }
 
@@ -77,10 +74,8 @@ int carl9170_read_mreg(struct ar9170 *ar, const int nregs,
 				4 * nregs, (u8 *)offs,
 				4 * nregs, (u8 *)res);
 	if (err) {
-		if (net_ratelimit()) {
-			wiphy_err(ar->hw->wiphy, "reading regs failed (%d)\n",
-				  err);
-		}
+		net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+			"reading regs failed (%d)\n", err);
 		return err;
 	}
 
diff --git a/drivers/net/wireless/ath/carl9170/phy.c b/drivers/net/wireless/ath/carl9170/phy.c
index ab4ee7d..cae9125 100644
--- a/drivers/net/wireless/ath/carl9170/phy.c
+++ b/drivers/net/wireless/ath/carl9170/phy.c
@@ -1715,11 +1715,8 @@ int carl9170_set_channel(struct ar9170 *ar, struct ieee80211_channel *channel,
 		err = carl9170_write_reg(ar, AR9170_PHY_REG_HEAVY_CLIP_ENABLE,
 					 0x200 | ar->heavy_clip);
 		if (err) {
-			if (net_ratelimit()) {
-				wiphy_err(ar->hw->wiphy, "failed to set "
-				       "heavy clip\n");
-			}
-
+			net_ratelimited_function(wiphy_err,
+				ar->hw->wiphy, "failed to set heavy clip\n");
 			return err;
 		}
 	}
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index e935f61..0ad905e 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -343,9 +343,8 @@ static int carl9170_rx_mac_status(struct ar9170 *ar,
 	if (unlikely(error)) {
 		/* TODO: update netdevice's RX dropped/errors statistics */
 
-		if (net_ratelimit())
-			wiphy_dbg(ar->hw->wiphy, "received frame with "
-			       "suspicious error code (%#x).\n", error);
+		net_ratelimited_function(wiphy_dbg, ar->hw->wiphy,
+			"received frame with suspicious error code (%#x).\n", error);
 
 		return -EINVAL;
 	}
@@ -374,11 +373,8 @@ static int carl9170_rx_mac_status(struct ar9170 *ar,
 			status->rate_idx = 3;
 			break;
 		default:
-			if (net_ratelimit()) {
-				wiphy_err(ar->hw->wiphy, "invalid plcp cck "
-				       "rate (%x).\n", head->plcp[0]);
-			}
-
+			net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+				"invalid plcp cck rate (%x).\n", head->plcp[0]);
 			return -EINVAL;
 		}
 		break;
@@ -411,11 +407,8 @@ static int carl9170_rx_mac_status(struct ar9170 *ar,
 			status->rate_idx = 7;
 			break;
 		default:
-			if (net_ratelimit()) {
-				wiphy_err(ar->hw->wiphy, "invalid plcp ofdm "
-					"rate (%x).\n", head->plcp[0]);
-			}
-
+			net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+				"invalid plcp ofdm rate (%x).\n", head->plcp[0]);
 			return -EINVAL;
 		}
 		if (status->band == IEEE80211_BAND_2GHZ)
@@ -742,11 +735,8 @@ static void carl9170_rx_untie_data(struct ar9170 *ar, u8 *buf, int len)
 
 			ar->rx_has_plcp = true;
 		} else {
-			if (net_ratelimit()) {
-				wiphy_err(ar->hw->wiphy, "plcp info "
-					"is clipped.\n");
-			}
-
+			net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+				"plcp info is clipped.\n");
 			goto drop;
 		}
 		break;
@@ -763,11 +753,8 @@ static void carl9170_rx_untie_data(struct ar9170 *ar, u8 *buf, int len)
 			mpdu_len -= sizeof(struct ar9170_rx_phystatus);
 			phy = (void *)(buf + mpdu_len);
 		} else {
-			if (net_ratelimit()) {
-				wiphy_err(ar->hw->wiphy, "frame tail "
-					"is clipped.\n");
-			}
-
+			net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+				"frame tail is clipped.\n");
 			goto drop;
 		}
 
@@ -900,11 +887,8 @@ static void carl9170_rx_stream(struct ar9170 *ar, void *buf, unsigned int len)
 			if (!ar->rx_failover_missing) {
 
 				/* this is not "short read". */
-				if (net_ratelimit()) {
-					wiphy_err(ar->hw->wiphy,
+				net_ratelimited_function(wiphy_err, ar->hw->wiphy,
 						"missing tag!\n");
-				}
-
 				__carl9170_rx(ar, tbuf, tlen);
 				return;
 			}
@@ -973,11 +957,8 @@ static void carl9170_rx_stream(struct ar9170 *ar, void *buf, unsigned int len)
 	}
 
 	if (tlen) {
-		if (net_ratelimit()) {
-			wiphy_err(ar->hw->wiphy, "%d bytes of unprocessed "
-				"data left in rx stream!\n", tlen);
-		}
-
+		net_ratelimited_function(wiphy_err, ar->hw->wiphy,
+			"%d bytes of unprocessed data left in rx stream!\n", tlen);
 		goto err_telluser;
 	}
 
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 307bc0d..0369f0f 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -144,10 +144,8 @@ static void carl9170_usb_submit_data_urb(struct ar9170 *ar)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (unlikely(err)) {
-		if (net_ratelimit()) {
-			dev_err(&ar->udev->dev, "tx submit failed (%d)\n",
-				urb->status);
-		}
+		net_ratelimited_function(dev_err, &ar->udev->dev,
+			"tx submit failed (%d)\n", urb->status);
 
 		usb_unanchor_urb(urb);
 		usb_anchor_urb(urb, &ar->tx_err);
@@ -194,10 +192,8 @@ static void carl9170_usb_tx_data_complete(struct urb *urb)
 
 	/* a random transmission error has occurred? */
 	default:
-		if (net_ratelimit()) {
-			dev_err(&ar->udev->dev, "tx failed (%d)\n",
-				urb->status);
-		}
+		net_ratelimited_function(dev_err, &ar->udev->dev,
+			"tx failed (%d)\n", urb->status);
 
 		usb_anchor_urb(urb, &ar->tx_err);
 		break;
diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index d39e3e2..a547d79 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -661,11 +661,9 @@ hostap_rx_frame_decrypt(local_info_t *local, struct sk_buff *skb,
 
 	if (local->tkip_countermeasures &&
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
+		net_dbg_ratelimited("%s: TKIP countermeasures: dropped "
 			       "received packet from %pM\n",
 			       local->dev->name, hdr->addr2);
-		}
 		return -1;
 	}
 
@@ -995,11 +993,9 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 
 	if (local->drop_unencrypted && !(fc & IEEE80211_FCTL_PROTECTED) &&
 	    !hostap_is_eapol_frame(local, skb)) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: dropped unencrypted RX data "
+		net_dbg_ratelimited("%s: dropped unencrypted RX data "
 			       "frame from %pM (drop_unencrypted=1)\n",
 			       dev->name, hdr->addr2);
-		}
 		goto rx_dropped;
 	}
 
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 344a981..7c8f798 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -330,11 +330,8 @@ static struct sk_buff * hostap_tx_encrypt(struct sk_buff *skb,
 	if (local->tkip_countermeasures &&
 	    strcmp(crypt->ops->name, "TKIP") == 0) {
 		hdr = (struct ieee80211_hdr *) skb->data;
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: TKIP countermeasures: dropped "
-			       "TX packet to %pM\n",
-			       local->dev->name, hdr->addr1);
-		}
+		net_dbg_ratelimited("%s: TKIP countermeasures: dropped "
+			"TX packet to %pM\n", local->dev->name, hdr->addr1);
 		kfree_skb(skb);
 		return NULL;
 	}
@@ -502,10 +499,8 @@ netdev_tx_t hostap_master_start_xmit(struct sk_buff *skb,
 	} else if (local->drop_unencrypted &&
 		   ieee80211_is_data(hdr->frame_control) &&
 		   meta->ethertype != ETH_P_PAE) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: dropped unencrypted TX data "
-			       "frame (drop_unencrypted=1)\n", dev->name);
-		}
+		net_dbg_ratelimited("%s: dropped unencrypted TX data "
+			"frame (drop_unencrypted=1)\n", dev->name);
 		iface->stats.tx_dropped++;
 		ret = NETDEV_TX_OK;
 		goto fail;
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index d6033a8..9320dc7 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -2781,10 +2781,8 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 		 * for a unicast frame. In this case, the packet is send to all
 		 * ports of the bridge. Since this is a valid scenario, do not
 		 * print out any errors here. */
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "AP: drop packet to non-associated "
-			       "STA %pM\n", hdr->addr1);
-		}
+		net_dbg_ratelimited("AP: drop packet to non-associatedSTA %pM\n",
+			hdr->addr1);
 #endif
 		local->ap->tx_drop_nonassoc++;
 		ret = AP_TX_DROP;
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index c275dc1..34b7246 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -1820,10 +1820,8 @@ static int prism2_tx_80211(struct sk_buff *skb, struct net_device *dev)
 
 	if ((local->func->card_present && !local->func->card_present(local)) ||
 	    !local->hw_ready || local->hw_downloading || local->pri_only) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: prism2_tx_80211: hw not ready -"
-			       " skipping\n", dev->name);
-		}
+		net_dbg_ratelimited("%s: prism2_tx_80211: hw not ready skipping\n",
+			dev->name);
 		goto fail;
 	}
 
@@ -2620,10 +2618,8 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 	/* Detect early interrupt before driver is fully configured */
 	spin_lock(&local->irq_init_lock);
 	if (!dev->base_addr) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: Interrupt, but dev not configured\n",
-			       dev->name);
-		}
+		net_dbg_ratelimited("%s: Interrupt, but dev not configured\n",
+			dev->name);
 		spin_unlock(&local->irq_init_lock);
 		return IRQ_HANDLED;
 	}
@@ -2632,10 +2628,7 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INTERRUPT, 0, 0);
 
 	if (local->func->card_present && !local->func->card_present(local)) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: Interrupt, but dev not OK\n",
-			       dev->name);
-		}
+		net_dbg_ratelimited("%s: Interrupt, but dev not OK\n", dev->name);
 		return IRQ_HANDLED;
 	}
 
diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index 9581d07..920c0b8 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -1027,8 +1027,8 @@ il3945_rx_allocate(struct il_priv *il, gfp_t priority)
 		/* Alloc a new receive buffer */
 		page = alloc_pages(gfp_mask, il->hw_params.rx_page_order);
 		if (!page) {
-			if (net_ratelimit())
-				D_INFO("Failed to allocate SKB buffer.\n");
+			net_ratelimited_function(D_INFO,
+				"Failed to allocate SKB buffer.\n");
 			if (rxq->free_count <= RX_LOW_WATERMARK &&
 			    net_ratelimit())
 				IL_ERR("Failed to allocate SKB buffer with %0x."
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 5ab50a5..4f8de71 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -340,9 +340,9 @@ il4965_rx_allocate(struct il_priv *il, gfp_t priority)
 		/* Alloc a new receive buffer */
 		page = alloc_pages(gfp_mask, il->hw_params.rx_page_order);
 		if (!page) {
-			if (net_ratelimit())
-				D_INFO("alloc_pages failed, " "order: %d\n",
-				       il->hw_params.rx_page_order);
+			net_ratelimited_function(D_INFO,
+				"alloc_pages failed, order: %d\n",
+				il->hw_params.rx_page_order);
 
 			if (rxq->free_count <= RX_LOW_WATERMARK &&
 			    net_ratelimit())
diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/iwlwifi/pcie/rx.c
index 3f237b4..022f612 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -293,10 +293,9 @@ static void iwl_pcie_rxq_alloc_rbs(struct iwl_trans *trans, gfp_t priority)
 		/* Alloc a new receive buffer */
 		page = alloc_pages(gfp_mask, trans_pcie->rx_page_order);
 		if (!page) {
-			if (net_ratelimit())
-				IWL_DEBUG_INFO(trans, "alloc_pages failed, "
-					   "order: %d\n",
-					   trans_pcie->rx_page_order);
+			net_ratelimited_function(IWL_DEBUG_INFO, trans,
+				"alloc_pages failed, order: %d\n",
+				trans_pcie->rx_page_order);
 
 			if ((rxq->free_count <= RX_LOW_WATERMARK) &&
 			    net_ratelimit())
diff --git a/drivers/net/wireless/libertas_tf/cmd.c b/drivers/net/wireless/libertas_tf/cmd.c
index 909ac36..806f750 100644
--- a/drivers/net/wireless/libertas_tf/cmd.c
+++ b/drivers/net/wireless/libertas_tf/cmd.c
@@ -737,10 +737,8 @@ int lbtf_process_rx_command(struct lbtf_private *priv)
 	respcmd = le16_to_cpu(resp->command);
 	result = le16_to_cpu(resp->result);
 
-	if (net_ratelimit())
-		pr_info("libertastf: cmd response 0x%04x, seq %d, size %d\n",
-			respcmd, le16_to_cpu(resp->seqnum),
-			le16_to_cpu(resp->size));
+	net_info_ratelimited("libertastf: cmd response 0x%04x, seq %d, size %d\n",
+		respcmd, le16_to_cpu(resp->seqnum), le16_to_cpu(resp->size));
 
 	if (resp->seqnum != priv->cur_cmd->cmdbuf->seqnum) {
 		spin_unlock_irqrestore(&priv->driver_lock, flags);
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index a3707fd..fe19424 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5060,9 +5060,8 @@ mwl8k_configure_filter_sniffer(struct ieee80211_hw *hw,
 	 * interface is active.
 	 */
 	if (!list_empty(&priv->vif_list)) {
-		if (net_ratelimit())
-			wiphy_info(hw->wiphy,
-				   "not enabling sniffer mode because STA interface is active\n");
+		net_ratelimited_function(wiphy_info, hw->wiphy,
+			"not enabling sniffer mode because STA interface is active\n");
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/orinoco/hermes.c b/drivers/net/wireless/orinoco/hermes.c
index 75c15bc..e4ff42f 100644
--- a/drivers/net/wireless/orinoco/hermes.c
+++ b/drivers/net/wireless/orinoco/hermes.c
@@ -261,14 +261,12 @@ static int hermes_docmd_wait(struct hermes *hw, u16 cmd, u16 parm0,
 	err = hermes_issue_cmd(hw, cmd, parm0, 0, 0);
 	if (err) {
 		if (!hermes_present(hw)) {
-			if (net_ratelimit())
-				printk(KERN_WARNING "hermes @ %p: "
+			net_warn_ratelimited("hermes @ %p: "
 				       "Card removed while issuing command "
 				       "0x%04x.\n", hw->iobase, cmd);
 			err = -ENODEV;
 		} else
-			if (net_ratelimit())
-				printk(KERN_ERR "hermes @ %p: "
+			net_err_ratelimited("hermes @ %p: "
 				       "Error %d issuing command 0x%04x.\n",
 				       hw->iobase, err, cmd);
 		goto out;
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 38ec8d1..22f3a6a 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -394,9 +394,7 @@ int orinoco_process_xmit_skb(struct sk_buff *skb,
 		int len = skb->len + sizeof(encaps_hdr) - (2 * ETH_ALEN);
 
 		if (skb_headroom(skb) < ENCAPS_OVERHEAD) {
-			if (net_ratelimit())
-				printk(KERN_ERR
-				       "%s: Not enough headroom for 802.2 headers %d\n",
+			net_err_ratelimited("%s: Not enough headroom for 802.2 headers %d\n",
 				       dev->name, skb_headroom(skb));
 			return -ENOMEM;
 		}
@@ -495,8 +493,7 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 		err = hw->ops->bap_pwrite(hw, USER_BAP, &desc, sizeof(desc),
 					  txfid, 0);
 		if (err) {
-			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error %d writing Tx "
+			net_err_ratelimited("%s: Error %d writing Tx "
 				       "descriptor to BAP\n", dev->name, err);
 			goto busy;
 		}
@@ -509,8 +506,7 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 		err = hw->ops->bap_pwrite(hw, USER_BAP, &desc, sizeof(desc),
 					  txfid, 0);
 		if (err) {
-			if (net_ratelimit())
-				printk(KERN_ERR "%s: Error %d writing Tx "
+			net_err_ratelimited("%s: Error %d writing Tx "
 				       "descriptor to BAP\n", dev->name, err);
 			goto busy;
 		}
@@ -554,8 +550,7 @@ static netdev_tx_t orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 				txfid, NULL);
 	if (err) {
 		netif_start_queue(dev);
-		if (net_ratelimit())
-			printk(KERN_ERR "%s: Error %d transmitting packet\n",
+		net_err_ratelimited("%s: Error %d transmitting packet\n",
 				dev->name, err);
 		goto busy;
 	}
@@ -1622,8 +1617,7 @@ EXPORT_SYMBOL(__orinoco_ev_info);
 
 static void __orinoco_ev_infdrop(struct net_device *dev, struct hermes *hw)
 {
-	if (net_ratelimit())
-		printk(KERN_DEBUG "%s: Information frame lost.\n", dev->name);
+	net_dbg_ratelimited("%s: Information frame lost.\n", dev->name);
 }
 
 /********************************************************************/
diff --git a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
index bdfe637..65a43d6 100644
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -1286,8 +1286,7 @@ static netdev_tx_t ezusb_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (err) {
 		netif_start_queue(dev);
-		if (net_ratelimit())
-			printk(KERN_ERR "%s: Error %d transmitting packet\n",
+		net_err_ratelimited("%s: Error %d transmitting packet\n",
 				dev->name, err);
 		goto busy;
 	}
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 57e3af8..1609084 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -212,10 +212,8 @@ static void p54p_check_rx_ring(struct ieee80211_hw *dev, u32 *index,
 		}
 
 		if (unlikely(len > priv->common.rx_mtu)) {
-			if (net_ratelimit())
-				dev_err(&priv->pdev->dev, "rx'd frame size "
-					"exceeds length threshold.\n");
-
+			net_ratelimited_function(dev_err, &priv->pdev->dev,
+				"rx'd frame size exceeds length threshold.\n");
 			len = priv->common.rx_mtu;
 		}
 		dma_addr = le32_to_cpu(desc->host_addr);
-- 
1.8.2.1
