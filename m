From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 5/20] [PATCH] [IPV6] MIP6: Add socket option and ancillary data interface of routing header type 2.
Date: Sat, 29 Jul 2006 18:38:25 +0900
Message-ID: <1154165905443-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:39555 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422713AbWG2Ji0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:26 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add socket option and ancillary data interface of routing header type 2.
Mobile IPv6 application will use this to send binding acknowledgement
with the header without relation of confirmed route optimization (binding).
Based on MIPL2 kernel patch.
---
 net/ipv6/datagram.c      |   11 +++++++----
 net/ipv6/ipv6_sockglue.c |   10 +++++++++-
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 99a6eb2..063a74e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -641,10 +641,13 @@ int datagram_send_ctl(struct msghdr *msg
 
 			rthdr = (struct ipv6_rt_hdr *)CMSG_DATA(cmsg);
 
-			/*
-			 *	TYPE 0
-			 */
-			if (rthdr->type) {
+			switch (rthdr->type) {
+			case IPV6_SRCRT_TYPE_0:
+#ifdef CONFIG_IPV6_MIP6
+			case IPV6_SRCRT_TYPE_2:
+#endif
+				break;
+			default:
 				err = -EINVAL;
 				goto exit_f;
 			}
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 4c20eeb..68c1512 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -304,8 +304,16 @@ static int do_ipv6_setsockopt(struct soc
 		/* routing header option needs extra check */
 		if (optname == IPV6_RTHDR && opt->srcrt) {
 			struct ipv6_rt_hdr *rthdr = opt->srcrt;
-			if (rthdr->type)
+			switch (rthdr->type) {
+			case IPV6_SRCRT_TYPE_0:
+#ifdef CONFIG_IPV6_MIP6
+			case IPV6_SRCRT_TYPE_2:
+#endif
+				break;
+			default:
 				goto sticky_done;
+			}
+
 			if ((rthdr->hdrlen & 1) ||
 			    (rthdr->hdrlen >> 1) != rthdr->segments_left)
 				goto sticky_done;
-- 
1.4.1

