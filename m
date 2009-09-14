From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/4] RxRPC: Allow key payloads to be passed in XDR form
Date: Mon, 14 Sep 2009 12:17:35 +0100
Message-ID: <20090914111735.10233.64676.stgit@warthog.procyon.org.uk>
References: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754661AbZINLRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 07:17:46 -0400
In-Reply-To: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow add_key() and KEYCTL_INSTANTIATE to accept key payloads in XDR form as
described by openafs-1.4.10/src/auth/afs_token.xg.  This provides a way of
passing kaserver, Kerberos 4, Kerberos 5 and GSSAPI keys from userspace, and
allows for future expansion.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/keys/rxrpc-type.h |   55 ++++++++
 net/rxrpc/ar-internal.h   |   16 --
 net/rxrpc/ar-key.c        |  308 +++++++++++++++++++++++++++++++++++++++------
 net/rxrpc/ar-security.c   |    8 +
 net/rxrpc/rxkad.c         |   41 +++---
 5 files changed, 353 insertions(+), 75 deletions(-)


diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
index 7609365..c0d9121 100644
--- a/include/keys/rxrpc-type.h
+++ b/include/keys/rxrpc-type.h
@@ -21,4 +21,59 @@ extern struct key_type key_type_rxrpc;
 
 extern struct key *rxrpc_get_null_key(const char *);
 
+/*
+ * RxRPC key for Kerberos IV (type-2 security)
+ */
+struct rxkad_key {
+	u32	vice_id;
+	u32	start;			/* time at which ticket starts */
+	u32	expiry;			/* time at which ticket expires */
+	u32	kvno;			/* key version number */
+	u8	primary_flag;		/* T if key for primary cell for this user */
+	u16	ticket_len;		/* length of ticket[] */
+	u8	session_key[8];		/* DES session key */
+	u8	ticket[0];		/* the encrypted ticket */
+};
+
+/*
+ * list of tokens attached to an rxrpc key
+ */
+struct rxrpc_key_token {
+	u16	security_index;		/* RxRPC header security index */
+	struct rxrpc_key_token *next;	/* the next token in the list */
+	union {
+		struct rxkad_key *kad;
+	};
+};
+
+/*
+ * structure of raw payloads passed to add_key() or instantiate key
+ */
+struct rxrpc_key_data_v1 {
+	u32		kif_version;		/* 1 */
+	u16		security_index;
+	u16		ticket_length;
+	u32		expiry;			/* time_t */
+	u32		kvno;
+	u8		session_key[8];
+	u8		ticket[0];
+};
+
+/*
+ * AF_RXRPC key payload derived from XDR format
+ * - based on openafs-1.4.10/src/auth/afs_token.xg
+ */
+#define AFSTOKEN_LENGTH_MAX		16384	/* max payload size */
+#define AFSTOKEN_CELL_MAX		64	/* max cellname length */
+#define AFSTOKEN_MAX			8	/* max tokens per payload */
+#define AFSTOKEN_RK_TIX_MAX		12000	/* max RxKAD ticket size */
+#define AFSTOKEN_GK_KEY_MAX		64	/* max GSSAPI key size */
+#define AFSTOKEN_GK_TOKEN_MAX		16384	/* max GSSAPI token size */
+#define AFSTOKEN_K5_COMPONENTS_MAX	16	/* max K5 components */
+#define AFSTOKEN_K5_NAME_MAX		128	/* max K5 name length */
+#define AFSTOKEN_K5_REALM_MAX		64	/* max K5 realm name length */
+#define AFSTOKEN_K5_TIX_MAX		16384	/* max K5 ticket size */
+#define AFSTOKEN_K5_ADDRESSES_MAX	16	/* max K5 addresses */
+#define AFSTOKEN_K5_AUTHDATA_MAX	16	/* max K5 pieces of auth data */
+
 #endif /* _KEYS_RXRPC_TYPE_H */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3e7318c..46c6d88 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -402,22 +402,6 @@ struct rxrpc_call {
 };
 
 /*
- * RxRPC key for Kerberos (type-2 security)
- */
-struct rxkad_key {
-	u16	security_index;		/* RxRPC header security index */
-	u16	ticket_len;		/* length of ticket[] */
-	u32	expiry;			/* time at which expires */
-	u32	kvno;			/* key version number */
-	u8	session_key[8];		/* DES session key */
-	u8	ticket[0];		/* the encrypted ticket */
-};
-
-struct rxrpc_key_payload {
-	struct rxkad_key k;
-};
-
-/*
  * locally abort an RxRPC call
  */
 static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index b3d10e7..a3a7acb 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -17,6 +17,7 @@
 #include <linux/skbuff.h>
 #include <linux/key-type.h>
 #include <linux/crypto.h>
