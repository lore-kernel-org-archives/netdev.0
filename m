From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: compare_ether_addr[_64bits]() has no ordering
Date: Mon, 07 May 2012 15:39:06 +0200
Message-ID: <1336397946.4325.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34888 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756162Ab2EGNjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 09:39:08 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.77)
	(envelope-from <johannes@sipsolutions.net>)
	id 1SRO9a-0000mQ-OB
	for netdev@vger.kernel.org; Mon, 07 May 2012 15:39:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Neither compare_ether_addr() nor compare_ether_addr_64bits()
(as it can fall back to the former) have comparison semantics
like memcmp() where the sign of the return value indicates sort
order. We had a bug in the wireless code due to a blind memcmp
replacement because of this.

A cursory look suggests that the wireless bug was the only one
due to this semantic difference.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/etherdevice.h |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

--- a/include/linux/etherdevice.h	2012-04-12 05:40:35.000000000 +0200
+++ b/include/linux/etherdevice.h	2012-05-07 15:34:28.000000000 +0200
@@ -159,7 +159,8 @@ static inline void eth_hw_addr_random(st
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet address
  *
- * Compare two ethernet addresses, returns 0 if equal
+ * Compare two ethernet addresses, returns 0 if equal, non-zero otherwise.
+ * Unlike memcmp(), it doesn't return a value suitable for sorting.
  */
 static inline unsigned compare_ether_addr(const u8 *addr1, const u8 *addr2)
 {
@@ -184,10 +185,10 @@ static inline unsigned long zap_last_2by
  * @addr1: Pointer to an array of 8 bytes
  * @addr2: Pointer to an other array of 8 bytes
  *
- * Compare two ethernet addresses, returns 0 if equal.
- * Same result than "memcmp(addr1, addr2, ETH_ALEN)" but without conditional
- * branches, and possibly long word memory accesses on CPU allowing cheap
- * unaligned memory reads.
+ * Compare two ethernet addresses, returns 0 if equal, non-zero otherwise.
+ * Unlike memcmp(), it doesn't return a value suitable for sorting.
+ * The function doesn't need any conditional branches and possibly uses
+ * word memory accesses on CPU allowing cheap unaligned memory reads.
  * arrays = { byte1, byte2, byte3, byte4, byte6, byte7, pad1, pad2}
  *
  * Please note that alignment of addr1 & addr2 is only guaranted to be 16 bits.
