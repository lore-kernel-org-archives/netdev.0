From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] niu: introduce temp variables to avoid sparse warnings when swapping in-situ
Date: Wed, 13 Oct 2010 21:59:13 -0700
Message-ID: <1287032353-30314-1-git-send-email-harvey.harrison@gmail.com>
Cc: Harvey Harrison <harvey.harrison@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:56505 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab0JNE7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 00:59:19 -0400
Received: by pvc7 with SMTP id 7so494978pvc.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 21:59:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppress a large block of warnings like:
drivers/net/niu.c:7094:38: warning: incorrect type in assignment (different base types)
drivers/net/niu.c:7094:38:    expected restricted __be32 [usertype] ip4src
drivers/net/niu.c:7094:38:    got unsigned long long
drivers/net/niu.c:7104:17: warning: cast from restricted __be32
...

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
This could be done without the temp variables, but they do make it a bit clearer.

 drivers/net/niu.c |   92 +++++++++++++++++++++-------------------------------
 1 files changed, 37 insertions(+), 55 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index c0437fd..781e368 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -7090,24 +7090,20 @@ static int niu_get_hash_opts(struct niu *np, struct ethtool_rxnfc *nfc)
 static void niu_get_ip4fs_from_tcam_key(struct niu_tcam_entry *tp,
 					struct ethtool_rx_flow_spec *fsp)
 {
+	u32 tmp;
+	u16 prt;
 
-	fsp->h_u.tcp_ip4_spec.ip4src = (tp->key[3] & TCAM_V4KEY3_SADDR) >>
-		TCAM_V4KEY3_SADDR_SHIFT;
-	fsp->h_u.tcp_ip4_spec.ip4dst = (tp->key[3] & TCAM_V4KEY3_DADDR) >>
-		TCAM_V4KEY3_DADDR_SHIFT;
-	fsp->m_u.tcp_ip4_spec.ip4src = (tp->key_mask[3] & TCAM_V4KEY3_SADDR) >>
-		TCAM_V4KEY3_SADDR_SHIFT;
-	fsp->m_u.tcp_ip4_spec.ip4dst = (tp->key_mask[3] & TCAM_V4KEY3_DADDR) >>
-		TCAM_V4KEY3_DADDR_SHIFT;
-
-	fsp->h_u.tcp_ip4_spec.ip4src =
-		cpu_to_be32(fsp->h_u.tcp_ip4_spec.ip4src);
-	fsp->m_u.tcp_ip4_spec.ip4src =
-		cpu_to_be32(fsp->m_u.tcp_ip4_spec.ip4src);
-	fsp->h_u.tcp_ip4_spec.ip4dst =
-		cpu_to_be32(fsp->h_u.tcp_ip4_spec.ip4dst);
-	fsp->m_u.tcp_ip4_spec.ip4dst =
-		cpu_to_be32(fsp->m_u.tcp_ip4_spec.ip4dst);
+	tmp = (tp->key[3] & TCAM_V4KEY3_SADDR) >> TCAM_V4KEY3_SADDR_SHIFT;
+	fsp->h_u.tcp_ip4_spec.ip4src = cpu_to_be32(tmp);
+
+	tmp = (tp->key[3] & TCAM_V4KEY3_DADDR) >> TCAM_V4KEY3_DADDR_SHIFT;
+	fsp->h_u.tcp_ip4_spec.ip4dst = cpu_to_be32(tmp);
+
+	tmp = (tp->key_mask[3] & TCAM_V4KEY3_SADDR) >> TCAM_V4KEY3_SADDR_SHIFT;
+	fsp->m_u.tcp_ip4_spec.ip4src = cpu_to_be32(tmp);
+
+	tmp = (tp->key_mask[3] & TCAM_V4KEY3_DADDR) >> TCAM_V4KEY3_DADDR_SHIFT;
+	fsp->m_u.tcp_ip4_spec.ip4dst = cpu_to_be32(tmp);
 
 	fsp->h_u.tcp_ip4_spec.tos = (tp->key[2] & TCAM_V4KEY2_TOS) >>
 		TCAM_V4KEY2_TOS_SHIFT;
@@ -7118,54 +7114,40 @@ static void niu_get_ip4fs_from_tcam_key(struct niu_tcam_entry *tp,
 	case TCP_V4_FLOW:
 	case UDP_V4_FLOW:
 	case SCTP_V4_FLOW:
-		fsp->h_u.tcp_ip4_spec.psrc =
-			((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
-			 TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
-		fsp->h_u.tcp_ip4_spec.pdst =
-			((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
-			 TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
-		fsp->m_u.tcp_ip4_spec.psrc =
-			((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
-			 TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
-		fsp->m_u.tcp_ip4_spec.pdst =
-			((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
-			 TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
+		prt = ((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
+		fsp->h_u.tcp_ip4_spec.psrc = cpu_to_be16(prt);
+
+		prt = ((tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
+		fsp->h_u.tcp_ip4_spec.pdst = cpu_to_be16(prt);
 
-		fsp->h_u.tcp_ip4_spec.psrc =
-			cpu_to_be16(fsp->h_u.tcp_ip4_spec.psrc);
-		fsp->h_u.tcp_ip4_spec.pdst =
-			cpu_to_be16(fsp->h_u.tcp_ip4_spec.pdst);
-		fsp->m_u.tcp_ip4_spec.psrc =
-			cpu_to_be16(fsp->m_u.tcp_ip4_spec.psrc);
-		fsp->m_u.tcp_ip4_spec.pdst =
-			cpu_to_be16(fsp->m_u.tcp_ip4_spec.pdst);
+		prt = ((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT) >> 16;
+		fsp->m_u.tcp_ip4_spec.psrc = cpu_to_be16(prt);
+
+		prt = ((tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			 TCAM_V4KEY2_PORT_SPI_SHIFT) & 0xffff;
+		fsp->m_u.tcp_ip4_spec.pdst = cpu_to_be16(prt);
 		break;
 	case AH_V4_FLOW:
 	case ESP_V4_FLOW:
-		fsp->h_u.ah_ip4_spec.spi =
-			(tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
-			TCAM_V4KEY2_PORT_SPI_SHIFT;
-		fsp->m_u.ah_ip4_spec.spi =
-			(tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+		tmp = (tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
 			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->h_u.ah_ip4_spec.spi = cpu_to_be32(tmp);
 
-		fsp->h_u.ah_ip4_spec.spi =
-			cpu_to_be32(fsp->h_u.ah_ip4_spec.spi);
-		fsp->m_u.ah_ip4_spec.spi =
-			cpu_to_be32(fsp->m_u.ah_ip4_spec.spi);
+		tmp = (tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->m_u.ah_ip4_spec.spi = cpu_to_be32(tmp);
 		break;
 	case IP_USER_FLOW:
-		fsp->h_u.usr_ip4_spec.l4_4_bytes =
-			(tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
-			TCAM_V4KEY2_PORT_SPI_SHIFT;
-		fsp->m_u.usr_ip4_spec.l4_4_bytes =
-			(tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+		tmp = (tp->key[2] & TCAM_V4KEY2_PORT_SPI) >>
 			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->h_u.usr_ip4_spec.l4_4_bytes = cpu_to_be32(tmp);
 
-		fsp->h_u.usr_ip4_spec.l4_4_bytes =
-			cpu_to_be32(fsp->h_u.usr_ip4_spec.l4_4_bytes);
-		fsp->m_u.usr_ip4_spec.l4_4_bytes =
-			cpu_to_be32(fsp->m_u.usr_ip4_spec.l4_4_bytes);
+		tmp = (tp->key_mask[2] & TCAM_V4KEY2_PORT_SPI) >>
+			TCAM_V4KEY2_PORT_SPI_SHIFT;
+		fsp->m_u.usr_ip4_spec.l4_4_bytes = cpu_to_be32(tmp);
 
 		fsp->h_u.usr_ip4_spec.proto =
 			(tp->key[2] & TCAM_V4KEY2_PROTO) >>
-- 
1.7.1

