From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH] net_sched:  act_ipt forward compat with xtables
Date: Sun, 28 Apr 2013 11:06:38 -0400
Message-ID: <517D3AFE.8020001@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070104090809060905020405"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Jan Engelhardt <jengelh@inai.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f182.google.com ([209.85.210.182]:61244 "EHLO
	mail-ia0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752108Ab3D1PGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 11:06:42 -0400
Received: by mail-ia0-f182.google.com with SMTP id w33so2567526iag.41
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 08:06:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070104090809060905020405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I have done minimal testing on this on my environment. I took Jan's
advise to simplify things.

Hasan,
I know you have your head buried in the sand right now; but please
when you get the time test this patch with the latest iproute2 git
tree and send your tested-by credential.

Dave,
When Hasan nods I think this should also go into stable because none
of the newer kernels work with newer iptables (which is a lot of
distros).

cheers,
jamal

--------------070104090809060905020405
Content-Type: text/plain; charset=UTF-8;
 name="patch-xt-alter2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-xt-alter2"

commit 94c39d99038dd7fdea4922ae4cfb4ad683c1307c
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Sun Apr 28 10:46:56 2013 -0400

    Deal with changes in newer xtables while maintaining backward
    compatibility. Thanks to Jan Engelhardt for suggestions.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index e0f6de6..60d88b6 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -8,7 +8,7 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  *
- * Copyright:	Jamal Hadi Salim (2002-4)
+ * Copyright:	Jamal Hadi Salim (2002-13)
  */
 
 #include <linux/types.h>
@@ -303,17 +303,44 @@ static struct tc_action_ops act_ipt_ops = {
 	.walk		=	tcf_generic_walker
 };
 
-MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
+static struct tc_action_ops act_xt_ops = {
+	.kind		=	"xt",
+	.hinfo		=	&ipt_hash_info,
+	.type		=	TCA_ACT_IPT,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_ipt,
+	.dump		=	tcf_ipt_dump,
+	.cleanup	=	tcf_ipt_cleanup,
+	.lookup		=	tcf_hash_search,
+	.init		=	tcf_ipt_init,
+	.walk		=	tcf_generic_walker
+};
+
+MODULE_AUTHOR("Jamal Hadi Salim(2002-13)");
 MODULE_DESCRIPTION("Iptables target actions");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("act_xt");
 
 static int __init ipt_init_module(void)
 {
-	return tcf_register_action(&act_ipt_ops);
+	int ret1, ret2;
+	ret1 = tcf_register_action(&act_xt_ops);
+	if (ret1 < 0)
+		printk("Failed to load xt action\n");
+	ret2 = tcf_register_action(&act_ipt_ops);
+	if (ret2 < 0)
+		printk("Failed to load ipt action\n");
+
+	if (ret1 < 0 && ret2 < 0)
+		return ret1;
+	else
+		return 0;
 }
 
 static void __exit ipt_cleanup_module(void)
 {
+	tcf_unregister_action(&act_xt_ops);
 	tcf_unregister_action(&act_ipt_ops);
 }
 

--------------070104090809060905020405--
