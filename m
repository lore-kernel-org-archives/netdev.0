From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 1/3] sctp: implement socket option SCTP_GET_ASSOC_ID_LIST
Date: Mon, 18 Apr 2011 11:27:08 +0800
Message-ID: <4DABAF8C.9070709@cn.fujitsu.com>
References: <4DABAEF1.1010506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59484 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751833Ab1DRD1B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 23:27:01 -0400
In-Reply-To: <4DABAEF1.1010506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch Implement socket option SCTP_GET_ASSOC_ID_LIST.
SCTP Socket API Extension:

  8.2.6. Get the Current Identifiers of Associations
         (SCTP_GET_ASSOC_ID_LIST)

  This option gets the current list of SCTP association identifiers of
  the SCTP associations handled by a one-to-many style socket.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/sctp/user.h |   13 +++++++++++
 net/sctp/socket.c       |   52 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index e73ebda..793617e 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -91,6 +91,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PEER_AUTH_CHUNKS	26	/* Read only */
 #define SCTP_LOCAL_AUTH_CHUNKS	27	/* Read only */
 #define SCTP_GET_ASSOC_NUMBER	28	/* Read only */
+#define SCTP_GET_ASSOC_ID_LIST	29	/* Read only */
 
 /* Internal Socket Options. Some of the sctp library functions are
  * implemented using these socket options.
@@ -669,6 +670,18 @@ struct sctp_authchunks {
 };
 
 /*
+ * 8.2.6. Get the Current Identifiers of Associations
+ *        (SCTP_GET_ASSOC_ID_LIST)
+ *
+ * This option gets the current list of SCTP association identifiers of
+ * the SCTP associations handled by a one-to-many style socket.
+ */
+struct sctp_assoc_ids {
+	__u32		gaids_number_of_ids;
+	sctp_assoc_t	gaids_assoc_id[];
+};
+
+/*
  * 8.3, 8.5 get all peer/local addresses in an association.
  * This parameter struct is used by SCTP_GET_PEER_ADDRS and 
  * SCTP_GET_LOCAL_ADDRS socket options used internally to implement
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index deb82e3..7bdeae7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5283,6 +5283,55 @@ static int sctp_getsockopt_assoc_number(struct sock *sk, int len,
 	return 0;
 }
 
+/*
+ * 8.2.6. Get the Current Identifiers of Associations
+ *        (SCTP_GET_ASSOC_ID_LIST)
+ *
+ * This option gets the current list of SCTP association identifiers of
+ * the SCTP associations handled by a one-to-many style socket.
+ */
+static int sctp_getsockopt_assoc_ids(struct sock *sk, int len,
+				    char __user *optval, int __user *optlen)
+{
+	struct sctp_sock *sp = sctp_sk(sk);
+	struct sctp_association *asoc;
+	struct sctp_assoc_ids *ids;
+	u32 num = 0;
+
+	if (sctp_style(sk, TCP))
+		return -EOPNOTSUPP;
+
+	if (len < sizeof(struct sctp_assoc_ids))
+		return -EINVAL;
+
+	list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
+		num++;
+	}
+
+	if (len < sizeof(struct sctp_assoc_ids) + sizeof(sctp_assoc_t) * num)
+		return -EINVAL;
+
+	len = sizeof(struct sctp_assoc_ids) + sizeof(sctp_assoc_t) * num;
+
+	ids = kmalloc(len, GFP_KERNEL);
+	if (unlikely(!ids))
+		return -ENOMEM;
+
+	ids->gaids_number_of_ids = num;
+	num = 0;
+	list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
+		ids->gaids_assoc_id[num++] = asoc->assoc_id;
+	}
+
+	if (put_user(len, optlen) || copy_to_user(optval, ids, len)) {
+		kfree(ids);
+		return -EFAULT;
+	}
+
+	kfree(ids);
+	return 0;
+}
+
 SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
@@ -5415,6 +5464,9 @@ SCTP_STATIC int sctp_getsockopt(struct sock *sk, int level, int optname,
 	case SCTP_GET_ASSOC_NUMBER:
 		retval = sctp_getsockopt_assoc_number(sk, len, optval, optlen);
 		break;
+	case SCTP_GET_ASSOC_ID_LIST:
+		retval = sctp_getsockopt_assoc_ids(sk, len, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
1.6.5.2