+#include <linux/ctype.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <keys/rxrpc-type.h>
@@ -55,6 +56,202 @@ struct key_type key_type_rxrpc_s = {
 };
 
 /*
+ * parse an RxKAD type XDR format token
+ * - the caller guarantees we have at least 4 words
+ */
+static int rxrpc_instantiate_xdr_rxkad(struct key *key, const __be32 *xdr,
+				       unsigned toklen)
+{
+	struct rxrpc_key_token *token;
+	size_t plen;
+	u32 tktlen;
+	int ret;
+
+	_enter(",{%x,%x,%x,%x},%u",
+	       ntohl(xdr[0]), ntohl(xdr[1]), ntohl(xdr[2]), ntohl(xdr[3]),
+	       toklen);
+
+	if (toklen <= 8 * 4)
+		return -EKEYREJECTED;
+	tktlen = ntohl(xdr[7]);
+	_debug("tktlen: %x", tktlen);
+	if (tktlen > AFSTOKEN_RK_TIX_MAX)
+		return -EKEYREJECTED;
+	if (8 * 4 + tktlen != toklen)
+		return -EKEYREJECTED;
+
+	plen = sizeof(*token) + sizeof(*token->kad) + tktlen;
+	ret = key_payload_reserve(key, key->datalen + plen);
+	if (ret < 0)
+		return ret;
+
+	plen -= sizeof(*token);
+	token = kmalloc(sizeof(*token), GFP_KERNEL);
+	if (!token)
+		return -ENOMEM;
+
+	token->kad = kmalloc(plen, GFP_KERNEL);
+	if (!token->kad) {
+		kfree(token);
+		return -ENOMEM;
+	}
+
+	token->security_index	= RXRPC_SECURITY_RXKAD;
+	token->kad->ticket_len	= tktlen;
+	token->kad->vice_id	= ntohl(xdr[0]);
+	token->kad->kvno	= ntohl(xdr[1]);
+	token->kad->start	= ntohl(xdr[4]);
+	token->kad->expiry	= ntohl(xdr[5]);
+	token->kad->primary_flag = ntohl(xdr[6]);
+	memcpy(&token->kad->session_key, &xdr[2], 8);
+	memcpy(&token->kad->ticket, &xdr[8], tktlen);
+
+	_debug("SCIX: %u", token->security_index);
+	_debug("TLEN: %u", token->kad->ticket_len);
+	_debug("EXPY: %x", token->kad->expiry);
+	_debug("KVNO: %u", token->kad->kvno);
+	_debug("PRIM: %u", token->kad->primary_flag);
+	_debug("SKEY: %02x%02x%02x%02x%02x%02x%02x%02x",
+	       token->kad->session_key[0], token->kad->session_key[1],
+	       token->kad->session_key[2], token->kad->session_key[3],
+	       token->kad->session_key[4], token->kad->session_key[5],
+	       token->kad->session_key[6], token->kad->session_key[7]);
+	if (token->kad->ticket_len >= 8)
+		_debug("TCKT: %02x%02x%02x%02x%02x%02x%02x%02x",
+		       token->kad->ticket[0], token->kad->ticket[1],
+		       token->kad->ticket[2], token->kad->ticket[3],
+		       token->kad->ticket[4], token->kad->ticket[5],
+		       token->kad->ticket[6], token->kad->ticket[7]);
+
+	/* count the number of tokens attached */
+	key->type_data.x[0]++;
+
+	/* attach the data */
+	token->next = key->payload.data;
+	key->payload.data = token;
+	if (token->kad->expiry < key->expiry)
+		key->expiry = token->kad->expiry;
+
+	_leave(" = 0");
+	return 0;
+}
+
+/*
+ * attempt to parse the data as the XDR format
+ * - the caller guarantees we have more than 7 words
+ */
+static int rxrpc_instantiate_xdr(struct key *key, const void *data, size_t datalen)
+{
+	const __be32 *xdr = data, *token;
+	const char *cp;
+	unsigned len, tmp, loop, ntoken, toklen, sec_ix;
+	int ret;
+
+	_enter(",{%x,%x,%x,%x},%zu",
+	       ntohl(xdr[0]), ntohl(xdr[1]), ntohl(xdr[2]), ntohl(xdr[3]),
+	       datalen);
+
+	if (datalen > AFSTOKEN_LENGTH_MAX)
+		goto not_xdr;
+
+	/* XDR is an array of __be32's */
+	if (datalen & 3)
+		goto not_xdr;
+
+	/* the flags should be 0 (the setpag bit must be handled by
+	 * userspace) */
+	if (ntohl(*xdr++) != 0)
+		goto not_xdr;
+	datalen -= 4;
+
+	/* check the cell name */
+	len = ntohl(*xdr++);
+	if (len < 1 || len > AFSTOKEN_CELL_MAX)
+		goto not_xdr;
+	datalen -= 4;
+	tmp = (len + 3) & ~3;
+	if (tmp > datalen)
+		goto not_xdr;
+
+	cp = (const char *) xdr;
+	for (loop = 0; loop < len; loop++)
+		if (!isprint(cp[loop]))
+			goto not_xdr;
+	if (len < tmp)
+		for (; loop < tmp; loop++)
+			if (cp[loop])
+				goto not_xdr;
+	_debug("cellname: [%u/%u] '%*.*s'",
+	       len, tmp, len, len, (const char *) xdr);
+	datalen -= tmp;
+	xdr += tmp >> 2;
+
+	/* get the token count */
+	if (datalen < 12)
+		goto not_xdr;
+	ntoken = ntohl(*xdr++);
+	datalen -= 4;
+	_debug("ntoken: %x", ntoken);
+	if (ntoken < 1 || ntoken > AFSTOKEN_MAX)
+		goto not_xdr;
+
+	/* check each token wrapper */
+	token = xdr;
+	loop = ntoken;
+	do {
+		if (datalen < 8)
+			goto not_xdr;
+		toklen = ntohl(*xdr++);
+		sec_ix = ntohl(*xdr);
+		datalen -= 4;
+		_debug("token: [%x/%zx] %x", toklen, datalen, sec_ix);
+		if (toklen < 20 || toklen > datalen)
+			goto not_xdr;
+		datalen -= (toklen + 3) & ~3;
+		xdr += (toklen + 3) >> 2;
+
+	} while (--loop > 0);
+
+	_debug("remainder: %zu", datalen);
+	if (datalen != 0)
+		goto not_xdr;
+
+	/* okay: we're going to assume it's valid XDR format
+	 * - we ignore the cellname, relying on the key to be correctly named
+	 */
+	do {
+		xdr = token;
+		toklen = ntohl(*xdr++);
+		token = xdr + ((toklen + 3) >> 2);
+		sec_ix = ntohl(*xdr++);
+		toklen -= 4;
+
+		switch (sec_ix) {
+		case RXRPC_SECURITY_RXKAD:
+			ret = rxrpc_instantiate_xdr_rxkad(key, xdr, toklen);
+			if (ret != 0)
+				goto error;
+			break;
+
+		default:
+			ret = -EPROTONOSUPPORT;
+			goto error;
+		}
+
+	} while (--ntoken > 0);
+
+	_leave(" = 0");
+	return 0;
+
+not_xdr:
+	_leave(" = -EPROTO");
+	return -EPROTO;
+error:
+	_leave(" = %d", ret);
+	return ret;
+}
+
+/*
  * instantiate an rxrpc defined key
  * data should be of the form:
  *	OFFSET	LEN	CONTENT
@@ -70,8 +267,8 @@ struct key_type key_type_rxrpc_s = {
  */
 static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 {
-	const struct rxkad_key *tsec;
-	struct rxrpc_key_payload *upayload;
+	const struct rxrpc_key_data_v1 *v1;
+	struct rxrpc_key_token *token, **pp;
 	size_t plen;
 	u32 kver;
 	int ret;
@@ -82,6 +279,13 @@ static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 	if (!data && datalen == 0)
 		return 0;
 
+	/* determine if the XDR payload format is being used */
+	if (datalen > 7 * 4) {
+		ret = rxrpc_instantiate_xdr(key, data, datalen);
+		if (ret != -EPROTO)
+			return ret;
+	}
+
 	/* get the key interface version number */
 	ret = -EINVAL;
 	if (datalen <= 4 || !data)
@@ -98,53 +302,67 @@ static int rxrpc_instantiate(struct key *key, const void *data, size_t datalen)
 
 	/* deal with a version 1 key */
 	ret = -EINVAL;
-	if (datalen < sizeof(*tsec))
+	if (datalen < sizeof(*v1))
 		goto error;
 
-	tsec = data;
-	if (datalen != sizeof(*tsec) + tsec->ticket_len)
+	v1 = data;
+	if (datalen != sizeof(*v1) + v1->ticket_length)
 		goto error;
 
-	_debug("SCIX: %u", tsec->security_index);
-	_debug("TLEN: %u", tsec->ticket_len);
-	_debug("EXPY: %x", tsec->expiry);
-	_debug("KVNO: %u", tsec->kvno);
+	_debug("SCIX: %u", v1->security_index);
+	_debug("TLEN: %u", v1->ticket_length);
+	_debug("EXPY: %x", v1->expiry);
+	_debug("KVNO: %u", v1->kvno);
 	_debug("SKEY: %02x%02x%02x%02x%02x%02x%02x%02x",
-	       tsec->session_key[0], tsec->session_key[1],
-	       tsec->session_key[2], tsec->session_key[3],
-	       tsec->session_key[4], tsec->session_key[5],
-	       tsec->session_key[6], tsec->session_key[7]);
-	if (tsec->ticket_len >= 8)
+	       v1->session_key[0], v1->session_key[1],
+	       v1->session_key[2], v1->session_key[3],
+	       v1->session_key[4], v1->session_key[5],
+	       v1->session_key[6], v1->session_key[7]);
+	if (v1->ticket_length >= 8)
 		_debug("TCKT: %02x%02x%02x%02x%02x%02x%02x%02x",
-		       tsec->ticket[0], tsec->ticket[1],
-		       tsec->ticket[2], tsec->ticket[3],
-		       tsec->ticket[4], tsec->ticket[5],
-		       tsec->ticket[6], tsec->ticket[7]);
+		       v1->ticket[0], v1->ticket[1],
+		       v1->ticket[2], v1->ticket[3],
+		       v1->ticket[4], v1->ticket[5],
+		       v1->ticket[6], v1->ticket[7]);
 
 	ret = -EPROTONOSUPPORT;
