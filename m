From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib rule
Date: Thu, 13 Jul 2017 12:11:37 -0700
Message-ID: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: idosch@mellanox.com, jiri@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36764 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752435AbdGMTLq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 15:11:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so7931153pgy.3
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 12:11:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The recent conversion to refcount_t, 717d1e993ad8 ("net: convert
fib_rule.refcnt from atomic_t to refcount_t"), and subsequent fix
by Eric, 5361e209dd30 ("net: avoid one splat in fib_nl_delrule()"),
exposed a bug in mlxsw.

The driver is doing a put on fib rules after processing it from the
notifier. This triggers a BUG on:

[  104.444889] BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
[  104.452821] IP: fib_rules_lookup+0x39/0x170
[  104.457056] PGD 409395067
[  104.457057] P4D 409395067
[  104.459783] PUD 408c23067
[  104.462507] PMD 0
...
[  104.519750] CPU: 1 PID: 900 Comm: vrf Tainted: G        W       4.12.0-rc7+ #51
[  104.527133] Hardware name: Mellanox Technologies Ltd. Mellanox switch/Mellanox switch, BIOS 4.6.5 05/21/2015
[  104.537084] task: ffff880401454380 task.stack: ffffc900007c0000
[  104.543029] RIP: 0010:fib_rules_lookup+0x39/0x170
[  104.547784] RSP: 0000:ffff88041dd039d8 EFLAGS: 00010207
[  104.553053] RAX: 00000000d8e1b910 RBX: 0000000000000000 RCX: 0000000000000002
[  104.560264] RDX: 00000000fffffff5 RSI: 0000000000000000 RDI: ffff880408d80f30
[  104.567461] RBP: ffff88041dd03a08 R08: 000000000000001d R09: 0000000000000000
[  104.574699] R10: 0000000000000000 R11: 0000000000000006 R12: ffff88040b160cc0
[  104.581916] R13: ffff88041dd03a18 R14: ffff88040b160d40 R15: ffff88041dd03aa0
[  104.589130] FS:  00007f44b0edf700(0000) GS:ffff88041dd00000(0000) knlGS:0000000000000000
[  104.597330] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  104.603151] CR2: 0000000000000010 CR3: 0000000408ca8000 CR4: 00000000001406e0
[  104.610371] Call Trace:
[  104.612839]  <IRQ>
[  104.614872]  __fib_lookup+0x54/0x90
[  104.618406]  fib_validate_source+0x31d/0x570
[  104.622731]  ? fib_rules_lookup+0x131/0x170
[  104.626975]  ? __fib_lookup+0x54/0x90
[  104.630685]  ip_route_input_rcu+0xbcf/0xd30

Since mlxsw is not doing a get on the rule to increase the ref count, it
should not be doing a put.

Fixes: 5d7bfd141924a("ipv4: fib_rules: Dump FIB rules when registering FIB notifier")
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 383fef5a8e24..b0fb8e5e83c9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2844,7 +2844,6 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		rule = fib_work->fr_info.rule;
 		if (!fib4_rule_default(rule) && !rule->l3mdev)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
-		fib_rule_put(rule);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
-- 
2.1.4
