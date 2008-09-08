From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 02/33] nf_conntrack_gre: more locking around keymap list
Date: Mon,  8 Sep 2008 07:02:39 +0400
Message-ID: <1220842990-30500-2-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:64074 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbYIHDB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:01:28 -0400
Received: by gv-out-0910.google.com with SMTP id e6so91840gvc.37
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:01:27 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre_keymap_list should be protected in all places.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 0e3d124..2752b74 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -97,10 +97,14 @@ int nf_ct_gre_keymap_add(struct nf_conn *ct, enum ip_conntrack_dir dir,
 	kmp = &help->help.ct_pptp_info.keymap[dir];
 	if (*kmp) {
 		/* check whether it's a retransmission */
+		read_lock_bh(&nf_ct_gre_lock);
 		list_for_each_entry(km, &gre_keymap_list, list) {
-			if (gre_key_cmpfn(km, t) && km == *kmp)
+			if (gre_key_cmpfn(km, t) && km == *kmp) {
+				read_unlock_bh(&nf_ct_gre_lock);
 				return 0;
+			}
 		}
+		read_unlock_bh(&nf_ct_gre_lock);
 		pr_debug("trying to override keymap_%s for ct %p\n",
 			 dir == IP_CT_DIR_REPLY ? "reply" : "orig", ct);
 		return -EEXIST;