-	if (tsec->security_index != RXRPC_SECURITY_RXKAD)
+	if (v1->security_index != RXRPC_SECURITY_RXKAD)
 		goto error;
 
-	key->type_data.x[0] = tsec->security_index;
-
-	plen = sizeof(*upayload) + tsec->ticket_len;
-	ret = key_payload_reserve(key, plen);
+	plen = sizeof(*token->kad) + v1->ticket_length;
+	ret = key_payload_reserve(key, plen + sizeof(*token));
 	if (ret < 0)
 		goto error;
 
 	ret = -ENOMEM;
-	upayload = kmalloc(plen, GFP_KERNEL);
-	if (!upayload)
+	token = kmalloc(sizeof(*token), GFP_KERNEL);
+	if (!token)
 		goto error;
+	token->kad = kmalloc(plen, GFP_KERNEL);
+	if (!token->kad)
+		goto error_free;
+
+	token->security_index		= RXRPC_SECURITY_RXKAD;
+	token->kad->ticket_len		= v1->ticket_length;
+	token->kad->expiry		= v1->expiry;
+	token->kad->kvno		= v1->kvno;
+	memcpy(&token->kad->session_key, &v1->session_key, 8);
+	memcpy(&token->kad->ticket, v1->ticket, v1->ticket_length);
 
 	/* attach the data */
