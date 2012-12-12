From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] net: filter: return -EINVAL if BPF_S_ANC* operation is not supported
Date: Wed, 12 Dec 2012 10:31:41 +0100
Message-ID: <1355304701-22228-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Ani Sinha <ani@aristanetworks.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814Ab2LLJcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 04:32:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we return -EINVAL for malicious or wrong BPF filters.
However, this is not done for BPF_S_ANC* operations, which makes it
more difficult to detect if it's actually supported or not by the
BPF machine. Therefore, we should also return -EINVAL if K is within
the SKF_AD_OFF universe and the ancillary operation did not match.

Cc: Ani Sinha <ani@aristanetworks.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/filter.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index c23543c..de9bed4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -531,7 +531,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
 		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
 	};
-	int pc;
+	int pc, anc_found;
 
 	if (flen == 0 || flen > BPF_MAXINSNS)
 		return -EINVAL;
@@ -592,8 +592,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		case BPF_S_LD_W_ABS:
 		case BPF_S_LD_H_ABS:
 		case BPF_S_LD_B_ABS:
+			anc_found = 0;
 #define ANCILLARY(CODE) case SKF_AD_OFF + SKF_AD_##CODE:	\
 				code = BPF_S_ANC_##CODE;	\
+				anc_found = 1;			\
 				break
 			switch (ftest->k) {
 			ANCILLARY(PROTOCOL);
@@ -610,6 +612,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			ANCILLARY(VLAN_TAG);
 			ANCILLARY(VLAN_TAG_PRESENT);
 			}
+
+			/* ancillary operation unkown or unsupported */
+			if (anc_found == 0 && ftest->k >= SKF_AD_OFF)
+				return -EINVAL;
 		}
 		ftest->code = code;
 	}
-- 
1.7.11.7
