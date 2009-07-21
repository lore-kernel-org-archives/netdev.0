From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH 1/1] ipv4: IP_RECVERR should also enqueue source quench messages
Date: Wed, 22 Jul 2009 01:32:07 +0200
Message-ID: <1248219127-3203-1-git-send-email-hagen@jauu.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:46173 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750729AbZGUXmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 19:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ICMP source quench messages are silently dropped and not
enqueued in a per-socket error queue. The socket option IP_RECVERR
enables a connected datagram socket to notice error conditions received
via ICMP. This modification allows applications to notice ICMP source
quench error condition too.

Side note: source quench are obsolete since day ~0 and are one of the
early design mistakes of the Internet. Anyway, this does not interfere
with the fact that a connected socket should not be informed about
received source quench messages.

Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/ipv4/raw.c |    3 ++-
 net/ipv4/udp.c |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2979f14..1d73953 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -229,7 +229,8 @@ static void raw_err(struct sock *sk, struct sk_buff *skb, u32 info)
 		err = EHOSTUNREACH;
 		break;
 	case ICMP_SOURCE_QUENCH:
-		return;
+		err = ENOBUFS;
+		break;
 	case ICMP_PARAMETERPROB:
 		err = EPROTO;
 		harderr = 1;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80e3812..ba4a4a8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -409,7 +409,8 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 		err = EHOSTUNREACH;
 		break;
 	case ICMP_SOURCE_QUENCH:
-		goto out;
+		err = ENOBUFS;
+		break;
 	case ICMP_PARAMETERPROB:
 		err = EPROTO;
 		harderr = 1;
-- 
1.6.3.GIT

