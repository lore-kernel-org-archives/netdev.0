From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: diag: Add support to filter on device index
Date: Thu, 23 Jun 2016 18:42:51 -0700
Message-ID: <1466732571-31133-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:32977 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcFXBnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 21:43:00 -0400
Received: by mail-pa0-f49.google.com with SMTP id b13so32485565pat.0
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 18:42:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to inet_diag facility to filter sockets based on device
index. If an interface index is in the filter only sockets bound
to that index (sk_bound_dev_if) are returned.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/inet_diag.h |  1 +
 net/ipv4/inet_diag.c           | 25 +++++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index a16643705669..abbd1dc5d683 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -72,6 +72,7 @@ enum {
 	INET_DIAG_BC_AUTO,
 	INET_DIAG_BC_S_COND,
 	INET_DIAG_BC_D_COND,
+	INET_DIAG_BC_DEV_COND,   /* u32 ifindex */
 };
 
 struct inet_diag_hostcond {
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 25af1243649b..38c2c47fe0e8 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -44,6 +44,7 @@ struct inet_diag_entry {
 	u16 dport;
 	u16 family;
 	u16 userlocks;
+	u32 ifindex;
 };
 
 static DEFINE_MUTEX(inet_diag_table_mutex);
@@ -571,6 +572,14 @@ static int inet_diag_bc_run(const struct nlattr *_bc,
 			yes = 0;
 			break;
 		}
+		case INET_DIAG_BC_DEV_COND: {
+			u32 ifindex;
+
+			ifindex = *((const u32 *)(op + 1));
+			if (ifindex != entry->ifindex)
+				yes = 0;
+			break;
+		}
 		}
 
 		if (yes) {
@@ -613,6 +622,7 @@ int inet_diag_bc_sk(const struct nlattr *bc, struct sock *sk)
 	entry_fill_addrs(&entry, sk);
 	entry.sport = inet->inet_num;
 	entry.dport = ntohs(inet->inet_dport);
+	entry.ifindex = sk->sk_bound_dev_if;
 	entry.userlocks = sk_fullsock(sk) ? sk->sk_userlocks : 0;
 
 	return inet_diag_bc_run(bc, &entry);
@@ -636,6 +646,17 @@ static int valid_cc(const void *bc, int len, int cc)
 	return 0;
 }
 
+/* data is u32 ifindex */
+static bool valid_devcond(const struct inet_diag_bc_op *op, int len,
+			  int *min_len)
+{
+	/* Check ifindex space. */
+	*min_len += sizeof(u32);
+	if (len < *min_len)
+		return false;
+
+	return true;
+}
 /* Validate an inet_diag_hostcond. */
 static bool valid_hostcond(const struct inet_diag_bc_op *op, int len,
 			   int *min_len)
@@ -700,6 +721,10 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 			if (!valid_hostcond(bc, len, &min_len))
 				return -EINVAL;
 			break;
+		case INET_DIAG_BC_DEV_COND:
+			if (!valid_devcond(bc, len, &min_len))
+				return -EINVAL;
+			break;
 		case INET_DIAG_BC_S_GE:
 		case INET_DIAG_BC_S_LE:
 		case INET_DIAG_BC_D_GE:
-- 
2.1.4
