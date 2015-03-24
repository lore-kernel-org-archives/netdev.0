From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: fix sparse warnings in privacy stable addresses generation
Date: Tue, 24 Mar 2015 11:05:28 +0100
Message-ID: <2c4b658a420789137afca51f5249fd15022a9383.1427191441.git.hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:42609 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752258AbbCXKFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 06:05:34 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id E7BA520631
	for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 06:05:30 -0400 (EDT)
Received: from stressinduktion.org (unknown [217.192.177.51])
	by mail.messagingengine.com (Postfix) with ESMTPA id 0B0AFC00013
	for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 06:05:32 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those warnings reported by sparse endianness check (via kbuild test robot)
are harmless, nevertheless fix them up and make the code a little bit
easier to read.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: 622c81d57b392cc ("ipv6: generation of stable privacy addresses for link-local and autoconf")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d2d2383..2660263 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2906,7 +2906,7 @@ static int ipv6_generate_stable_address(struct in6_addr *address,
 		char __data[SHA_MESSAGE_BYTES];
 		struct {
 			struct in6_addr secret;
-			__be64 prefix;
+			__be32 prefix[2];
 			unsigned char hwaddr[MAX_ADDR_LEN];
 			u8 dad_count;
 		} __packed;
@@ -2932,16 +2932,16 @@ retry:
 	memset(&data, 0, sizeof(data));
 	memset(workspace, 0, sizeof(workspace));
 	memcpy(data.hwaddr, idev->dev->perm_addr, idev->dev->addr_len);
-	data.prefix = ((__be64)address->s6_addr32[0] << 32) |
-		       (__be64)address->s6_addr32[1];
+	data.prefix[0] = address->s6_addr32[0];
+	data.prefix[1] = address->s6_addr32[1];
 	data.secret = secret;
 	data.dad_count = dad_count;
 
 	sha_transform(digest, data.__data, workspace);
 
 	temp = *address;
-	temp.s6_addr32[2] = digest[0];
-	temp.s6_addr32[3] = digest[1];
+	temp.s6_addr32[2] = (__force __be32)digest[0];
+	temp.s6_addr32[3] = (__force __be32)digest[1];
 
 	spin_unlock_bh(&lock);
 
-- 
2.1.0
