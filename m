From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/53] netfilter: nfnetlink_cthelper: reject too large userspace allocation requests
Date: Mon,  1 May 2017 12:46:55 +0200
Message-ID: <1493635640-24325-29-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Userspace should not abuse the kernel to store large amounts of data,
reject requests larger than the private area can accommodate.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cthelper.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index 9a50bf93dd16..eef7120e1f74 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -104,7 +104,7 @@ nfnl_cthelper_from_nlattr(struct nlattr *attr, struct nf_conn *ct)
 	if (help->helper->data_len == 0)
 		return -EINVAL;
 
-	memcpy(help->data, nla_data(attr), help->helper->data_len);
+	nla_memcpy(help->data, nla_data(attr), sizeof(help->data));
 	return 0;
 }
 
@@ -216,6 +216,7 @@ nfnl_cthelper_create(const struct nlattr * const tb[],
 {
 	struct nf_conntrack_helper *helper;
 	struct nfnl_cthelper *nfcth;
+	unsigned int size;
 	int ret;
 
 	if (!tb[NFCTH_TUPLE] || !tb[NFCTH_POLICY] || !tb[NFCTH_PRIV_DATA_LEN])
@@ -231,7 +232,12 @@ nfnl_cthelper_create(const struct nlattr * const tb[],
 		goto err1;
 
 	strncpy(helper->name, nla_data(tb[NFCTH_NAME]), NF_CT_HELPER_NAME_LEN);
-	helper->data_len = ntohl(nla_get_be32(tb[NFCTH_PRIV_DATA_LEN]));
+	size = ntohl(nla_get_be32(tb[NFCTH_PRIV_DATA_LEN]));
+	if (size > FIELD_SIZEOF(struct nf_conn_help, data)) {
+		ret = -ENOMEM;
+		goto err2;
+	}
+
 	helper->flags |= NF_CT_HELPER_F_USERSPACE;
 	memcpy(&helper->tuple, tuple, sizeof(struct nf_conntrack_tuple));
 
-- 
2.1.4

