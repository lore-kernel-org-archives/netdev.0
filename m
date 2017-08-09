From: Baolin Wang <baolin.wang@linaro.org>
Subject: [PATCH 3/3] net: rxrpc: Replace time_t type with time64_t type
Date: Wed,  9 Aug 2017 10:51:32 +0800
Message-ID: <8ac57c96bf5a0695ecc67fd230440b0b9d15740f.1502246502.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Cc: james.l.morris@oracle.com, serge@hallyn.com,
        marc.dionne@auristor.com, dan.carpenter@oracle.com,
        Jason@zx2c4.com, arnd@arndb.de, broonie@kernel.org,
        keyrings@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
        baolin.wang@linaro.org
To: dhowells@redhat.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
In-Reply-To: <cover.1502246501.git.baolin.wang@linaro.org>
References: <cover.1502246501.git.baolin.wang@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the 'expiry' variable of 'struct key_preparsed_payload' has been
changed to 'time64_t' type, which is year 2038 safe on 32bits system.

In net/rxrpc subsystem, we need convert 'u32' type to 'time64_t' type
when copying ticket expires time to 'prep->expiry', then this patch
introduces two helper functions to help convert 'u32' to 'time64_t'
type.

This patch also uses ktime_get_real_seconds() to get current time instead
of get_seconds() which is not year 2038 safe on 32bits system.

Signed-off-by: Baolin Wang <baolin.wang@linaro.org>
---
 include/keys/rxrpc-type.h |   21 +++++++++++++++++++++
 net/rxrpc/ar-internal.h   |    2 +-
 net/rxrpc/key.c           |   22 ++++++++++++++--------
 net/rxrpc/rxkad.c         |   14 +++++++-------
 4 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
index 5de0673..76421e2 100644
--- a/include/keys/rxrpc-type.h
+++ b/include/keys/rxrpc-type.h
@@ -127,4 +127,25 @@ struct rxrpc_key_data_v1 {
 #define AFSTOKEN_K5_ADDRESSES_MAX	16	/* max K5 addresses */
 #define AFSTOKEN_K5_AUTHDATA_MAX	16	/* max K5 pieces of auth data */
 
+/*
+ * truncate a time64_t to the range from 1970 to 2106 as
+ * in the network protocol
+ */
+static inline u32 rxrpc_time64_to_u32(time64_t time)
+{
+	if (time < 0)
+		return 0;
+
+	if (time > UINT_MAX)
+		return UINT_MAX;
+
+	return (u32)time;
+}
+
+/* extend u32 back to time64_t using the same 1970-2106 range */
+static inline time64_t rxrpc_u32_to_time64(u32 time)
+{
+	return (time64_t)time;
+}
+
 #endif /* _KEYS_RXRPC_TYPE_H */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 69b9733..3c11443 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -894,7 +894,7 @@ void rxrpc_new_incoming_connection(struct rxrpc_sock *,
 
 int rxrpc_request_key(struct rxrpc_sock *, char __user *, int);
 int rxrpc_server_keyring(struct rxrpc_sock *, char __user *, int);
-int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time_t,
+int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time64_t,
 			      u32);
 
 /*
diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index 5436922..e2d3661 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -92,6 +92,7 @@ static int rxrpc_preparse_xdr_rxkad(struct key_preparsed_payload *prep,
 				    const __be32 *xdr, unsigned int toklen)
 {
 	struct rxrpc_key_token *token, **pptoken;
+	time64_t expiry;
 	size_t plen;
 	u32 tktlen;
 
@@ -158,8 +159,9 @@ static int rxrpc_preparse_xdr_rxkad(struct key_preparsed_payload *prep,
 	     pptoken = &(*pptoken)->next)
 		continue;
 	*pptoken = token;
-	if (token->kad->expiry < prep->expiry)
-		prep->expiry = token->kad->expiry;
+	expiry = rxrpc_u32_to_time64(token->kad->expiry);
+	if (expiry < prep->expiry)
+		prep->expiry = expiry;
 
 	_leave(" = 0");
 	return 0;
@@ -433,6 +435,7 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
 	struct rxrpc_key_token *token, **pptoken;
 	struct rxk5_key *rxk5;
 	const __be32 *end_xdr = xdr + (toklen >> 2);
+	time64_t expiry;
 	int ret;
 
 	_enter(",{%x,%x,%x,%x},%u",
@@ -533,8 +536,9 @@ static int rxrpc_preparse_xdr_rxk5(struct key_preparsed_payload *prep,
 	     pptoken = &(*pptoken)->next)
 		continue;
 	*pptoken = token;
-	if (token->kad->expiry < prep->expiry)
-		prep->expiry = token->kad->expiry;
+	expiry = rxrpc_u32_to_time64(token->kad->expiry);
+	if (expiry < prep->expiry)
+		prep->expiry = expiry;
 
 	_leave(" = 0");
 	return 0;
@@ -691,6 +695,7 @@ static int rxrpc_preparse(struct key_preparsed_payload *prep)
 {
 	const struct rxrpc_key_data_v1 *v1;
 	struct rxrpc_key_token *token, **pp;
+	time64_t expiry;
 	size_t plen;
 	u32 kver;
 	int ret;
@@ -777,8 +782,9 @@ static int rxrpc_preparse(struct key_preparsed_payload *prep)
 	while (*pp)
 		pp = &(*pp)->next;
 	*pp = token;
-	if (token->kad->expiry < prep->expiry)
-		prep->expiry = token->kad->expiry;
+	expiry = rxrpc_u32_to_time64(token->kad->expiry);
+	if (expiry < prep->expiry)
+		prep->expiry = expiry;
 	token = NULL;
 	ret = 0;
 
@@ -955,7 +961,7 @@ int rxrpc_server_keyring(struct rxrpc_sock *rx, char __user *optval,
  */
 int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 			      const void *session_key,
