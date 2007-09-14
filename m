From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/8] SCTP: Implement SCTP-AUTH internals
Date: Fri, 14 Sep 2007 14:44:53 -0400
Message-ID: <11897954993782-git-send-email-vladislav.yasevich@hp.com>
References: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:33814 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752545AbXINSpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:02 -0400
In-Reply-To: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the internals operations of the AUTH, such as
key computation and storage.  It also adds necessary variables to
the SCTP data structures.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/auth.h      |  112 +++++++
 include/net/sctp/constants.h |   49 +++-
 include/net/sctp/sctp.h      |    1 +
 include/net/sctp/structs.h   |   71 ++++-
 net/sctp/Makefile            |    3 +-
 net/sctp/auth.c              |  744 ++++++++++++++++++++++++++++++++++++++++++
 net/sctp/objcnt.c            |    2 +
 7 files changed, 975 insertions(+), 7 deletions(-)
 create mode 100644 include/net/sctp/auth.h
 create mode 100644 net/sctp/auth.c

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
new file mode 100644
index 0000000..10c8010
--- /dev/null
+++ b/include/net/sctp/auth.h
@@ -0,0 +1,112 @@
+/* SCTP kernel reference Implementation
+ * (C) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *
+ * This file is part of the SCTP kernel reference Implementation
+ *
+ * The SCTP reference implementation is free software;
+ * you can redistribute it and/or modify it under the terms of
+ * the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * The SCTP reference implementation is distributed in the hope that it
+ * will be useful, but WITHOUT ANY WARRANTY; without even the implied
+ *                 ************************
+ * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with GNU CC; see the file COPYING.  If not, write to
+ * the Free Software Foundation, 59 Temple Place - Suite 330,
+ * Boston, MA 02111-1307, USA.
+ *
+ * Please send any bug reports or fixes you make to the
+ * email address(es):
+ *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *
+ * Or submit a bug report through the following website:
+ *    http://www.sf.net/projects/lksctp
+ *
+ * Written or modified by:
+ *   Vlad Yasevich     <vladislav.yasevich@hp.com>
+ *
+ * Any bugs reported given to us we will try to fix... any fixes shared will
+ * be incorporated into the next SCTP release.
+ */
+
+#ifndef __sctp_auth_h__
+#define __sctp_auth_h__
+
+#include <linux/list.h>
+#include <linux/crypto.h>
+
+struct sctp_endpoint;
+struct sctp_association;
+struct sctp_authkey;
+
+/*
+ * Define a generic struct that will hold all the info
+ * necessary for an HMAC transform
+ */
+struct sctp_hmac {
+	__u16 hmac_id;		/* one of the above ids */
+	char *hmac_name;	/* name for loading */
+	__u16 hmac_len;		/* length of the signature */
+};
+
+/* This is generic structure that containst authentication bytes used
+ * as keying material.  It's a what is referred to as byte-vector all
+ * over SCTP-AUTH
+ */
+struct sctp_auth_bytes {
+	atomic_t refcnt;
+	__u32 len;
+	__u8  data[];
+};
+
+/* Definition for a shared key, weather endpoint or association */
+struct sctp_shared_key {
+	struct list_head key_list;
+	__u16 key_id;
+	struct sctp_auth_bytes *key;
+};
+
+#define key_for_each(__key, __list_head) \
+	list_for_each_entry(__key, __list_head, key_list)
+
+#define key_for_each_safe(__key, __tmp, __list_head) \
+	list_for_each_entry_safe(__key, __tmp, __list_head, key_list)
+
+static inline void sctp_auth_key_hold(struct sctp_auth_bytes *key)
+{
+	if (!key)
+		return;
+
+	atomic_inc(&key->refcnt);
+}
+
+void sctp_auth_key_put(struct sctp_auth_bytes *key);
+struct sctp_shared_key *sctp_auth_shkey_create(__u16 key_id, gfp_t gfp);
+void sctp_auth_shkey_free(struct sctp_shared_key *sh_key);
+void sctp_auth_destroy_keys(struct list_head *keys);
+int sctp_auth_asoc_init_active_key(struct sctp_association *asoc, gfp_t gfp);
+struct sctp_shared_key *sctp_auth_get_shkey(
+				const struct sctp_association *asoc,
+				__u16 key_id);
+int sctp_auth_asoc_copy_shkeys(const struct sctp_endpoint *ep,
+				struct sctp_association *asoc,
+				gfp_t gfp);
+int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp);
+void sctp_auth_destroy_hmacs(struct crypto_hash *auth_hmacs[]);
+struct sctp_hmac *sctp_auth_get_hmac(__u16 hmac_id);
+struct sctp_hmac *sctp_auth_asoc_get_hmac(const struct sctp_association *asoc);
+void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
+				     struct sctp_hmac_algo_param *hmacs);
+int sctp_auth_asoc_verify_hmac_id(const struct sctp_association *asoc,
+				    __u16 hmac_id);
+int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc);
+int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc);
+void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
+			    struct sk_buff *skb,
+			    struct sctp_auth_chunk *auth, gfp_t gfp);
+#endif
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index bb37724..777118f 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -64,12 +64,18 @@ enum { SCTP_DEFAULT_INSTREAMS = SCTP_MAX_STREAM };
 #define SCTP_CID_MAX			SCTP_CID_ASCONF_ACK
 
 #define SCTP_NUM_BASE_CHUNK_TYPES	(SCTP_CID_BASE_MAX + 1)