-	memcpy(&upayload->k, tsec, sizeof(*tsec));
-	memcpy(&upayload->k.ticket, (void *)tsec + sizeof(*tsec),
-	       tsec->ticket_len);
-	key->payload.data = upayload;
-	key->expiry = tsec->expiry;
+	key->type_data.x[0]++;
+
+	pp = (struct rxrpc_key_token **)&key->payload.data;
+	while (*pp)
+		pp = &(*pp)->next;
+	*pp = token;
+	if (token->kad->expiry < key->expiry)
+		key->expiry = token->kad->expiry;
+	token = NULL;
 	ret = 0;
 
+error_free:
+	kfree(token);
 error:
 	return ret;
 }
@@ -184,7 +402,22 @@ static int rxrpc_instantiate_s(struct key *key, const void *data,
  */
 static void rxrpc_destroy(struct key *key)
 {
-	kfree(key->payload.data);
+	struct rxrpc_key_token *token;
+
+	while ((token = key->payload.data)) {
+		key->payload.data = token->next;
+		switch (token->security_index) {
+		case RXRPC_SECURITY_RXKAD:
+			kfree(token->kad);
+			break;
+		default:
+			printk(KERN_ERR "Unknown token type %x on rxrpc key\n",
+			       token->security_index);
+			BUG();
+		}
+
+		kfree(token);
+	}
 }
 
 /*
@@ -293,7 +526,7 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 
 	struct {
 		u32 kver;
-		struct rxkad_key tsec;
+		struct rxrpc_key_data_v1 v1;
 	} data;
 
 	_enter("");
@@ -308,13 +541,12 @@ int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
 	_debug("key %d", key_serial(key));
 
 	data.kver = 1;
-	data.tsec.security_index = RXRPC_SECURITY_RXKAD;
-	data.tsec.ticket_len = 0;
-	data.tsec.expiry = expiry;
-	data.tsec.kvno = 0;
+	data.v1.security_index = RXRPC_SECURITY_RXKAD;
+	data.v1.ticket_length = 0;
+	data.v1.expiry = expiry;
+	data.v1.kvno = 0;
 
-	memcpy(&data.tsec.session_key, session_key,
-	       sizeof(data.tsec.session_key));
+	memcpy(&data.v1.session_key, session_key, sizeof(data.v1.session_key));
 
 	ret = key_instantiate_and_link(key, &data, sizeof(data), NULL, NULL);
 	if (ret < 0)
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index dc62920..49b3cc3 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -16,6 +16,7 @@
 #include <linux/crypto.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
+#include <keys/rxrpc-type.h>
 #include "ar-internal.h"
 
 static LIST_HEAD(rxrpc_security_methods);
@@ -122,6 +123,7 @@ EXPORT_SYMBOL_GPL(rxrpc_unregister_security);
  */
 int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 {
+	struct rxrpc_key_token *token;
 	struct rxrpc_security *sec;
 	struct key *key = conn->key;
 	int ret;
@@ -135,7 +137,11 @@ int rxrpc_init_client_conn_security(struct rxrpc_connection *conn)
 	if (ret < 0)
 		return ret;
 
-	sec = rxrpc_security_lookup(key->type_data.x[0]);
+	if (!key->payload.data)
+		return -EKEYREJECTED;
+	token = key->payload.data;
+
+	sec = rxrpc_security_lookup(token->security_index);
 	if (!sec)
 		return -EKEYREJECTED;
 	conn->security = sec;
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index acec762..713ac59 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -18,6 +18,7 @@
 #include <linux/ctype.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
+#include <keys/rxrpc-type.h>
 #define rxrpc_debug rxkad_debug
 #include "ar-internal.h"
 
@@ -59,14 +60,14 @@ static DEFINE_MUTEX(rxkad_ci_mutex);
  */
 static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 {
-	struct rxrpc_key_payload *payload;
 	struct crypto_blkcipher *ci;
+	struct rxrpc_key_token *token;
 	int ret;
 
 	_enter("{%d},{%x}", conn->debug_id, key_serial(conn->key));
 
-	payload = conn->key->payload.data;
-	conn->security_ix = payload->k.security_index;
+	token = conn->key->payload.data;
+	conn->security_ix = token->security_index;
 
 	ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ci)) {
@@ -75,8 +76,8 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 		goto error;
 	}
 
-	if (crypto_blkcipher_setkey(ci, payload->k.session_key,
-				    sizeof(payload->k.session_key)) < 0)
+	if (crypto_blkcipher_setkey(ci, token->kad->session_key,
+				    sizeof(token->kad->session_key)) < 0)
 		BUG();
 
 	switch (conn->security_level) {
@@ -110,7 +111,7 @@ error:
  */
 static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 {
-	struct rxrpc_key_payload *payload;
+	struct rxrpc_key_token *token;
 	struct blkcipher_desc desc;
 	struct scatterlist sg[2];
 	struct rxrpc_crypt iv;
@@ -123,8 +124,8 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	if (!conn->key)
 		return;
 
-	payload = conn->key->payload.data;
-	memcpy(&iv, payload->k.session_key, sizeof(iv));
+	token = conn->key->payload.data;
+	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	desc.tfm = conn->cipher;
 	desc.info = iv.x;
@@ -197,7 +198,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 					u32 data_size,
 					void *sechdr)
 {
-	const struct rxrpc_key_payload *payload;
+	const struct rxrpc_key_token *token;
 	struct rxkad_level2_hdr rxkhdr
 		__attribute__((aligned(8))); /* must be all on one page */
 	struct rxrpc_skb_priv *sp;
@@ -219,8 +220,8 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	rxkhdr.checksum = 0;
 
 	/* encrypt from the session key */
-	payload = call->conn->key->payload.data;
-	memcpy(&iv, payload->k.session_key, sizeof(iv));
+	token = call->conn->key->payload.data;
+	memcpy(&iv, token->kad->session_key, sizeof(iv));
 	desc.tfm = call->conn->cipher;
 	desc.info = iv.x;
 	desc.flags = 0;
@@ -400,7 +401,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 				       struct sk_buff *skb,
 				       u32 *_abort_code)
 {
-	const struct rxrpc_key_payload *payload;
+	const struct rxrpc_key_token *token;
 	struct rxkad_level2_hdr sechdr;
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
@@ -431,8 +432,8 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	skb_to_sgvec(skb, sg, 0, skb->len);
 
 	/* decrypt from the session key */
-	payload = call->conn->key->payload.data;
-	memcpy(&iv, payload->k.session_key, sizeof(iv));
+	token = call->conn->key->payload.data;
+	memcpy(&iv, token->kad->session_key, sizeof(iv));
 	desc.tfm = call->conn->cipher;
 	desc.info = iv.x;
 	desc.flags = 0;
@@ -737,7 +738,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 				      struct sk_buff *skb,
 				      u32 *_abort_code)
 {
-	const struct rxrpc_key_payload *payload;
+	const struct rxrpc_key_token *token;
 	struct rxkad_challenge challenge;
 	struct rxkad_response resp
 		__attribute__((aligned(8))); /* must be aligned for crypto */
@@ -778,7 +779,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	if (conn->security_level < min_level)
 		goto protocol_error;
 
-	payload = conn->key->payload.data;
+	token = conn->key->payload.data;
 
 	/* build the response packet */
 	memset(&resp, 0, sizeof(resp));
@@ -797,13 +798,13 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 		(conn->channels[3] ? conn->channels[3]->call_id : 0);
 	resp.encrypted.inc_nonce = htonl(nonce + 1);
 	resp.encrypted.level = htonl(conn->security_level);
-	resp.kvno = htonl(payload->k.kvno);
-	resp.ticket_len = htonl(payload->k.ticket_len);
+	resp.kvno = htonl(token->kad->kvno);
+	resp.ticket_len = htonl(token->kad->ticket_len);
 
 	/* calculate the response checksum and then do the encryption */
 	rxkad_calc_response_checksum(&resp);
-	rxkad_encrypt_response(conn, &resp, &payload->k);
-	return rxkad_send_response(conn, &sp->hdr, &resp, &payload->k);
+	rxkad_encrypt_response(conn, &resp, token->kad);
+	return rxkad_send_response(conn, &sp->hdr, &resp, token->kad);
 
 protocol_error:
 	*_abort_code = abort_code;

