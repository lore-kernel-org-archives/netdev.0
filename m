From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()
Date: Sun, 22 Mar 2015 19:46:33 +0100
Message-ID: <1427049998-5665-2-git-send-email-pablo@netfilter.org>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ian Wilson <iwilson@brocade.com>

nfnl_cthelper_parse_tuple() is called from nfnl_cthelper_new(),
nfnl_cthelper_get() and nfnl_cthelper_del().  In each case they pass
a pointer to an nf_conntrack_tuple data structure local variable:

    struct nf_conntrack_tuple tuple;
    ...
    ret = nfnl_cthelper_parse_tuple(&tuple, tb[NFCTH_TUPLE]);

The problem is that this local variable is not initialized, and
nfnl_cthelper_parse_tuple() only initializes two fields: src.l3num and
dst.protonum.  This leaves all other fields with undefined values
based on whatever is on the stack:

    tuple->src.l3num = ntohs(nla_get_be16(tb[NFCTH_TUPLE_L3PROTONUM]));
    tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);

The symptom observed was that when the rpc and tns helpers were added
then traffic to port 1536 was being sent to user-space.

Signed-off-by: Ian Wilson <iwilson@brocade.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cthelper.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nfnetlink_cthelper.c b/net/netfilter/nfnetlink_cthelper.c
index a5599fc..54330fb 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -77,6 +77,9 @@ nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple *tuple,
 	if (!tb[NFCTH_TUPLE_L3PROTONUM] || !tb[NFCTH_TUPLE_L4PROTONUM])
 		return -EINVAL;
 
+	/* Not all fields are initialized so first zero the tuple */
+	memset(tuple, 0, sizeof(struct nf_conntrack_tuple));
+
 	tuple->src.l3num = ntohs(nla_get_be16(tb[NFCTH_TUPLE_L3PROTONUM]));
 	tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);
 
-- 
1.7.10.4

