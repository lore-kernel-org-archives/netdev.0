From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net v2 1/3] gre: do not assign header_ops in collect metadata mode
Date: Sun, 24 Apr 2016 13:00:20 +0200
Message-ID: <bd50f4691e9edc28c5a9ec861863f7f6cf316077.1461495411.git.jbenc@redhat.com>
References: <cover.1461495411.git.jbenc@redhat.com>
Cc: Pravin B Shelar <pshelar@nicira.com>, Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770AbcDXLAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 07:00:43 -0400
In-Reply-To: <cover.1461495411.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ipgre mode (i.e. not gretap) with collect metadata flag set, the tunnel
is incorrectly assumed to be mGRE in NBMA mode (see commit 6a5f44d7a048c).
This is not the case, we're controlling the encapsulation addresses by
lwtunnel metadata. And anyway, assigning dev->header_ops in collect metadata
mode does not make sense.

Similarly, when a multicast remote IP address is set together with the
collect metadata flag, the processing described above would happen, too. As
there's not much sense in specifying remote/local IP address for lwtunnels,
reject such configuration.

v2: Reject configuration specifying both remote/local address and collect
    metadata flag.

Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index af5d1f38217f..c035b43b1d4b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
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
@@ -946,6 +947,15 @@ static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 	if (flags & (GRE_VERSION|GRE_ROUTING))
 		return -EINVAL;
 
+	if (data[IFLA_GRE_COLLECT_METADATA]) {
+		if (data[IFLA_GRE_REMOTE] &&
+		    nla_get_in_addr(data[IFLA_GRE_REMOTE]))
+			return -EINVAL;
+		if (data[IFLA_GRE_LOCAL] &&
+		    nla_get_in_addr(data[IFLA_GRE_LOCAL]))
+			return -EINVAL;
+	}
+
 	return 0;
 }
 
-- 
1.8.3.1
