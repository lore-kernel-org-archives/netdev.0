From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH next-2.6 2/3] [SCTP]: Support the new specification of sctp_connectx()
Date: Fri,  9 May 2008 15:16:05 -0400
Message-ID: <1210360566-16661-2-git-send-email-vladislav.yasevich@hp.com>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:28778 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926AbYEITQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 15:16:13 -0400
In-Reply-To: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The specification of sctp_connectx() has been changed to return
an association id.  We've added a new socket option that will
return the association id as the return value from the setsockopt()
call.  The library that implements sctp_connectx() interface will
implement both socket options.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |    6 +++-
 net/sctp/socket.c       |   70 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 63 insertions(+), 13 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 31371d2..f205b10 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -137,12 +137,14 @@ enum sctp_optname {
 #define SCTP_GET_LOCAL_ADDRS_NUM_OLD	SCTP_GET_LOCAL_ADDRS_NUM_OLD
 	SCTP_GET_LOCAL_ADDRS_OLD, 	/* Get all local addresss. */
 #define SCTP_GET_LOCAL_ADDRS_OLD	SCTP_GET_LOCAL_ADDRS_OLD
-	SCTP_SOCKOPT_CONNECTX, /* CONNECTX requests. */
-#define SCTP_SOCKOPT_CONNECTX	SCTP_SOCKOPT_CONNECTX
+	SCTP_SOCKOPT_CONNECTX_OLD, /* CONNECTX old requests. */
+#define SCTP_SOCKOPT_CONNECTX_OLD	SCTP_SOCKOPT_CONNECTX_OLD
 	SCTP_GET_PEER_ADDRS, 	/* Get all peer addresss. */
 #define SCTP_GET_PEER_ADDRS	SCTP_GET_PEER_ADDRS
 	SCTP_GET_LOCAL_ADDRS, 	/* Get all local addresss. */
 #define SCTP_GET_LOCAL_ADDRS	SCTP_GET_LOCAL_ADDRS
+	SCTP_SOCKOPT_CONNECTX, /* CONNECTX requests. */
+#define SCTP_SOCKOPT_CONNECTX	SCTP_SOCKOPT_CONNECTX
 };
 
 /*
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 6698587..81600ee 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -956,7 +956,8 @@ out:
  */
 static int __sctp_connect(struct sock* sk,
 			  struct sockaddr *kaddrs,
-			  int addrs_size)
+			  int addrs_size,
+			  sctp_assoc_t *assoc_id)
 {
 	struct sctp_sock *sp;
 	struct sctp_endpoint *ep;
@@ -1111,6 +1112,8 @@ static int __sctp_connect(struct sock* sk,
 	timeo = sock_sndtimeo(sk, f_flags & O_NONBLOCK);
 
 	err = sctp_wait_for_connect(asoc, &timeo);
+	if (!err && assoc_id)
+		*assoc_id = asoc->assoc_id;
 
 	/* Don't free association on exit. */
 	asoc = NULL;
@@ -1128,7 +1131,8 @@ out_free:
 /* Helper for tunneling sctp_connectx() requests through sctp_setsockopt()
  *
  * API 8.9
- * int sctp_connectx(int sd, struct sockaddr *addrs, int addrcnt);
+ * int sctp_connectx(int sd, struct sockaddr *addrs, int addrcnt,
+ * 			sctp_assoc_t *asoc);
  *
  * If sd is an IPv4 socket, the addresses passed must be IPv4 addresses.
  * If the sd is an IPv6 socket, the addresses passed can either be IPv4
@@ -1144,8 +1148,10 @@ out_free:
  * representation is termed a "packed array" of addresses). The caller
  * specifies the number of addresses in the array with addrcnt.
  *
- * On success, sctp_connectx() returns 0. On failure, sctp_connectx() returns
- * -1, and sets errno to the appropriate error code.
+ * On success, sctp_connectx() returns 0. It also sets the assoc_id to
+ * the association id of the new association.  On failure, sctp_connectx()
+ * returns -1, and sets errno to the appropriate error code.  The assoc_id
+ * is not touched by the kernel.
  *
  * For SCTP, the port given in each socket address must be the same, or
  * sctp_connectx() will fail, setting errno to EINVAL.
@@ -1182,11 +1188,12 @@ out_free:
  * addrs     The pointer to the addresses in user land
  * addrssize Size of the addrs buffer
  *
- * Returns 0 if ok, <0 errno code on error.
+ * Returns >=0 if ok, <0 errno code on error.
  */
-SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
+SCTP_STATIC int __sctp_setsockopt_connectx(struct sock* sk,
 				      struct sockaddr __user *addrs,
-				      int addrs_size)
+				      int addrs_size,
+				      sctp_assoc_t *assoc_id)
 {
 	int err = 0;
 	struct sockaddr *kaddrs;
@@ -1209,13 +1216,46 @@ SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
 	if (__copy_from_user(kaddrs, addrs, addrs_size)) {
 		err = -EFAULT;
 	} else {
-		err = __sctp_connect(sk, kaddrs, addrs_size);
+		err = __sctp_connect(sk, kaddrs, addrs_size, assoc_id);
 	}
 
 	kfree(kaddrs);
+
 	return err;
 }
 
+/*
+ * This is an older interface.  It's kept for backward compatibility
+ * to the option that doesn't provide association id.
+ */
+SCTP_STATIC int sctp_setsockopt_connectx_old(struct sock* sk,
+				      struct sockaddr __user *addrs,
+				      int addrs_size)
+{
+	return __sctp_setsockopt_connectx(sk, addrs, addrs_size, NULL);
+}
+
+/*
+ * New interface for the API.  The since the API is done with a socket
+ * option, to make it simple we feed back the association id is as a return
+ * indication to the call.  Error is always negative and association id is
+ * always positive.
+ */
+SCTP_STATIC int sctp_setsockopt_connectx(struct sock* sk,
+				      struct sockaddr __user *addrs,
+				      int addrs_size)
+{
+	sctp_assoc_t assoc_id = 0;
+	int err = 0;
+
+	err = __sctp_setsockopt_connectx(sk, addrs, addrs_size, &assoc_id);
+
+	if (err)
+		return err;
+	else
+		return assoc_id;
+}
+
 /* API 3.1.4 close() - UDP Style Syntax
  * Applications use close() to perform graceful shutdown (as described in
  * Section 10.1 of [SCTP]) on ALL the associations currently represented
@@ -3206,10 +3246,18 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 					       optlen, SCTP_BINDX_REM_ADDR);
 		break;
 
+	case SCTP_SOCKOPT_CONNECTX_OLD:
+		/* 'optlen' is the size of the addresses buffer. */
+		retval = sctp_setsockopt_connectx_old(sk,
+					    (struct sockaddr __user *)optval,
+					    optlen);
+		break;
+
 	case SCTP_SOCKOPT_CONNECTX:
 		/* 'optlen' is the size of the addresses buffer. */
-		retval = sctp_setsockopt_connectx(sk, (struct sockaddr __user *)optval,
-					       optlen);
+		retval = sctp_setsockopt_connectx(sk,
+					    (struct sockaddr __user *)optval,
+					    optlen);
 		break;
 
 	case SCTP_DISABLE_FRAGMENTS:
@@ -3336,7 +3384,7 @@ SCTP_STATIC int sctp_connect(struct sock *sk, struct sockaddr *addr,
 		/* Pass correct addr len to common routine (so it knows there
 		 * is only one address being passed.
 		 */
-		err = __sctp_connect(sk, addr, af->sockaddr_len);
+		err = __sctp_connect(sk, addr, af->sockaddr_len, NULL);
 	}
 
 	sctp_release_sock(sk);
-- 
1.5.3.5

