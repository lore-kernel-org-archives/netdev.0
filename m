From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net 2/2] ipv6/udp: use sticky pktinfo egress ifindex on connect()
Date: Wed, 27 Jan 2016 14:45:59 +0100
Message-ID: <3ec9c8a2f92af7c3b285b40ab5ea06997088fd32.1453830778.git.pabeni@redhat.com>
References: <cover.1453830778.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Hajime Tazaki <thehajime@gmail.com>, lucien.xin@gmail.com,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932469AbcA0Nqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jan 2016 08:46:46 -0500
In-Reply-To: <cover.1453830778.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the egress interface index specified via IPV6_PKTINFO
is ignored by __ip6_datagram_connect(), so that RFC 3542 section 6.7
can be subverted when the user space application calls connect()
before sendmsg().
Fix it by initializing properly flowi6_oif in connect() before
performing the route lookup.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/datagram.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 517c55b..4281621 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -162,6 +162,9 @@ ipv4_connected:
 	fl6.fl6_dport = inet->inet_dport;
 	fl6.fl6_sport = inet->inet_sport;
 
+	if (!fl6.flowi6_oif)
+		fl6.flowi6_oif = np->sticky_pktinfo.ipi6_ifindex;
+
 	if (!fl6.flowi6_oif && (addr_type&IPV6_ADDR_MULTICAST))
 		fl6.flowi6_oif = np->mcast_oif;
 
-- 
1.8.3.1
