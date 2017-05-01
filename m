From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 33/53] nefilter: eache: reduce struct size from 32 to 24 byte
Date: Mon,  1 May 2017 12:47:00 +0200
Message-ID: <1493635640-24325-34-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Only "cache" needs to use ulong (its used with set_bit()), missed can use
u16.  Also add build-time assertion to ensure event bits fit.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_ecache.h        | 4 ++--
 include/uapi/linux/netfilter/nf_conntrack_common.h | 3 +++
 net/netfilter/nf_conntrack_ecache.c                | 3 +++
 3 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 12d967b58726..2a10c6570fcc 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -20,11 +20,11 @@ enum nf_ct_ecache_state {
 
 struct nf_conntrack_ecache {
 	unsigned long cache;		/* bitops want long */
-	unsigned long missed;		/* missed events */
+	u16 missed;			/* missed events */
 	u16 ctmask;			/* bitmask of ct events to be delivered */
 	u16 expmask;			/* bitmask of expect events to be delivered */
+	enum nf_ct_ecache_state state:8;/* ecache state */
 	u32 portid;			/* netlink portid of destroyer */
-	enum nf_ct_ecache_state state;	/* ecache state */
 };
 
 static inline struct nf_conntrack_ecache *
diff --git a/include/uapi/linux/netfilter/nf_conntrack_common.h b/include/uapi/linux/netfilter/nf_conntrack_common.h
index b4a0a1940118..a8072cc7fa0b 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_common.h
@@ -119,6 +119,9 @@ enum ip_conntrack_events {
 	IPCT_NATSEQADJ = IPCT_SEQADJ,
 	IPCT_SECMARK,		/* new security mark has been set */
 	IPCT_LABEL,		/* new connlabel has been set */
+#ifdef __KERNEL__
+	__IPCT_MAX
+#endif
 };
 
 enum ip_conntrack_expect_events {
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 6161e92d2980..515212948125 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -420,6 +420,9 @@ int nf_conntrack_ecache_init(void)
 	int ret = nf_ct_extend_register(&event_extend);
 	if (ret < 0)
 		pr_err("nf_ct_event: Unable to register event extension.\n");
+
+	BUILD_BUG_ON(__IPCT_MAX >= 16);	/* ctmask, missed use u16 */
+
 	return ret;
 }
 
-- 
2.1.4

