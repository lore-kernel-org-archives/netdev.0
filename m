From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 7/8] SCTP: API updates to suport SCTP-AUTH extensions.
Date: Fri, 14 Sep 2007 14:44:58 -0400
Message-ID: <1189795500886-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:33817 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752278AbXINSpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:02 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add SCTP-AUTH API.  The API implemented here was
agreed to between implementors at the 9th SCTP Interop.
It will be documented in the next revision of the
SCTP socket API spec.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/auth.h     |   16 +++
 include/net/sctp/ulpevent.h |    4 +
 include/net/sctp/user.h     |   90 +++++++++++++
 net/sctp/auth.c             |  193 +++++++++++++++++++++++++++
 net/sctp/sm_statefuns.c     |   13 ++
 net/sctp/socket.c           |  304 +++++++++++++++++++++++++++++++++++++++++++
 net/sctp/ulpevent.c         |   37 +++++
 7 files changed, 657 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index 10c8010..4945954 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -43,6 +43,7 @@
 struct sctp_endpoint;
 struct sctp_association;
 struct sctp_authkey;
+struct sctp_hmacalgo;
 
 /*
  * Define a generic struct that will hold all the info
@@ -109,4 +110,19 @@ int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc);
 void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
 			    struct sk_buff *skb,
 			    struct sctp_auth_chunk *auth, gfp_t gfp);
+
+/* API Helpers */
+int sctp_auth_ep_add_chunkid(struct sctp_endpoint *ep, __u8 chunk_id);
+int sctp_auth_ep_set_hmacs(struct sctp_endpoint *ep,
+			    struct sctp_hmacalgo *hmacs);
+int sctp_auth_set_key(struct sctp_endpoint *ep,
+		      struct sctp_association *asoc,
+		      struct sctp_authkey *auth_key);
+int sctp_auth_set_active_key(struct sctp_endpoint *ep,
+		      struct sctp_association *asoc,
+		      __u16 key_id);
+int sctp_auth_del_key_id(struct sctp_endpoint *ep,
+		      struct sctp_association *asoc,
+		      __u16 key_id);
+
 #endif
diff --git a/include/net/sctp/ulpevent.h b/include/net/sctp/ulpevent.h
index de88ed5..922a151 100644
--- a/include/net/sctp/ulpevent.h
+++ b/include/net/sctp/ulpevent.h
@@ -128,6 +128,10 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	struct sctp_chunk *chunk,
 	gfp_t gfp);
 