-#define SCTP_NUM_CHUNK_TYPES		(SCTP_NUM_BASE_CHUNKTYPES + 2)
 
 #define SCTP_NUM_ADDIP_CHUNK_TYPES	2
 
 #define SCTP_NUM_PRSCTP_CHUNK_TYPES	1
 
+#define SCTP_NUM_AUTH_CHUNK_TYPES	1
+
+#define SCTP_NUM_CHUNK_TYPES		(SCTP_NUM_BASE_CHUNK_TYPES + \
+					 SCTP_NUM_ADDIP_CHUNK_TYPES +\
+					 SCTP_NUM_PRSCTP_CHUNK_TYPES +\
+					 SCTP_NUM_AUTH_CHUNK_TYPES)
+
 /* These are the different flavours of event.  */
 typedef enum {
 
@@ -409,4 +415,45 @@ typedef enum {
 	SCTP_LOWER_CWND_INACTIVE,
 } sctp_lower_cwnd_t;
 
+
+/* SCTP-AUTH Necessary constants */
+
+/* SCTP-AUTH, Section 3.3
+ *
+ *  The following Table 2 shows the currently defined values for HMAC
+ *  identifiers.
+ *
+ *  +-----------------+--------------------------+
+ *  | HMAC Identifier | Message Digest Algorithm |
+ *  +-----------------+--------------------------+
+ *  | 0               | Reserved                 |
+ *  | 1               | SHA-1 defined in [8]     |
+ *  | 2               | Reserved                 |
+ *  | 3               | SHA-256 defined in [8]   |
+ *  +-----------------+--------------------------+
+ */
+enum {
+	SCTP_AUTH_HMAC_ID_RESERVED_0,
+	SCTP_AUTH_HMAC_ID_SHA1,
+	SCTP_AUTH_HMAC_ID_RESERVED_2,
+	SCTP_AUTH_HMAC_ID_SHA256
+};
+
+#define SCTP_AUTH_HMAC_ID_MAX	SCTP_AUTH_HMAC_ID_SHA256
+#define SCTP_AUTH_NUM_HMACS (SCTP_AUTH_HMAC_ID_SHA256 + 1)
+#define SCTP_SHA1_SIG_SIZE 20
+#define SCTP_SHA256_SIG_SIZE 32
+
+/*  SCTP-AUTH, Section 3.2
+ *     The chunk types for INIT, INIT-ACK, SHUTDOWN-COMPLETE and AUTH chunks
+ *     MUST NOT be listed in the CHUNKS parameter
+ */
+#define SCTP_NUM_NOAUTH_CHUNKS	4
+#define SCTP_AUTH_MAX_CHUNKS	(SCTP_NUM_CHUNK_TYPES - SCTP_NUM_NOAUTH_CHUNKS)
+
+/* SCTP-AUTH Section 6.1
+ * The RANDOM parameter MUST contain a 32 byte random number.
+ */
+#define SCTP_AUTH_RANDOM_LENGTH 32
+
 #endif /* __sctp_constants_h__ */
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 46d7d09..b542e96 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -340,6 +340,7 @@ extern atomic_t sctp_dbg_objcnt_bind_bucket;
 extern atomic_t sctp_dbg_objcnt_addr;
 extern atomic_t sctp_dbg_objcnt_ssnmap;
 extern atomic_t sctp_dbg_objcnt_datamsg;
+extern atomic_t sctp_dbg_objcnt_keys;
 
 /* Macros to atomically increment/decrement objcnt counters.  */
 #define SCTP_DBG_OBJCNT_INC(name) \
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 8505ecc..a668825 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -64,6 +64,7 @@
 #include <linux/skbuff.h>	/* We need sk_buff_head. */
 #include <linux/workqueue.h>	/* We need tq_struct.	 */
 #include <linux/sctp.h>		/* We need sctp* header structs.  */
+#include <net/sctp/auth.h>	/* We need auth specific structs */
 
 /* A convenience structure for handling sockaddr structures.
  * We should wean ourselves off this.
@@ -213,6 +214,9 @@ extern struct sctp_globals {
 
 	/* Flag to indicate if PR-SCTP is enabled. */
 	int prsctp_enable;
+
+	/* Flag to idicate if SCTP-AUTH is enabled */
+	int auth_enable;
 } sctp_globals;
 
 #define sctp_rto_initial		(sctp_globals.rto_initial)
