From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/8] netfilter: nf_conntrack: reserve two bytes for nf_ct_ext->len
Date: Sat,  5 Apr 2014 18:03:47 +0200
Message-ID: <1396713830-4009-6-git-send-email-pablo@netfilter.org>
References: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34340 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753015AbaDEQED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2014 12:04:03 -0400
In-Reply-To: <1396713830-4009-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>

"len" contains sizeof(nf_ct_ext) and size of extensions. In a worst
case it can contain all extensions. Bellow you can find sizes for all
types of extensions. Their sum is definitely bigger than 256.

nf_ct_ext_types[0]->len = 24
nf_ct_ext_types[1]->len = 32
nf_ct_ext_types[2]->len = 24
nf_ct_ext_types[3]->len = 32
nf_ct_ext_types[4]->len = 152
nf_ct_ext_types[5]->len = 2
nf_ct_ext_types[6]->len = 16
nf_ct_ext_types[7]->len = 8

I have seen "len" up to 280 and my host has crashes w/o this patch.

The right way to fix this problem is reducing the size of the ecache
extension (4) and Florian is going to do this, but these changes will
be quite large to be appropriate for a stable tree.

Fixes: 5b423f6a40a0 (netfilter: nf_conntrack: fix racy timer handling with reliable)
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_extend.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 956b175..55d1504 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -47,8 +47,8 @@ enum nf_ct_ext_id {
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
 	struct rcu_head rcu;
-	u8 offset[NF_CT_EXT_NUM];
-	u8 len;
+	u16 offset[NF_CT_EXT_NUM];
+	u16 len;
 	char data[0];
 };
 
-- 
1.7.10.4
