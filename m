From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/3] gre: do not assign header_ops in collect metadata mode
Date: Fri, 22 Apr 2016 19:44:06 +0200
Message-ID: <7c34e7243a146fc5ccdf6349892355746741ff26.1461346798.git.jbenc@redhat.com>
References: <cover.1461346798.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48196 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932345AbcDVRoV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 13:44:21 -0400
In-Reply-To: <cover.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipgre mode (i.e. not gretap) with collect metadata flag set, the tunnel
is incorrectly assumed to be mGRE in NBMA mode (see commit 6a5f44d7a048c).
This is not the case, we're controlling the encapsulation addresses by
lwtunnel metadata. And anyway, assigning dev->header_ops in collect metadata
mode does not make sense.

Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index af5d1f38217f..d0abde4236af 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -893,7 +893,7 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	netif_keep_dst(dev);
 	dev->addr_len		= 4;
 
-	if (iph->daddr) {
+	if (iph->daddr && !tunnel->collect_md) {
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (ipv4_is_multicast(iph->daddr)) {
 			if (!iph->saddr)
@@ -902,8 +902,9 @@ static int ipgre_tunnel_init(struct net_device *dev)
 			dev->header_ops = &ipgre_header_ops;
 		}
 #endif
-	} else
+	} else if (!tunnel->collect_md) {
 		dev->header_ops = &ipgre_header_ops;
+	}
 
 	return ip_tunnel_init(dev);
 }
-- 
1.8.3.1
