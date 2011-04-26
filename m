From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v6 3/5] sctp: Add socket option operation for Auto-ASCONF
Date: Tue, 26 Apr 2011 13:30:08 +0900
Message-ID: <0B9100AB-44C5-49E7-AA03-8B99180BE7E3@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:36223 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751332Ab1DZEaJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 00:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the application to operate Auto-ASCONF on/off behavior via setsockopt() and getsockopt().  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 32fd512..0842ef0 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -92,6 +92,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_LOCAL_AUTH_CHUNKS	27	/* Read only */
 #define SCTP_GET_ASSOC_NUMBER	28	/* Read only */
 #define SCTP_GET_ASSOC_ID_LIST	29	/* Read only */
+#define SCTP_AUTO_ASCONF       30
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f694ee1..bf3501c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3335,6 +3335,46 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 
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
@@ -3482,6 +3522,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_AUTH_DELETE_KEY:
 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -5277,6 +5320,28 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
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
 /*
  * 8.2.6. Get the Current Identifiers of Associations
  *        (SCTP_GET_ASSOC_ID_LIST)
@@ -5461,6 +5526,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_GET_ASSOC_ID_LIST:
 		retval = sctp_getsockopt_assoc_ids(sk, len, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;

