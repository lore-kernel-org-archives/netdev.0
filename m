From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 1/6] sctp: add SCTP_PR_SUPPORTED on sctp sockopt
Date: Sat,  9 Jul 2016 19:47:40 +0800
Message-ID: <121aa41aceff56b3dda51c41b8f3c4d8662d65b7.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33344 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897AbcGILr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 07:47:57 -0400
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1468064737.git.lucien.xin@gmail.com>
References: <cover.1468064737.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to section 4.5 of rfc7496, prsctp_enable should be per asoc.
We will add prsctp_enable to both asoc and ep, and replace the places
where it used net.sctp->prsctp_enable with asoc->prsctp_enable.

ep->prsctp_enable will be initialized with net.sctp->prsctp_enable, and
asoc->prsctp_enable will be initialized with ep->prsctp_enable. We can
also modify it's value through sockopt SCTP_PR_SUPPORTED.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  6 ++--
 include/uapi/linux/sctp.h  |  1 +
 net/sctp/associola.c       |  1 +
 net/sctp/endpointola.c     |  1 +
 net/sctp/sm_make_chunk.c   | 12 +++----
 net/sctp/socket.c          | 80 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 93 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 83c5ec5..07115ca 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1256,7 +1256,8 @@ struct sctp_endpoint {
 	/* SCTP-AUTH: endpoint shared keys */
 	struct list_head endpoint_shared_keys;
 	__u16 active_key_id;
-	__u8  auth_enable;
+	__u8  auth_enable:1,
+	      prsctp_enable:1;
 };
 
 /* Recover the outter endpoint structure. */
@@ -1848,7 +1849,8 @@ struct sctp_association {
 	__u16 active_key_id;
 
 	__u8 need_ecne:1,	/* Need to send an ECNE Chunk? */
-	     temp:1;		/* Is it a temporary association? */
+	     temp:1,		/* Is it a temporary association? */
+	     prsctp_enable:1;
 
 	struct sctp_priv_assoc_stats stats;
 };
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index ce70fe6..aa08906 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -112,6 +112,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_SOCKOPT_CONNECTX	110		/* CONNECTX requests. */
 #define SCTP_SOCKOPT_CONNECTX3	111	/* CONNECTX requests (updated) */
 #define SCTP_GET_ASSOC_STATS	112	/* Read only */
+#define SCTP_PR_SUPPORTED	113
 
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index e1849f3..1c23060 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -268,6 +268,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 		goto fail_init;
 
 	asoc->active_key_id = ep->active_key_id;
+	asoc->prsctp_enable = ep->prsctp_enable;
 
 	/* Save the hmacs and chunks list into this association */
 	if (ep->auth_hmacs_list)
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 9d494e3..1f03065 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -163,6 +163,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	 */
 	ep->auth_hmacs_list = auth_hmacs;
 	ep->auth_chunk_list = auth_chunks;
+	ep->prsctp_enable = net->sctp.prsctp_enable;
 
 	return ep;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 56f364d..0e3045e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -261,7 +261,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	chunksize += WORD_ROUND(SCTP_SAT_LEN(num_types));
 	chunksize += sizeof(ecap_param);
 
-	if (net->sctp.prsctp_enable)
+	if (asoc->prsctp_enable)
 		chunksize += sizeof(prsctp_param);
 
 	/* ADDIP: Section 4.2.7:
@@ -355,7 +355,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 		sctp_addto_param(retval, num_ext, extensions);
 	}
 
-	if (net->sctp.prsctp_enable)
+	if (asoc->prsctp_enable)
 		sctp_addto_chunk(retval, sizeof(prsctp_param), &prsctp_param);
 
 	if (sp->adaptation_ind) {
@@ -2024,8 +2024,8 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 	for (i = 0; i < num_ext; i++) {
 		switch (param.ext->chunks[i]) {
 		case SCTP_CID_FWD_TSN:
-			if (net->sctp.prsctp_enable && !asoc->peer.prsctp_capable)
-				    asoc->peer.prsctp_capable = 1;
+			if (asoc->prsctp_enable && !asoc->peer.prsctp_capable)
+				asoc->peer.prsctp_capable = 1;
 			break;
 		case SCTP_CID_AUTH:
 			/* if the peer reports AUTH, assume that he
@@ -2169,7 +2169,7 @@ static sctp_ierror_t sctp_verify_param(struct net *net,
 		break;
 
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
-		if (net->sctp.prsctp_enable)
+		if (ep->prsctp_enable)
 			break;
 		goto fallthrough;
 
@@ -2653,7 +2653,7 @@ do_addr_param:
 		break;
 
 	case SCTP_PARAM_FWD_TSN_SUPPORT:
-		if (net->sctp.prsctp_enable) {
+		if (asoc->prsctp_enable) {
 			asoc->peer.prsctp_capable = 1;
 			break;
 		}
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index cdabbd8..7460dde 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3661,6 +3661,39 @@ static int sctp_setsockopt_recvnxtinfo(struct sock *sk,
 	return 0;
 }
 
+static int sctp_setsockopt_pr_supported(struct sock *sk,
+					char __user *optval,
+					unsigned int optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_association *asoc;
+	int retval = -EINVAL;
+
+	if (optlen != sizeof(params))
+		goto out;
+
+	if (copy_from_user(&params, optval, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (asoc) {
+		asoc->prsctp_enable = !!params.assoc_value;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		sp->ep->prsctp_enable = !!params.assoc_value;
+	} else {
+		goto out;
+	}
+
+	retval = 0;
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3821,6 +3854,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RECVNXTINFO:
 		retval = sctp_setsockopt_recvnxtinfo(sk, optval, optlen);
 		break;
+	case SCTP_PR_SUPPORTED:
+		retval = sctp_setsockopt_pr_supported(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -6166,6 +6202,47 @@ static int sctp_getsockopt_recvnxtinfo(struct sock *sk,	int len,
 	return 0;
 }
 
+static int sctp_getsockopt_pr_supported(struct sock *sk, int len,
+					char __user *optval,
+					int __user *optlen)
+{
+	struct sctp_assoc_value params;
+	struct sctp_association *asoc;
+	int retval = -EFAULT;
+
+	if (len < sizeof(params)) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	len = sizeof(params);
+	if (copy_from_user(&params, optval, len))
+		goto out;
+
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (asoc) {
+		params.assoc_value = asoc->prsctp_enable;
+	} else if (!params.assoc_id) {
+		struct sctp_sock *sp = sctp_sk(sk);
+
+		params.assoc_value = sp->ep->prsctp_enable;
+	} else {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	if (put_user(len, optlen))
+		goto out;
+
+	if (copy_to_user(optval, &params, len))
+		goto out;
+
+	retval = 0;
+
+out:
+	return retval;
+}
+
 static int sctp_getsockopt(struct sock *sk, int level, int optname,
 			   char __user *optval, int __user *optlen)
 {
@@ -6319,6 +6396,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RECVNXTINFO:
 		retval = sctp_getsockopt_recvnxtinfo(sk, len, optval, optlen);
 		break;
+	case SCTP_PR_SUPPORTED:
+		retval = sctp_getsockopt_pr_supported(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
