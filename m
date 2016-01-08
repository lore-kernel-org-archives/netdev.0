From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/17] netfilter: nft_byteorder: provide 64bit le/be conversion
Date: Fri,  8 Jan 2016 15:02:16 +0100
Message-ID: <1452261737-7475-17-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54196 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755283AbcAHODd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:03:33 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id AC51FDA88C
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9D2A0DA86D
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:32 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 3E8B4DA86E
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:27 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Needed to convert the (64bit) conntrack counters to BE ordering.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_byteorder.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/net/netfilter/nft_byteorder.c b/net/netfilter/nft_byteorder.c
index fde5145..383c171 100644
--- a/net/netfilter/nft_byteorder.c
+++ b/net/netfilter/nft_byteorder.c
@@ -8,6 +8,7 @@
  * Development of this code funded by Astaro AG (http://www.astaro.com/)
  */
 
+#include <asm/unaligned.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/module.h>
@@ -39,6 +40,27 @@ static void nft_byteorder_eval(const struct nft_expr *expr,
 	d = (void *)dst;
 
 	switch (priv->size) {
+	case 8: {
+		u64 src64;
+
+		switch (priv->op) {
+		case NFT_BYTEORDER_NTOH:
+			for (i = 0; i < priv->len / 8; i++) {
+				src64 = get_unaligned_be64(&src[i]);
+				src64 = be64_to_cpu((__force __be64)src64);
+				put_unaligned_be64(src64, &dst[i]);
+			}
+			break;
+		case NFT_BYTEORDER_HTON:
+			for (i = 0; i < priv->len / 8; i++) {
+				src64 = get_unaligned_be64(&src[i]);
+				src64 = (__force u64)cpu_to_be64(src64);
+				put_unaligned_be64(src64, &dst[i]);
+			}
+			break;
+		}
+		break;
+	}
 	case 4:
 		switch (priv->op) {
 		case NFT_BYTEORDER_NTOH:
@@ -101,6 +123,7 @@ static int nft_byteorder_init(const struct nft_ctx *ctx,
 	switch (priv->size) {
 	case 2:
 	case 4:
+	case 8:
 		break;
 	default:
 		return -EINVAL;
-- 
2.1.4
