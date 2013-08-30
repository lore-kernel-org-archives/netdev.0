From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/16] sfc: Document conditions for multicast
 replication vs filter replacement
Date: Fri, 30 Aug 2013 04:39:35 +0100
Message-ID: <1377833975.2552.31.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34970 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099Ab3H3Dji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:39:38 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the efx_filter_is_mc_recip() function to decide whether a filter
is for a multicast recipient and can coexist with other filters with
the same match values.  Update efx_filter_insert_filter() kernel-doc
to explain the conditions for this.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.h |   22 +++++++++++++++-------
 drivers/net/ethernet/sfc/rx.c  |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 3bbc047..9de28f6 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -79,13 +79,20 @@ extern void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
  * On success, return the filter ID.
  * On failure, return a negative error code.
  *
- * If an existing filter has equal match values to the new filter
- * spec, then the new filter might replace it, depending on the
- * relative priorities.  If the existing filter has lower priority, or
- * if @replace_equal is set and it has equal priority, then it is
- * replaced.  Otherwise the function fails, returning -%EPERM if
- * the existing filter has higher priority or -%EEXIST if it has
- * equal priority.
+ * If existing filters have equal match values to the new filter spec,
+ * then the new filter might replace them or the function might fail,
+ * as follows.
+ *
+ * 1. If the existing filters have lower priority, or @replace_equal
+ *    is set and they have equal priority, replace them.
+ *
+ * 2. If the existing filters have higher priority, return -%EPERM.
+ *
+ * 3. If !efx_filter_is_mc_recipient(@spec), or the NIC does not
+ *    support delivery to multiple recipients, return -%EEXIST.
+ *
+ * This implies that filters for multiple multicast recipients must
+ * all be inserted with the same priority and @replace_equal = %false.
  */
 static inline s32 efx_filter_insert_filter(struct efx_nic *efx,
 					   struct efx_filter_spec *spec,
@@ -169,6 +176,7 @@ static inline void efx_filter_rfs_expire(struct efx_channel *channel)
 static inline void efx_filter_rfs_expire(struct efx_channel *channel) {}
 #define efx_filter_rfs_enabled() 0
 #endif
+extern bool efx_filter_is_mc_recipient(const struct efx_filter_spec *spec);
 
 /* Channels */
 extern int efx_channel_dummy_op_int(struct efx_channel *channel);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 864b6ff..81eab21 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -903,3 +903,37 @@ bool __efx_filter_rfs_expire(struct efx_nic *efx, unsigned int quota)
 }
 
 #endif /* CONFIG_RFS_ACCEL */
+
+/**
+ * efx_filter_is_mc_recipient - test whether spec is a multicast recipient
+ * @spec: Specification to test
+ *
+ * Return: %true if the specification is a non-drop RX filter that
+ * matches a local MAC address I/G bit value of 1 or matches a local
+ * IPv4 or IPv6 address value in the respective multicast address
+ * range.  Otherwise %false.
+ */
+bool efx_filter_is_mc_recipient(const struct efx_filter_spec *spec)
+{
+	if (!(spec->flags & EFX_FILTER_FLAG_RX) ||
+	    spec->dmaq_id == EFX_FILTER_RX_DMAQ_ID_DROP)
+		return false;
+
+	if (spec->match_flags &
+	    (EFX_FILTER_MATCH_LOC_MAC | EFX_FILTER_MATCH_LOC_MAC_IG) &&
+	    is_multicast_ether_addr(spec->loc_mac))
+		return true;
+
+	if ((spec->match_flags &
+	     (EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILTER_MATCH_LOC_HOST)) ==
+	    (EFX_FILTER_MATCH_ETHER_TYPE | EFX_FILTER_MATCH_LOC_HOST)) {
+		if (spec->ether_type == htons(ETH_P_IP) &&
+		    ipv4_is_multicast(spec->loc_host[0]))
+			return true;
+		if (spec->ether_type == htons(ETH_P_IPV6) &&
+		    ((const u8 *)spec->loc_host)[0] == 0xff)
+			return true;
+	}
+
+	return false;
+}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
