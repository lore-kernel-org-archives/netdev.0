From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v3 1/4] ipv4: introduce frag_expire_skip_icmp()
Date: Thu,  7 May 2015 21:26:36 -0700
Message-ID: <1431059199-7139-2-git-send-email-azhou@nicira.com>
References: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:37668 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751367AbbEHEsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 00:48:17 -0400
Received: by mail-pd0-f174.google.com with SMTP id qa5so62807360pdb.1
        for <netdev@vger.kernel.org>; Thu, 07 May 2015 21:48:16 -0700 (PDT)
In-Reply-To: <1431059199-7139-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve readability of skip ICMP for de-fragmentation expiration logic.
This change will also make the logic easier to maintain when the
following patches in this series are applied.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h       | 10 ++++++++++
 net/ipv4/ip_fragment.c | 13 +++++++++----
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index d14af7e..f79193a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -478,6 +478,16 @@ enum ip_defrag_users {
 	IP_DEFRAG_MACVLAN,
 };
 
+/* Return true if the value of 'user' is between 'lower_bond'
+ * and 'upper_bond' inclusively.
+ */
+static inline bool ip_defrag_user_in_between(u32 user,
+					     enum ip_defrag_users lower_bond,
+					     enum ip_defrag_users upper_bond)
+{
+	return (user >= lower_bond && user <= upper_bond);
+}
+
 int ip_defrag(struct sk_buff *skb, u32 user);
 #ifdef CONFIG_INET
 struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index cc1da6d..429cefa 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -173,6 +173,13 @@ static void ipq_kill(struct ipq *ipq)
 	inet_frag_kill(&ipq->q, &ip4_frags);
 }
 
+static bool frag_expire_skip_icmp(u32 user)
+{
+	return (user == IP_DEFRAG_AF_PACKET ||
+		ip_defrag_user_in_between(user, IP_DEFRAG_CONNTRACK_IN,
+					  __IP_DEFRAG_CONNTRACK_IN_END));
+}
+
 /*
  * Oops, a fragment queue timed out.  Kill it and send an ICMP reply.
  */
@@ -217,10 +224,8 @@ static void ip_expire(unsigned long arg)
 		/* Only an end host needs to send an ICMP
 		 * "Fragment Reassembly Timeout" message, per RFC792.
 		 */
-		if (qp->user == IP_DEFRAG_AF_PACKET ||
-		    ((qp->user >= IP_DEFRAG_CONNTRACK_IN) &&
-		     (qp->user <= __IP_DEFRAG_CONNTRACK_IN_END) &&
-		     (skb_rtable(head)->rt_type != RTN_LOCAL)))
+		if (frag_expire_skip_icmp(qp->user) &&
+		    (skb_rtable(head)->rt_type != RTN_LOCAL))
 			goto out_rcu_unlock;
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
-- 
1.9.1
