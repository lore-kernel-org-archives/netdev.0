From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: secure_seq: Move net_secret_init() definition into CONFIG_IPV6 if block
Date: Sat,  5 Oct 2013 17:09:50 -0300
Message-ID: <1381003790-12731-1-git-send-email-festevam@gmail.com>
Cc: edumazet@google.com, hannes@strressinduktion.org,
	netdev@vger.kernel.org, olof@lixom.net,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f171.google.com ([209.85.213.171]:34940 "EHLO
	mail-ye0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab3JEUQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Oct 2013 16:16:07 -0400
Received: by mail-ye0-f171.google.com with SMTP id q3so1249148yen.30
        for <netdev@vger.kernel.org>; Sat, 05 Oct 2013 13:16:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Commit 9a3bab6b05 (net: net_secret should not depend on TCP) introduced
the following build warning when CONFIG_IPV6 is not selected:

net/core/secure_seq.c:17:13: warning: 'net_secret_init' defined but not used [-Wunused-function]

Fix it by moving net_secret_init(void) inside the '#if IS_ENABLED(CONFIG_IPV6)'
block.

Reported-by: Olof Johansson <olof@lixom.net>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/core/secure_seq.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3f1ec15..ee70541 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -10,6 +10,24 @@
 
 #include <net/secure_seq.h>
 
+#ifdef CONFIG_INET
+static u32 seq_scale(u32 seq)
+{
+	/*
+	 *	As close as possible to RFC 793, which
+	 *	suggests using a 250 kHz clock.
+	 *	Further reading shows this assumes 2 Mb/s networks.
+	 *	For 10 Mb/s Ethernet, a 1 MHz clock is appropriate.
+	 *	For 10 Gb/s Ethernet, a 1 GHz clock should be ok, but
+	 *	we also need to limit the resolution so that the u32 seq
+	 *	overlaps less than one time per MSL (2 minutes).
+	 *	Choosing a clock of 64 ns period is OK. (period of 274 s)
+	 */
+	return seq + (ktime_to_ns(ktime_get_real()) >> 6);
+}
+#endif
+
+#if IS_ENABLED(CONFIG_IPV6)
 #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
@@ -30,24 +48,6 @@ static void net_secret_init(void)
 	}
 }
 
-#ifdef CONFIG_INET
-static u32 seq_scale(u32 seq)
-{
-	/*
-	 *	As close as possible to RFC 793, which
-	 *	suggests using a 250 kHz clock.
-	 *	Further reading shows this assumes 2 Mb/s networks.
-	 *	For 10 Mb/s Ethernet, a 1 MHz clock is appropriate.
-	 *	For 10 Gb/s Ethernet, a 1 GHz clock should be ok, but
-	 *	we also need to limit the resolution so that the u32 seq
-	 *	overlaps less than one time per MSL (2 minutes).
-	 *	Choosing a clock of 64 ns period is OK. (period of 274 s)
-	 */
-	return seq + (ktime_to_ns(ktime_get_real()) >> 6);
-}
-#endif
-
-#if IS_ENABLED(CONFIG_IPV6)
 __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 				   __be16 sport, __be16 dport)
 {
-- 
1.8.1.2
