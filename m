From: adobriyan@gmail.com
Subject: [PATCH] nf_conntrack_gre: more locking around keymap list
Date: Thu, 21 Aug 2008 00:54:51 +0400
Message-ID: <20080820205451.GA16405@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:28979 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbYHTUxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 16:53:32 -0400
Received: by yx-out-2324.google.com with SMTP id 8so295745yxm.1
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 13:53:32 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre_keymap_list should be protected in all places.
(unless I'm misreading something)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_proto_gre.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

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

