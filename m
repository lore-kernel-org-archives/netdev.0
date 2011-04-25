From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v5 3/5] sctp: Add socket option operation for Auto-ASCONF
Date: Tue, 26 Apr 2011 00:23:41 +0900
Message-ID: <0A966B15-C985-40AC-9402-CAE9BA7F2AC2@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53022 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757663Ab1DYPXm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 11:23:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the application to operate Auto-ASCONF on/off behavior via setsockopt() and getsockopt().  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index e73ebda..36bf64b 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -91,6 +91,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PEER_AUTH_CHUNKS	26	/* Read only */
 #define SCTP_LOCAL_AUTH_CHUNKS	27	/* Read only */
 #define SCTP_GET_ASSOC_NUMBER	28	/* Read only */
+#define SCTP_AUTO_ASCONF       29
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3951a10..c9be08a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3341,6 +3341,46 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 
 }
 
+/*
+ * 8.1.23 SCTP_AUTO_ASCONF
+ *
+ * This option will enable or disable the use of the automatic generation of
+ * ASCONF chunks to add and delete addresses to an existing association.  Note
+ * that this option has two caveats namely: a) it only affects sockets that
+ * are bound to all addresses available to the SCTP stack, and b) the system
+ * administrator may have an overriding control that turns the ASCONF feature
+ * off no matter what setting the socket option may have.
+ * This option expects an integer boolean flag, where a non-zero value turns on
+ * the option, and a zero value turns off the option.
+ * Note. In this implementation, socket operation overrides default parameter
+ * being set by sysctl as well as FreeBSD implementation
+ */
+static int sctp_setsockopt_auto_asconf(struct sock *sk, char __user *optval,
+					unsigned int optlen)
+{
+	int val;
+	struct sctp_sock *sp = sctp_sk(sk);
+
+	if (optlen < sizeof(int))
+		return -EINVAL;
+	if (get_user(val, (int __user *)optval))
+		return -EFAULT;
+	if (!sctp_is_ep_boundall(sk) && val)
+		return -EINVAL;
+	if ((val && sp->do_auto_asconf) || (!val && !sp->do_auto_asconf))
+		return 0;
+
+	if (val == 0 && sp->do_auto_asconf) {
+		list_del(&sp->auto_asconf_list);
+		sp->do_auto_asconf = 0;
+	} else if (val && !sp->do_auto_asconf) {
+		list_add_tail(&sp->auto_asconf_list,
+		    &sctp_auto_asconf_splist);
+		sp->do_auto_asconf = 1;
+	}
+	return 0;
+}
+
 
 /* API 6.2 setsockopt(), getsockopt()
  *
@@ -3488,6 +3528,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_AUTH_DELETE_KEY:
 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -5283,6 +5326,28 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
 	return 0;
 }
 
+/*
+ * 8.1.23 SCTP_AUTO_ASCONF
+ * See the corresponding setsockopt entry as description
+ */
+static int sctp_getsockopt_auto_asconf(struct sock *sk, int len,
+				   char __user *optval, int __user *optlen)
+{
+	int val = 0;
+
+	if (len < sizeof(int))
+		return -EINVAL;
+
+	len = sizeof(int);
+	if (sctp_sk(sk)->do_auto_asconf && sctp_is_ep_boundall(sk))
+		val = 1;
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &val, len))
+		return -EFAULT;
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -5415,6 +5480,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_GET_ASSOC_NUMBER:
 		retval = sctp_getsockopt_assoc_number(sk, len, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;

