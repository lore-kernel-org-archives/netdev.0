From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/05: ctnetlink: allow changing NAT sequence adjustment in creation
Date: Mon,  9 Feb 2009 17:39:31 +0100 (MET)
Message-ID: <20090209163930.13918.91017.sendpatchset@x2.localnet>
References: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59012 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754071AbZBIQjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 11:39:32 -0500
In-Reply-To: <20090209163926.13918.96177.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 028cf4480479685d7768bfdd6afe3f7bf9545b39
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Feb 9 14:25:52 2009 +0100

    netfilter: ctnetlink: allow changing NAT sequence adjustment in creation
    
    This patch fixes an inconsistency in the current ctnetlink code
    since NAT sequence adjustment bit can only be updated but not set
    in the conntrack entry creation.
    
    This patch is used by conntrackd to successfully recover newly
    created entries that represent connections with helpers and NAT
    payload mangling.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index c32a7e8..9051bb4 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1215,6 +1215,16 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		}
 	}
 
+#ifdef CONFIG_NF_NAT_NEEDED
+	if (cda[CTA_NAT_SEQ_ADJ_ORIG] || cda[CTA_NAT_SEQ_ADJ_REPLY]) {
+		err = ctnetlink_change_nat_seq_adj(ct, cda);
+		if (err < 0) {
+			rcu_read_unlock();
+			goto err;
+		}
+	}
+#endif
+
 	if (cda[CTA_PROTOINFO]) {
 		err = ctnetlink_change_protoinfo(ct, cda);
 		if (err < 0) {
