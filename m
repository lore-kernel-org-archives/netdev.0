From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH v2] cipso: handle CIPSO options correctly when NetLabel is
 disabled
Date: Fri, 01 Jun 2012 11:54:56 -0400
Message-ID: <20120601155456.5114.68007.stgit@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964952Ab2FAPzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Jun 2012 11:55:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When NetLabel is not enabled, e.g. CONFIG_NETLABEL=n, and the system
receives a CIPSO tagged packet it is dropped (cipso_v4_validate()
returns non-zero).  In most cases this is the correct and desired
behavior, however, in the case where we are simply forwarding the
traffic, e.g. acting as a network bridge, this becomes a problem.

This patch fixes the forwarding problem by providing the basic CIPSO
validation code directly in ip_options_compile() without the need for
the NetLabel or CIPSO code.  The new validation code can not perform
any of the CIPSO option label/value verification that
cipso_v4_validate() does, but it can verify the basic CIPSO option
format.

The behavior when NetLabel is enabled is unchanged.

CC: stable@vger.kernel.org
Signed-off-by: Paul Moore <pmoore@redhat.com>

--
ChangeLog
-v2
 * Moved the CONFIG_NETLABEL=n code into cipso_ipv4.h
-v1
 * Initial version
---
 include/net/cipso_ipv4.h |   29 ++++++++++++++++++++++++++++-
 1 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/include/net/cipso_ipv4.h b/include/net/cipso_ipv4.h
index 9808877..a7a683e 100644
--- a/include/net/cipso_ipv4.h
+++ b/include/net/cipso_ipv4.h
@@ -42,6 +42,7 @@
 #include <net/netlabel.h>
 #include <net/request_sock.h>
 #include <linux/atomic.h>
+#include <asm/unaligned.h>
 
 /* known doi values */
 #define CIPSO_V4_DOI_UNKNOWN          0x00000000
@@ -285,7 +286,33 @@ static inline int cipso_v4_skbuff_getattr(const struct sk_buff *skb,
 static inline int cipso_v4_validate(const struct sk_buff *skb,
 				    unsigned char **option)
 {
-	return -ENOSYS;
+	unsigned char *opt = *option;
+	unsigned char err_offset = 0;
+	u8 opt_len = opt[1];
+	u8 opt_iter;
+
+	if (opt_len < 8) {
+		err_offset = 1;
+		goto out;
+	}
+
+	if (get_unaligned_be32(&opt[2]) == 0) {
+		err_offset = 2;
+		goto out;
+	}
+
+	for (opt_iter = 6; opt_iter < opt_len;) {
+		if (opt[opt_iter + 1] > (opt_len - opt_iter)) {
+			err_offset = opt_iter + 1;
+			goto out;
+		}
+		opt_iter += opt[opt_iter + 1];
+	}
+
+out:
+	*option = opt + err_offset;
+	return err_offset;
+
 }
 #endif /* CONFIG_NETLABEL */
 