-			      time_t expiry,
+			      time64_t expiry,
 			      u32 kvno)
 {
 	const struct cred *cred = current_cred();
@@ -982,7 +988,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 	data.kver = 1;
 	data.v1.security_index = RXRPC_SECURITY_RXKAD;
 	data.v1.ticket_length = 0;
-	data.v1.expiry = expiry;
+	data.v1.expiry = rxrpc_time64_to_u32(expiry);
 	data.v1.kvno = 0;
 
 	memcpy(&data.v1.session_key, session_key, sizeof(data.v1.session_key));
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 46d1a1f..34c86d2 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -854,7 +854,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 				struct sk_buff *skb,
 				void *ticket, size_t ticket_len,
 				struct rxrpc_crypt *_session_key,
-				time_t *_expiry,
+				time64_t *_expiry,
 				u32 *_abort_code)
 {
 	struct skcipher_request *req;
@@ -864,7 +864,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	struct in_addr addr;
 	unsigned int life;
 	const char *eproto;
-	time_t issue, now;
+	time64_t issue, now;
 	bool little_endian;
 	int ret;
 	u32 abort_code;
@@ -960,15 +960,15 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	if (little_endian) {
 		__le32 stamp;
 		memcpy(&stamp, p, 4);
-		issue = le32_to_cpu(stamp);
+		issue = rxrpc_u32_to_time64(le32_to_cpu(stamp));
 	} else {
 		__be32 stamp;
 		memcpy(&stamp, p, 4);
-		issue = be32_to_cpu(stamp);
+		issue = rxrpc_u32_to_time64(be32_to_cpu(stamp));
 	}
 	p += 4;
-	now = get_seconds();
-	_debug("KIV ISSUE: %lx [%lx]", issue, now);
+	now = ktime_get_real_seconds();
+	_debug("KIV ISSUE: %llx [%llx]", issue, now);
 
 	/* check the ticket is in date */
 	if (issue > now) {
@@ -1053,7 +1053,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_crypt session_key;
 	const char *eproto;
-	time_t expiry;
+	time64_t expiry;
 	void *ticket;
 	u32 abort_code, version, kvno, ticket_len, level;
 	__be32 csum;
-- 
1.7.9.5
