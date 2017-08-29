From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: dsa: Don't dereference dst->cpu_dp->netdev
Date: Mon, 28 Aug 2017 17:10:51 -0700
Message-ID: <1503965451-59498-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, dan.carpenter@oracle.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:38799 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdH2AQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 20:16:42 -0400
Received: by mail-qk0-f196.google.com with SMTP id o63so1772448qkb.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 17:16:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we do not have a master network device attached dst->cpu_dp will be
NULL and accessing cpu_dp->netdev will create a trace similar to the one
below. The correct check is on dst->cpu_dp period.

[    1.004650] DSA: switch 0 0 parsed
[    1.008078] Unable to handle kernel NULL pointer dereference at
virtual address 00000010
[    1.016195] pgd = c0003000
[    1.018918] [00000010] *pgd=80000000004003, *pmd=00000000
[    1.024349] Internal error: Oops: 206 [#1] SMP ARM
[    1.029157] Modules linked in:
[    1.032228] CPU: 0 PID: 1 Comm: swapper/0 Not tainted
4.13.0-rc6-00071-g45b45afab9bd-dirty #7
[    1.040772] Hardware name: Broadcom STB (Flattened Device Tree)
[    1.046704] task: ee08f840 task.stack: ee090000
[    1.051258] PC is at dsa_register_switch+0x5e0/0x9dc
[    1.056234] LR is at dsa_register_switch+0x5d0/0x9dc
[    1.061211] pc : [<c08fb28c>]    lr : [<c08fb27c>]    psr: 60000213
[    1.067491] sp : ee091d88  ip : 00000000  fp : 0000000c
[    1.072728] r10: 00000000  r9 : 00000001  r8 : ee208010
[    1.077965] r7 : ee2b57b0  r6 : ee2b5780  r5 : 00000000  r4 :
ee208e0c
[    1.084506] r3 : 00000000  r2 : 00040d00  r1 : 2d1b2000  r0 :
00000016
[    1.091050] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
Segment user
[    1.098199] Control: 32c5387d  Table: 00003000  DAC: fffffffd
[    1.103957] Process swapper/0 (pid: 1, stack limit = 0xee090210)

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 6d3c8c0dd88a ("net: dsa: Remove master_netdev and use dst->cpu_dp->netdev")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index c442051d5a55..20bc9c56fca0 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -577,7 +577,7 @@ static int dsa_dst_parse(struct dsa_switch_tree *dst)
 			return err;
 	}
 
-	if (!dst->cpu_dp->netdev) {
+	if (!dst->cpu_dp) {
 		pr_warn("Tree has no master device\n");
 		return -EINVAL;
 	}
-- 
1.9.1
