From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] inet_diag: fix possible overflow in
 inet_diag_dump_one_icsk()
Date: Fri, 13 Mar 2015 09:49:59 -0700
Message-ID: <1426265399.11398.190.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426262994.11398.188.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:33711 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbbCMQuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:50:01 -0400
Received: by iecvj10 with SMTP id vj10so111101566iec.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 09:50:00 -0700 (PDT)
In-Reply-To: <1426262994.11398.188.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

inet_diag_dump_one_icsk() allocates too small skb.

Add inet_sk_attr_size() helper right before inet_sk_diag_fill()
so that it can be updated if/when new attributes are added.

iproute2/ss currently does not use this dump_one() interface,
this might explain nobody noticed this problem yet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
v2: added missing 'static' qualifier

 net/ipv4/inet_diag.c |   18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 81751f12645f..592aff37366b 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -71,6 +71,20 @@ static inline void inet_diag_unlock_handler(
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
+static size_t inet_sk_attr_size(void)
+{
+	return	  nla_total_size(sizeof(struct tcp_info))
+		+ nla_total_size(1) /* INET_DIAG_SHUTDOWN */
+		+ nla_total_size(1) /* INET_DIAG_TOS */
+		+ nla_total_size(1) /* INET_DIAG_TCLASS */
+		+ nla_total_size(sizeof(struct inet_diag_meminfo))
+		+ nla_total_size(sizeof(struct inet_diag_msg))
+		+ nla_total_size(SK_MEMINFO_VARS * sizeof(u32))
+		+ nla_total_size(TCP_CA_NAME_MAX)
+		+ nla_total_size(sizeof(struct tcpvegas_info))
+		+ 64;
+}
+
 int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 			      struct sk_buff *skb, struct inet_diag_req_v2 *req,
 			      struct user_namespace *user_ns,		      	
@@ -326,9 +340,7 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 	if (err)
 		goto out;
 
-	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
-			sizeof(struct inet_diag_meminfo) +
-			sizeof(struct tcp_info) + 64, GFP_KERNEL);
+	rep = nlmsg_new(inet_sk_attr_size(), GFP_KERNEL);
 	if (!rep) {
 		err = -ENOMEM;
 		goto out;
