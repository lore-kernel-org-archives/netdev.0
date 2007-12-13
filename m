From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 09/12] [DCCP]: Support inserting options during the 3-way handshake
Date: Thu, 13 Dec 2007 13:06:02 -0200
Message-ID: <1197558365-31134-10-git-send-email-acme@redhat.com>
References: <1197558365-31134-1-git-send-email-acme@redhat.com>
 <1197558365-31134-2-git-send-email-acme@redhat.com>
 <1197558365-31134-3-git-send-email-acme@redhat.com>
 <1197558365-31134-4-git-send-email-acme@redhat.com>
 <1197558365-31134-5-git-send-email-acme@redhat.com>
 <1197558365-31134-6-git-send-email-acme@redhat.com>
 <1197558365-31134-7-git-send-email-acme@redhat.com>
 <1197558365-31134-8-git-send-email-acme@redhat.com>
 <1197558365-31134-9-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:4095 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762180AbXLMPGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:24 -0500
Received: by an-out-0708.google.com with SMTP id d31so185751and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:22 -0800 (PST)
In-Reply-To: <1197558365-31134-9-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This provides a separate routine to insert options during the initial handshake.
The main purpose is to conduct feature negotiation, for the moment the only user
is the timestamp echo needed for the (CCID3) handshake RTT sample.

Padding of options has been put into a small separate routine, to be shared among
the two functions. This could also be used as a generic routine to finish inserting
options.

Also removed an `XXX' comment since its content was obvious.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h    |    1 +
 net/dccp/options.c |   32 ++++++++++++++++++++++----------
 net/dccp/output.c  |    2 +-
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 3af3320..b138e20 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -428,6 +428,7 @@ static inline int dccp_ack_pending(const struct sock *sk)
 }
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
+extern int dccp_insert_options_rsk(struct dccp_request_sock*, struct sk_buff*);
 extern int dccp_insert_option_elapsed_time(struct sock *sk,
 					    struct sk_buff *skb,
 					    u32 elapsed_time);
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 0c996d8..bedb5da 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -537,6 +537,18 @@ static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
+/* The length of all options needs to be a multiple of 4 (5.8) */
+static void dccp_insert_option_padding(struct sk_buff *skb)
+{
+	int padding = DCCP_SKB_CB(skb)->dccpd_opt_len % 4;
+
+	if (padding != 0) {
+		padding = 4 - padding;
+		memset(skb_push(skb, padding), 0, padding);
+		DCCP_SKB_CB(skb)->dccpd_opt_len += padding;
+	}
+}
+
 int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -580,18 +592,18 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 	    dccp_insert_option_timestamp_echo(dp, NULL, skb))
 		return -1;
 
-	/* XXX: insert other options when appropriate */
+	dccp_insert_option_padding(skb);
+	return 0;
+}
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len != 0) {
-		/* The length of all options has to be a multiple of 4 */
-		int padding = DCCP_SKB_CB(skb)->dccpd_opt_len % 4;
+int dccp_insert_options_rsk(struct dccp_request_sock *dreq, struct sk_buff *skb)
+{
+	DCCP_SKB_CB(skb)->dccpd_opt_len = 0;
 
-		if (padding != 0) {
-			padding = 4 - padding;
-			memset(skb_push(skb, padding), 0, padding);
-			DCCP_SKB_CB(skb)->dccpd_opt_len += padding;
-		}
-	}
+	if (dreq->dreq_timestamp_echo != 0 &&
+	    dccp_insert_option_timestamp_echo(NULL, dreq, skb))
+		return -1;
 
+	dccp_insert_option_padding(skb);
 	return 0;
 }
diff --git a/net/dccp/output.c b/net/dccp/output.c
index b2e1791..5589a5e 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -303,7 +303,7 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
 	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
 
-	if (dccp_insert_options(sk, skb)) {
+	if (dccp_insert_options_rsk(dreq, skb)) {
 		kfree_skb(skb);
 		return NULL;
 	}
-- 
1.5.3.4

