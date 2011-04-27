From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 5/6] sctp: Add socket option operation for Auto-ASCONF.
Date: Wed, 27 Apr 2011 17:30:11 +0900
Message-ID: <8B37E19D-CFD7-4714-88C5-02C687FF000B@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Honda Michio <micchie@sfc.wide.ad.jp>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:45069 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752672Ab1D0IaM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 04:30:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From cabf61b74e65a4b2dcd65a2ad7259c3957f277da Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 26 Apr 2011 20:16:31 +0900
Subject: [PATCH 5/6] sctp: Add socket option operation for Auto-ASCONF.

This patch allows the application to operate Auto-ASCONF on/off
behavior via setsockopt() and getsockopt().

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/sctp/user.h |    1 +
 net/sctp/socket.c       |   68 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+), 0 deletions(-)

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
index 68c618a..78a2f94 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3351,6 +3351,46 @@ static int sctp_setsockopt_del_key(struct sock *sk,
 
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
@@ -3498,6 +3538,9 @@ SCTP_STATIC int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_AUTH_DELETE_KEY:
 		retval = sctp_setsockopt_del_key(sk, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_setsockopt_auto_asconf(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
@@ -5305,6 +5348,28 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
 }
 
 /*
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
+/*
  * 8.2.6. Get the Current Identifiers of Associations
  *        (SCTP_GET_ASSOC_ID_LIST)
  *
@@ -5488,6 +5553,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_GET_ASSOC_ID_LIST:
 		retval = sctp_getsockopt_assoc_ids(sk, len, optval, optlen);
 		break;
+	case SCTP_AUTO_ASCONF:
+		retval = sctp_getsockopt_auto_asconf(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
1.7.3.2


