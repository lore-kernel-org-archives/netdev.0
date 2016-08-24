From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next v2 2/2] net: diag: allow socket bytecode filters to match socket marks
Date: Wed, 24 Aug 2016 15:46:26 +0900
Message-ID: <1472021186-4106-2-git-send-email-lorenzo@google.com>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Cc: eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, ek@google.com,
        Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36081 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753616AbcHXGqi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:46:38 -0400
Received: by mail-pf0-f171.google.com with SMTP id h186so3682940pfg.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 23:46:38 -0700 (PDT)
In-Reply-To: <1472021186-4106-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows a privileged process to filter by socket mark when
dumping sockets via INET_DIAG_BY_FAMILY. This is useful on
systems that use mark-based routing such as Android.

The ability to filter socket marks requires CAP_NET_ADMIN, which
is consistent with other privileged operations allowed by the
SOCK_DIAG interface such as the ability to destroy sockets and
the ability to inspect BPF filters attached to packet sockets.

Tested: https://android-review.googlesource.com/261350
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/uapi/linux/inet_diag.h |  6 ++++++
 net/ipv4/inet_diag.c           | 36 +++++++++++++++++++++++++++++++++---
 2 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index abbd1dc..5581206 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -73,6 +73,7 @@ enum {
 	INET_DIAG_BC_S_COND,
 	INET_DIAG_BC_D_COND,
 	INET_DIAG_BC_DEV_COND,   /* u32 ifindex */
+	INET_DIAG_BC_MARK_COND,
 };
 
 struct inet_diag_hostcond {
@@ -82,6 +83,11 @@ struct inet_diag_hostcond {
 	__be32	addr[0];
 };
 
+struct inet_diag_markcond {
+	__u32 mark;
+	__u32 mask;
+};
+
 /* Base info structure. It contains socket identity (addrs/ports/cookie)
  * and, alas, the information shown by netstat. */
 struct inet_diag_msg {
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a89b68c..abfbe49 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -45,6 +45,7 @@ struct inet_diag_entry {
 	u16 family;
 	u16 userlocks;
 	u32 ifindex;
+	u32 mark;
 };
 
 static DEFINE_MUTEX(inet_diag_table_mutex);
@@ -580,6 +581,14 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 				yes = 0;
 			break;
 		}
+		case INET_DIAG_BC_MARK_COND: {
+			struct inet_diag_markcond *cond;
+
+			cond = (struct inet_diag_markcond *)(op + 1);
+			if ((entry->mark & cond->mask) != cond->mark)
+				yes = 0;
+			break;
+		}
 		}
 
 		if (yes) {
@@ -624,6 +633,12 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 	entry.dport = ntohs(inet->inet_dport);
 	entry.ifindex = sk->sk_bound_dev_if;
 	entry.userlocks = sk_fullsock(sk) ? sk->sk_userlocks : 0;
+	if (sk_fullsock(sk))
+		entry.mark = sk->sk_mark;
+	else if (sk->sk_state == TCP_NEW_SYN_RECV)
+		entry.mark = inet_rsk(inet_reqsk(sk))->ir_mark;
+	else
+		entry.mark = 0;
 
 	return inet_diag_bc_run(bc, &entry);
 }
@@ -706,8 +721,17 @@ static bool valid_port_comparison(const struct inet_diag_bc_op *op,
 	return true;
 }
 
-static int inet_diag_bc_audit(const struct nlattr *attr)
+static bool valid_markcond(const struct inet_diag_bc_op *op, int len,
+			   int *min_len)
 {
+	*min_len += sizeof(struct inet_diag_markcond);
+	return len >= *min_len;
+}
+
+static int inet_diag_bc_audit(const struct nlattr *attr,
+			      const struct sk_buff *skb)
+{
+	bool net_admin = netlink_net_capable(skb, CAP_NET_ADMIN);
 	const void *bytecode, *bc;
 	int bytecode_len, len;
 
@@ -738,6 +762,12 @@ static int inet_diag_bc_audit(const struct nlattr *attr)
 			if (!valid_port_comparison(bc, len, &min_len))
 				return -EINVAL;
 			break;
+		case INET_DIAG_BC_MARK_COND:
+			if (!net_admin)
+				return -EPERM;
+			if (!valid_markcond(bc, len, &min_len))
+				return -EINVAL;
+			break;
 		case INET_DIAG_BC_AUTO:
 		case INET_DIAG_BC_JMP:
 		case INET_DIAG_BC_NOP:
@@ -1030,7 +1060,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			attr = nlmsg_find_attr(nlh, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			err = inet_diag_bc_audit(attr);
+			err = inet_diag_bc_audit(attr, skb);
 			if (err)
 				return err;
 		}
@@ -1061,7 +1091,7 @@ static int inet_diag_handler_cmd(struct sk_buff *skb, struct nlmsghdr *h)
 
 			attr = nlmsg_find_attr(h, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			err = inet_diag_bc_audit(attr);
+			err = inet_diag_bc_audit(attr, skb);
 			if (err)
 				return err;
 		}
-- 
2.8.0.rc3.226.g39d4020
