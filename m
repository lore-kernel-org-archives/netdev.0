From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 6/8] alx: fix MAC address alignment problem
Date: Sat, 29 Jun 2013 19:23:18 +0200
Message-ID: <1372526600-15934-7-git-send-email-johannes@sipsolutions.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58304 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab3F2RX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 13:23:27 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Usyru-0006aE-13
	for netdev@vger.kernel.org; Sat, 29 Jun 2013 19:23:26 +0200
In-Reply-To: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In two places, parts of MAC addresses are used as u32/u16
values. This can cause alignment problems, use put_unaligned
and get_unaligned to fix this.

Reported-by: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/alx/hw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/hw.c b/drivers/net/ethernet/atheros/alx/hw.c
index aed48a7..ea99e5d 100644
--- a/drivers/net/ethernet/atheros/alx/hw.c
+++ b/drivers/net/ethernet/atheros/alx/hw.c
@@ -282,8 +282,8 @@ static bool alx_read_macaddr(struct alx_hw *hw, u8 *addr)
 	mac1 = alx_read_mem32(hw, ALX_STAD1);
 
 	/* addr should be big-endian */
-	*(__be32 *)(addr + 2) = cpu_to_be32(mac0);
-	*(__be16 *)addr = cpu_to_be16(mac1);
+	put_unaligned(cpu_to_be32(mac0), (__be32 *)(addr + 2));
+	put_unaligned(cpu_to_be16(mac1), (__be16 *)addr);
 
 	return is_valid_ether_addr(addr);
 }
@@ -326,9 +326,9 @@ void alx_set_macaddr(struct alx_hw *hw, const u8 *addr)
 	u32 val;
 
 	/* for example: 00-0B-6A-F6-00-DC * STAD0=6AF600DC, STAD1=000B */
-	val = be32_to_cpu(*(__be32 *)(addr + 2));
+	val = be32_to_cpu(get_unaligned((__be32 *)(addr + 2)));
 	alx_write_mem32(hw, ALX_STAD0, val);
-	val = be16_to_cpu(*(__be16 *)addr);
+	val = be16_to_cpu(get_unaligned((__be16 *)addr));
 	alx_write_mem32(hw, ALX_STAD1, val);
 }
 
-- 
1.8.0
