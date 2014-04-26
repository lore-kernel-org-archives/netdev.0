From: Tom Herbert <therbert@google.com>
Subject: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sat, 26 Apr 2014 14:26:35 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:53100 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbaDZV0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:26:36 -0400
Received: by mail-qa0-f74.google.com with SMTP id w8so812781qac.5
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:26:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if a device provides CHECKSUM_COMPLETE but the checksum
is calculated to be invalid we recompute the checksum and try
again in software. On the other hand, if device returns
CHECKSUM_UNNECESSARY we implicitly trust it and don't verify what it
did. This seems backwards!

Add a sysctl to trust the device and report an invalid checksum when
CHECKSUM_COMPLETE shows it is incorrect. sysctl defaults to enabled.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h     | 7 ++++++-
 net/core/dev.c             | 3 +++
 net/core/sysctl_net_core.c | 7 +++++++
 3 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 3b14acc..f3c6018 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2763,6 +2763,8 @@ static inline __sum16 __skb_checksum_validate_unnecessary(struct sk_buff *skb,
 	return 1;
 }
 
+extern int sysctl_trust_dev_checksum;
+
 /*
  * Validate (init) checksum based on checksum complete.
  *
@@ -2775,9 +2777,12 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 						       __wsum psum)
 {
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		if (!csum_fold(csum_add(psum, skb->csum))) {
+		__sum16 csum = csum_fold(csum_add(psum, skb->csum));
+		if (!csum) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			return 0;
+		} else if (sysctl_trust_dev_checksum) {
+			return csum;
 		}
 	}
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 11d70e3..4f7980a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2918,6 +2918,9 @@ int netdev_tstamp_prequeue __read_mostly = 1;
 int netdev_budget __read_mostly = 300;
 int weight_p __read_mostly = 64;            /* old backlog weight */
 
+int sysctl_trust_dev_checksum = 1;
+EXPORT_SYMBOL(sysctl_trust_dev_checksum);
+
 /* Called with irq disabled */
 static inline void ____napi_schedule(struct softnet_data *sd,
 				     struct napi_struct *napi)
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index cf9cd13..246b9e3 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -263,6 +263,13 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "trust_dev_checksum",
+		.data		= &sysctl_trust_dev_checksum,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 #ifdef CONFIG_BPF_JIT
 	{
 		.procname	= "bpf_jit_enable",
-- 
1.9.1.423.g4596e3a
