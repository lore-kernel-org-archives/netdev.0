From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] net: bonding: fix tlb_dynamic_lb default value
Date: Tue, 12 Sep 2017 15:10:05 +0300
Message-ID: <1505218205-2637-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        maheshb@google.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f169.google.com ([209.85.128.169]:34171 "EHLO
        mail-wr0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751373AbdILMKV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 08:10:21 -0400
Received: by mail-wr0-f169.google.com with SMTP id v109so21449834wrc.1
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 05:10:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 8b426dc54cf4 ("bonding: remove hardcoded value") changed the
default value for tlb_dynamic_lb which lead to either broken ALB mode
(since tlb_dynamic_lb can be changed only in TLB) or setting TLB mode
with tlb_dynamic_lb equal to 0.
The first issue was recently fixed by setting tlb_dynamic_lb to 1 always
when switching to ALB mode, but the default value is still wrong and
we'll enter TLB mode with tlb_dynamic_lb equal to 0 if the mode is
changed via netlink or sysfs. In order to restore the previous behaviour
and default value simply remove the mode check around the default param
initialization for tlb_dynamic_lb which will always set it to 1 as
before.

Fixes: 8b426dc54cf4 ("bonding: remove hardcoded value")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/bonding/bond_main.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fc63992ab0e0..c99dc59d729b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4289,7 +4289,7 @@ static int bond_check_params(struct bond_params *params)
 	int bond_mode	= BOND_MODE_ROUNDROBIN;
 	int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
 	int lacp_fast = 0;
-	int tlb_dynamic_lb = 0;
+	int tlb_dynamic_lb;
 
 	/* Convert string parameters. */
 	if (mode) {
@@ -4601,16 +4601,13 @@ static int bond_check_params(struct bond_params *params)
 	}
 	ad_user_port_key = valptr->value;
 
-	if ((bond_mode == BOND_MODE_TLB) || (bond_mode == BOND_MODE_ALB)) {
-		bond_opt_initstr(&newval, "default");
-		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB),
-					&newval);
-		if (!valptr) {
-			pr_err("Error: No tlb_dynamic_lb default value");
-			return -EINVAL;
-		}
-		tlb_dynamic_lb = valptr->value;
+	bond_opt_initstr(&newval, "default");
+	valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB), &newval);
+	if (!valptr) {
+		pr_err("Error: No tlb_dynamic_lb default value");
+		return -EINVAL;
 	}
+	tlb_dynamic_lb = valptr->value;
 
 	if (lp_interval == 0) {
 		pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
-- 
2.1.4
