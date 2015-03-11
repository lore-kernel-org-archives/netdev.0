From: Ian Wilson <iwilson@brocade.com>
Subject: [PATCH] netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()
Date: Wed, 11 Mar 2015 21:01:55 +0000
Message-ID: <5500AD43.3070402@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: <pablo@netfilter.org>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 From 0d63c5b06276d7946ba2f1f4aace4f0486ec74cf Mon Sep 17 00:00:00 2001
From: Ian Wilson <iwilson@brocade.com>
Date: Wed, 11 Mar 2015 20:34:21 +0000
Subject: [PATCH] netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()

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

---
  net/netfilter/nfnetlink_cthelper.c | 3 +++
  1 file changed, 3 insertions(+)

diff --git a/net/netfilter/nfnetlink_cthelper.c 
b/net/netfilter/nfnetlink_cthelper.c
index a5599fc..01f4c45 100644
--- a/net/netfilter/nfnetlink_cthelper.c
+++ b/net/netfilter/nfnetlink_cthelper.c
@@ -77,6 +77,9 @@ nfnl_cthelper_parse_tuple(struct nf_conntrack_tuple 
*tuple,
      if (!tb[NFCTH_TUPLE_L3PROTONUM] || !tb[NFCTH_TUPLE_L4PROTONUM])
          return -EINVAL;

+     /* Not all fields are initialized so first zero the tuple */
+    memset(tuple, 0, sizeof(struct nf_conntrack_tuple));
+
      tuple->src.l3num = ntohs(nla_get_be16(tb[NFCTH_TUPLE_L3PROTONUM]));
      tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);

-- 
1.9.1


