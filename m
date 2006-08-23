From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 33/44] [IPV6] MIP6: Add sending mobility header functions through raw socket.
Date: Thu, 24 Aug 2006 00:02:34 +0900
Message-ID: <11563453672959-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org> <11563453671174-git-send-email-yoshfuji@linux-ipv6.org> <11563453674049-git-send-email-yoshfuji@linux-ipv6.org> <11563453673517-git-send-email-yoshfuji@linux-ipv6.org> <11563453674137-git-send-email-yoshfuji@linux-ipv6.org> <11563453671944-git-send-email-yoshfuji@linux-ipv6.org> <11
 563453671187-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:8585 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964949AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453671187-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Mobility header is built by user-space and sent through raw socket.
Kernel just extracts its type to flow.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/raw.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 2178a2a..87b0adc 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -609,6 +609,9 @@ static void rawv6_probe_proto_opt(struct
 	struct iovec *iov;
 	u8 __user *type = NULL;
 	u8 __user *code = NULL;
+#ifdef CONFIG_IPV6_MIP6
+	u8 len = 0;
+#endif
 	int probed = 0;
 	int i;
 
@@ -640,6 +643,20 @@ static void rawv6_probe_proto_opt(struct
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
1.4.0

