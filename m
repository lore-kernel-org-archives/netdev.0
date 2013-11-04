From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/3] net: checksum: fix warning in skb_checksum
Date: Mon,  4 Nov 2013 17:10:25 +0100
Message-ID: <80c34a5c4797401661f4bd36945e72fd2e785a5b.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29823 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753447Ab3KDQKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 11:10:31 -0500
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a build warning in skb_checksum() by wrapping the
csum_partial() usage in skb_checksum(). The problem is that on a few
architectures, csum_partial is used with prefix asmlinkage whereas
on most architectures it's not. So fix this up generically as we did
with csum_block_add_ext() to match the signature. Introduced by
2817a336d4d ("net: skb_checksum: allow custom update/combine for
walking skb").

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Only net-next affected, nothing else.

 include/net/checksum.h | 5 +++++
 net/core/skbuff.c      | 2 +-
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 15f33fd..37a0e24 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -98,6 +98,11 @@ static inline __wsum csum_unfold(__sum16 n)
 	return (__force __wsum)n;
 }
 
+static inline __wsum csum_partial_ext(const void *buff, int len, __wsum sum)
+{
+	return csum_partial(buff, len, sum);
+}
+
 #define CSUM_MANGLED_0 ((__force __sum16)0xffff)
 
 static inline void csum_replace4(__sum16 *sum, __be32 from, __be32 to)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 31aab53..e411559 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2003,7 +2003,7 @@ __wsum skb_checksum(const struct sk_buff *skb, int offset,
 		    int len, __wsum csum)
 {
 	const struct skb_checksum_ops ops = {
-		.update  = csum_partial,
+		.update  = csum_partial_ext,
 		.combine = csum_block_add_ext,
 	};
 
-- 
1.8.3.1
