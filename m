From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [BUG] index is out of range for nfnl_group2type[]
Date: Fri, 14 Nov 2014 18:44:38 +0100
Message-ID: <20141114174438.GA10644@salvia>
References: <5464733B.5060505@samsung.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5464733B.5060505@samsung.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 13, 2014 at 12:00:43PM +0300, Andrey Ryabinin wrote:
> FYI I've spotted this:
> 
> [  180.202810] ================================================================================
> [  180.203600] UBSan: Undefined behaviour in ../net/netfilter/nfnetlink.c:467:28
> [  180.204249] index 9 is out of range for type 'int [9]'
> [  180.204697] CPU: 0 PID: 1771 Comm: trinity-main Not tainted 3.18.0-rc4-mm1+ #122
> [  180.205365] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
> [  180.206498]  0000000000000018 0000000000000000 0000000000000009 ffff88007bdf7da8
> [  180.207220]  ffffffff82b0ef5f 0000000000000092 ffffffff845ae2e0 ffff88007bdf7db8
> [  180.207887]  ffffffff8199e489 ffff88007bdf7e18 ffffffff8199ea22 0000003900000000
> [  180.208639] Call Trace:
> [  180.208857] dump_stack (lib/dump_stack.c:52)
> [  180.209370] ubsan_epilogue (lib/ubsan.c:174)
> [  180.209849] __ubsan_handle_out_of_bounds (lib/ubsan.c:400)
> [  180.210512] nfnetlink_bind (net/netfilter/nfnetlink.c:467)
> [  180.210986] netlink_bind (net/netlink/af_netlink.c:1483)
> [  180.211495] SYSC_bind (net/socket.c:1541)
> [  180.211940] ? security_socket_setsockopt (security/security.c:1208)
> [  180.212541] ? SyS_setsockopt (net/socket.c:1920 net/socket.c:1900)
> [  180.213057] ? SyS_write (fs/read_write.c:276 fs/read_write.c:588 fs/read_write.c:577)
> [  180.213506] SyS_bind (net/socket.c:1527)
> [  180.213919] system_call_fastpath (arch/x86/kernel/entry_64.S:423)
> [  180.214479] ================================================================================

Thanks for reporting. I think the attached patch fixes this problem.

--X1bOJ3K7DJ5YkBrT
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nfnetlink-fix-insufficient-validation-in-n.patch"

>From 289a727f1561b4e228078d60235f77e88b350f84 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 14 Nov 2014 18:14:33 +0100
Subject: [PATCH] netfilter: nfnetlink: fix insufficient validation in
 nfnetlink_bind

Make sure the netlink group exists, otherwise this trigger an out of
bound array memory access from the netlink_bind() path. This splat
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

Moreover, define the missing nf_tables and nf_acct multicast groups
too to skip.

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


--X1bOJ3K7DJ5YkBrT--
