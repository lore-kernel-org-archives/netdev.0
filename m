From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] netfilter: nf_conntrack: reserve two bytes for nf_ct_ext->len (v2)
Date: Fri, 28 Mar 2014 00:06:20 +0400
Message-ID: <1395950780-14792-1-git-send-email-avagin@openvz.org>
References: <20140327154504.GC31944@macbook.localnet>
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org, vvs@parallels.com,
	Andrey Vagin <avagin@openvz.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <20140327154504.GC31944@macbook.localnet>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

v2: rearrange the extension so ECACHE comes last. This is required to
prevent overflow of nf_ct_ext->offset.

Fixes: 5b423f6a40a0 (netfilter: nf_conntrack: fix racy timer handling with reliable)
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/net/netfilter/nf_conntrack_extend.h | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 956b175..9d41750 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -12,9 +12,6 @@ enum nf_ct_ext_id {
 #endif
 	NF_CT_EXT_SEQADJ,
 	NF_CT_EXT_ACCT,
-#ifdef CONFIG_NF_CONNTRACK_EVENTS
-	NF_CT_EXT_ECACHE,
-#endif
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	NF_CT_EXT_ZONE,
 #endif
@@ -30,6 +27,15 @@ enum nf_ct_ext_id {
 #if IS_ENABLED(CONFIG_NETFILTER_SYNPROXY)
 	NF_CT_EXT_SYNPROXY,
 #endif
+
+/*
+ * The size of the nf_conntrack_ecache struct is about 150 bytes, so
+ * NF_CT_EXT_ECACHE must be the last one to prevent overflow of
+ * nf_ct_ext->offset[id]
+ */
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	NF_CT_EXT_ECACHE,
+#endif
 	NF_CT_EXT_NUM,
 };
 
@@ -48,7 +54,7 @@ enum nf_ct_ext_id {
 struct nf_ct_ext {
 	struct rcu_head rcu;
 	u8 offset[NF_CT_EXT_NUM];
-	u8 len;
+	u16 len;
 	char data[0];
 };
 
-- 
1.8.5.3

