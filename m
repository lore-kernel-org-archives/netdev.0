From: Ian Wilson <iwilson@brocade.com>
Subject: [PATCH] netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()
Date: Thu, 12 Mar 2015 09:37:58 +0000
Message-ID: <1426153078-20863-1-git-send-email-iwilson@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Wilson <iwilson@brocade.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:33829 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753943AbbCLJi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 05:38:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/netfilter/nfnetlink_cthelper.c | 3 +++
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
1.9.1
