From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/9] net: ptp: use sk_unattached_filter_create() for BPF
Date: Fri, 21 Mar 2014 13:20:13 +0100
Message-ID: <1395404418-25376-5-git-send-email-dborkman@redhat.com>
References: <1395404418-25376-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Richard Cochran <richard.cochran@omicron.at>,
	Jiri Benc <jbenc@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760506AbaCUMU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:20:56 -0400
In-Reply-To: <1395404418-25376-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch migrates an open-coded sk_run_filter() implementation with
proper use of the BPF API, that is, sk_unattached_filter_create(). This
migration is needed, as we will be internally transforming the filter
to a different representation, and therefore needs to be decoupled.

It is okay to do so as skb_timestamping_init() is called during
initialization of the network stack in core initcall via sock_init().
This would effectively also allow for PTP filters to be jit compiled if
bpf_jit_enable is set.

For better readability, there are also some newlines introduced, also
ptp_classify.h is only in kernel space.

Joint work with Alexei Starovoitov.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Cc: Richard Cochran <richard.cochran@omicron.at>
Cc: Jiri Benc <jbenc@redhat.com>
---
 include/linux/ptp_classify.h |  4 ----
 net/core/timestamping.c      | 21 ++++++++++++++-------
 2 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.h
index 1dc420b..3decfa4 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -27,11 +27,7 @@
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/filter.h>
-#ifdef __KERNEL__
 #include <linux/in.h>
-#else
-#include <netinet/in.h>
-#endif
 
 #define PTP_CLASS_NONE  0x00 /* not a PTP event message */
 #define PTP_CLASS_V1    0x01 /* protocol version 1 */
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 661b5a4..837485d 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -23,16 +23,13 @@
 #include <linux/skbuff.h>
 #include <linux/export.h>
 
-static struct sock_filter ptp_filter[] = {
-	PTP_FILTER
-};
+static struct sk_filter *ptp_insns __read_mostly;
 
 static unsigned int classify(const struct sk_buff *skb)
 {
-	if (likely(skb->dev &&
-		   skb->dev->phydev &&
+	if (likely(skb->dev && skb->dev->phydev &&
 		   skb->dev->phydev->drv))
-		return sk_run_filter(skb, ptp_filter);
+		return SK_RUN_FILTER(ptp_insns, skb);
 	else
 		return PTP_CLASS_NONE;
 }
@@ -60,11 +57,13 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 		if (likely(phydev->drv->txtstamp)) {
 			if (!atomic_inc_not_zero(&sk->sk_refcnt))
 				return;
+
 			clone = skb_clone(skb, GFP_ATOMIC);
 			if (!clone) {
 				sock_put(sk);
 				return;
 			}
+
 			clone->sk = sk;
 			phydev->drv->txtstamp(phydev, clone, type);
 		}
@@ -89,12 +88,15 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	}
 
 	*skb_hwtstamps(skb) = *hwtstamps;
+
 	serr = SKB_EXT_ERR(skb);
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno = ENOMSG;
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	skb->sk = NULL;
+
 	err = sock_queue_err_skb(sk, skb);
+
 	sock_put(sk);
 	if (err)
 		kfree_skb(skb);
@@ -135,5 +137,10 @@ EXPORT_SYMBOL_GPL(skb_defer_rx_timestamp);
 
 void __init skb_timestamping_init(void)
 {
-	BUG_ON(sk_chk_filter(ptp_filter, ARRAY_SIZE(ptp_filter)));
+	struct sock_filter ptp_filter[] = { PTP_FILTER };
+	struct sock_fprog ptp_prog = {
+		.len = ARRAY_SIZE(ptp_filter), .filter = ptp_filter,
+	};
+
+	BUG_ON(sk_unattached_filter_create(&ptp_insns, &ptp_prog));
 }
-- 
1.7.11.7
