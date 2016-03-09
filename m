From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 2/2] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Wed, 09 Mar 2016 09:25:26 -0800
Message-ID: <20160309172429.11477.29342.stgit@localhost.localdomain>
References: <20160309171924.11477.93179.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35208 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933251AbcCIRZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 12:25:28 -0500
Received: by mail-pa0-f52.google.com with SMTP id td3so18112800pab.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 09:25:28 -0800 (PST)
In-Reply-To: <20160309171924.11477.93179.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code for csum_block_add was doing a funky byteswap to swap the even and
odd bytes of the checksum if the offset was odd.  Instead of doing this we
can save ourselves some trouble and just shift by 8 as this should have the
same effect in terms of the final checksum value and only requires one
instruction.

In addition we can update csum_block_sub to just use csum_block_add with a
inverse value for csum2.  This way we follow the same code path as
csum_block_add without having to duplicate it.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2:  Replaced (x << 24) + (x >> 8) with ror32(x, 8) and added comment.

 include/net/checksum.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index abffc64e7300..5c30891e84e5 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -88,8 +88,11 @@ static inline __wsum
 csum_block_add(__wsum csum, __wsum csum2, int offset)
 {
 	u32 sum = (__force u32)csum2;
-	if (offset&1)
-		sum = ((sum&0xFF00FF)<<8)+((sum>>8)&0xFF00FF);
+
+	/* rotate sum to align it with a 16b boundary */
+	if (offset & 1)
+		sum = ror32(sum, 8);
+
 	return csum_add(csum, (__force __wsum)sum);
 }
 
@@ -102,10 +105,7 @@ csum_block_add_ext(__wsum csum, __wsum csum2, int offset, int len)
 static inline __wsum
 csum_block_sub(__wsum csum, __wsum csum2, int offset)
 {
-	u32 sum = (__force u32)csum2;
-	if (offset&1)
-		sum = ((sum&0xFF00FF)<<8)+((sum>>8)&0xFF00FF);
-	return csum_sub(csum, (__force __wsum)sum);
+	return csum_block_add(csum, ~csum2, offset);
 }
 
 static inline __wsum csum_unfold(__sum16 n)
