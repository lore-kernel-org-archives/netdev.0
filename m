From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: enable 4-tuple RSS hashing for UDP
Date: Thu, 3 Nov 2016 22:12:27 +0000
Message-ID: <532154ca-609b-df14-9f18-c7dfce22f22b@solarflare.com>
References: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:63612 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754034AbcKCWMo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 18:12:44 -0400
In-Reply-To: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves UDP spreading, and also slightly improves GRO performance
of encapsulated TCP on 7000 series NICs.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 82 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 82 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 00279da..9f6d769 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2245,6 +2245,84 @@ static void efx_ef10_tx_write(struct efx_tx_queue *tx_queue)
 	}
 }
 
+#define RSS_MODE_HASH_ADDRS	(1 << RSS_MODE_HASH_SRC_ADDR_LBN |\
+				 1 << RSS_MODE_HASH_DST_ADDR_LBN)
+#define RSS_MODE_HASH_PORTS	(1 << RSS_MODE_HASH_SRC_PORT_LBN |\
+				 1 << RSS_MODE_HASH_DST_PORT_LBN)
+#define RSS_CONTEXT_FLAGS_DEFAULT	(1 << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV4_EN_LBN |\
+					 1 << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_TCPV4_EN_LBN |\
+					 1 << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_IPV6_EN_LBN |\
+					 1 << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TOEPLITZ_TCPV6_EN_LBN |\
+					 (RSS_MODE_HASH_ADDRS | RSS_MODE_HASH_PORTS) << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV4_RSS_MODE_LBN |\
+					 RSS_MODE_HASH_ADDRS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV4_RSS_MODE_LBN |\
+					 RSS_MODE_HASH_ADDRS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV4_RSS_MODE_LBN |\
+					 (RSS_MODE_HASH_ADDRS | RSS_MODE_HASH_PORTS) << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_TCP_IPV6_RSS_MODE_LBN |\
+					 RSS_MODE_HASH_ADDRS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV6_RSS_MODE_LBN |\
+					 RSS_MODE_HASH_ADDRS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_OTHER_IPV6_RSS_MODE_LBN)
+
+static int efx_ef10_get_rss_flags(struct efx_nic *efx, u32 context, u32 *flags)
+{
+	/* Firmware had a bug (sfc bug 61952) where it would not actually
+	 * fill in the flags field in the response to MC_CMD_RSS_CONTEXT_GET_FLAGS.
+	 * This meant that it would always contain whatever was previously
+	 * in the MCDI buffer.  Fortunately, all firmware versions with
+	 * this bug have the same default flags value for a newly-allocated
+	 * RSS context, and the only time we want to get the flags is just
+	 * after allocating.  Moreover, the response has a 32-bit hole
+	 * where the context ID would be in the request, so we can use an
+	 * overlength buffer in the request and pre-fill the flags field
+	 * with what we believe the default to be.  Thus if the firmware
+	 * has the bug, it will leave our pre-filled value in the flags
+	 * field of the response, and we will get the right answer.
+	 *
+	 * However, this does mean that this function should NOT be used if
+	 * the RSS context flags might not be their defaults - it is ONLY
+	 * reliably correct for a newly-allocated RSS context.
+	 */
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_LEN);
+	size_t outlen;
+	int rc;
+
+	/* Check we have a hole for the context ID */
+	BUILD_BUG_ON(MC_CMD_RSS_CONTEXT_GET_FLAGS_IN_LEN != MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_FLAGS_OFST);
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_GET_FLAGS_IN_RSS_CONTEXT_ID, context);
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_GET_FLAGS_OUT_FLAGS,
+		       RSS_CONTEXT_FLAGS_DEFAULT);
+	rc = efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_GET_FLAGS, inbuf,
+			  sizeof(inbuf), outbuf, sizeof(outbuf), &outlen);
+	if (rc == 0) {
+		if (outlen < MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_LEN)
+			rc = -EIO;
+		else
+			*flags = MCDI_DWORD(outbuf, RSS_CONTEXT_GET_FLAGS_OUT_FLAGS);
+	}
+	return rc;
+}
+
+/* Attempt to enable 4-tuple UDP hashing on the specified RSS context.
+ * If we fail, we just leave the RSS context at its default hash settings,
+ * which is safe but may slightly reduce performance.
+ * Defaults are 4-tuple for TCP and 2-tuple for UDP and other-IP, so we
+ * just need to set the UDP ports flags (for both IP versions).
+ */
+static void efx_ef10_set_rss_flags(struct efx_nic *efx, u32 context)
+{
+	MCDI_DECLARE_BUF(inbuf, MC_CMD_RSS_CONTEXT_SET_FLAGS_IN_LEN);
+	u32 flags;
+
+	BUILD_BUG_ON(MC_CMD_RSS_CONTEXT_SET_FLAGS_OUT_LEN != 0);
+
+	if (efx_ef10_get_rss_flags(efx, context, &flags) != 0)
+		return;
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_SET_FLAGS_IN_RSS_CONTEXT_ID, context);
+	flags |= RSS_MODE_HASH_PORTS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV4_RSS_MODE_LBN;
+	flags |= RSS_MODE_HASH_PORTS << MC_CMD_RSS_CONTEXT_GET_FLAGS_OUT_UDP_IPV6_RSS_MODE_LBN;
+	MCDI_SET_DWORD(inbuf, RSS_CONTEXT_SET_FLAGS_IN_FLAGS, flags);
+	efx_mcdi_rpc(efx, MC_CMD_RSS_CONTEXT_SET_FLAGS, inbuf, sizeof(inbuf),
+		     NULL, 0, NULL);
+}
+
 static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context,
 				      bool exclusive, unsigned *context_size)
 {
@@ -2290,6 +2368,10 @@ static int efx_ef10_alloc_rss_context(struct efx_nic *efx, u32 *context,
 	if (context_size)
 		*context_size = rss_spread;
 
+	if (nic_data->datapath_caps &
+	    1 << MC_CMD_GET_CAPABILITIES_OUT_ADDITIONAL_RSS_MODES_LBN)
+		efx_ef10_set_rss_flags(efx, *context);
+
 	return 0;
 }
 
