From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 09/15] nfp: fix invalid area detection
Date: Tue, 21 Mar 2017 17:59:15 -0700
Message-ID: <20170322005921.10965-10-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35612 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758253AbdCVBGK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:06:10 -0400
Received: by mail-pf0-f182.google.com with SMTP id 20so38782922pfk.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:06:07 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Core should detect when someone is trying to request an access
window which is too large for a given type of access.  Otherwise
the requester will be put on a wait queue for ever without any
error message.

Add const qualifiers to clarify that we are only looking at read-
-only members in relevant functions.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c  | 29 +++++++++++-----------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
index 15cc3e77cf6a..43dc68e01274 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp6000_pcie.c
@@ -217,7 +217,7 @@ static resource_size_t nfp_bar_resource_start(struct nfp_bar *bar)
 #define TARGET_WIDTH_64    8
 
 static int
-compute_bar(struct nfp6000_pcie *nfp, struct nfp_bar *bar,
+compute_bar(const struct nfp6000_pcie *nfp, const struct nfp_bar *bar,
 	    u32 *bar_config, u64 *bar_base,
 	    int tgt, int act, int tok, u64 offset, size_t size, int width)
 {
@@ -410,35 +410,36 @@ find_matching_bar(struct nfp6000_pcie *nfp,
 
 /* Return EAGAIN if no resource is available */
 static int
-find_unused_bar_noblock(struct nfp6000_pcie *nfp,
+find_unused_bar_noblock(const struct nfp6000_pcie *nfp,
 			int tgt, int act, int tok,
 			u64 offset, size_t size, int width)
 {
-	int n, invalid = 0;
+	int n, busy = 0;
 
 	for (n = 0; n < nfp->bars; n++) {
-		struct nfp_bar *bar = &nfp->bar[n];
+		const struct nfp_bar *bar = &nfp->bar[n];
 		int err;
 
-		if (bar->bitsize == 0) {
-			invalid++;
-			continue;
-		}
-
-		if (atomic_read(&bar->refcnt) != 0)
+		if (!bar->bitsize)
 			continue;
 
 		/* Just check to see if we can make it fit... */
 		err = compute_bar(nfp, bar, NULL, NULL,
 				  tgt, act, tok, offset, size, width);
+		if (err)
+			continue;
 
-		if (err < 0)
-			invalid++;
-		else
+		if (!atomic_read(&bar->refcnt))
 			return n;
+
+		busy++;
 	}
 
-	return (n == invalid) ? -EINVAL : -EAGAIN;
+	if (WARN(!busy, "No suitable BAR found for request tgt:0x%x act:0x%x tok:0x%x off:0x%llx size:%zd width:%d\n",
+		 tgt, act, tok, offset, size, width))
+		return -EINVAL;
+
+	return -EAGAIN;
 }
 
 static int
-- 
2.11.0
