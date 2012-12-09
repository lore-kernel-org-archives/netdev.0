From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] inet_diag: validate port comparison byte code to prevent unsafe reads
Date: Sun,  9 Dec 2012 16:03:00 -0500
Message-ID: <1355086980-30438-1-git-send-email-ncardwell@google.com>
Cc: edumazet@google.com, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f74.google.com ([209.85.215.74]:55623 "EHLO
	mail-la0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759023Ab2LIVKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 16:10:07 -0500
Received: by mail-la0-f74.google.com with SMTP id v3so131303lag.1
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 13:10:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add logic to verify that a port comparison byte code operation
actually has the second inet_diag_bc_op from which we read the port
for such operations.

Previously the code blindly referenced op[1] without first checking
whether a second inet_diag_bc_op struct could fit there. So a
malicious user could make the kernel read 4 bytes beyond the end of
the bytecode array by claiming to have a whole port comparison byte
code (2 inet_diag_bc_op structs) when in fact the bytecode was not
long enough to hold both.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
[Patch was generated relative to the previous 3-patch inet_diag patch series
 from last night.]
 net/ipv4/inet_diag.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 95f1a45..67746f5 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -557,6 +557,16 @@ static bool valid_hostcond(const struct inet_diag_bc_op *op, int len,
 	return true;
 }
 
+/* Validate a port comparison operator. */
+static inline bool valid_port_comparison(const struct inet_diag_bc_op *op,
+					 int len, int *min_len)
+{
+	/* Port comparisons put the port in a follow-on inet_diag_bc_op. */
+	*min_len += sizeof(struct inet_diag_bc_op);
+	if (len < *min_len)
+		return false;
+}
+
 static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 {
 	const void *bc = bytecode;
@@ -572,24 +582,30 @@ static int inet_diag_bc_audit(const void *bytecode, int bytecode_len)
 		case INET_DIAG_BC_D_COND:
 			if (!valid_hostcond(bc, len, &min_len))
 				return -EINVAL;
-			/* fall through */
-		case INET_DIAG_BC_AUTO:
+			break;
 		case INET_DIAG_BC_S_GE:
 		case INET_DIAG_BC_S_LE:
 		case INET_DIAG_BC_D_GE:
 		case INET_DIAG_BC_D_LE:
-		case INET_DIAG_BC_JMP:
-			if (op->no < min_len || op->no > len + 4 || op->no & 3)
-				return -EINVAL;
-			if (op->no < len &&
-			    !valid_cc(bytecode, bytecode_len, len - op->no))
+			if (!valid_port_comparison(bc, len, &min_len))
 				return -EINVAL;
 			break;
+		case INET_DIAG_BC_AUTO:
+		case INET_DIAG_BC_JMP:
 		case INET_DIAG_BC_NOP:
 			break;
 		default:
 			return -EINVAL;
 		}
+
+		if (op->code != INET_DIAG_BC_NOP) {
+			if (op->no < min_len || op->no > len + 4 || op->no & 3)
+				return -EINVAL;
+			if (op->no < len &&
+			    !valid_cc(bytecode, bytecode_len, len - op->no))
+				return -EINVAL;
+		}
+
 		if (op->yes < min_len || op->yes > len + 4 || op->yes & 3)
 			return -EINVAL;
 		bc  += op->yes;
-- 
1.7.7.3
