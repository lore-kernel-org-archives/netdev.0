From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] [net-next] tcp: avoid sending zero TSval
Date: Mon, 31 Aug 2009 20:44:56 +0300
Message-ID: <200908312044.56235.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_YwAnKb27wATAJ3i"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:17327 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753301AbZHaRrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 13:47:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--Boundary-00=_YwAnKb27wATAJ3i
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit


Per RFC1323, zero TSecr is considered invalid. Thus we must avoid when
possible sending a zero TSval.

Currently, we use the least significant 32 bits of jiffies to fill in
TSval. But that can wrap around to zero (in 5 minutes after reboot,
and every 49 days after that in the worst case).

This patch approximate a wrap-around zero TSval to 1. This is better
then emitting a value which will be ignored.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/ipv4/tcp_output.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

--Boundary-00=_YwAnKb27wATAJ3i
Content-Type: text/x-patch;
  charset="utf-8";
  name="71e6d2ae2ae12cfaf0d7cb8e010fd0c7f520874b.diff"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline;
	filename="71e6d2ae2ae12cfaf0d7cb8e010fd0c7f520874b.diff"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4e00442..607d675 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -415,7 +415,10 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 				       (TCPOPT_TIMESTAMP << 8) |
 				       TCPOLEN_TIMESTAMP);
 		}
-		*ptr++ = htonl(opts->tsval);
+		/* Currently, opts->tsval always comes from tcp_time_stamp.
+		 * Thus, if zero, its caused by jiffie wrap-around, and we can
+		 * approximate it to one to avoid a later TSecr drop */
+		*ptr++ = htonl(opts->tsval?:1);
 		*ptr++ = htonl(opts->tsecr);
 	}
 

--Boundary-00=_YwAnKb27wATAJ3i--


