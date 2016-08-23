From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next 2/2] net: diag: allow socket bytecode filters to match socket marks
Date: Wed, 24 Aug 2016 03:06:11 +0900
Message-ID: <1471975571-26612-2-git-send-email-lorenzo@google.com>
References: <1471975571-26612-1-git-send-email-lorenzo@google.com>
Cc: eric.dumazet@gmail.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36150 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbcHWSGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:06:22 -0400
Received: by mail-pa0-f53.google.com with SMTP id di2so1997964pad.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:06:21 -0700 (PDT)
In-Reply-To: <1471975571-26612-1-git-send-email-lorenzo@google.com>
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
 net/ipv4/inet_diag.c           | 28 +++++++++++++++++++++++++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index abbd1dc..2939d65 100644
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
+	u32 mark;
+	u32 mask;
+};
+
 /* Base info structure. It contains socket identity (addrs/ports/cookie)
  * and, alas, the information shown by netstat. */
 struct inet_diag_msg {
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a835f94..f2a61f1 100644
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
@@ -713,10 +728,11 @@ static bool valid_markcond(const struct inet_diag_bc_op *op, int len,
 	return len >= *min_len;
 }
 
-static int inet_diag_bc_audit(struct nlattr *attr)
+static int inet_diag_bc_audit(struct nlattr *attr, const struct sk_buff *skb)
 {
 	const void *bytecode, *bc;
 	int bytecode_len, len;
+	bool net_admin = netlink_net_capable(skb, CAP_NET_ADMIN);
 
 	if (!attr || nla_len(attr) < sizeof(struct inet_diag_bc_op))
 		return -EINVAL;
@@ -745,6 +761,12 @@ static int inet_diag_bc_audit(struct nlattr *attr)
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
@@ -1037,7 +1059,7 @@ static int inet_diag_rcv_msg_compat(struct sk_buff *skb, struct nlmsghdr *nlh)
 
 			attr = nlmsg_find_attr(nlh, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			err = inet_diag_bc_audit(attr);
+			err = inet_diag_bc_audit(attr, skb);
 			if (err)
 				return err;
 		}
@@ -1068,7 +1090,7 @@ static int inet_diag_handler_cmd(struct sk_buff *skb, struct nlmsghdr *h)
 
 			attr = nlmsg_find_attr(h, hdrlen,
 					       INET_DIAG_REQ_BYTECODE);
-			err = inet_diag_bc_audit(attr);
+			err = inet_diag_bc_audit(attr, skb);
 			if (err)
 				return err;
 		}
-- 
2.8.0.rc3.226.g39d4020
