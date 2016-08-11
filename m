From: Colin King <colin.king@canonical.com>
Subject: [PATCH] calipso: fix resource leak on calipso_genopt failure
Date: Thu, 11 Aug 2016 18:17:22 +0100
Message-ID: <1470935842-13884-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Currently, if calipso_genopt fails then the error exit path
does not free the ipv6_opt_hdr new causing a memory leak. Fix
this by kfree'ing new on the error exit path.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv6/calipso.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/calipso.c b/net/ipv6/calipso.c
index c53b92c..37ac9de 100644
--- a/net/ipv6/calipso.c
+++ b/net/ipv6/calipso.c
@@ -952,8 +952,10 @@ calipso_opt_insert(struct ipv6_opt_hdr *hop,
 		memcpy(new, hop, start);
 	ret_val = calipso_genopt((unsigned char *)new, start, buf_len, doi_def,
 				 secattr);
-	if (ret_val < 0)
+	if (ret_val < 0) {
+		kfree(new);
 		return ERR_PTR(ret_val);
+	}
 
 	buf_len = start + ret_val;
 	/* At this point buf_len aligns to 4n, so (buf_len & 4) pads to 8n */
-- 
2.8.1
