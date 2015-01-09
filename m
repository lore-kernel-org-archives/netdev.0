From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH] bonding: cleanup bond_opts array
Date: Fri,  9 Jan 2015 13:31:08 -0500
Message-ID: <1420828268-10360-1-git-send-email-jtoppins@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:63338 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbbAIShR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:37:17 -0500
Received: by mail-yh0-f42.google.com with SMTP id v1so4858817yhn.1
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:37:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the empty array element initializer and size the array with
BOND_OPT_LAST so the compiler will complain if more elements are in
there than should be.

An interesting unwanted side effect of this initializer is that if one
inserts new options into the middle of the array then this initializer
will zero out the option that equals BOND_OPT_TLB_DYNAMIC_LB+1.

Example:
Extend the OPTS enum:
enum {
   ...
   BOND_OPT_TLB_DYNAMIC_LB,
   BOND_OPT_LACP_NEW1,
   BOND_OPT_LAST
};

Now insert into bond_opts array:
static const struct bond_option bond_opts[] = {
      ...
      [BOND_OPT_LACP_RATE] = { .... unchanged stuff .... },
      [BOND_OPT_LACP_NEW1] = { ... new stuff ... },
      ...
      [BOND_OPT_TLB_DYNAMIC_LB] = { .... unchanged stuff ....},
      { } // MARK A
};

Since BOND_OPT_LACP_NEW1 = BOND_OPT_TLB_DYNAMIC_LB+1, the last
initializer (MARK A) will overwrite the contents of BOND_OPT_LACP_NEW1
and can be easily viewed with the crash utility.

Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_options.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1a61cc9..9bd538d4 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -186,7 +186,7 @@ static const struct bond_opt_value bond_tlb_dynamic_lb_tbl[] = {
 	{ NULL,  -1, 0}
 };
 
-static const struct bond_option bond_opts[] = {
+static const struct bond_option bond_opts[BOND_OPT_LAST] = {
 	[BOND_OPT_MODE] = {
 		.id = BOND_OPT_MODE,
 		.name = "mode",
@@ -379,8 +379,7 @@ static const struct bond_option bond_opts[] = {
 		.values = bond_tlb_dynamic_lb_tbl,
 		.flags = BOND_OPTFLAG_IFDOWN,
 		.set = bond_option_tlb_dynamic_lb_set,
-	},
-	{ }
+	}
 };
 
 /* Searches for an option by name */
-- 
1.7.10.4
