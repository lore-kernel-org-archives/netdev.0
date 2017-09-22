From: Paolo Abeni <pabeni@redhat.com>
Subject: [RFC PATCH 01/11] net: add support for noref skb->sk
Date: Fri, 22 Sep 2017 23:06:25 +0200
Message-ID: <b16163e3a4fa4d772edeabd8743acb4a07206bb9.1506114055.git.pabeni@redhat.com>
References: <cover.1506114055.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44696 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752694AbdIVVG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 17:06:58 -0400
In-Reply-To: <cover.1506114055.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noref sk do not carry a socket refcount, are valid
only inside the current RCU section and must be
explicitly cleared before exiting such section.

They will be used in a later patch to allow early demux
without sock refcounting.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 31 +++++++++++++++++++++++++++++++
 net/core/sock.c        |  7 +++++++
 2 files changed, 38 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 492828801acb..c3fc32636690 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -922,6 +922,37 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 	return (struct rtable *)skb_dst(skb);
 }
 
+void sock_dummyfree(struct sk_buff *skb);
+
+/* only early demux can set noref socks
+ * noref socks do not carry any refcount and must be
+ * cleared before exiting the current RCU section
+ */
+static inline void skb_set_noref_sk(struct sk_buff *skb, struct sock *sk)
+{
+	skb->sk = sk;
+	skb->destructor = sock_dummyfree;
+}
+
+static inline bool skb_has_noref_sk(struct sk_buff *skb)
+{
+	return skb->destructor == sock_dummyfree;
+}
+
+static inline struct sock *skb_clear_noref_sk(struct sk_buff *skb)
+{
+	struct sock *ret;
+
+	if (!skb_has_noref_sk(skb))
+		return NULL;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+	ret = skb->sk;
+	skb->sk = NULL;
+	skb->destructor = NULL;
+	return ret;
+}
+
 /* For mangling skb->pkt_type from user space side from applications
  * such as nft, tc, etc, we only allow a conservative subset of
  * possible pkt_types to be set.
diff --git a/net/core/sock.c b/net/core/sock.c
index 9b7b6bbb2a23..33da8e7e58a0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1893,6 +1893,13 @@ void sock_efree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_efree);
 
+/* dummy destructor used by noref sockets */
+void sock_dummyfree(struct sk_buff *skb)
+{
+	WARN_ON_ONCE(!rcu_read_lock_held());
+}
+EXPORT_SYMBOL(sock_dummyfree);
+
 kuid_t sock_i_uid(struct sock *sk)
 {
 	kuid_t uid;
-- 
2.13.5
