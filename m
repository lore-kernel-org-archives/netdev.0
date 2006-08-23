From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 21/44] [IPV6] MIP6: Add socket option and ancillary data interface of routing header type 2.
Date: Thu, 24 Aug 2006 00:02:22 +0900
Message-ID: <11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:3977 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964933AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add socket option and ancillary data interface of routing header type 2.
Mobile IPv6 application will use this to send binding acknowledgement
with the header without relation of confirmed route optimization (binding).
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/datagram.c      |   11 +++++++----
 net/ipv6/ipv6_sockglue.c |   10 +++++++++-
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 79ebbec..c98acd8 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -643,10 +643,13 @@ int datagram_send_ctl(struct msghdr *msg
 
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
index 4332726..241f7dc 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -407,8 +407,16 @@ static int do_ipv6_setsockopt(struct soc
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
1.4.0

