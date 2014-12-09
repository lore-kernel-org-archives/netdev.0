From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 15/25] ipv6 equivalent of "ipv4: Avoid reading user iov twice after raw_probe_proto_opt"
Date: Tue,  9 Dec 2014 22:50:28 +0000
Message-ID: <1418165438-2205-15-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:37475 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaLIWul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 17:50:41 -0500
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv6/raw.c | 112 ++++++++++++++++++++++++++++-----------------------------
 1 file changed, 56 insertions(+), 56 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8baa53e..942f67b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -672,65 +672,62 @@ error:
 	return err;
 }
 
-static int rawv6_probe_proto_opt(struct flowi6 *fl6, struct msghdr *msg)
+struct raw6_frag_vec {
+	struct msghdr *msg;
+	int hlen;
+	char c[4];
+};
+
+static int rawv6_probe_proto_opt(struct raw6_frag_vec *rfv, struct flowi6 *fl6)
 {
-	struct iovec *iov;
-	u8 __user *type = NULL;
-	u8 __user *code = NULL;
-	u8 len = 0;
-	int probed = 0;
-	int i;
-
-	if (!msg->msg_iov)
-		return 0;
+	int err = 0;
+	switch (fl6->flowi6_proto) {
+	case IPPROTO_ICMPV6:
+		rfv->hlen = 2;
+		err = memcpy_from_msg(rfv->c, rfv->msg, rfv->hlen);
+		if (!err) {
+			fl6->fl6_icmp_type = rfv->c[0];
+			fl6->fl6_icmp_code = rfv->c[1];
+		}
+		break;
+	case IPPROTO_MH:
+		rfv->hlen = 4;
+		err = memcpy_from_msg(rfv->c, rfv->msg, rfv->hlen);
+		if (!err)
+			fl6->fl6_mh_type = rfv->c[2];
+	}
+	return err;
+}
 
-	for (i = 0; i < msg->msg_iovlen; i++) {
-		iov = &msg->msg_iov[i];
-		if (!iov)
-			continue;
+static int raw6_getfrag(void *from, char *to, int offset, int len, int odd,
+		       struct sk_buff *skb)
+{
+	struct raw6_frag_vec *rfv = from;
 
-		switch (fl6->flowi6_proto) {
-		case IPPROTO_ICMPV6:
-			/* check if one-byte field is readable or not. */
-			if (iov->iov_base && iov->iov_len < 1)
-				break;
-
-			if (!type) {
-				type = iov->iov_base;
-				/* check if code field is readable or not. */
-				if (iov->iov_len > 1)
-					code = type + 1;
-			} else if (!code)
-				code = iov->iov_base;
-
-			if (type && code) {
-				if (get_user(fl6->fl6_icmp_type, type) ||
-				    get_user(fl6->fl6_icmp_code, code))
-					return -EFAULT;
-				probed = 1;
-			}
-			break;
-		case IPPROTO_MH:
-			if (iov->iov_base && iov->iov_len < 1)
-				break;
-			/* check if type field is readable or not. */
-			if (iov->iov_len > 2 - len) {
-				u8 __user *p = iov->iov_base;
-				if (get_user(fl6->fl6_mh_type, &p[2 - len]))
-					return -EFAULT;
-				probed = 1;
-			} else
-				len += iov->iov_len;
+	if (offset < rfv->hlen) {
+		int copy = min(rfv->hlen - offset, len);
 
-			break;
-		default:
-			probed = 1;
-			break;
-		}
-		if (probed)
-			break;
+		if (skb->ip_summed == CHECKSUM_PARTIAL)
+			memcpy(to, rfv->c + offset, copy);
+		else
+			skb->csum = csum_block_add(
+				skb->csum,
+				csum_partial_copy_nocheck(rfv->c + offset,
+							  to, copy, 0),
+				odd);
+
+		odd = 0;
+		offset += copy;
+		to += copy;
+		len -= copy;
+
+		if (!len)
+			return 0;
 	}
-	return 0;
+
+	offset -= rfv->hlen;
+
+	return ip_generic_getfrag(rfv->msg->msg_iov, to, offset, len, odd, skb);
 }
 
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
@@ -745,6 +742,7 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	struct ipv6_txoptions *opt = NULL;
 	struct ip6_flowlabel *flowlabel = NULL;
 	struct dst_entry *dst = NULL;
+	struct raw6_frag_vec rfv;
 	struct flowi6 fl6;
 	int addr_len = msg->msg_namelen;
 	int hlimit = -1;
@@ -848,7 +846,9 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 	opt = ipv6_fixup_options(&opt_space, opt);
 
 	fl6.flowi6_proto = proto;
-	err = rawv6_probe_proto_opt(&fl6, msg);
+	rfv.msg = msg;
+	rfv.hlen = 0;
+	err = rawv6_probe_proto_opt(&rfv, &fl6);
 	if (err)
 		goto out;
 
@@ -889,7 +889,7 @@ back_from_confirm:
 		err = rawv6_send_hdrinc(sk, msg->msg_iov, len, &fl6, &dst, msg->msg_flags);
 	else {
 		lock_sock(sk);
-		err = ip6_append_data(sk, ip_generic_getfrag, msg->msg_iov,
+		err = ip6_append_data(sk, raw6_getfrag, &rfv,
 			len, 0, hlimit, tclass, opt, &fl6, (struct rt6_info *)dst,
 			msg->msg_flags, dontfrag);
 
-- 
2.1.3
