From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 6/7] net: Add flow_keys digest
Date: Fri, 1 May 2015 11:30:17 -0700
Message-ID: <1430505018-496801-7-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:27554 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751873AbbEASao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:44 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IRgwM016506
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u4e72861d-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:43 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 2c30a4d4f03011e484500002c95209d8-7cad8240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:41 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
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
 include/net/flow_keys.h   | 16 ++++++++++++++++
 net/core/flow_dissector.c | 27 +++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index dc8fd81..6d6ef62 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -42,4 +42,20 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8
 u32 flow_hash_from_keys(struct flow_keys *keys);
 unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
 			   __be16 protocol);
+
+/* struct flow_keys_digest:
+ *
+ * This structure is used to hold a digest of the full flow keys. This is a
+ * larger "hash" of a flow to allow definitively matching specific flows where
+ * the 32 bit skb->hash is not large enough. The size is limited to 16 bytes so
+ * that it can by used in CB of skb (see sch_choke for an example).
+ */
+#define FLOW_KEYS_DIGEST_LEN	16
+struct flow_keys_digest {
+	u8	data[FLOW_KEYS_DIGEST_LEN];
+};
+
+void make_flow_keys_digest(struct flow_keys_digest *digest,
+			   const struct flow_keys *flow);
+
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index b1df995..d3acc4d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -310,6 +310,33 @@ static inline u32 ___skb_get_hash(const struct sk_buff *skb,
 	return __flow_hash_from_keys(keys, keyval);
 }
 
+struct _flow_keys_digest_data {
+	__be16	n_proto;
+	u8	ip_proto;
+	u8	padding;
+	__be32	ports;
+	__be32	src;
+	__be32	dst;
+};
+
+void make_flow_keys_digest(struct flow_keys_digest *digest,
+			   const struct flow_keys *flow)
+{
+	struct _flow_keys_digest_data *data =
+	    (struct _flow_keys_digest_data *)digest;
+
+	BUILD_BUG_ON(sizeof(*data) > sizeof(*digest));
+
+	memset(digest, 0, sizeof(*digest));
+
+	data->n_proto = flow->n_proto;
+	data->ip_proto = flow->ip_proto;
+	data->ports = flow->ports;
+	data->src = flow->src;
+	data->dst = flow->dst;
+}
+EXPORT_SYMBOL(make_flow_keys_digest);
+
 /*
  * __skb_get_hash: calculate a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
-- 
1.8.1
