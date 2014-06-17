From: Geir Ola Vaagland <geirola@gmail.com>
Subject: [PATCH net-next 6/6] Support for SCTP_DEFAULT_SNDINFO socket option
Date: Tue, 17 Jun 2014 17:01:36 +0200
Message-ID: <1403017296-28469-7-git-send-email-geirola@gmail.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:52973 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933261AbaFQPBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 11:01:50 -0400
In-Reply-To: <1403017296-28469-1-git-send-email-geirola@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Geir Ola Vaagland <geirola@gmail.com>
---
 include/uapi/linux/sctp.h |  1 +
 net/sctp/socket.c         | 94 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 95 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 986563e..133df4e 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -99,6 +99,7 @@ typedef __s32 sctp_assoc_t;
 
 #define SCTP_RECVRCVINFO 32
 #define SCTP_RECVNXTINFO 33
+#define SCTP_DEFAULT_SNDINFO 34
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 57106e8..a725376 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2801,6 +2801,55 @@ static int sctp_setsockopt_default_send_param(struct sock *sk,
 
 	return 0;
 }
+
+/* 8.1.31. Set Default Send Parameters (SCTP_DEFAULT_SNDINFO)
+ *
+ *   Applications that wish to use the sendto() system call may wish to
+ *   specify a default set of parameters that would normally be supplied
+ *   through the inclusion of ancillary data.  This socket option allows
+ *   such an application to set the default sctp_sndinfo structure.  The
+ *   application that wishes to use this socket option simply passes the
+ *   sctp_sndinfo structure (defined in Section 5.3.4) to this call.  The
+ *   input parameters accepted by this call include snd_sid, snd_flags,
+ *   snd_ppid, and snd_context.  The snd_flags parameter is composed of a
+ *   bitwise OR of SCTP_UNORDERED, SCTP_EOF, and SCTP_SENDALL.  The
+ *   snd_assoc_id field specifies the association to which to apply the
+ *   parameters.  For a one-to-many style socket, any of the predefined
+ *   constants are also allowed in this field.  The field is ignored for
+ *   one-to-one style sockets.
+ */
+static int sctp_setsockopt_default_sndinfo(struct sock *sk,
+					    char __user *optval,
+					    unsigned int optlen){
+	struct sctp_sndinfo info;
+	struct sctp_association *asoc;
+	struct sctp_sock *sp = sctp_sk(sk);
+
+	if (optlen != sizeof(struct sctp_sndinfo))
+		return -EINVAL;
+	if (copy_from_user(&info, optval, optlen))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, info.snd_assoc_id);
+	if (!asoc && info.snd_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	/* Note! asoc->default_timetolive is not set in this way anymore.
+	 * The PR-SCTP extension needs to be implemented.
+    */
+	if (asoc) {
+		asoc->default_stream = info.snd_sid;
+		asoc->default_flags = info.snd_flags;
+		asoc->default_ppid = info.snd_ppid;
+		asoc->default_context = info.snd_context;
+	} else {
+		sp->default_stream = info.snd_sid;
+		sp->default_flags = info.snd_flags;
+		sp->default_ppid = info.snd_ppid;
+		sp->default_context = info.snd_context;
+	}
+	return 0;
+}
+
 
 /* 7.1.10 Set Primary Address (SCTP_PRIMARY_ADDR)
  *
@@ -3724,6 +3773,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_setsockopt_default_send_param(sk, optval,
 							    optlen);
 		break;
+	case SCTP_DEFAULT_SNDINFO:
+		retval = sctp_setsockopt_default_sndinfo(sk, optval, optlen);
+		break;
 	case SCTP_PRIMARY_ADDR:
 		retval = sctp_setsockopt_primary_addr(sk, optval, optlen);
 		break;
@@ -5063,6 +5115,45 @@ static int sctp_getsockopt_default_send_param(struct sock *sk,
 
 	return 0;
 }
+static int sctp_getsockopt_default_sndinfo(struct sock *sk,
+					int len, char __user *optval,
+					int __user *optlen)
+{
+	struct sctp_sndinfo info;
+	struct sctp_association *asoc;
+	struct sctp_sock *sp = sctp_sk(sk);
+
+	if (len < sizeof(struct sctp_sndinfo))
+		return -EINVAL;
+
+	len = sizeof(struct sctp_sndinfo);
+
+	if (copy_from_user(&info, optval, len))
+		return -EFAULT;
+
+	asoc = sctp_id2assoc(sk, info.snd_assoc_id);
+	if (!asoc && info.snd_assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	if (asoc) {
+		info.snd_sid = asoc->default_stream;
+		info.snd_flags = asoc->default_flags;
+		info.snd_ppid = asoc->default_ppid;
+		info.snd_context = asoc->default_context;
+	} else {
+		info.snd_sid = sp->default_stream;
+		info.snd_flags = sp->default_flags;
+		info.snd_ppid = sp->default_ppid;
+		info.snd_context = sp->default_context;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+	if (copy_to_user(optval, &info, len))
+		return -EFAULT;
+
+	return 0;
+}
 
 /*
  *
@@ -5917,6 +6008,9 @@ static int sctp_getsockopt(struct sock *sk, int level, int optname,
 		retval = sctp_getsockopt_default_send_param(sk, len,
 							    optval, optlen);
 		break;
+	case SCTP_DEFAULT_SNDINFO:
+		retval = sctp_getsockopt_default_sndinfo(sk, len,
+							 optval, optlen);
+		break;
 	case SCTP_PRIMARY_ADDR:
 		retval = sctp_getsockopt_primary_addr(sk, len, optval, optlen);
 		break;
