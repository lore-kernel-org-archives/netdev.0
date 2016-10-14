From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] lwtunnel: Add destroy state operation
Date: Thu, 13 Oct 2016 17:57:42 -0700
Message-ID: <20161014005743.288956-2-tom@herbertland.com>
References: <20161014005743.288956-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45700 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755218AbcJNBAN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 21:00:13 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9E0uetb000446
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 18:00:12 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 2615dqu0bc-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 18:00:12 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 8e7b75da91a911e69c660002c9dfb610-353e6a50 for <netdev@vger.kernel.org>;        Thu,
 13 Oct 2016 18:00:10 -0700
In-Reply-To: <20161014005743.288956-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users of lwt tunnels may set up some secondary state in build_state
function. Add a corresponding destroy_state function to allow users to
clean up state. This destroy state function is called from lwstate_free.
Also, we now free lwstate using kfree_rcu so user can assume structure
is not freed before rcu.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/lwtunnel.h |  7 +++----
 net/core/lwtunnel.c    | 13 +++++++++++++
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index ea3f80f..119b11b 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -29,6 +29,7 @@ struct lwtunnel_state {
 	int		(*orig_input)(struct sk_buff *);
 	int             len;
 	__u16		headroom;
+	struct		rcu_head rcu;
 	__u8            data[0];
 };
 
@@ -43,13 +44,11 @@ struct lwtunnel_encap_ops {
 	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
 	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
 	int (*xmit)(struct sk_buff *skb);
+	void (*destroy_state)(struct lwtunnel_state *lws);
 };
 
 #ifdef CONFIG_LWTUNNEL
-static inline void lwtstate_free(struct lwtunnel_state *lws)
-{
-	kfree(lws);
-}
+void lwtstate_free(struct lwtunnel_state *lws);
 
 static inline struct lwtunnel_state *
 lwtstate_get(struct lwtunnel_state *lws)
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index e5f84c2..7401474 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -130,6 +130,19 @@ int lwtunnel_build_state(struct net_device *dev, u16 encap_type,
 }
 EXPORT_SYMBOL(lwtunnel_build_state);
 
+void  lwtstate_free(struct lwtunnel_state *lws)
+{
+	const struct lwtunnel_encap_ops *ops = lwtun_encaps[lws->type];
+
+	if (ops->destroy_state) {
+		ops->destroy_state(lws);
+		kfree_rcu(lws, rcu);
+	} else {
+		kfree(lws);
+	}
+}
+EXPORT_SYMBOL(lwtstate_free);
+
 int lwtunnel_fill_encap(struct sk_buff *skb, struct lwtunnel_state *lwtstate)
 {
 	const struct lwtunnel_encap_ops *ops;
-- 
2.9.3