@@ -244,6 +248,7 @@ extern struct sctp_globals {
 #define sctp_local_addr_list		(sctp_globals.local_addr_list)
 #define sctp_addip_enable		(sctp_globals.addip_enable)
 #define sctp_prsctp_enable		(sctp_globals.prsctp_enable)
+#define sctp_auth_enable		(sctp_globals.auth_enable)
 
 /* SCTP Socket type: UDP or TCP style. */
 typedef enum {
@@ -393,6 +398,9 @@ struct sctp_cookie {
 
 	__u32 adaptation_ind;
 
+	__u8 auth_random[sizeof(sctp_paramhdr_t) + SCTP_AUTH_RANDOM_LENGTH];
+	__u8 auth_hmacs[SCTP_AUTH_NUM_HMACS + 2];
+	__u8 auth_chunks[sizeof(sctp_paramhdr_t) + SCTP_AUTH_MAX_CHUNKS];
 
 	/* This is a shim for my peer's INIT packet, followed by
 	 * a copy of the raw address list of the association.
@@ -436,6 +444,9 @@ union sctp_params {
 	union sctp_addr_param *addr;
 	struct sctp_adaptation_ind_param *aind;
 	struct sctp_supported_ext_param *ext;
+	struct sctp_random_param *random;
+	struct sctp_chunks_param *chunks;
+	struct sctp_hmac_algo_param *hmac_algo;
 };
 
 /* RFC 2960.  Section 3.3.5 Heartbeat.
@@ -674,6 +685,7 @@ struct sctp_chunk {
 		struct sctp_errhdr *err_hdr;
 		struct sctp_addiphdr *addip_hdr;
 		struct sctp_fwdtsn_hdr *fwdtsn_hdr;
+		struct sctp_authhdr *auth_hdr;
 	} subh;
 
 	__u8 *chunk_end;
@@ -719,6 +731,7 @@ struct sctp_chunk {
 	__s8 fast_retransmit;	 /* Is this chunk fast retransmitted? */
 	__u8 tsn_missing_report; /* Data chunk missing counter. */
 	__u8 data_accepted; 	/* At least 1 chunk in this packet accepted */
+	__u8 auth;		/* IN: was auth'ed | OUT: needs auth */
 };
 
 void sctp_chunk_hold(struct sctp_chunk *);
@@ -766,16 +779,22 @@ struct sctp_packet {
 	 */
 	struct sctp_transport *transport;
 
+	/* pointer to the auth chunk for this packet */
+	struct sctp_chunk *auth;
+
 	/* This packet contains a COOKIE-ECHO chunk. */
-	char has_cookie_echo;
+	__u8 has_cookie_echo;
+
+	/* This packet contains a SACK chunk. */
+	__u8 has_sack;
 
-	/* This packet containsa SACK chunk. */
-	char has_sack;
+	/* This packet contains an AUTH chunk */
+	__u8 has_auth;
 
 	/* SCTP cannot fragment this packet. So let ip fragment it. */
-	char ipfragok;
+	__u8 ipfragok;
 
-	int malloced;
+	__u8 malloced;
 };
 
 struct sctp_packet *sctp_packet_init(struct sctp_packet *,
@@ -1285,6 +1304,21 @@ struct sctp_endpoint {
 
 	/* rcvbuf acct. policy.	*/
 	__u32 rcvbuf_policy;
+
+	/* SCTP AUTH: array of the HMACs that will be allocated
+	 * we need this per association so that we don't serialize
+	 */
+	struct crypto_hash **auth_hmacs;
+
+	/* SCTP-AUTH: hmacs for the endpoint encoded into parameter */
+	 struct sctp_hmac_algo_param *auth_hmacs_list;
+
+	/* SCTP-AUTH: chunks to authenticate encoded into parameter */
+	struct sctp_chunks_param *auth_chunk_list;
+
+	/* SCTP-AUTH: endpoint shared keys */
+	struct list_head endpoint_shared_keys;
+	__u16 active_key_id;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1491,6 +1525,7 @@ struct sctp_association {
 		__u8	hostname_address;/* Peer understands DNS addresses? */
 		__u8    asconf_capable;  /* Does peer support ADDIP? */
 		__u8    prsctp_capable;  /* Can peer do PR-SCTP? */
+		__u8	auth_capable;	 /* Is peer doing SCTP-AUTH? */
 
 		__u32   adaptation_ind;	 /* Adaptation Code point. */
 
@@ -1508,6 +1543,14 @@ struct sctp_association {
 		 * Initial TSN Value minus 1
 		 */
 		__u32 addip_serial;
+
+		/* SCTP-AUTH: We need to know pears random number, hmac list
+		 * and authenticated chunk list.  All that is part of the
+		 * cookie and these are just pointers to those locations
+		 */
+		sctp_random_param_t *peer_random;
+		sctp_chunks_param_t *peer_chunks;
+		sctp_hmac_algo_param_t *peer_hmacs;
 	} peer;
 
 	/* State       : A state variable indicating what state the
@@ -1791,6 +1834,24 @@ struct sctp_association {
 	 */
 	__u32 addip_serial;
 
+	/* SCTP AUTH: list of the endpoint shared keys.  These
+	 * keys are provided out of band by the user applicaton
+	 * and can't change during the lifetime of the association
+	 */
+	struct list_head endpoint_shared_keys;
+
+	/* SCTP AUTH:
+	 * The current generated assocaition shared key (secret)
+	 */
+	struct sctp_auth_bytes *asoc_shared_key;
+
+	/* SCTP AUTH: hmac id of the first peer requested algorithm
+	 * that we support.
+	 */
+	__u16 default_hmac_id;
+
+	__u16 active_key_id;
+
 	/* Need to send an ECNE Chunk? */
 	char need_ecne;
 
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 70c828b..1da7204 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -9,7 +9,8 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o command.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o proc.o crc32c.o
+	  output.o input.o debug.o ssnmap.o proc.o crc32c.o \
+	  auth.o
 
 sctp-$(CONFIG_SCTP_DBG_OBJCNT) += objcnt.o
 sctp-$(CONFIG_SYSCTL) += sysctl.o
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
new file mode 100644
index 0000000..1fee43e
--- /dev/null
+++ b/net/sctp/auth.c
@@ -0,0 +1,744 @@
+/* SCTP kernel reference Implementation
+ * (C) Copyright 2007 Hewlett-Packard Development Company, L.P.
+ *
+ * This file is part of the SCTP kernel reference Implementation
+ *
+ * The SCTP reference implementation is free software;
+ * you can redistribute it and/or modify it under the terms of
+ * the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * The SCTP reference implementation is distributed in the hope that it
+ * will be useful, but WITHOUT ANY WARRANTY; without even the implied
+ *                 ************************
+ * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with GNU CC; see the file COPYING.  If not, write to
+ * the Free Software Foundation, 59 Temple Place - Suite 330,
+ * Boston, MA 02111-1307, USA.
+ *
+ * Please send any bug reports or fixes you make to the
+ * email address(es):
+ *    lksctp developers <lksctp-developers@lists.sourceforge.net>
+ *
+ * Or submit a bug report through the following website:
+ *    http://www.sf.net/projects/lksctp
+ *
+ * Written or modified by:
+ *   Vlad Yasevich     <vladislav.yasevich@hp.com>
+ *
+ * Any bugs reported given to us we will try to fix... any fixes shared will
+ * be incorporated into the next SCTP release.
+ */
+
+#include <linux/types.h>
+#include <linux/crypto.h>
+#include <net/sctp/sctp.h>
+#include <net/sctp/auth.h>
+
+static struct sctp_hmac sctp_hmac_list[SCTP_AUTH_NUM_HMACS] = {
+	{
+		/* id 0 is reserved.  as all 0 */
+		.hmac_id = SCTP_AUTH_HMAC_ID_RESERVED_0,
+	},
+	{
+		.hmac_id = SCTP_AUTH_HMAC_ID_SHA1,
+		.hmac_name="hmac(sha1)",
+		.hmac_len = SCTP_SHA1_SIG_SIZE,
+	},
+	{
+		/* id 2 is reserved as well */
+		.hmac_id = SCTP_AUTH_HMAC_ID_RESERVED_2,
+	},
+	{
+		.hmac_id = SCTP_AUTH_HMAC_ID_SHA256,
+		.hmac_name="hmac(sha256)",
+		.hmac_len = SCTP_SHA256_SIG_SIZE,
+	}
+};
+
+
+void sctp_auth_key_put(struct sctp_auth_bytes *key)
+{
+	if (!key)
+		return;
+
+	if (atomic_dec_and_test(&key->refcnt)) {
+		kfree(key);
+		SCTP_DBG_OBJCNT_DEC(keys);
+	}
+}
+
+/* Create a new key structure of a given length */
+static struct sctp_auth_bytes *sctp_auth_create_key(__u32 key_len, gfp_t gfp)
+{
+	struct sctp_auth_bytes *key;
+
+	/* Allocate the shared key */
+	key = kmalloc(sizeof(struct sctp_auth_bytes) + key_len, gfp);
+	if (!key)
+		return NULL;
+
+	key->len = key_len;
+	atomic_set(&key->refcnt, 1);
+	SCTP_DBG_OBJCNT_INC(keys);
+
+	return key;
+}
+
+/* Create a new shared key container with a give key id */
+struct sctp_shared_key *sctp_auth_shkey_create(__u16 key_id, gfp_t gfp)
+{
+	struct sctp_shared_key *new;
+
+	/* Allocate the shared key container */
+	new = kzalloc(sizeof(struct sctp_shared_key), gfp);
+	if (!new)
+		return NULL;
+
+	INIT_LIST_HEAD(&new->key_list);
+	new->key_id = key_id;
+
+	return new;
+}
+
+/* Free the shared key stucture */
+void sctp_auth_shkey_free(struct sctp_shared_key *sh_key)
+{
+	BUG_ON(!list_empty(&sh_key->key_list));
+	sctp_auth_key_put(sh_key->key);
+	sh_key->key = NULL;
+	kfree(sh_key);
+}
+
+/* Destory the entire key list.  This is done during the
+ * associon and endpoint free process.
+ */
+void sctp_auth_destroy_keys(struct list_head *keys)
+{
+	struct sctp_shared_key *ep_key;
+	struct sctp_shared_key *tmp;
+
+	if (list_empty(keys))
+		return;
+
+	key_for_each_safe(ep_key, tmp, keys) {
+		list_del_init(&ep_key->key_list);
+		sctp_auth_shkey_free(ep_key);
+	}
+}
+
+/* Compare two byte vectors as numbers.  Return values
+ * are:
+ * 	  0 - vectors are equal
+ * 	< 0 - vector 1 is smaller then vector2
+ * 	> 0 - vector 1 is greater then vector2
+ *
+ * Algorithm is:
+ * 	This is performed by selecting the numerically smaller key vector...
+ *	If the key vectors are equal as numbers but differ in length ...
+ *	the shorter vector is considered smaller
+ *
+ * Examples (with small values):
+ * 	000123456789 > 123456789 (first number is longer)
+ * 	000123456789 < 234567891 (second number is larger numerically)
+ * 	123456789 > 2345678 	 (first number is both larger & longer)
+ */
+static int sctp_auth_compare_vectors(struct sctp_auth_bytes *vector1,
+			      struct sctp_auth_bytes *vector2)
+{
+	int diff;
+	int i;
+	const __u8 *longer;
+
+	diff = vector1->len - vector2->len;
+	if (diff) {
+		longer = (diff > 0) ? vector1->data : vector2->data;
+
+		/* Check to see if the longer number is
+		 * lead-zero padded.  If it is not, it
+		 * is automatically larger numerically.
+		 */
+		for (i = 0; i < abs(diff); i++ ) {
+			if (longer[i] != 0)
+				return diff;
+		}
+	}
+
+	/* lengths are the same, compare numbers */
+	return memcmp(vector1->data, vector2->data, vector1->len);
+}
+
+/*
+ * Create a key vector as described in SCTP-AUTH, Section 6.1
+ *    The RANDOM parameter, the CHUNKS parameter and the HMAC-ALGO
+ *    parameter sent by each endpoint are concatenated as byte vectors.
+ *    These parameters include the parameter type, parameter length, and
+ *    the parameter value, but padding is omitted; all padding MUST be
+ *    removed from this concatenation before proceeding with further
+ *    computation of keys.  Parameters which were not sent are simply
+ *    omitted from the concatenation process.  The resulting two vectors
+ *    are called the two key vectors.
+ */
+static struct sctp_auth_bytes *sctp_auth_make_key_vector(
+			sctp_random_param_t *random,
+			sctp_chunks_param_t *chunks,
+			sctp_hmac_algo_param_t *hmacs,
+			gfp_t gfp)
+{
+	struct sctp_auth_bytes *new;
+	__u32	len;
+	__u32	offset = 0;
+
+	len = ntohs(random->param_hdr.length) + ntohs(hmacs->param_hdr.length);
+        if (chunks)
+		len += ntohs(chunks->param_hdr.length);
+
+	new = kmalloc(sizeof(struct sctp_auth_bytes) + len, gfp);
+	if (!new)
+		return NULL;
+
+	new->len = len;
+
+	memcpy(new->data, random, ntohs(random->param_hdr.length));
+	offset += ntohs(random->param_hdr.length);
+
+	if (chunks) {
+		memcpy(new->data + offset, chunks,
+			ntohs(chunks->param_hdr.length));
+		offset += ntohs(chunks->param_hdr.length);
+	}
+
+	memcpy(new->data + offset, hmacs, ntohs(hmacs->param_hdr.length));
+
+	return new;
+}
+
+
+/* Make a key vector based on our local parameters */
+struct sctp_auth_bytes *sctp_auth_make_local_vector(
+				    const struct sctp_association *asoc,
+				    gfp_t gfp)
+{
+	return sctp_auth_make_key_vector(
+				    (sctp_random_param_t*)asoc->c.auth_random,
+				    (sctp_chunks_param_t*)asoc->c.auth_chunks,
+				    (sctp_hmac_algo_param_t*)asoc->c.auth_hmacs,
+				    gfp);
+}
+
+/* Make a key vector based on peer's parameters */
+struct sctp_auth_bytes *sctp_auth_make_peer_vector(
+				    const struct sctp_association *asoc,
+				    gfp_t gfp)
+{
+	return sctp_auth_make_key_vector(asoc->peer.peer_random,
+					 asoc->peer.peer_chunks,
+					 asoc->peer.peer_hmacs,
+					 gfp);
+}
+
+
+/* Set the value of the association shared key base on the parameters
+ * given.  The algorithm is:
+ *    From the endpoint pair shared keys and the key vectors the
+ *    association shared keys are computed.  This is performed by selecting
+ *    the numerically smaller key vector and concatenating it to the
+ *    endpoint pair shared key, and then concatenating the numerically
+ *    larger key vector to that.  The result of the concatenation is the
+ *    association shared key.
+ */
+static struct sctp_auth_bytes *sctp_auth_asoc_set_secret(
+			struct sctp_shared_key *ep_key,
+			struct sctp_auth_bytes *first_vector,
+			struct sctp_auth_bytes *last_vector,
+			gfp_t gfp)
+{
+	struct sctp_auth_bytes *secret;
+	__u32 offset = 0;
+	__u32 auth_len;
+
+	auth_len = first_vector->len + last_vector->len;
+	if (ep_key->key)
+		auth_len += ep_key->key->len;
+
+	secret = sctp_auth_create_key(auth_len, gfp);
+	if (!secret)
+		return NULL;
+
+	if (ep_key->key) {
+		memcpy(secret->data, ep_key->key->data, ep_key->key->len);
+		offset += ep_key->key->len;
+	}
+
+	memcpy(secret->data + offset, first_vector->data, first_vector->len);
+	offset += first_vector->len;
+
+	memcpy(secret->data + offset, last_vector->data, last_vector->len);
+
+	return secret;
+}
+
+/* Create an association shared key.  Follow the algorithm
+ * described in SCTP-AUTH, Section 6.1
+ */
+static struct sctp_auth_bytes *sctp_auth_asoc_create_secret(
+				 const struct sctp_association *asoc,
+				 struct sctp_shared_key *ep_key,
+				 gfp_t gfp)
+{
+	struct sctp_auth_bytes *local_key_vector;
+	struct sctp_auth_bytes *peer_key_vector;
+	struct sctp_auth_bytes	*first_vector,
+				*last_vector;
+	struct sctp_auth_bytes	*secret = NULL;
+	int	cmp;
+
+
+	/* Now we need to build the key vectors
+	 * SCTP-AUTH , Section 6.1
+	 *    The RANDOM parameter, the CHUNKS parameter and the HMAC-ALGO
+	 *    parameter sent by each endpoint are concatenated as byte vectors.
+	 *    These parameters include the parameter type, parameter length, and
+	 *    the parameter value, but padding is omitted; all padding MUST be
+	 *    removed from this concatenation before proceeding with further
+	 *    computation of keys.  Parameters which were not sent are simply
+	 *    omitted from the concatenation process.  The resulting two vectors
+	 *    are called the two key vectors.
+	 */
+	
+	local_key_vector = sctp_auth_make_local_vector(asoc, gfp);
+	peer_key_vector = sctp_auth_make_peer_vector(asoc, gfp);
+
+	if (!peer_key_vector || !local_key_vector)
+		goto out;
+
+	/* Figure out the order in wich the key_vectors will be
+	 * added to the endpoint shared key.
+	 * SCTP-AUTH, Section 6.1:
+	 *   This is performed by selecting the numerically smaller key
+	 *   vector and concatenating it to the endpoint pair shared
+	 *   key, and then concatenating the numerically larger key
+	 *   vector to that.  If the key vectors are equal as numbers
+	 *   but differ in length, then the concatenation order is the
+	 *   endpoint shared key, followed by the shorter key vector,
+	 *   followed by the longer key vector.  Otherwise, the key
+	 *   vectors are identical, and may be concatenated to the
+	 *   endpoint pair key in any order.
+	 */
+	cmp = sctp_auth_compare_vectors(local_key_vector,
+					peer_key_vector);
+	if (cmp < 0) {
+		first_vector = local_key_vector;
+		last_vector = peer_key_vector;
+	} else {
+		first_vector = peer_key_vector;
+		last_vector = local_key_vector;
+	}
+
+	secret = sctp_auth_asoc_set_secret(ep_key, first_vector, last_vector,
+					    gfp);
+out:
+	kfree(local_key_vector);
+	kfree(peer_key_vector);
+
+	return secret; 
+}
+
+/*
+ * Populate the association overlay list with the list
+ * from the endpoint.
+ */
+int sctp_auth_asoc_copy_shkeys(const struct sctp_endpoint *ep,
+				struct sctp_association *asoc,
+				gfp_t gfp)
+{
+	struct sctp_shared_key *sh_key;
+	struct sctp_shared_key *new;
+
+	BUG_ON(!list_empty(&asoc->endpoint_shared_keys));
+
+	key_for_each(sh_key, &ep->endpoint_shared_keys) {
+		new = sctp_auth_shkey_create(sh_key->key_id, gfp);
+		if (!new)
+			goto nomem;
+
+		new->key = sh_key->key;
+		sctp_auth_key_hold(new->key);
+		list_add(&new->key_list, &asoc->endpoint_shared_keys);
+	}
+
+	return 0;
+
+nomem:
+	sctp_auth_destroy_keys(&asoc->endpoint_shared_keys);
+	return -ENOMEM;
+}
+
+
+/* Public interface to creat the association shared key.
+ * See code above for the algorithm.
+ */
+int sctp_auth_asoc_init_active_key(struct sctp_association *asoc, gfp_t gfp)
+{
+	struct sctp_auth_bytes	*secret;
+	struct sctp_shared_key *ep_key;
+
+	/* If we don't support AUTH, or peer is not capable
+	 * we don't need to do anything.
+	 */
+	if (!sctp_auth_enable || !asoc->peer.auth_capable)
+		return 0;
+
+	/* If the key_id is non-zero and we couldn't find an
+	 * endpoint pair shared key, we can't compute the
+	 * secret.
+	 * For key_id 0, endpoint pair shared key is a NULL key.
+	 */
+	ep_key = sctp_auth_get_shkey(asoc, asoc->active_key_id);
+	BUG_ON(!ep_key);
+
+	secret = sctp_auth_asoc_create_secret(asoc, ep_key, gfp);
+	if (!secret)
+		return -ENOMEM;
+
+	sctp_auth_key_put(asoc->asoc_shared_key);
+	asoc->asoc_shared_key = secret;
+
+	return 0;
+}
+
+
+/* Find the endpoint pair shared key based on the key_id */
+struct sctp_shared_key *sctp_auth_get_shkey(
+				const struct sctp_association *asoc,
+				__u16 key_id)
+{
+	struct sctp_shared_key *key = NULL;
+	
+	/* First search associations set of endpoint pair shared keys */
+	key_for_each(key, &asoc->endpoint_shared_keys) {
+		if (key->key_id == key_id)
+			break;
+	}
+
+	return key;
+}
+
+/* 
+ * Initialize all the possible digest transforms that we can use.  Right now
+ * now, the supported digests are SHA1 and SHA256.  We do this here once
+ * because of the restrictiong that transforms may only be allocated in
+ * user context.  This forces us to pre-allocated all possible transforms
+ * at the endpoint init time.
+ */
+int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
+{
+	struct crypto_hash *tfm = NULL;
+	__u16   id;
+
+	/* if the transforms are already allocted, we are done */
+	if (!sctp_auth_enable) {
+		ep->auth_hmacs = NULL;
+		return 0;
+	}
+
+	if (ep->auth_hmacs)
+		return 0;
+
+	/* Allocated the array of pointers to transorms */
+	ep->auth_hmacs = kzalloc(
+			    sizeof(struct crypto_hash *) * SCTP_AUTH_NUM_HMACS,
+			    gfp);
+	if (!ep->auth_hmacs)
+		return -ENOMEM;
+
+	for (id = 0; id < SCTP_AUTH_NUM_HMACS; id++) {
+
+		/* See is we support the id.  Supported IDs have name and
+		 * length fields set, so that we can allocated and use
+		 * them.  We can safely just check for name, for without the
+		 * name, we can't allocate the TFM.
+		 */
+		if (!sctp_hmac_list[id].hmac_name)
+			continue;
+
+		/* If this TFM has been allocated, we are all set */
+		if (ep->auth_hmacs[id])
+			continue;
+
+		/* Allocate the ID */
+		tfm = crypto_alloc_hash(sctp_hmac_list[id].hmac_name, 0,
+					CRYPTO_ALG_ASYNC);
+		if (IS_ERR(tfm))
+			goto out_err;
+
+		ep->auth_hmacs[id] = tfm;
+	}
+
+	return 0;
+
+out_err:
+	/* Clean up any successfull allocations */
+	sctp_auth_destroy_hmacs(ep->auth_hmacs);
+	return -ENOMEM;
+}
+
+/* Destroy the hmac tfm array */
+void sctp_auth_destroy_hmacs(struct crypto_hash *auth_hmacs[])
+{
+	int i;
+
+	if (!auth_hmacs)
+		return;
+
+	for (i = 0; i < SCTP_AUTH_NUM_HMACS; i++)
+	{
+		if (auth_hmacs[i])
+			crypto_free_hash(auth_hmacs[i]);
+	}
+	kfree(auth_hmacs);
+}
+
+
+struct sctp_hmac *sctp_auth_get_hmac(__u16 hmac_id)
+{
+	return &sctp_hmac_list[hmac_id];
+}
+
+/* Get an hmac description information that we can use to build
+ * the AUTH chunk
+ */
+struct sctp_hmac *sctp_auth_asoc_get_hmac(const struct sctp_association *asoc)
+{
+	struct sctp_hmac_algo_param *hmacs;
+	__u16 n_elt;
+	__u16 id = 0;
+	int i;
+
+	/* If we have a default entry, use it */
+	if (asoc->default_hmac_id)
+		return &sctp_hmac_list[asoc->default_hmac_id];
+
+	/* Since we do not have a default entry, find the first entry
+	 * we support and return that.  Do not cache that id.
+	 */
+	hmacs = asoc->peer.peer_hmacs;
+	if (!hmacs)
+		return NULL;
+
+	n_elt = (ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t)) >> 1;
+	for (i = 0; i < n_elt; i++) {
+		id = ntohs(hmacs->hmac_ids[i]);
+
+		/* Check the id is in the supported range */
+		if (id > SCTP_AUTH_HMAC_ID_MAX)
+			continue;
+
+		/* See is we support the id.  Supported IDs have name and
+		 * length fields set, so that we can allocated and use
+		 * them.  We can safely just check for name, for without the
+		 * name, we can't allocate the TFM.
+		 */
+		if (!sctp_hmac_list[id].hmac_name)
+			continue;
+
+		break;
+	}
+
+	if (id == 0)
+		return NULL;
+
+	return &sctp_hmac_list[id];
+}
+
+static int __sctp_auth_find_hmacid(__u16 *hmacs, int n_elts, __u16 hmac_id)
+{
+	int  found = 0;
+	int  i;
+
+	for (i = 0; i < n_elts; i++) {
+		if (hmac_id == hmacs[i]) {
+			found = 1;
+			break;
+		}
+	}
+
+	return found;
+}
+
+/* See if the HMAC_ID is one that we claim as supported */
+int sctp_auth_asoc_verify_hmac_id(const struct sctp_association *asoc,
+				    __u16 hmac_id)
+{
+	struct sctp_hmac_algo_param *hmacs;
+	__u16 n_elt;
+
+	if (!asoc)
+		return 0;
+
+	hmacs = (struct sctp_hmac_algo_param *)asoc->c.auth_hmacs;
+	n_elt = (ntohs(hmacs->param_hdr.length) - sizeof(sctp_paramhdr_t)) >> 1;
+
+	return __sctp_auth_find_hmacid(hmacs->hmac_ids, n_elt, hmac_id);
+}
+
+
+/* Cache the default HMAC id.  This to follow this text from SCTP-AUTH:
+ * Section 6.1:
+ *   The receiver of a HMAC-ALGO parameter SHOULD use the first listed
+ *   algorithm it supports.
+ */
+void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
+				     struct sctp_hmac_algo_param *hmacs)
+{
+	struct sctp_endpoint *ep;
+	__u16   id;
+	int	i;
+	int	n_params;
+
+	/* if the default id is already set, use it */
+	if (asoc->default_hmac_id)
+		return;
+
+	n_params = (ntohs(hmacs->param_hdr.length)
+				- sizeof(sctp_paramhdr_t)) >> 1;
+	ep = asoc->ep;
+	for (i = 0; i < n_params; i++) {
+		id = ntohs(hmacs->hmac_ids[i]);
+
+		/* Check the id is in the supported range */
+		if (id > SCTP_AUTH_HMAC_ID_MAX)
+			continue;
+
+		/* If this TFM has been allocated, use this id */
+		if (ep->auth_hmacs[id]) {
+			asoc->default_hmac_id = id;
+			break;
+		}
+	}
+}
+
+
+/* Check to see if the given chunk is supposed to be authenticated */
+static int __sctp_auth_cid(sctp_cid_t chunk, struct sctp_chunks_param *param)
+{
+	unsigned short len;
+	int found = 0;
+	int i;
+
+	if (!param)
+		return 0;
+
+	len = ntohs(param->param_hdr.length) - sizeof(sctp_paramhdr_t);
+
+	/* SCTP-AUTH, Section 3.2
+	 *    The chunk types for INIT, INIT-ACK, SHUTDOWN-COMPLETE and AUTH
+	 *    chunks MUST NOT be listed in the CHUNKS parameter.  However, if
+	 *    a CHUNKS parameter is received then the types for INIT, INIT-ACK,
+	 *    SHUTDOWN-COMPLETE and AUTH chunks MUST be ignored.
+	 */
+	for (i = 0; !found && i < len; i++) {
+		switch (param->chunks[i]) {
+		    case SCTP_CID_INIT:
+		    case SCTP_CID_INIT_ACK:
+		    case SCTP_CID_SHUTDOWN_COMPLETE:
+		    case SCTP_CID_AUTH:
+			break; 
+
+		    default:
+			if (param->chunks[i] == chunk)
+			    found = 1;
+			break;
+		}
+	}
+
+	return found;
+}
+
+/* Check if peer requested that this chunk is authenticated */
+int sctp_auth_send_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
+{
+	if (!sctp_auth_enable || !asoc || !asoc->peer.auth_capable)
+		return 0;
+
+	return __sctp_auth_cid(chunk, asoc->peer.peer_chunks);
+}
+
+/* Check if we requested that peer authenticate this chunk. */
+int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
+{
+	if (!sctp_auth_enable || !asoc)
+		return 0;
+
+	return __sctp_auth_cid(chunk,
+			      (struct sctp_chunks_param *)asoc->c.auth_chunks);
+}
+
+/* SCTP-AUTH: Section 6.2:
+ *    The sender MUST calculate the MAC as described in RFC2104 [2] using
+ *    the hash function H as described by the MAC Identifier and the shared
+ *    association key K based on the endpoint pair shared key described by
+ *    the shared key identifier.  The 'data' used for the computation of
+ *    the AUTH-chunk is given by the AUTH chunk with its HMAC field set to
+ *    zero (as shown in Figure 6) followed by all chunks that are placed
+ *    after the AUTH chunk in the SCTP packet.
+ */
+void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
+			      struct sk_buff *skb,
+			      struct sctp_auth_chunk *auth,
+			      gfp_t gfp)
+{
+	struct scatterlist sg;
+	struct hash_desc desc;
+	struct sctp_auth_bytes *asoc_key;
+	__u16 key_id, hmac_id;
+	__u8 *digest;
+	unsigned char *end;
+	int free_key = 0;
+
+	/* Extract the info we need:
+	 * - hmac id
+	 * - key id
+	 */
+	key_id = ntohs(auth->auth_hdr.shkey_id);
+	hmac_id = ntohs(auth->auth_hdr.hmac_id);
+
+	if (key_id == asoc->active_key_id)
+		asoc_key = asoc->asoc_shared_key;
+	else {
+		struct sctp_shared_key *ep_key;
+		
+		ep_key = sctp_auth_get_shkey(asoc, key_id);
+		if (!ep_key)
+			return;
+
+		asoc_key = sctp_auth_asoc_create_secret(asoc, ep_key, gfp);
+		if (!asoc_key)
+			return;
+
+		free_key = 1;
+	}
+	    
+	/* set up scatter list */
+	end = skb_tail_pointer(skb);
+	sg.page = virt_to_page(auth);
+	sg.offset = (unsigned long)(auth) % PAGE_SIZE;
+	sg.length = end - (unsigned char *)auth;
+
+	desc.tfm = asoc->ep->auth_hmacs[hmac_id];
+	desc.flags = 0;
+
+	digest = auth->auth_hdr.hmac;
+	if (crypto_hash_setkey(desc.tfm, &asoc_key->data[0], asoc_key->len))
+		goto free;
+
+	crypto_hash_digest(&desc, &sg, sg.length, digest);
+
+free:
+	if (free_key)
+		sctp_auth_key_put(asoc_key);
+}
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index fcfb9d8..2cf6ad6 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -58,6 +58,7 @@ SCTP_DBG_OBJCNT(chunk);
 SCTP_DBG_OBJCNT(addr);
 SCTP_DBG_OBJCNT(ssnmap);
 SCTP_DBG_OBJCNT(datamsg);
+SCTP_DBG_OBJCNT(keys);
 
 /* An array to make it easy to pretty print the debug information
  * to the proc fs.
@@ -73,6 +74,7 @@ static sctp_dbg_objcnt_entry_t sctp_dbg_objcnt[] = {
 	SCTP_DBG_OBJCNT_ENTRY(addr),
 	SCTP_DBG_OBJCNT_ENTRY(ssnmap),
 	SCTP_DBG_OBJCNT_ENTRY(datamsg),
+	SCTP_DBG_OBJCNT_ENTRY(keys),
 };
 
 /* Callback from procfs to read out objcount information.
-- 
1.5.2.4

