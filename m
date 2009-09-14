From: David Howells <dhowells@redhat.com>
Subject: [PATCH 4/4] RxRPC: Parse security index 5 keys (Kerberos 5)
Date: Mon, 14 Sep 2009 12:17:46 +0100
Message-ID: <20090914111745.10233.73904.stgit@warthog.procyon.org.uk>
References: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755315AbZINLRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 07:17:55 -0400
In-Reply-To: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse RxRPC security index 5 type keys (Kerberos 5 tokens).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/keys/rxrpc-type.h |   52 ++++
 net/rxrpc/ar-key.c        |  577 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 589 insertions(+), 40 deletions(-)


diff --git a/include/keys/rxrpc-type.h b/include/keys/rxrpc-type.h
index c0d9121..5eb2357 100644
--- a/include/keys/rxrpc-type.h
+++ b/include/keys/rxrpc-type.h
@@ -36,6 +36,54 @@ struct rxkad_key {
 };
 
 /*
+ * Kerberos 5 principal
+ *	name/name/name@realm
+ */
+struct krb5_principal {
+	u8	n_name_parts;		/* N of parts of the name part of the principal */
+	char	**name_parts;		/* parts of the name part of the principal */
+	char	*realm;			/* parts of the realm part of the principal */
+};
+
+/*
+ * Kerberos 5 tagged data
+ */
+struct krb5_tagged_data {
+	/* for tag value, see /usr/include/krb5/krb5.h
+	 * - KRB5_AUTHDATA_* for auth data
+	 * - 
+	 */
+	int32_t		tag;
+	uint32_t	data_len;
+	u8		*data;
+};
+
+/*
+ * RxRPC key for Kerberos V (type-5 security)
+ */
+struct rxk5_key {
+	uint64_t		authtime;	/* time at which auth token generated */
+	uint64_t		starttime;	/* time at which auth token starts */
+	uint64_t		endtime;	/* time at which auth token expired */
+	uint64_t		renew_till;	/* time to which auth token can be renewed */
+	int32_t			is_skey;	/* T if ticket is encrypted in another ticket's
+						 * skey */
+	int32_t			flags;		/* mask of TKT_FLG_* bits (krb5/krb5.h) */
+	struct krb5_principal	client;		/* client principal name */
+	struct krb5_principal	server;		/* server principal name */
+	uint16_t		ticket_len;	/* length of ticket */
+	uint16_t		ticket2_len;	/* length of second ticket */
+	u8			n_authdata;	/* number of authorisation data elements */
+	u8			n_addresses;	/* number of addresses */
+	struct krb5_tagged_data	session;	/* session data; tag is enctype */
+	struct krb5_tagged_data *addresses;	/* addresses */
+	u8			*ticket;	/* krb5 ticket */
+	u8			*ticket2;	/* second krb5 ticket, if related to ticket (via
+						 * DUPLICATE-SKEY or ENC-TKT-IN-SKEY) */
+	struct krb5_tagged_data *authdata;	/* authorisation data */
+};
+
+/*
  * list of tokens attached to an rxrpc key
  */
 struct rxrpc_key_token {
@@ -43,6 +91,7 @@ struct rxrpc_key_token {
 	struct rxrpc_key_token *next;	/* the next token in the list */
 	union {
 		struct rxkad_key *kad;
+		struct rxk5_key *k5;
 	};
 };
 
@@ -64,8 +113,11 @@ struct rxrpc_key_data_v1 {
  * - based on openafs-1.4.10/src/auth/afs_token.xg
  */
 #define AFSTOKEN_LENGTH_MAX		16384	/* max payload size */
+#define AFSTOKEN_STRING_MAX		256	/* max small string length */
+#define AFSTOKEN_DATA_MAX		64	/* max small data length */
 #define AFSTOKEN_CELL_MAX		64	/* max cellname length */
 #define AFSTOKEN_MAX			8	/* max tokens per payload */
+#define AFSTOKEN_BDATALN_MAX		16384	/* max big data length */
 #define AFSTOKEN_RK_TIX_MAX		12000	/* max RxKAD ticket size */
 #define AFSTOKEN_GK_KEY_MAX		64	/* max GSSAPI key size */
 #define AFSTOKEN_GK_TOKEN_MAX		16384	/* max GSSAPI token size */
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index bf4d623..44836f6 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -64,7 +64,7 @@ struct key_type key_type_rxrpc_s = {
 static int rxrpc_instantiate_xdr_rxkad(struct key *key, const __be32 *xdr,
 				       unsigned toklen)
 {
-	struct rxrpc_key_token *token;
+	struct rxrpc_key_token *token, **pptoken;
 	size_t plen;
 	u32 tktlen;
 	int ret;
@@ -129,13 +129,398 @@ static int rxrpc_instantiate_xdr_rxkad(struct key *key, const __be32 *xdr,
 	key->type_data.x[0]++;
 
 	/* attach the data */
-	token->next = key->payload.data;
-	key->payload.data = token;
+	for (pptoken = (struct rxrpc_key_token **)&key->payload.data;
+	     *pptoken;
+	     pptoken = &(*pptoken)->next)
+		continue;
+	*pptoken = token;
+	if (token->kad->expiry < key->expiry)
+		key->expiry = token->kad->expiry;
+
+	_leave(" = 0");
+	return 0;
+}
+
+static void rxrpc_free_krb5_principal(struct krb5_principal *princ)
+{
+	int loop;
+
+	if (princ->name_parts) {
+		for (loop = princ->n_name_parts - 1; loop >= 0; loop--)
+			kfree(princ->name_parts[loop]);
+		kfree(princ->name_parts);
+	}
+	kfree(princ->realm);
+}
+
+static void rxrpc_free_krb5_tagged(struct krb5_tagged_data *td)
+{
+	kfree(td->data);
+}
+
+/*
+ * free up an RxK5 token
+ */
+static void rxrpc_rxk5_free(struct rxk5_key *rxk5)
+{
+	int loop;
+
+	rxrpc_free_krb5_principal(&rxk5->client);
+	rxrpc_free_krb5_principal(&rxk5->server);
+	rxrpc_free_krb5_tagged(&rxk5->session);
+
+	if (rxk5->addresses) {
+		for (loop = rxk5->n_addresses - 1; loop >= 0; loop--)
+			rxrpc_free_krb5_tagged(&rxk5->addresses[loop]);
+		kfree(rxk5->addresses);
+	}
+	if (rxk5->authdata) {
+		for (loop = rxk5->n_authdata - 1; loop >= 0; loop--)
+			rxrpc_free_krb5_tagged(&rxk5->authdata[loop]);
+		kfree(rxk5->authdata);
+	}
+
+	kfree(rxk5->ticket);
+	kfree(rxk5->ticket2);
+	kfree(rxk5);
+}
+
+/*
+ * extract a krb5 principal
+ */
+static int rxrpc_krb5_decode_principal(struct krb5_principal *princ,
+				       const __be32 **_xdr,
+				       unsigned *_toklen)
+{
+	const __be32 *xdr = *_xdr;
+	unsigned toklen = *_toklen, n_parts, loop, tmp;
+
+	/* there must be at least one name, and at least #names+1 length
+	 * words */
+	if (toklen <= 12)
+		return -EINVAL;
+
+	_enter(",{%x,%x,%x},%u",
+	       ntohl(xdr[0]), ntohl(xdr[1]), ntohl(xdr[2]), toklen);
+
+	n_parts = ntohl(*xdr++);
+	toklen -= 4;
+	if (n_parts <= 0 || n_parts > AFSTOKEN_K5_COMPONENTS_MAX)
+		return -EINVAL;
+	princ->n_name_parts = n_parts;
+
+	if (toklen <= (n_parts + 1) * 4)
+		return -EINVAL;
+
+	princ->name_parts = kcalloc(sizeof(char *), n_parts, GFP_KERNEL);
+	if (!princ->name_parts)
+		return -ENOMEM;
+
+	for (loop = 0; loop < n_parts; loop++) {
+		if (toklen < 4)
+			return -EINVAL;
+		tmp = ntohl(*xdr++);
+		toklen -= 4;
+		if (tmp <= 0 || tmp > AFSTOKEN_STRING_MAX)
+			return -EINVAL;
+		if (tmp > toklen)
+			return -EINVAL;
+		princ->name_parts[loop] = kmalloc(tmp + 1, GFP_KERNEL);
+		if (!princ->name_parts[loop])
+			return -ENOMEM;
+		memcpy(princ->name_parts[loop], xdr, tmp);
+		princ->name_parts[loop][tmp] = 0;
+		tmp = (tmp + 3) & ~3;
+		toklen -= tmp;
+		xdr += tmp >> 2;
+	}
+
+	if (toklen < 4)
+		return -EINVAL;
+	tmp = ntohl(*xdr++);
+	toklen -= 4;
+	if (tmp <= 0 || tmp > AFSTOKEN_K5_REALM_MAX)
+		return -EINVAL;
+	if (tmp > toklen)
+		return -EINVAL;
+	princ->realm = kmalloc(tmp + 1, GFP_KERNEL);
+	if (!princ->realm)
+		return -ENOMEM;
+	memcpy(princ->realm, xdr, tmp);
+	princ->realm[tmp] = 0;
+	tmp = (tmp + 3) & ~3;
+	toklen -= tmp;
+	xdr += tmp >> 2;
+
+	_debug("%s/...@%s", princ->name_parts[0], princ->realm);
+
+	*_xdr = xdr;
+	*_toklen = toklen;
+	_leave(" = 0 [toklen=%u]", toklen);
+	return 0;
+}
+
+/*
+ * extract a piece of krb5 tagged data
+ */
+static int rxrpc_krb5_decode_tagged_data(struct krb5_tagged_data *td,
+					 size_t max_data_size,
+					 const __be32 **_xdr,
+					 unsigned *_toklen)
+{
+	const __be32 *xdr = *_xdr;
+	unsigned toklen = *_toklen, len;
+
+	/* there must be at least one tag and one length word */
+	if (toklen <= 8)
+		return -EINVAL;
+
+	_enter(",%zu,{%x,%x},%u",
+	       max_data_size, ntohl(xdr[0]), ntohl(xdr[1]), toklen);
+
+	td->tag = ntohl(*xdr++);
+	len = ntohl(*xdr++);
+	toklen -= 8;
+	if (len > max_data_size)
+		return -EINVAL;
+	td->data_len = len;
+
+	if (len > 0) {
+		td->data = kmalloc(len, GFP_KERNEL);
+		if (!td->data)
+			return -ENOMEM;
+		memcpy(td->data, xdr, len);
+		len = (len + 3) & ~3;
+		toklen -= len;
+		xdr += len >> 2;
+	}
+
+	_debug("tag %x len %x", td->tag, td->data_len);
+
+	*_xdr = xdr;
+	*_toklen = toklen;
+	_leave(" = 0 [toklen=%u]", toklen);
+	return 0;
+}
+
+/*
+ * extract an array of tagged data
+ */
+static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
+					  u8 *_n_elem,
+					  u8 max_n_elem,
+					  size_t max_elem_size,
+					  const __be32 **_xdr,
+					  unsigned *_toklen)
+{
+	struct krb5_tagged_data *td;
+	const __be32 *xdr = *_xdr;
+	unsigned toklen = *_toklen, n_elem, loop;
+	int ret;
+
+	/* there must be at least one count */
+	if (toklen < 4)
+		return -EINVAL;
+
+	_enter(",,%u,%zu,{%x},%u",
+	       max_n_elem, max_elem_size, ntohl(xdr[0]), toklen);
+
+	n_elem = ntohl(*xdr++);
+	toklen -= 4;
+	if (n_elem < 0 || n_elem > max_n_elem)
+		return -EINVAL;
+	*_n_elem = n_elem;
+	if (n_elem > 0) {
+		if (toklen <= (n_elem + 1) * 4)
+			return -EINVAL;
+
+		_debug("n_elem %d", n_elem);
+
+		td = kcalloc(sizeof(struct krb5_tagged_data), n_elem,
+			     GFP_KERNEL);
+		if (!td)
+			return -ENOMEM;
+		*_td = td;
+
+		for (loop = 0; loop < n_elem; loop++) {
+			ret = rxrpc_krb5_decode_tagged_data(&td[loop],
+							    max_elem_size,
+							    &xdr, &toklen);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	*_xdr = xdr;
+	*_toklen = toklen;
+	_leave(" = 0 [toklen=%u]", toklen);
+	return 0;
+}
+
+/*
+ * extract a krb5 ticket
+ */
+static int rxrpc_krb5_decode_ticket(u8 **_ticket, uint16_t *_tktlen,
+				    const __be32 **_xdr, unsigned *_toklen)
+{
+	const __be32 *xdr = *_xdr;
+	unsigned toklen = *_toklen, len;
+
+	/* there must be at least one length word */
+	if (toklen <= 4)
+		return -EINVAL;
+
+	_enter(",{%x},%u", ntohl(xdr[0]), toklen);
+
+	len = ntohl(*xdr++);
+	toklen -= 4;
+	if (len > AFSTOKEN_K5_TIX_MAX)
+		return -EINVAL;
+	*_tktlen = len;
+
+	_debug("ticket len %u", len);
+
+	if (len > 0) {
+		*_ticket = kmalloc(len, GFP_KERNEL);
+		if (!*_ticket)
+			return -ENOMEM;
+		memcpy(*_ticket, xdr, len);
+		len = (len + 3) & ~3;
+		toklen -= len;
+		xdr += len >> 2;
+	}
+
+	*_xdr = xdr;
+	*_toklen = toklen;
+	_leave(" = 0 [toklen=%u]", toklen);
+	return 0;
+}
+
+/*
+ * parse an RxK5 type XDR format token
+ * - the caller guarantees we have at least 4 words
+ */
+static int rxrpc_instantiate_xdr_rxk5(struct key *key, const __be32 *xdr,
+				      unsigned toklen)
+{
+	struct rxrpc_key_token *token, **pptoken;
+	struct rxk5_key *rxk5;
+	const __be32 *end_xdr = xdr + (toklen >> 2);
+	int ret;
+
+	_enter(",{%x,%x,%x,%x},%u",
+	       ntohl(xdr[0]), ntohl(xdr[1]), ntohl(xdr[2]), ntohl(xdr[3]),
+	       toklen);
+
+	/* reserve some payload space for this subkey - the length of the token
+	 * is a reasonable approximation */
+	ret = key_payload_reserve(key, key->datalen + toklen);
+	if (ret < 0)
+		return ret;
+
+	token = kzalloc(sizeof(*token), GFP_KERNEL);
+	if (!token)
+		return -ENOMEM;
+
+	rxk5 = kzalloc(sizeof(*rxk5), GFP_KERNEL);
+	if (!rxk5) {
+		kfree(token);
+		return -ENOMEM;
+	}
+
+	token->security_index = RXRPC_SECURITY_RXK5;
+	token->k5 = rxk5;
+
+	/* extract the principals */
+	ret = rxrpc_krb5_decode_principal(&rxk5->client, &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+	ret = rxrpc_krb5_decode_principal(&rxk5->server, &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+
+	/* extract the session key and the encoding type (the tag field ->
+	 * ENCTYPE_xxx) */
+	ret = rxrpc_krb5_decode_tagged_data(&rxk5->session, AFSTOKEN_DATA_MAX,
+					    &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+
+	if (toklen < 4 * 8 + 2 * 4)
+		goto inval;
+	rxk5->authtime	= be64_to_cpup((const __be64 *) xdr);
+	xdr += 2;
+	rxk5->starttime	= be64_to_cpup((const __be64 *) xdr);
+	xdr += 2;
+	rxk5->endtime	= be64_to_cpup((const __be64 *) xdr);
+	xdr += 2;
+	rxk5->renew_till = be64_to_cpup((const __be64 *) xdr);
+	xdr += 2;
+	rxk5->is_skey = ntohl(*xdr++);
+	rxk5->flags = ntohl(*xdr++);
+	toklen -= 4 * 8 + 2 * 4;
+
+	_debug("times: a=%llx s=%llx e=%llx rt=%llx",
+	       rxk5->authtime, rxk5->starttime, rxk5->endtime,
+	       rxk5->renew_till);
+	_debug("is_skey=%x flags=%x", rxk5->is_skey, rxk5->flags);
+
+	/* extract the permitted client addresses */
+	ret = rxrpc_krb5_decode_tagged_array(&rxk5->addresses,
+					     &rxk5->n_addresses,
+					     AFSTOKEN_K5_ADDRESSES_MAX,
+					     AFSTOKEN_DATA_MAX,
+					     &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+
+	ASSERTCMP((end_xdr - xdr) << 2, ==, toklen);
+
+	/* extract the tickets */
+	ret = rxrpc_krb5_decode_ticket(&rxk5->ticket, &rxk5->ticket_len,
+				       &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+	ret = rxrpc_krb5_decode_ticket(&rxk5->ticket2, &rxk5->ticket2_len,
+				       &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+
+	ASSERTCMP((end_xdr - xdr) << 2, ==, toklen);
+
+	/* extract the typed auth data */
+	ret = rxrpc_krb5_decode_tagged_array(&rxk5->authdata,
+					     &rxk5->n_authdata,
+					     AFSTOKEN_K5_AUTHDATA_MAX,
+					     AFSTOKEN_BDATALN_MAX,
+					     &xdr, &toklen);
+	if (ret < 0)
+		goto error;
+
+	ASSERTCMP((end_xdr - xdr) << 2, ==, toklen);
+
+	if (toklen != 0)
+		goto inval;
+
+	/* attach the payload to the key */
+	for (pptoken = (struct rxrpc_key_token **)&key->payload.data;
+	     *pptoken;
+	     pptoken = &(*pptoken)->next)
+		continue;
+	*pptoken = token;
 	if (token->kad->expiry < key->expiry)
 		key->expiry = token->kad->expiry;
 
 	_leave(" = 0");
 	return 0;
+
+inval:
+	ret = -EINVAL;
+error:
+	rxrpc_rxk5_free(rxk5);
+	kfree(token);
+	_leave(" = %d", ret);
+	return ret;
 }
 
 /*
@@ -228,6 +613,8 @@ static int rxrpc_instantiate_xdr(struct key *key, const void *data, size_t datal
 		sec_ix = ntohl(*xdr++);
 		toklen -= 4;
 
+		_debug("TOKEN type=%u [%p-%p]", sec_ix, xdr, token);
+
 		switch (sec_ix) {
 		case RXRPC_SECURITY_RXKAD:
 			ret = rxrpc_instantiate_xdr_rxkad(key, xdr, toklen);
@@ -235,6 +622,12 @@ static int rxrpc_instantiate_xdr(struct key *key, const void *data, size_t datal
 				goto error;
 			break;
 
+		case RXRPC_SECURITY_RXK5:
+			ret = rxrpc_instantiate_xdr_rxk5(key, xdr, toklen);
+			if (ret != 0)
+				goto error;
+			break;
+
 		default:
 			ret = -EPROTONOSUPPORT;
 			goto error;
@@ -412,6 +805,10 @@ static void rxrpc_destroy(struct key *key)
 		case RXRPC_SECURITY_RXKAD:
 			kfree(token->kad);
 			break;
+		case RXRPC_SECURITY_RXK5:
+			if (token->k5)
+				rxrpc_rxk5_free(token->k5);
+			break;
 		default:
 			printk(KERN_ERR "Unknown token type %x on rxrpc key\n",
 			       token->security_index);
@@ -602,10 +999,13 @@ EXPORT_SYMBOL(rxrpc_get_null_key);
 static long rxrpc_read(const struct key *key,
 		       char __user *buffer, size_t buflen)
 {
-	struct rxrpc_key_token *token;
-	size_t size, toksize;
-	__be32 __user *xdr;
-	u32 cnlen, tktlen, ntoks, zero;
+	const struct rxrpc_key_token *token;
+	const struct krb5_principal *princ;
+	size_t size;
+	__be32 __user *xdr, *oldxdr;
+	u32 cnlen, toksize, ntoks, tok, zero;
+	u16 toksizes[AFSTOKEN_MAX];
+	int loop;
 
 	_enter("");
 
@@ -614,28 +1014,68 @@ static long rxrpc_read(const struct key *key,
 		return -EOPNOTSUPP;
 	cnlen = strlen(key->description + 4);
 
+#define RND(X) (((X) + 3) & ~3)
+
 	/* AFS keys we return in XDR form, so we need to work out the size of
 	 * the XDR */
 	size = 2 * 4;	/* flags, cellname len */
-	size += (cnlen + 3) & ~3;	/* cellname */
+	size += RND(cnlen);	/* cellname */
 	size += 1 * 4;	/* token count */
 
 	ntoks = 0;
 	for (token = key->payload.data; token; token = token->next) {
+		toksize = 4;	/* sec index */
+
 		switch (token->security_index) {
 		case RXRPC_SECURITY_RXKAD:
-			size += 2 * 4;	/* length, security index (switch ID) */
-			size += 8 * 4;	/* viceid, kvno, key*2, begin, end,
-					 * primary, tktlen */
-			size += (token->kad->ticket_len + 3) & ~3; /* ticket */
-			ntoks++;
+			toksize += 8 * 4;	/* viceid, kvno, key*2, begin,
+						 * end, primary, tktlen */
+			toksize += RND(token->kad->ticket_len);
 			break;
 
-		default: /* can't encode */
+		case RXRPC_SECURITY_RXK5:
+			princ = &token->k5->client;
+			toksize += 4 + princ->n_name_parts * 4;
+			for (loop = 0; loop < princ->n_name_parts; loop++)
+				toksize += RND(strlen(princ->name_parts[loop]));
+			toksize += 4 + RND(strlen(princ->realm));
+
+			princ = &token->k5->server;
+			toksize += 4 + princ->n_name_parts * 4;
+			for (loop = 0; loop < princ->n_name_parts; loop++)
+				toksize += RND(strlen(princ->name_parts[loop]));
+			toksize += 4 + RND(strlen(princ->realm));
+
+			toksize += 8 + RND(token->k5->session.data_len);
+
+			toksize += 4 * 8 + 2 * 4;
+
+			toksize += 4 + token->k5->n_addresses * 8;
+			for (loop = 0; loop < token->k5->n_addresses; loop++)
+				toksize += RND(token->k5->addresses[loop].data_len);
+
+			toksize += 4 + RND(token->k5->ticket_len);
+			toksize += 4 + RND(token->k5->ticket2_len);
+
+			toksize += 4 + token->k5->n_authdata * 8;
+			for (loop = 0; loop < token->k5->n_authdata; loop++)
+				toksize += RND(token->k5->authdata[loop].data_len);
 			break;
+
+		default: /* we have a ticket we can't encode */
+			BUG();
+			continue;
 		}
+
+		_debug("token[%u]: toksize=%u", ntoks, toksize);
+		ASSERTCMP(toksize, <=, AFSTOKEN_LENGTH_MAX);
+
+		toksizes[ntoks++] = toksize;
+		size += toksize + 4; /* each token has a length word */
 	}
 
+#undef RND
+
 	if (!buffer || buflen < size)
 		return size;
 
@@ -647,52 +1087,109 @@ static long rxrpc_read(const struct key *key,
 		if (put_user(y, xdr++) < 0)	\
 			goto fault;		\
 	} while(0)
+#define ENCODE_DATA(l, s)						\
+	do {								\
+		u32 _l = (l);						\
+		ENCODE(l);						\
+		if (copy_to_user(xdr, (s), _l) != 0)			\
+			goto fault;					\
+		if (_l & 3 &&						\
+		    copy_to_user((u8 *)xdr + _l, &zero, 4 - (_l & 3)) != 0) \
+			goto fault;					\
+		xdr += (_l + 3) >> 2;					\
+	} while(0)
+#define ENCODE64(x)					\
+	do {						\
+		__be64 y = cpu_to_be64(x);		\
+		if (copy_to_user(xdr, &y, 8) != 0)	\
+			goto fault;			\
+		xdr += 8 >> 2;				\
+	} while(0)
+#define ENCODE_STR(s)				\
+	do {					\
+		const char *_s = (s);		\
+		ENCODE_DATA(strlen(_s), _s);	\
+	} while(0)
 
-	ENCODE(0);	/* flags */
-	ENCODE(cnlen);	/* cellname length */
-	if (copy_to_user(xdr, key->description + 4, cnlen) != 0)
-		goto fault;
-	if (cnlen & 3 &&
-	    copy_to_user((u8 *)xdr + cnlen, &zero, 4 - (cnlen & 3)) != 0)
-		goto fault;
-	xdr += (cnlen + 3) >> 2;
-	ENCODE(ntoks);	/* token count */
+	ENCODE(0);					/* flags */
+	ENCODE_DATA(cnlen, key->description + 4);	/* cellname */
+	ENCODE(ntoks);
 
+	tok = 0;
 	for (token = key->payload.data; token; token = token->next) {
-		toksize = 1 * 4;	/* sec index */
+		toksize = toksizes[tok++];
+		ENCODE(toksize);
+		oldxdr = xdr;
+		ENCODE(token->security_index);
 
 		switch (token->security_index) {
 		case RXRPC_SECURITY_RXKAD:
-			toksize += 8 * 4;
-			toksize += (token->kad->ticket_len + 3) & ~3;
-			ENCODE(toksize);
-			ENCODE(token->security_index);
 			ENCODE(token->kad->vice_id);
 			ENCODE(token->kad->kvno);
-			if (copy_to_user(xdr, token->kad->session_key, 8) != 0)
-				goto fault;
-			xdr += 8 >> 2;
+			ENCODE_DATA(8, token->kad->session_key);
 			ENCODE(token->kad->start);
 			ENCODE(token->kad->expiry);
 			ENCODE(token->kad->primary_flag);
-			tktlen = token->kad->ticket_len;
-			ENCODE(tktlen);
-			if (copy_to_user(xdr, token->kad->ticket, tktlen) != 0)
-				goto fault;
-			if (tktlen & 3 &&
-			    copy_to_user((u8 *)xdr + tktlen, &zero,
-					 4 - (tktlen & 3)) != 0)
-				goto fault;
-			xdr += (tktlen + 3) >> 2;
+			ENCODE_DATA(token->kad->ticket_len, token->kad->ticket);
+			break;
+
+		case RXRPC_SECURITY_RXK5:
+			princ = &token->k5->client;
+			ENCODE(princ->n_name_parts);
+			for (loop = 0; loop < princ->n_name_parts; loop++)
+				ENCODE_STR(princ->name_parts[loop]);
+			ENCODE_STR(princ->realm);
+
+			princ = &token->k5->server;
+			ENCODE(princ->n_name_parts);
+			for (loop = 0; loop < princ->n_name_parts; loop++)
+				ENCODE_STR(princ->name_parts[loop]);
+			ENCODE_STR(princ->realm);
+
+			ENCODE(token->k5->session.tag);
+			ENCODE_DATA(token->k5->session.data_len,
+				    token->k5->session.data);
+
+			ENCODE64(token->k5->authtime);
+			ENCODE64(token->k5->starttime);
+			ENCODE64(token->k5->endtime);
+			ENCODE64(token->k5->renew_till);
+			ENCODE(token->k5->is_skey);
+			ENCODE(token->k5->flags);
+
+			ENCODE(token->k5->n_addresses);
+			for (loop = 0; loop < token->k5->n_addresses; loop++) {
+				ENCODE(token->k5->addresses[loop].tag);
+				ENCODE_DATA(token->k5->addresses[loop].data_len,
+					    token->k5->addresses[loop].data);
+			}
+
+			ENCODE_DATA(token->k5->ticket_len, token->k5->ticket);
+			ENCODE_DATA(token->k5->ticket2_len, token->k5->ticket2);
+
+			ENCODE(token->k5->n_authdata);
+			for (loop = 0; loop < token->k5->n_authdata; loop++) {
+				ENCODE(token->k5->authdata[loop].tag);
+				ENCODE_DATA(token->k5->authdata[loop].data_len,
+					    token->k5->authdata[loop].data);
+			}
 			break;
 
 		default:
+			BUG();
 			break;
 		}
+
+		ASSERTCMP((unsigned long)xdr - (unsigned long)oldxdr, ==,
+			  toksize);
 	}
 
+#undef ENCODE_STR
+#undef ENCODE_DATA
+#undef ENCODE64
 #undef ENCODE
 
+	ASSERTCMP(tok, ==, ntoks);
 	ASSERTCMP((char __user *) xdr - buffer, ==, size);
 	_leave(" = %zu", size);
 	return size;

