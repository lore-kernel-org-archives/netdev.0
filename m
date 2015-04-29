From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/7] net: Add flow_keys digest
Date: Tue, 28 Apr 2015 21:27:40 -0700
Message-ID: <1430281661-2271966-7-git-send-email-tom@herbertland.com>
References: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jiri@resnulli.us>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39868 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751518AbbD2E2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 00:28:17 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t3T4R4im021998
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u2pxcr470-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 21:28:16 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 274912b2ee2811e4afb00002c992ebde-377d02c0 for <netdev@vger.kernel.org>;	Tue,
 28 Apr 2015 21:28:15 -0700
In-Reply-To: <1430281661-2271966-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some users of flow keys (well just sch_choke now) need to pass
flow_keys in skbuff cb, and use them for exact comparisons of flows
so that skb->hash is not sufficient. In order to increase size of
the flow_keys structure, we introduce another structure for
the purpose of passing flow keys in skbuff cb. We limit this structure
to sixteen bytes, and we will technically treat this as a digest of
flow_keys struct hence its name flow_keys_digest. In the first
incaranation we just copy the flow_keys structure up to 16 bytes--
this is the same information previously passed in the cb. In the
future, we'll adapt this for larger flow_keys and could use something
like SHA-1 over the whole flow_keys to improve the quality of the
digest.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_keys.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index dc8fd81..f2610ad 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -42,4 +42,23 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8
 u32 flow_hash_from_keys(struct flow_keys *keys);
 unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
 			   __be16 protocol);
+
+/* struct flow_keys_digest:
+ *
+ * This structure used to hold a digest of the full flow keys. This is a larger
+ * "hash" of a connection to allow definitively matching specific flows where
+ * the 32 bit skb_hash is not large enough. The size is limited to 16 bytes
+ * so that it can by used in CB of skb (see sch_choke for an example).
+ */
+#define FLOW_KEYS_DIGEST_LEN	16
+struct flow_keys_digest {
+	u8	data[FLOW_KEYS_DIGEST_LEN];
+};
+
+static inline void make_flow_keys_digest(struct flow_keys_digest *digest,
+					 struct flow_keys *flow)
+{
+	memcpy(&digest->data, flow, FLOW_KEYS_DIGEST_LEN);
+}
+
 #endif
-- 
1.8.1
