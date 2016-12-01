From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 2/2] tcp: allow to turn tcp timestamp randomization off
Date: Thu,  1 Dec 2016 11:32:07 +0100
Message-ID: <1480588327-2902-2-git-send-email-fw@strlen.de>
References: <1480588327-2902-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51602 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753933AbcLAKbz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 05:31:55 -0500
In-Reply-To: <1480588327-2902-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric says: "By looking at tcpdump, and TS val of xmit packets of multiple
flows, we can deduct the relative qdisc delays (think of fq pacing).
This should work even if we have one flow per remote peer."

Having random per flow (or host) offsets doesn't allow that anymore so add
a way to turn this off.

Suggested-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Yuchung Cheng <ycheng@google.com>
---
 change since v2:
 - make 2 the new 'non-random' mode, suggested by Yuchung.
 1 is now still the default but it will use per-offset randomization.

 Tested:
 sysctl_tcp_timestamps=2, tcpdump on lo, both ends have same ts value.

 change since v1: do check in secure_tcpv4/6_sequence_number so outgoing
 syn packets won't have a random offset either in if randomization is off.

 Documentation/networking/ip-sysctl.txt | 9 +++++++--
 net/core/secure_seq.c                  | 5 +++--
 net/ipv4/tcp_input.c                   | 1 +
 3 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5af48dd7c5fc..5ca567fa6b8c 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -610,8 +610,13 @@ tcp_syn_retries - INTEGER
 	with the current initial RTO of 1second. With this the final timeout
 	for an active TCP connection attempt will happen after 127seconds.
 
-tcp_timestamps - BOOLEAN
-	Enable timestamps as defined in RFC1323.
+tcp_timestamps - INTEGER
+Enable timestamps as defined in RFC1323.
+	0: Disabled.
+	1: Enable timestamps as defined in RFC1323 and use random offset for
+	each connection rather than only using the current time.
+	2: Like 1, but without random offsets.
+	Default: 1
 
 tcp_min_tso_segs - INTEGER
 	Minimal number of segments per TSO frame.
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index a8d6062cbb4a..88a8e429fc3e 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -12,6 +12,7 @@
 #include <net/secure_seq.h>
 
 #if IS_ENABLED(CONFIG_IPV6) || IS_ENABLED(CONFIG_INET)
+#include <net/tcp.h>
 #define NET_SECRET_SIZE (MD5_MESSAGE_BYTES / 4)
 
 static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
@@ -58,7 +59,7 @@ u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
 
 	md5_transform(hash, secret);
 
-	*tsoff = hash[1];
+	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
 	return seq_scale(hash[0]);
 }
 EXPORT_SYMBOL(secure_tcpv6_sequence_number);
@@ -100,7 +101,7 @@ u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
 
 	md5_transform(hash, net_secret);
 
-	*tsoff = hash[1];
+	*tsoff = sysctl_tcp_timestamps == 1 ? hash[1] : 0;
 	return seq_scale(hash[0]);
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2257de244622..fe668c1b9ced 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -85,6 +85,7 @@ int sysctl_tcp_dsack __read_mostly = 1;
 int sysctl_tcp_app_win __read_mostly = 31;
 int sysctl_tcp_adv_win_scale __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_tcp_adv_win_scale);
+EXPORT_SYMBOL(sysctl_tcp_timestamps);
 
 /* rfc5961 challenge ack rate limiting */
 int sysctl_tcp_challenge_ack_limit = 1000;
-- 
2.7.3
