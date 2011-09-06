From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/4] ethtool: Update ethtool_rxnfc::rule_cnt on
 return from ETHTOOL_GRXCLSRLALL
Date: Wed, 07 Sep 2011 00:52:47 +0100
Message-ID: <1315353167.12033.5.camel@bwh-desktop>
References: <1315352693.2788.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Sebastian Poehn <sebastian.poehn@belden.com>,
	Santwona Behera <santwona.behera@sun.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:45945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355Ab1IFXwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 19:52:50 -0400
In-Reply-To: <1315352693.2788.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A user-space process must use ETHTOOL_GRXCLSRLCNT to find the number
of classification rules, then allocate a buffer of the right size,
then use ETHTOOL_GRXCLSRLALL to fill the buffer.  If some other
process inserts or deletes a rule between those two operations,
the user buffer might turn out to be the wrong size.

If it's too small, the return value will be -EMSGSIZE.  But if it's
too large, there is no indication of this.  Fix this by updating
the rule_cnt field on return.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
The change to ixgbe and niu is compile-tested only.  The change to
gianfar isn't tested at all.

Ben.

 drivers/net/ethernet/freescale/gianfar_ethtool.c |    1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |    2 ++
 drivers/net/ethernet/sun/niu.c                   |    2 ++
 include/linux/ethtool.h                          |    6 +++---
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 4223830..f30b96f 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1676,6 +1676,7 @@ static int gfar_get_cls_all(struct gfar_private *priv,
 	}
 
 	cmd->data = MAX_FILER_IDX;
+	cmd->rule_cnt = i;
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index bad2d27..34591c3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2279,6 +2279,8 @@ static int ixgbe_get_ethtool_fdir_all(struct ixgbe_adapter *adapter,
 		cnt++;
 	}
 
+	cmd->rule_cnt = cnt;
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8037059..fff0f8b 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -7302,6 +7302,8 @@ static int niu_get_ethtool_tcam_all(struct niu *np,
 	}
 	niu_unlock_parent(np, flags);
 
+	nfc->rule_cnt = cnt;
+
 	return ret;
 }
 
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 3df1f3b..ddd536d 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -496,9 +496,9 @@ struct ethtool_rx_flow_spec {
  *
  * For %ETHTOOL_GRXCLSRLALL, @rule_cnt specifies the array size of the
  * user buffer for @rule_locs on entry.  On return, @data is the size
- * of the rule table and @rule_locs contains the locations of the
- * defined rules.  Drivers must use the second parameter to get_rxnfc()
- * instead of @rule_locs.
+ * of the rule table, @rule_cnt is the number of defined rules, and
+ * @rule_locs contains the locations of the defined rules.  Drivers
+ * must use the second parameter to get_rxnfc() instead of @rule_locs.
  *
  * For %ETHTOOL_SRXCLSRLINS, @fs specifies the rule to add or update.
  * @fs.@location specifies the location to use and must not be ignored.
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
