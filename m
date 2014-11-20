From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: nfnetlink: fix insufficient validation in nfnetlink_bind
Date: Thu, 20 Nov 2014 13:30:50 +0100
Message-ID: <1416486651-12271-2-git-send-email-pablo@netfilter.org>
References: <1416486651-12271-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41548 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756659AbaKTMfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 07:35:37 -0500
In-Reply-To: <1416486651-12271-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the netlink group exists, otherwise you can trigger an out
of bound array memory access from the netlink_bind() path. This splat
can only be triggered only by superuser.

[  180.203600] UBSan: Undefined behaviour in ../net/netfilter/nfnetlink.c:467:28
[  180.204249] index 9 is out of range for type 'int [9]'
[  180.204697] CPU: 0 PID: 1771 Comm: trinity-main Not tainted 3.18.0-rc4-mm1+ #122
[  180.205365] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org
+04/01/2014
[  180.206498]  0000000000000018 0000000000000000 0000000000000009 ffff88007bdf7da8
[  180.207220]  ffffffff82b0ef5f 0000000000000092 ffffffff845ae2e0 ffff88007bdf7db8
[  180.207887]  ffffffff8199e489 ffff88007bdf7e18 ffffffff8199ea22 0000003900000000
[  180.208639] Call Trace:
[  180.208857] dump_stack (lib/dump_stack.c:52)
[  180.209370] ubsan_epilogue (lib/ubsan.c:174)
[  180.209849] __ubsan_handle_out_of_bounds (lib/ubsan.c:400)
[  180.210512] nfnetlink_bind (net/netfilter/nfnetlink.c:467)
[  180.210986] netlink_bind (net/netlink/af_netlink.c:1483)
[  180.211495] SYSC_bind (net/socket.c:1541)

Moreover, define the missing nf_tables and nf_acct multicast groups too.

Reported-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 6c5a915..13c2e17 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -47,6 +47,8 @@ static const int nfnl_group2type[NFNLGRP_MAX+1] = {
 	[NFNLGRP_CONNTRACK_EXP_NEW]	= NFNL_SUBSYS_CTNETLINK_EXP,
 	[NFNLGRP_CONNTRACK_EXP_UPDATE]	= NFNL_SUBSYS_CTNETLINK_EXP,
 	[NFNLGRP_CONNTRACK_EXP_DESTROY] = NFNL_SUBSYS_CTNETLINK_EXP,
+	[NFNLGRP_NFTABLES]		= NFNL_SUBSYS_NFTABLES,
+	[NFNLGRP_ACCT_QUOTA]		= NFNL_SUBSYS_ACCT,
 };
 
 void nfnl_lock(__u8 subsys_id)
@@ -464,7 +466,12 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 static int nfnetlink_bind(int group)
 {
 	const struct nfnetlink_subsystem *ss;
-	int type = nfnl_group2type[group];
+	int type;
+
+	if (group <= NFNLGRP_NONE || group > NFNLGRP_MAX)
+		return -EINVAL;
+
+	type = nfnl_group2type[group];
 
 	rcu_read_lock();
 	ss = nfnetlink_get_subsys(type);
@@ -514,6 +521,9 @@ static int __init nfnetlink_init(void)
 {
 	int i;
 
+	for (i = NFNLGRP_NONE + 1; i <= NFNLGRP_MAX; i++)
+		BUG_ON(nfnl_group2type[i] == NFNL_SUBSYS_NONE);
+
 	for (i=0; i<NFNL_SUBSYS_COUNT; i++)
 		mutex_init(&table[i].mutex);
 
-- 
1.7.10.4