+struct sctp_ulpevent *sctp_ulpevent_make_authkey(
+	const struct sctp_association *asoc, __u16 key_id,
+	__u32 indication, gfp_t gfp);
+
 void sctp_ulpevent_read_sndrcvinfo(const struct sctp_ulpevent *event,
 	struct msghdr *);
 __u16 sctp_ulpevent_get_notification_type(const struct sctp_ulpevent *event);
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 6d2b577..00848b6 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -103,6 +103,21 @@ enum sctp_optname {
 #define SCTP_PARTIAL_DELIVERY_POINT SCTP_PARTIAL_DELIVERY_POINT
 	SCTP_MAX_BURST,		/* Set/Get max burst */
 #define SCTP_MAX_BURST SCTP_MAX_BURST
+	SCTP_AUTH_CHUNK,	/* Set only: add a chunk type to authenticat */
+#define SCTP_AUTH_CHUNK SCTP_AUTH_CHUNK
+	SCTP_HMAC_IDENT,
+#define SCTP_HMAC_IDENT SCTP_HMAC_IDENT
+	SCTP_AUTH_KEY,
+#define SCTP_AUTH_KEY SCTP_AUTH_KEY
+	SCTP_AUTH_ACTIVE_KEY,
+#define SCTP_AUTH_ACTIVE_KEY SCTP_AUTH_ACTIVE_KEY
+	SCTP_AUTH_DELETE_KEY,
+#define SCTP_AUTH_DELETE_KEY SCTP_AUTH_DELETE_KEY
+	SCTP_PEER_AUTH_CHUNKS,		/* Read only */
+#define SCTP_PEER_AUTH_CHUNKS SCTP_PEER_AUTH_CHUNKS
+	SCTP_LOCAL_AUTH_CHUNKS,		/* Read only */
+#define SCTP_LOCAL_AUTH_CHUNKS SCTP_LOCAL_AUTH_CHUNKS
+
 
 	/* Internal Socket Options. Some of the sctp library functions are 
 	 * implemented using these socket options.
@@ -370,6 +385,19 @@ struct sctp_pdapi_event {
 
 enum { SCTP_PARTIAL_DELIVERY_ABORTED=0, };
 
+struct sctp_authkey_event {
+	__u16 auth_type;
+	__u16 auth_flags;
+	__u32 auth_length;
+	__u16 auth_keynumber;
+	__u16 auth_altkeynumber;
+	__u32 auth_indication;
+	sctp_assoc_t auth_assoc_id;
+};
+
+enum { SCTP_AUTH_NEWKEY = 0, };
+
+
 /*
  * Described in Section 7.3
  *   Ancillary Data and Notification Interest Options
@@ -405,6 +433,7 @@ union sctp_notification {
 	struct sctp_shutdown_event sn_shutdown_event;
 	struct sctp_adaptation_event sn_adaptation_event;
 	struct sctp_pdapi_event sn_pdapi_event;
+	struct sctp_authkey_event sn_authkey_event;
 };
 
 /* Section 5.3.1
@@ -421,6 +450,7 @@ enum sctp_sn_type {
 	SCTP_SHUTDOWN_EVENT,
 	SCTP_PARTIAL_DELIVERY_EVENT,
 	SCTP_ADAPTATION_INDICATION,
+	SCTP_AUTHENTICATION_EVENT,
 };
 
 /* Notification error codes used to fill up the error fields in some
@@ -539,6 +569,54 @@ struct sctp_paddrparams {
 	__u32			spp_flags;
 } __attribute__((packed, aligned(4)));
 
+/*
+ * 7.1.18.  Add a chunk that must be authenticated (SCTP_AUTH_CHUNK)
+ *
+ * This set option adds a chunk type that the user is requesting to be
+ * received only in an authenticated way.  Changes to the list of chunks
+ * will only effect future associations on the socket.
+ */
+struct sctp_authchunk {
+	__u8		sauth_chunk;
+};
+
+/*
+ * 7.1.19.  Get or set the list of supported HMAC Identifiers (SCTP_HMAC_IDENT)
+ *
+ * This option gets or sets the list of HMAC algorithms that the local
+ * endpoint requires the peer to use.
+*/
+struct sctp_hmacalgo {
+	__u16		shmac_num_idents;
+	__u16		shmac_idents[];
+};
+
+/*
+ * 7.1.20.  Set a shared key (SCTP_AUTH_KEY)
+ *
+ * This option will set a shared secret key which is used to build an
+ * association shared key.
+ */
+struct sctp_authkey {
+	sctp_assoc_t	sca_assoc_id;
+	__u16		sca_keynumber;
+	__u16		sca_keylen;
+	__u8		sca_key[];
+};
+
+/*
+ * 7.1.21.  Get or set the active shared key (SCTP_AUTH_ACTIVE_KEY)
+ *
+ * This option will get or set the active shared key to be used to build
+ * the association shared key.
+ */
+
+struct sctp_authkeyid {
+	sctp_assoc_t	scact_assoc_id;
+	__u16		scact_keynumber;
+};
+
+
 /* 7.1.23. Delayed Ack Timer (SCTP_DELAYED_ACK_TIME)
  *
  *   This options will get or set the delayed ack timer.  The time is set
@@ -608,6 +686,18 @@ struct sctp_status {
 };
 
 /*
+ * 7.2.3.  Get the list of chunks the peer requires to be authenticated
+ *         (SCTP_PEER_AUTH_CHUNKS)
+ *
+ * This option gets a list of chunks for a specified association that
+ * the peer requires to be received authenticated only.
+ */
+struct sctp_authchunks {
+	sctp_assoc_t            gauth_assoc_id;
+	uint8_t                 gauth_chunks[];
+};
+
+/*
  * 8.3, 8.5 get all peer/local addresses in an association.
  * This parameter struct is used by SCTP_GET_PEER_ADDRS and 
  * SCTP_GET_LOCAL_ADDRS socket options used internally to implement
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 1fee43e..c2b3999 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -742,3 +742,196 @@ free:
 	if (free_key)
 		sctp_auth_key_put(asoc_key);
 }
+
+/* API Helpers */
+
+/* Add a chunk to the endpoint authenticated chunk list */
+int sctp_auth_ep_add_chunkid(struct sctp_endpoint *ep, __u8 chunk_id)
+{
+	struct sctp_chunks_param *p = ep->auth_chunk_list;
+	__u16 nchunks;
+	__u16 param_len;
+
+	/* If this chunk is already specified, we are done */
+	if (__sctp_auth_cid(chunk_id, p))
+		return 0;
+
+	/* Check if we can add this chunk to the array */
+	param_len = ntohs(p->param_hdr.length);
+	nchunks = param_len - sizeof(sctp_paramhdr_t);
+	if (nchunks == SCTP_NUM_CHUNK_TYPES)
+		return -EINVAL;
+
+	p->chunks[nchunks] = chunk_id;
+	p->param_hdr.length = htons(param_len + 1);
+	return 0;
+}
+
+/* Add hmac identifires to the endpoint list of supported hmac ids */
+int sctp_auth_ep_set_hmacs(struct sctp_endpoint *ep,
+			   struct sctp_hmacalgo *hmacs)
+{
+	int has_sha1 = 0;
+	__u16 id;
+	int i;
+
+	/* Scan the list looking for unsupported id.  Also make sure that
+	 * SHA1 is specified.
+	 */
+	for (i = 0; i < hmacs->shmac_num_idents; i++) {
+		id = hmacs->shmac_idents[i];
+
+		if (SCTP_AUTH_HMAC_ID_SHA1 == id)
+			has_sha1 = 1;
+
+		if (!sctp_hmac_list[id].hmac_name)
+			return -EOPNOTSUPP;
+	}
+
+	if (!has_sha1)
+		return -EINVAL;
+
+	memcpy(ep->auth_hmacs_list->hmac_ids, &hmacs->shmac_idents[0],
+		hmacs->shmac_num_idents * sizeof(__u16));
+	ep->auth_hmacs_list->param_hdr.length = htons(sizeof(sctp_paramhdr_t) +
+				hmacs->shmac_num_idents * sizeof(__u16));
+	return 0;
+}
+
+/* Set a new shared key on either endpoint or association.  If the
+ * the key with a same ID already exists, replace the key (remove the
+ * old key and add a new one).
+ */
+int sctp_auth_set_key(struct sctp_endpoint *ep,
+		      struct sctp_association *asoc,
+		      struct sctp_authkey *auth_key)
+{
+	struct sctp_shared_key *cur_key = NULL;
+	struct sctp_auth_bytes *key;
+	struct list_head *sh_keys;
+	int replace = 0;
+
+	/* Try to find the given key id to see if
+	 * we are doing a replace, or adding a new key
+	 */
+	if (asoc)
+		sh_keys = &asoc->endpoint_shared_keys;
+	else
+		sh_keys = &ep->endpoint_shared_keys;
+
+	key_for_each(cur_key, sh_keys) {
+		if (cur_key->key_id == auth_key->sca_keynumber) {
+			replace = 1;
+			break;
+		}
+	}
+
+	/* If we are not replacing a key id, we need to allocate
+	 * a shared key.
+	 */
+	if (!replace) {
+		cur_key = sctp_auth_shkey_create(auth_key->sca_keynumber,
+						 GFP_KERNEL);
+		if (!cur_key)
+			return -ENOMEM;
+	}
+
+	/* Create a new key data based on the info passed in */
+	key = sctp_auth_create_key(auth_key->sca_keylen, GFP_KERNEL);
+	if (!key)
+		goto nomem;
+
+	memcpy(key->data, &auth_key->sca_key[0], auth_key->sca_keylen);
+
+	/* If we are replacing, remove the old keys data from the
+	 * key id.  If we are adding new key id, add it to the
+	 * list.
+	 */
+	if (replace)
+		sctp_auth_key_put(cur_key->key);
+	else
+		list_add(&cur_key->key_list, sh_keys);
+
+	cur_key->key = key;
+	sctp_auth_key_hold(key);
+
+	return 0;
+nomem:
+	if (!replace)
+		sctp_auth_shkey_free(cur_key);
+
+	return -ENOMEM;
+}
+
+int sctp_auth_set_active_key(struct sctp_endpoint *ep,
+			     struct sctp_association *asoc,
+			     __u16  key_id)
+{
+	struct sctp_shared_key *key;
+	struct list_head *sh_keys;
+	int found = 0;
+
+	/* The key identifier MUST correst to an existing key */
+	if (asoc)
+		sh_keys = &asoc->endpoint_shared_keys;
+	else
+		sh_keys = &ep->endpoint_shared_keys;
+
+	key_for_each(key, sh_keys) {
+		if (key->key_id == key_id) {
+			found = 1;
+			break;
+		}
+	}
+
+	if (!found)
+		return -EINVAL;
+
+	if (asoc) {
+		asoc->active_key_id = key_id;
+		sctp_auth_asoc_init_active_key(asoc, GFP_KERNEL);
+	} else
+		ep->active_key_id = key_id;
+
+	return 0;
+}
+
+int sctp_auth_del_key_id(struct sctp_endpoint *ep,
+			 struct sctp_association *asoc,
+			 __u16  key_id)
+{
+	struct sctp_shared_key *key;
+	struct list_head *sh_keys;
+	int found = 0;
+
+	/* The key identifier MUST NOT be the current active key
+	 * The key identifier MUST correst to an existing key
+	 */
+	if (asoc) {
+		if (asoc->active_key_id == key_id)
+			return -EINVAL;
+
+		sh_keys = &asoc->endpoint_shared_keys;
+	} else {
+		if (ep->active_key_id == key_id)
+			return -EINVAL;
+
+		sh_keys = &ep->endpoint_shared_keys;
+	}
+
+	key_for_each(key, sh_keys) {
+		if (key->key_id == key_id) {
+			found = 1;
+			break;
+		}
+	}
+
+	if (!found)
+		return -EINVAL;
+
+	/* Delete the shared key */
+	list_del_init(&key->key_list);
+	sctp_auth_shkey_free(key);
+
+	return 0;
+}
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 21b0f48..a9b46d2 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3776,6 +3776,19 @@ sctp_disposition_t sctp_sf_eat_auth(const struct sctp_endpoint *ep,
 			break;
 	}
 
+	if (asoc->active_key_id != ntohs(auth_hdr->shkey_id)) {
+		struct sctp_ulpevent *ev;
+
+		ev = sctp_ulpevent_make_authkey(asoc, ntohs(auth_hdr->shkey_id),
+				    SCTP_AUTH_NEWKEY, GFP_ATOMIC);
+
+		if (!ev)
+			return -ENOMEM;
+
+		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
+				SCTP_ULPEVENT(ev));
+	}
+
 	return SCTP_DISPOSITION_CONSUME;
 }
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f53545a..8e48fe4 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2968,6 +2968,164 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 	return 0;
 }
 
