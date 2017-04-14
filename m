From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/9] netfilter: ctnetlink: skip dumping expect when nfct_help(ct) is NULL
Date: Fri, 14 Apr 2017 02:26:48 +0200
Message-ID: <1492129611-29336-7-git-send-email-pablo@netfilter.org>
References: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35324 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754020AbdDNA1L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 20:27:11 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 856C5E0439
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 75534DA865
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:06 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 61F45DA729
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 02:27:04 +0200 (CEST)
In-Reply-To: <1492129611-29336-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

For IPCTNL_MSG_EXP_GET, if the CTA_EXPECT_MASTER attr is specified, then
the NLM_F_DUMP request will dump the expectations related to this
connection tracking.

But we forget to check whether the conntrack has nf_conn_help or not,
so if nfct_help(ct) is NULL, oops will happen:

 BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
 IP: ctnetlink_exp_ct_dump_table+0xf9/0x1e0 [nf_conntrack_netlink]
 Call Trace:
  ? ctnetlink_exp_ct_dump_table+0x75/0x1e0 [nf_conntrack_netlink]
  netlink_dump+0x124/0x2a0
  __netlink_dump_start+0x161/0x190
  ctnetlink_dump_exp_ct+0x16c/0x1bc [nf_conntrack_netlink]
  ? ctnetlink_exp_fill_info.constprop.33+0xf0/0xf0 [nf_conntrack_netlink]
  ? ctnetlink_glue_seqadj+0x20/0x20 [nf_conntrack_netlink]
  ctnetlink_get_expect+0x32e/0x370 [nf_conntrack_netlink]
  ? debug_lockdep_rcu_enabled+0x1d/0x20
  nfnetlink_rcv_msg+0x60a/0x6a9 [nfnetlink]
  ? nfnetlink_rcv_msg+0x1b9/0x6a9 [nfnetlink]
  [...]

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index f9c643bc1a8e..f78eadba343d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -2794,6 +2794,12 @@ static int ctnetlink_dump_exp_ct(struct net *net, struct sock *ctnl,
 		return -ENOENT;
 
 	ct = nf_ct_tuplehash_to_ctrack(h);
+	/* No expectation linked to this connection tracking. */
+	if (!nfct_help(ct)) {
+		nf_ct_put(ct);
+		return 0;
+	}
+
 	c.data = ct;
 
 	err = netlink_dump_start(ctnl, skb, nlh, &c);
-- 
2.1.4
