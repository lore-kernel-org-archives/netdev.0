From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : align inet_protos[] on SMP
Date: Tue, 27 Mar 2007 15:47:04 +0200
Message-ID: <20070327154704.cd85d943.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:33833 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753861AbXC0NrG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:47:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As IPPROTO_TCP is 6, it makes sense to make sure inet_protos[] array is properly cache line aligned to avoid false sharing on SMP.

c0680540 b peer_total
c0680544 b inet_peer_unused_head
c0680560 B inet_protos

On i386 this example, we can see that inet_protos[IPPROTO_TCP] shares a potentially hot (and modified) cache line.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index da70fef..971ab93 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -45,7 +45,7 @@ #include <net/udp.h>
 #include <net/ipip.h>
 #include <linux/igmp.h>
 
-struct net_protocol *inet_protos[MAX_INET_PROTOS];
+struct net_protocol *inet_protos[MAX_INET_PROTOS] ____cacheline_aligned_in_smp;
 static DEFINE_SPINLOCK(inet_proto_lock);
 
 /*
