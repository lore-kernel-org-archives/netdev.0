From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 19/20] [PATCH] [IPV6] MIP6: Add sending mobility header functions through raw socket.
Date: Sat, 29 Jul 2006 18:39:07 +0900
Message-ID: <11541659472134-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:53891 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422722AbWG2JjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:39:08 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mobility header is built by user-space and sent through raw socket.
Kernel just extracts its type to flow.
Based on MIPL2 kernel patch.
---
 net/ipv6/raw.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e0faf4d..0e8dca2 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -608,6 +608,9 @@ static void rawv6_probe_proto_opt(struct
 	struct iovec *iov;
 	u8 __user *type = NULL;
 	u8 __user *code = NULL;
+#ifdef CONFIG_IPV6_MIP6
+	u8 len = 0;
+#endif
 	int probed = 0;
 	int i;
 
@@ -639,6 +642,20 @@ static void rawv6_probe_proto_opt(struct
 				probed = 1;
 			}
 			break;
+#ifdef CONFIG_IPV6_MIP6
+		case IPPROTO_MH:
+			if (iov->iov_base && iov->iov_len < 1)
+				break;
+			/* check if type field is readable or not. */
+			if (iov->iov_len > 2 - len) {
+				u8 __user *p = iov->iov_base;
+				get_user(fl->fl_mh_type, &p[2 - len]);
+				probed = 1;
+			} else
+				len += iov->iov_len;
+
+			break;
+#endif
 		default:
 			probed = 1;
 			break;
-- 
1.4.1

