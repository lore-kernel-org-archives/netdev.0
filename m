From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/4] RxRPC: Allow RxRPC keys to be read
Date: Mon, 14 Sep 2009 12:17:40 +0100
Message-ID: <20090914111740.10233.56177.stgit@warthog.procyon.org.uk>
References: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	David Howells <dhowells@redhat.com>
To: torvalds@osdl.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755302AbZINLRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 07:17:49 -0400
In-Reply-To: <20090914111730.10233.44007.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow RxRPC keys to be read.  This is to allow pioctl() to be implemented in
userspace.  RxRPC keys are read out in XDR format.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-key.c |  109 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 109 insertions(+), 0 deletions(-)


diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index a3a7acb..bf4d623 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -29,6 +29,7 @@ static int rxrpc_instantiate_s(struct key *, const void *, size_t);
 static void rxrpc_destroy(struct key *);
 static void rxrpc_destroy_s(struct key *);
 static void rxrpc_describe(const struct key *, struct seq_file *);
+static long rxrpc_read(const struct key *, char __user *, size_t);
 
 /*
  * rxrpc defined keys take an arbitrary string as the description and an
@@ -40,6 +41,7 @@ struct key_type key_type_rxrpc = {
 	.match		= user_match,
 	.destroy	= rxrpc_destroy,
 	.describe	= rxrpc_describe,
+	.read		= rxrpc_read,
 };
 EXPORT_SYMBOL(key_type_rxrpc);
 
@@ -592,3 +594,110 @@ struct key *rxrpc_get_null_key(const char *keyname)
 	return key;
 }
 EXPORT_SYMBOL(rxrpc_get_null_key);
+
+/*
+ * read the contents of an rxrpc key
+ * - this returns the result in XDR form
+ */
+static long rxrpc_read(const struct key *key,
+		       char __user *buffer, size_t buflen)
+{
+	struct rxrpc_key_token *token;
+	size_t size, toksize;
+	__be32 __user *xdr;
+	u32 cnlen, tktlen, ntoks, zero;
+
+	_enter("");
+
+	/* we don't know what form we should return non-AFS keys in */
+	if (memcmp(key->description, "afs@", 4) != 0)
+		return -EOPNOTSUPP;
+	cnlen = strlen(key->description + 4);
+
+	/* AFS keys we return in XDR form, so we need to work out the size of
+	 * the XDR */
+	size = 2 * 4;	/* flags, cellname len */
+	size += (cnlen + 3) & ~3;	/* cellname */
+	size += 1 * 4;	/* token count */
+
+	ntoks = 0;
+	for (token = key->payload.data; token; token = token->next) {
+		switch (token->security_index) {
+		case RXRPC_SECURITY_RXKAD:
+			size += 2 * 4;	/* length, security index (switch ID) */
+			size += 8 * 4;	/* viceid, kvno, key*2, begin, end,
+					 * primary, tktlen */
+			size += (token->kad->ticket_len + 3) & ~3; /* ticket */
+			ntoks++;
+			break;
+
+		default: /* can't encode */
+			break;
+		}
+	}
+
+	if (!buffer || buflen < size)
+		return size;
+
+	xdr = (__be32 __user *) buffer;
+	zero = 0;
+#define ENCODE(x)				\
+	do {					\
+		__be32 y = htonl(x);		\
+		if (put_user(y, xdr++) < 0)	\
+			goto fault;		\
+	} while(0)
+
+	ENCODE(0);	/* flags */
+	ENCODE(cnlen);	/* cellname length */
+	if (copy_to_user(xdr, key->description + 4, cnlen) != 0)
+		goto fault;
+	if (cnlen & 3 &&
+	    copy_to_user((u8 *)xdr + cnlen, &zero, 4 - (cnlen & 3)) != 0)
+		goto fault;
+	xdr += (cnlen + 3) >> 2;
+	ENCODE(ntoks);	/* token count */
+
+	for (token = key->payload.data; token; token = token->next) {
+		toksize = 1 * 4;	/* sec index */
+
+		switch (token->security_index) {
+		case RXRPC_SECURITY_RXKAD:
+			toksize += 8 * 4;
+			toksize += (token->kad->ticket_len + 3) & ~3;
+			ENCODE(toksize);
+			ENCODE(token->security_index);
+			ENCODE(token->kad->vice_id);
+			ENCODE(token->kad->kvno);
+			if (copy_to_user(xdr, token->kad->session_key, 8) != 0)
+				goto fault;
+			xdr += 8 >> 2;
+			ENCODE(token->kad->start);
+			ENCODE(token->kad->expiry);
+			ENCODE(token->kad->primary_flag);
+			tktlen = token->kad->ticket_len;
+			ENCODE(tktlen);
+			if (copy_to_user(xdr, token->kad->ticket, tktlen) != 0)
+				goto fault;
+			if (tktlen & 3 &&
+			    copy_to_user((u8 *)xdr + tktlen, &zero,
+					 4 - (tktlen & 3)) != 0)
+				goto fault;
+			xdr += (tktlen + 3) >> 2;
+			break;
+
+		default:
+			break;
+		}
+	}
+
+#undef ENCODE
+
+	ASSERTCMP((char __user *) xdr - buffer, ==, size);
+	_leave(" = %zu", size);
+	return size;
+
+fault:
+	_leave(" = -EFAULT");
+	return -EFAULT;
+}

