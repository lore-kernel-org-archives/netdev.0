From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/2] gianfar: Clean up implementation of RX
 network flow classification
Date: Sat, 09 Apr 2011 00:45:11 +0100
Message-ID: <1302306311.2871.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@lists.ozlabs.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:6217 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398Ab1DHXpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 19:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code was cribbed from niu, so gfar_set_hash_opts() begins by
converting the ethtool flow class code into a class code for Sun
Neptune hardware, then does the same thing again for the hardware it's
really dealing with.  It may also return -1 (-EPERM) for some
unhandled ethtool flow class codes.

Remove the useless code and definitions, and fix the error code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This isn't even compile-tested, since it can only be built for some
PowerPC SoCs.  Could someone on ppc-dev check that this won't break the
driver?

Ben.

 drivers/net/gianfar.h         |   17 -------------
 drivers/net/gianfar_ethtool.c |   52 +----------------------------------------
 2 files changed, 1 insertions(+), 68 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index ec5d595..57ee3b0 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -382,23 +382,6 @@ extern const char gfar_driver_version[];
 #define BD_LFLAG(flags) ((flags) << 16)
 #define BD_LENGTH_MASK		0x0000ffff
 
-#define CLASS_CODE_UNRECOG		0x00
-#define CLASS_CODE_DUMMY1		0x01
-#define CLASS_CODE_ETHERTYPE1		0x02
-#define CLASS_CODE_ETHERTYPE2		0x03
-#define CLASS_CODE_USER_PROG1		0x04
-#define CLASS_CODE_USER_PROG2		0x05
-#define CLASS_CODE_USER_PROG3		0x06
-#define CLASS_CODE_USER_PROG4		0x07
-#define CLASS_CODE_TCP_IPV4		0x08
-#define CLASS_CODE_UDP_IPV4		0x09
-#define CLASS_CODE_AH_ESP_IPV4		0x0a
-#define CLASS_CODE_SCTP_IPV4		0x0b
-#define CLASS_CODE_TCP_IPV6		0x0c
-#define CLASS_CODE_UDP_IPV6		0x0d
-#define CLASS_CODE_AH_ESP_IPV6		0x0e
-#define CLASS_CODE_SCTP_IPV6		0x0f
-
 #define FPR_FILER_MASK	0xFFFFFFFF
 #define MAX_FILER_IDX	0xFF
 
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 3bc8e27..0840590 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -645,42 +645,6 @@ static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 }
 #endif
 
-static int gfar_ethflow_to_class(int flow_type, u64 *class)
-{
-	switch (flow_type) {
-	case TCP_V4_FLOW:
-		*class = CLASS_CODE_TCP_IPV4;
-		break;
-	case UDP_V4_FLOW:
-		*class = CLASS_CODE_UDP_IPV4;
-		break;
-	case AH_V4_FLOW:
-	case ESP_V4_FLOW:
-		*class = CLASS_CODE_AH_ESP_IPV4;
-		break;
-	case SCTP_V4_FLOW:
-		*class = CLASS_CODE_SCTP_IPV4;
-		break;
-	case TCP_V6_FLOW:
-		*class = CLASS_CODE_TCP_IPV6;
-		break;
-	case UDP_V6_FLOW:
-		*class = CLASS_CODE_UDP_IPV6;
-		break;
-	case AH_V6_FLOW:
-	case ESP_V6_FLOW:
-		*class = CLASS_CODE_AH_ESP_IPV6;
-		break;
-	case SCTP_V6_FLOW:
-		*class = CLASS_CODE_SCTP_IPV6;
-		break;
-	default:
-		return 0;
-	}
-
-	return 1;
-}
-
 static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 {
 	u32 fcr = 0x0, fpr = FPR_FILER_MASK;
@@ -778,11 +742,6 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 	case UDP_V6_FLOW:
 		cmp_rqfpr = RQFPR_IPV6 |RQFPR_UDP;
 		break;
-	case IPV4_FLOW:
-		cmp_rqfpr = RQFPR_IPV4;
-	case IPV6_FLOW:
-		cmp_rqfpr = RQFPR_IPV6;
-		break;
 	default:
 		printk(KERN_ERR "Right now this class is not supported\n");
 		return 0;
@@ -848,18 +807,9 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow, u
 
 static int gfar_set_hash_opts(struct gfar_private *priv, struct ethtool_rxnfc *cmd)
 {
-	u64 class;
-
-	if (!gfar_ethflow_to_class(cmd->flow_type, &class))
-		return -EINVAL;
-
-	if (class < CLASS_CODE_USER_PROG1 ||
-			class > CLASS_CODE_SCTP_IPV6)
-		return -EINVAL;
-
 	/* write the filer rules here */
 	if (!gfar_ethflow_to_filer_table(priv, cmd->data, cmd->flow_type))
-		return -1;
+		return -EINVAL;
 
 	return 0;
 }
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

