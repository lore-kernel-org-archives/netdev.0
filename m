From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/5] net: add support for noref skb->sk
Date: Wed, 20 Sep 2017 18:54:01 +0200
Message-ID: <39b55ec9584df7dfd6eb498a3d354cd2e08e3eaa.1505926196.git.pabeni@redhat.com>
References: <cover.1505926196.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750938AbdITQ6K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 12:58:10 -0400
In-Reply-To: <cover.1505926196.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noref sk do not carry a socket refcount, are valid
only inside the current RCU section and must be
explicitly cleared before exiting such section.

They will be used in a later patch to allow early demux
without sock refcounting.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 include/linux/skbuff.h | 30 ++++++++++++++++++++++++++++++
 net/core/sock.c        |  6 ++++++
 2 files changed, 36 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 72299ef00061..459a5672811d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -922,6 +922,36 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
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
index 9b7b6bbb2a23..3aa4950639bb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1893,6 +1893,12 @@ void sock_efree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_efree);
 
+/* dummy destructor used by noref sockets */
+void sock_dummyfree(struct sk_buff *skb)
+{
+}
+EXPORT_SYMBOL(sock_dummyfree);
+
 kuid_t sock_i_uid(struct sock *sk)
 {
 	kuid_t uid;
-- 
2.13.5