+/*
+ * 7.1.18.  Add a chunk that must be authenticated (SCTP_AUTH_CHUNK)
+ *
+ * This set option adds a chunk type that the user is requesting to be
+ * received only in an authenticated way.  Changes to the list of chunks
+ * will only effect future associations on the socket.
+ */
+static int sctp_setsockopt_auth_chunk(struct sock *sk,
+				    char __user *optval,
+				    int optlen)
+{
+	struct sctp_authchunk val;
+
+	if (optlen != sizeof(struct sctp_authchunk))
+		return -EINVAL;
+	if (copy_from_user(&val, optval, optlen))
+		return -EFAULT;
+
+	switch (val.sauth_chunk) {
+		case SCTP_CID_INIT:
+		case SCTP_CID_INIT_ACK:
+		case SCTP_CID_SHUTDOWN_COMPLETE:
+		case SCTP_CID_AUTH:
+			return -EINVAL;
+	}
+
+	/* add this chunk id to the endpoint */
+	return sctp_auth_ep_add_chunkid(sctp_sk(sk)->ep, val.sauth_chunk);
+}
+
+/*
+ * 7.1.19.  Get or set the list of supported HMAC Identifiers (SCTP_HMAC_IDENT)
+ *
+ * This option gets or sets the list of HMAC algorithms that the local
+ * endpoint requires the peer to use.
+ */
+static int sctp_setsockopt_hmac_ident(struct sock *sk,
+				    char __user *optval,
+				    int optlen)
+{
+	struct sctp_hmacalgo *hmacs;
+	int err;
+
+	if (optlen < sizeof(struct sctp_hmacalgo))
+		return -EINVAL;
+
+	hmacs = kmalloc(optlen, GFP_KERNEL);
+	if (!hmacs)
+		return -ENOMEM;
+
+	if (copy_from_user(hmacs, optval, optlen)) {
+		err = -EFAULT;
+		goto out;
+	}
+
+	if (hmacs->shmac_num_idents == 0 ||
+	    hmacs->shmac_num_idents > SCTP_AUTH_NUM_HMACS) {
+		err = -EINVAL;
+		goto out;
+	}
+
+	err = sctp_auth_ep_set_hmacs(sctp_sk(sk)->ep, hmacs);
+out:
+	kfree(hmacs);
+	return err;
+}
+
+/*
+ * 7.1.20.  Set a shared key (SCTP_AUTH_KEY)
+ *
+ * This option will set a shared secret key which is used to build an
+ * association shared key.
+ */
+static int sctp_setsockopt_auth_key(struct sock *sk,
+				    char __user *optval,
+				    int optlen)
+{
+	struct sctp_authkey *authkey;
+	struct sctp_association *asoc;
+	int ret;
+
+	if (optlen <= sizeof(struct sctp_authkey))
+		return -EINVAL;
+
+	authkey = kmalloc(optlen, GFP_KERNEL);
+	if (!authkey)
+		return -ENOMEM;
+
+	if (copy_from_user(authkey, optval, optlen)) {
+		ret = -EFAULT;
+		goto out;
+	}
+
+	asoc = sctp_id2assoc(sk, authkey->sca_assoc_id);
+	if (!asoc && authkey->sca_assoc_id && sctp_style(sk, UDP)) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	ret = sctp_auth_set_key(sctp_sk(sk)->ep, asoc, authkey);
+out:
+	kfree(authkey);
+	return ret;
+}
+
+/*
+ * 7.1.21.  Get or set the active shared key (SCTP_AUTH_ACTIVE_KEY)
+ *
+ * This option will get or set the active shared key to be used to build
+ * the association shared key.
+ */
+static int sctp_setsockopt_active_key(struct sock *sk,
+					char __user *optval,
+					int optlen)
+{
+	struct sctp_authkeyid val;
+	struct sctp_association *asoc;
+
+	if (optlen != sizeof(struct sctp_authkeyid))
+		return -EINVAL;
+	if (copy_from_user(&val, optval, optlen))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, val.scact_assoc_id);
+	if (!asoc && val.scact_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	return sctp_auth_set_active_key(sctp_sk(sk)->ep, asoc,
+					val.scact_keynumber);
+}
+
+/*
+ * 7.1.22.  Delete a shared key (SCTP_AUTH_DELETE_KEY)
+ *
+ * This set option will delete a shared secret key from use.
+ */
+static int sctp_setsockopt_del_key(struct sock *sk,
+					char __user *optval,
+					int optlen)
+{
+	struct sctp_authkeyid val;
+	struct sctp_association *asoc;
+
+	if (optlen != sizeof(struct sctp_authkeyid))
+		return -EINVAL;
+	if (copy_from_user(&val, optval, optlen))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, val.scact_assoc_id);
+	if (!asoc && val.scact_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	return sctp_auth_del_key_id(sctp_sk(sk)->ep, asoc,
+				    val.scact_keynumber);
+
+}
+
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3091,6 +3249,21 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_MAX_BURST:
 		retval = sctp_setsockopt_maxburst(sk, optval, optlen);
 		break;
