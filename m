From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Ensure validity of dst->ds[0]
Date: Mon,  9 Jan 2017 11:58:34 -0800
Message-ID: <20170109195834.11697-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35212 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751754AbdAIT6k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:58:40 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so6197317pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 11:58:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is perfectly possible to have non zero indexed switches being present
in a DSA switch tree, in such a case, we will be deferencing a NULL
pointer while dsa_cpu_port_ethtool_{setup,restore}. Be more defensive
and ensure that dst->ds[0] is valid before doing anything with it.

Fixes: 0c73c523cf73 ("net: dsa: Initialize CPU port ethtool ops per tree")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 5fff951a0a49..da3862124545 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -394,9 +394,11 @@ static int dsa_dst_apply(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	err = dsa_cpu_port_ethtool_setup(dst->ds[0]);
-	if (err)
-		return err;
+	if (dst->ds[0]) {
+		err = dsa_cpu_port_ethtool_setup(dst->ds[0]);
+		if (err)
+			return err;
+	}
 
 	/* If we use a tagging format that doesn't have an ethertype
 	 * field, make sure that all packets from this point on get
@@ -433,7 +435,8 @@ static void dsa_dst_unapply(struct dsa_switch_tree *dst)
 		dsa_ds_unapply(dst, ds);
 	}
 
-	dsa_cpu_port_ethtool_restore(dst->ds[0]);
+	if (dst->ds[0])
+		dsa_cpu_port_ethtool_restore(dst->ds[0]);
 
 	pr_info("DSA: tree %d unapplied\n", dst->tree);
 	dst->applied = false;
-- 
2.9.3
