From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 13/14] e1000: 3 new driver stats for managability testing
Date: Fri, 15 Dec 2006 11:17:23 -0500
Message-ID: <4582CA93.5040206@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175701.3365.135.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050108030508090408050800"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55972 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbWLOQRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 11:17:25 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175701.3365.135.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050108030508090408050800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Arjan van de Ven wrote:
> Subject: e1000: 3 new driver stats for managability testing
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Add 3 extra packet redirect counters for tracking purposes to make sure we
> can test that all packets arrive properly.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

as revised...


--------------050108030508090408050800
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

commit 979b575f7666d12157d8b975f022bf8fb6d23c64
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Dec 15 11:16:33 2006 -0500

    e1000: 3 new driver stats for managability testing
    
    Add 3 extra packet redirect counters for tracking purposes to make sure
    we can test that all packets arrive properly.
    
    Originally from Jesse Brandeburg <jesse.brandeburg@intel.com>,
    rewritten to use feature flags by me.
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

979b575f7666d12157d8b975f022bf8fb6d23c64
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index da459f7..fb96c87 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -100,6 +100,9 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_csum_offload_errors", E1000_STAT(hw_csum_err) },
 	{ "rx_header_split", E1000_STAT(rx_hdr_split) },
 	{ "alloc_rx_buff_failed", E1000_STAT(alloc_rx_buff_failed) },
+	{ "tx_smbus", E1000_STAT(stats.mgptc) },
+	{ "rx_smbus", E1000_STAT(stats.mgprc) },
+	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
 };
 
 #define E1000_QUEUE_STATS_LEN 0
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 5a6a61e..9be4469 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -458,6 +458,9 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	if (hw->mac_type == e1000_80003es2lan)
 		hw->rx_needs_kicking = TRUE;
 
+	if (hw->mac_type > e1000_82544)
+		hw->has_smbus = TRUE;
+
 	return E1000_SUCCESS;
 }
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 15b8625..d671058 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1464,6 +1464,7 @@ struct e1000_hw {
 	boolean_t		bad_tx_carr_stats_fd;
 	boolean_t		has_manc2h;
 	boolean_t		rx_needs_kicking;
+	boolean_t		has_smbus;
 };
 
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 3f40a90..b06b51a 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3743,6 +3743,13 @@ e1000_update_stats(struct e1000_adapter *adapter)
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
+	/* Management Stats */
+	if (adapter->hw.has_smbus) {
+		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
+		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
+		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
+	}
+
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
 }
 #ifdef CONFIG_PCI_MSI

--------------050108030508090408050800--
