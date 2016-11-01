From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ila: Fix crash caused by rhashtable changes
Date: Tue, 1 Nov 2016 14:55:25 -0700
Message-ID: <20161101215525.360859-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59674 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750889AbcKAVze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 17:55:34 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA1LslWB024863
        for <netdev@vger.kernel.org>; Tue, 1 Nov 2016 14:55:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 26ey3wayt3-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 14:55:33 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 e946e17ea07d11e6b6150002c99293a0-63deaa50 for <netdev@vger.kernel.org>;        Tue,
 01 Nov 2016 14:55:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ca26893f05e86 ("rhashtable: Add rhlist interface")
added a field to rhashtable_iter so that length became 56 bytes
and would exceed the size of args in netlink_callback (which is
48 bytes). The netlink diag dump function already has been
allocating a iter structure and storing the pointed to that
in the args of netlink_callback. ila_xlat also uses
rhahstable_iter but is still putting that directly in
the arg block. Now since rhashtable_iter size is increased
we are overwriting beyond the structure. The next field
happens to be cb_mutex pointer in netlink_sock and hence the crash.

Fix is to alloc the rhashtable_iter and save it as pointer
in arg.

Tested:

  modprobe ila
  ./ip ila add loc 3333:0:0:0 loc_match 2222:0:0:1,
  ./ip ila list  # NO crash now

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/ila/ila_xlat.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
index 628ae6d..af8f52e 100644
--- a/net/ipv6/ila/ila_xlat.c
+++ b/net/ipv6/ila/ila_xlat.c
@@ -474,7 +474,15 @@ static int ila_nl_dump_start(struct netlink_callback *cb)
 {
 	struct net *net = sock_net(cb->skb->sk);
 	struct ila_net *ilan = net_generic(net, ila_net_id);
-	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args[0];
+
+	if (!iter) {
+		iter = kmalloc(sizeof(*iter), GFP_KERNEL);
+		if (!iter)
+			return -ENOMEM;
+
+		cb->args[0] = (long)iter;
+	}
 
 	return rhashtable_walk_init(&ilan->rhash_table, &iter->rhiter,
 				    GFP_KERNEL);
@@ -482,16 +490,18 @@ static int ila_nl_dump_start(struct netlink_callback *cb)
 
 static int ila_nl_dump_done(struct netlink_callback *cb)
 {
-	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args[0];
 
 	rhashtable_walk_exit(&iter->rhiter);
 
+	kfree(iter);
+
 	return 0;
 }
 
 static int ila_nl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
-	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args;
+	struct ila_dump_iter *iter = (struct ila_dump_iter *)cb->args[0];
 	struct rhashtable_iter *rhiter = &iter->rhiter;
 	struct ila_map *ila;
 	int ret;
-- 
2.9.3
