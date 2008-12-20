From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 1/5] sctp: Bring SCTP_MAXSEG socket option into ietf API extension compliance
Date: Fri, 19 Dec 2008 20:47:48 -0500
Message-ID: <1229737672-28328-3-git-send-email-vladislav.yasevich@hp.com>
References: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:21099 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbYLTBrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 20:47:55 -0500
In-Reply-To: <1229737672-28328-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Brings maxseg socket option set/get into line with the latest ietf socket
extensions API draft, while maintaining backwards compatibility.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |  130 +++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 107 insertions(+), 23 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index a2de585..0738843 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2778,32 +2778,77 @@ static int sctp_setsockopt_mappedv4(struct sock *sk, char __user *optval, int op
 }
 
 /*
- * 7.1.17 Set the maximum fragrmentation size (SCTP_MAXSEG)
- *
- * This socket option specifies the maximum size to put in any outgoing
- * SCTP chunk.  If a message is larger than this size it will be
+ * 8.1.16.  Get or Set the Maximum Fragmentation Size (SCTP_MAXSEG)
+ * This option will get or set the maximum size to put in any outgoing
+ * SCTP DATA chunk.  If a message is larger than this size it will be
  * fragmented by SCTP into the specified size.  Note that the underlying
  * SCTP implementation may fragment into smaller sized chunks when the
  * PMTU of the underlying association is smaller than the value set by
- * the user.
+ * the user.  The default value for this option is '0' which indicates
+ * the user is NOT limiting fragmentation and only the PMTU will effect
+ * SCTP's choice of DATA chunk size.  Note also that values set larger
+ * than the maximum size of an IP datagram will effectively let SCTP
+ * control fragmentation (i.e. the same as setting this option to 0).
+ *
+ * The following structure is used to access and modify this parameter:
+ *
+ * struct sctp_assoc_value {
+ *   sctp_assoc_t assoc_id;
+ *   uint32_t assoc_value;
+ * };
+ *
+ * assoc_id:  This parameter is ignored for one-to-one style sockets.
+ *    For one-to-many style sockets this parameter indicates which
+ *    association the user is performing an action upon.  Note that if
+ *    this field's value is zero then the endpoints default value is
+ *    changed (effecting future associations only).
+ * assoc_value:  This parameter specifies the maximum size in bytes.
  */
 static int sctp_setsockopt_maxseg(struct sock *sk, char __user *optval, int optlen)
 {
+	struct sctp_assoc_value params;
 	struct sctp_association *asoc;
 	struct sctp_sock *sp = sctp_sk(sk);
 	int val;
 
-	if (optlen < sizeof(int))
+	if (optlen == sizeof(int)) {
+		printk(KERN_WARNING
+		   "SCTP: Use of int in maxseg socket option deprecated\n");
+		printk(KERN_WARNING
+		   "SCTP: Use struct sctp_assoc_value instead\n");
+		if (copy_from_user(&val, optval, optlen))
+			return -EFAULT;
+		params.assoc_id = 0;
+	} else if (optlen == sizeof(struct sctp_assoc_value)) {
+		if (copy_from_user(&params, optval, optlen))
+			return -EFAULT;
+		val = params.assoc_value;
+	} else
 		return -EINVAL;
-	if (get_user(val, (int __user *)optval))
-		return -EFAULT;
+
 	if ((val != 0) && ((val < 8) || (val > SCTP_MAX_CHUNK_LEN)))
 		return -EINVAL;
-	sp->user_frag = val;
 
-	/* Update the frag_point of the existing associations. */
-	list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
-		asoc->frag_point = sctp_frag_point(sp, asoc->pathmtu);
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (!asoc && params.assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	if (asoc) {
+		if (val == 0) {
+			val = asoc->pathmtu;
+			val -= sp->pf->af->net_header_len;
+			val -= sizeof(struct sctphdr) +
+					sizeof(struct sctp_data_chunk);
+		}
+
+		asoc->frag_point = val;
+	} else {
+		sp->user_frag = val;
+
+		/* Update the frag_point of the existing associations. */
+		list_for_each_entry(asoc, &(sp->ep->asocs), asocs) {
+			asoc->frag_point = sctp_frag_point(sp, asoc->pathmtu);
+		}
 	}
 
 	return 0;
@@ -5100,30 +5145,69 @@ static int sctp_getsockopt_context(struct sock *sk, int len,
 }
 
 /*
- * 7.1.17 Set the maximum fragrmentation size (SCTP_MAXSEG)
- *
- * This socket option specifies the maximum size to put in any outgoing
- * SCTP chunk.  If a message is larger than this size it will be
+ * 8.1.16.  Get or Set the Maximum Fragmentation Size (SCTP_MAXSEG)
+ * This option will get or set the maximum size to put in any outgoing
+ * SCTP DATA chunk.  If a message is larger than this size it will be
  * fragmented by SCTP into the specified size.  Note that the underlying
  * SCTP implementation may fragment into smaller sized chunks when the
  * PMTU of the underlying association is smaller than the value set by
- * the user.
+ * the user.  The default value for this option is '0' which indicates
+ * the user is NOT limiting fragmentation and only the PMTU will effect
+ * SCTP's choice of DATA chunk size.  Note also that values set larger
+ * than the maximum size of an IP datagram will effectively let SCTP
+ * control fragmentation (i.e. the same as setting this option to 0).
+ *
+ * The following structure is used to access and modify this parameter:
+ *
+ * struct sctp_assoc_value {
+ *   sctp_assoc_t assoc_id;
+ *   uint32_t assoc_value;
+ * };
+ *
+ * assoc_id:  This parameter is ignored for one-to-one style sockets.
+ *    For one-to-many style sockets this parameter indicates which
+ *    association the user is performing an action upon.  Note that if
+ *    this field's value is zero then the endpoints default value is
+ *    changed (effecting future associations only).
+ * assoc_value:  This parameter specifies the maximum size in bytes.
  */
 static int sctp_getsockopt_maxseg(struct sock *sk, int len,
 				  char __user *optval, int __user *optlen)
 {
-	int val;
+	struct sctp_assoc_value params;
+	struct sctp_association *asoc;
 
-	if (len < sizeof(int))
+	if (len == sizeof(int)) {
+		printk(KERN_WARNING
+		   "SCTP: Use of int in maxseg socket option deprecated\n");
+		printk(KERN_WARNING
+		   "SCTP: Use struct sctp_assoc_value instead\n");
+		params.assoc_id = 0;
+	} else if (len >= sizeof(struct sctp_assoc_value)) {
+		len = sizeof(struct sctp_assoc_value);
+		if (copy_from_user(&params, optval, sizeof(params)))
+			return -EFAULT;
+	} else
 		return -EINVAL;
 
-	len = sizeof(int);
+	asoc = sctp_id2assoc(sk, params.assoc_id);
+	if (!asoc && params.assoc_id && sctp_style(sk, UDP))
+		return -EINVAL;
+
+	if (asoc)
+		params.assoc_value = asoc->frag_point;
+	else
+		params.assoc_value = sctp_sk(sk)->user_frag;
 
-	val = sctp_sk(sk)->user_frag;
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval, &val, len))
-		return -EFAULT;
+	if (len == sizeof(int)) {
+		if (copy_to_user(optval, &params.assoc_value, len))
+			return -EFAULT;
+	} else {
+		if (copy_to_user(optval, &params, len))
+			return -EFAULT;
+	}
 
 	return 0;
 }
-- 
1.5.3.5

