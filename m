From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] net: ptp: oki-semi: fix build dependency
Date: Mon, 31 Mar 2014 11:02:21 -0700
Message-ID: <1396288941-23063-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:48578 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755AbaCaSC0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 14:02:26 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so8573688pbc.13
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 11:02:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix kbuild test error:
ERROR: "ptp_classify_raw" [drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.ko] undefined!

move ptp_classify_raw() out of timestamping into ptp driver

Fixes: 164d8c666521 ("net: ptp: do not reimplement PTP/BPF classifier")
Cc: Paul Mackerras <paulus@samba.org>
Cc: linux-ppp@vger.kernel.org
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

Richard,
thank you for suggestion.
oki-semi depends on ptp, so it's cleaner to move ptp_classify_raw there,
instead of making it unconditionally available in net/core

Daniel,
timestamping has its own copy of PTP_FILTER, since timestamping
doesn't depend on ptp and I didn't want to add circular dependency,
since some of ptp pieces depend on timestamping, but not the others

 drivers/ptp/ptp_clock.c |   16 ++++++++++++++++
 net/core/timestamping.c |    8 +-------
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index e25d2bc898e5..8e4027489de6 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -28,6 +28,7 @@
 #include <linux/slab.h>
 #include <linux/syscalls.h>
 #include <linux/uaccess.h>
+#include <linux/ptp_classify.h>
 
 #include "ptp_private.h"
 
@@ -328,10 +329,19 @@ int ptp_find_pin(struct ptp_clock *ptp,
 }
 EXPORT_SYMBOL(ptp_find_pin);
 
+static struct sk_filter *ptp_insns __read_mostly;
+
+unsigned int ptp_classify_raw(const struct sk_buff *skb)
+{
+	return SK_RUN_FILTER(ptp_insns, skb);
+}
+EXPORT_SYMBOL_GPL(ptp_classify_raw);
+
 /* module operations */
 
 static void __exit ptp_exit(void)
 {
+	sk_unattached_filter_destroy(ptp_insns);
 	class_destroy(ptp_class);
 	unregister_chrdev_region(ptp_devt, MINORMASK + 1);
 	ida_destroy(&ptp_clocks_map);
@@ -339,6 +349,10 @@ static void __exit ptp_exit(void)
 
 static int __init ptp_init(void)
 {
+	static struct sock_filter ptp_filter[] = { PTP_FILTER };
+	struct sock_fprog ptp_prog = {
+		.len = ARRAY_SIZE(ptp_filter), .filter = ptp_filter,
+	};
 	int err;
 
 	ptp_class = class_create(THIS_MODULE, "ptp");
@@ -353,6 +367,8 @@ static int __init ptp_init(void)
 		goto no_region;
 	}
 
+	BUG_ON(sk_unattached_filter_create(&ptp_insns, &ptp_prog));
+
 	ptp_class->dev_groups = ptp_groups;
 	pr_info("PTP clock support registered\n");
 	return 0;
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 9ff26b3cc021..e43d56acf803 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -25,17 +25,11 @@
 
 static struct sk_filter *ptp_insns __read_mostly;
 
-unsigned int ptp_classify_raw(const struct sk_buff *skb)
-{
-	return SK_RUN_FILTER(ptp_insns, skb);
-}
-EXPORT_SYMBOL_GPL(ptp_classify_raw);
-
 static unsigned int classify(const struct sk_buff *skb)
 {
 	if (likely(skb->dev && skb->dev->phydev &&
 		   skb->dev->phydev->drv))
-		return ptp_classify_raw(skb);
+		return SK_RUN_FILTER(ptp_insns, skb);
 	else
 		return PTP_CLASS_NONE;
 }
-- 
1.7.9.5
