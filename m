From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/14] e1000: omit stats for broken counter in 82543
Date: Fri, 15 Dec 2006 10:37:39 -0500
Message-ID: <4582C143.70009@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175100.3365.115.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070009010209080407030601"
Cc: netdev@vger.kernel.org, "Kok, Auke" <auke-jan.h.kok@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55658 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752749AbWLOPhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 10:37:41 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1166175100.3365.115.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070009010209080407030601
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Arjan van de Ven wrote:
> Subject: e1000: omit stats for broken counter in 82543
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> The 82543 chip does not count tx_carrier_errors properly in FD mode;
> report zeros instead of garbage.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

I rewrote your patch #3 into the attached patch.  Man, that was hard. 
It was a MAJOR REVISION, trust me.

See attached.  (e1000 even ALREADY HAS some feature flags for this sort 
of thing)

	Jeff



--------------070009010209080407030601
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 0201ca5..7376609 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -442,6 +442,9 @@ e1000_set_mac_type(struct e1000_hw *hw)
 		break;
 	}
 
+	if (hw->mac_type == e1000_82543)
+		hw->bad_tx_carr_stats_fd = TRUE;
+
 	return E1000_SUCCESS;
 }
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 28cdfe3..fef1f7b 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -1460,6 +1460,7 @@ struct e1000_hw {
 	boolean_t		mng_reg_access_disabled;
 	boolean_t		leave_av_bit_off;
 	boolean_t		kmrn_lock_loss_workaround_disabled;
+	boolean_t		bad_tx_carr_stats_fd;
 };
 
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 62ef267..0816de2 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3581,6 +3581,11 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
 	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
 	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
+	if (adapter->hw.bad_tx_carr_stats_fd &&
+	    adapter->link_duplex == FULL_DUPLEX) {
+		adapter->net_stats.tx_carrier_errors = 0;
+		adapter->stats.tncrs = 0;
+	}
 
 	/* Tx Dropped needs to be maintained elsewhere */
 

--------------070009010209080407030601--