+	case SCTP_AUTH_CHUNK:
+		retval = sctp_setsockopt_auth_chunk(sk, optval, optlen);
+		break;
+	case SCTP_HMAC_IDENT:
+		retval = sctp_setsockopt_hmac_ident(sk, optval, optlen);
+		break;
+	case SCTP_AUTH_KEY:
+		retval = sctp_setsockopt_auth_key(sk, optval, optlen);
+		break;
+	case SCTP_AUTH_ACTIVE_KEY:
+		retval = sctp_setsockopt_active_key(sk, optval, optlen);
+		break;
+	case SCTP_AUTH_DELETE_KEY:
+		retval = sctp_setsockopt_del_key(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -4870,6 +5043,118 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 	return -ENOTSUPP;
 }
 
+static int sctp_getsockopt_hmac_ident(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_hmac_algo_param *hmacs;
+	__u16 param_len;
+
+	hmacs = sctp_sk(sk)->ep->auth_hmacs_list;
+	param_len = ntohs(hmacs->param_hdr.length);
+
+	if (len < param_len)
+		return -EINVAL;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, hmacs->hmac_ids, len))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int sctp_getsockopt_active_key(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_authkeyid val;
+	struct sctp_association *asoc;
+
+	if (len < sizeof(struct sctp_authkeyid))
+		return -EINVAL;
+	if (copy_from_user(&val, optval, sizeof(struct sctp_authkeyid)))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, val.scact_assoc_id);
+	if (!asoc && val.scact_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	if (asoc)
+		val.scact_keynumber = asoc->active_key_id;
+	else
+		val.scact_keynumber = sctp_sk(sk)->ep->active_key_id;
+
+	return 0;
+}
+
+static int sctp_getsockopt_peer_auth_chunks(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_authchunks val;
+	struct sctp_association *asoc;
+	struct sctp_chunks_param *ch;
+	char __user *to;
+
+	if (len <= sizeof(struct sctp_authchunks))
+		return -EINVAL;
+
+	if (copy_from_user(&val, optval, sizeof(struct sctp_authchunks)))
+		return -EFAULT;
+
+	to = val.gauth_chunks;
+	asoc = sctp_id2assoc(sk, val.gauth_assoc_id);
+	if (!asoc)
+		return -EINVAL;
+
+	ch = asoc->peer.peer_chunks;
+
+	/* See if the user provided enough room for all the data */
+	if (len < ntohs(ch->param_hdr.length))
+		return -EINVAL;
+
+	len = ntohs(ch->param_hdr.length);
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(to, ch->chunks, len))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int sctp_getsockopt_local_auth_chunks(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_authchunks val;
+	struct sctp_association *asoc;
+	struct sctp_chunks_param *ch;
+	char __user *to;
+
+	if (len <= sizeof(struct sctp_authchunks))
+		return -EINVAL;
+
+	if (copy_from_user(&val, optval, sizeof(struct sctp_authchunks)))
+		return -EFAULT;
+
+	to = val.gauth_chunks;
+	asoc = sctp_id2assoc(sk, val.gauth_assoc_id);
+	if (!asoc && val.gauth_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	if (asoc)
+		ch = (struct sctp_chunks_param*)asoc->c.auth_chunks;
+	else
+		ch = sctp_sk(sk)->ep->auth_chunk_list;
+
+	if (len < ntohs(ch->param_hdr.length))
+		return -EINVAL;
+
+	len = ntohs(ch->param_hdr.length);
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(to, ch->chunks, len))
+		return -EFAULT;
+
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -4993,6 +5278,25 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_MAX_BURST:
 		retval = sctp_getsockopt_maxburst(sk, len, optval, optlen);
 		break;
+	case SCTP_AUTH_KEY:
+	case SCTP_AUTH_CHUNK:
+	case SCTP_AUTH_DELETE_KEY:
+		retval = -EOPNOTSUPP;
+		break;
+	case SCTP_HMAC_IDENT:
+		retval = sctp_getsockopt_hmac_ident(sk, len, optval, optlen);
+		break;
+	case SCTP_AUTH_ACTIVE_KEY:
+		retval = sctp_getsockopt_active_key(sk, len, optval, optlen);
+		break;
+	case SCTP_PEER_AUTH_CHUNKS:
+		retval = sctp_getsockopt_peer_auth_chunks(sk, len, optval,
+							optlen);
+		break;
+	case SCTP_LOCAL_AUTH_CHUNKS:
+		retval = sctp_getsockopt_local_auth_chunks(sk, len, optval,
+							optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index 5dc094b..2c17c7e 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -813,6 +813,43 @@ fail:
 	return NULL;
 }
 
+struct sctp_ulpevent *sctp_ulpevent_make_authkey(
+	const struct sctp_association *asoc, __u16 key_id,
+	__u32 indication, gfp_t gfp)
+{
+	struct sctp_ulpevent *event;
+	struct sctp_authkey_event *ak;
+	struct sk_buff *skb;
+
+	event = sctp_ulpevent_new(sizeof(struct sctp_authkey_event),
+				  MSG_NOTIFICATION, gfp);
+	if (!event)
+		goto fail;
+
+	skb = sctp_event2skb(event);
+	ak = (struct sctp_authkey_event *)
+		skb_put(skb, sizeof(struct sctp_authkey_event));
+
+	ak->auth_type = SCTP_AUTHENTICATION_EVENT;
+	ak->auth_flags = 0;
+	ak->auth_length = sizeof(struct sctp_authkey_event);
+
+	ak->auth_keynumber = key_id;
+	ak->auth_altkeynumber = 0;
+	ak->auth_indication = indication;
+
+	/*
+	 * The association id field, holds the identifier for the association.
+	 */
+	sctp_ulpevent_set_owner(event, asoc);
+	ak->auth_assoc_id = sctp_assoc2id(asoc);
+
+	return event;
+fail:
+	return NULL;
+}
+
+
 /* Return the notification type, assuming this is a notification
  * event.
  */
-- 
1.5.2.4

