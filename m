From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH] csum: Update csum_block_add to use rotate instead
 of byteswap
Date: Tue, 08 Mar 2016 14:42:38 -0800
Message-ID: <20160308224238.16551.73881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36587 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbcCHWmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 17:42:40 -0500
Received: by mail-pf0-f173.google.com with SMTP id 63so22975215pfe.3
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 14:42:40 -0800 (PST)
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
 include/net/checksum.h |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 10a16b5bd1c7..f9fac66c0e66 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -88,8 +88,10 @@ static inline __wsum
 csum_block_add(__wsum csum, __wsum csum2, int offset)
 {
 	u32 sum = (__force u32)csum2;
-	if (offset&1)
-		sum = ((sum&0xFF00FF)<<8)+((sum>>8)&0xFF00FF);
+
+	if (offset & 1)
+		sum = (sum << 24) + (sum >> 8);
+
 	return csum_add(csum, (__force __wsum)sum);
 }
 
@@ -102,10 +104,7 @@ csum_block_add_ext(__wsum csum, __wsum csum2, int offset, int len)
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
