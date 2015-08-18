From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] lwtunnel: ip tunnel: fix multiple routes with different encap
Date: Tue, 18 Aug 2015 18:42:09 +0200
Message-ID: <fe9cdcf34e26de1e9107f964c3e6612dcaf13662.1439916029.git.jbenc@redhat.com>
References: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753342AbbHRQm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 12:42:29 -0400
In-Reply-To: <54251151b649756a3aa6f30c8fafe2357150f5ee.1439916029.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, two routes going through the same tunnel interface are considered
the same even when they are routed to a different host after encapsulation.
This causes all routes added after the first one to have incorrect
encapsulation parameters.

This is nicely visible by doing:

  # ip r a 192.168.1.2/32 dev vxlan0 tunnel dst 10.0.0.2
  # ip r a 192.168.1.3/32 dev vxlan0 tunnel dst 10.0.0.3
  # ip r
  [...]
  192.168.1.2/32 tunnel id 0 src 0.0.0.0 dst 10.0.0.2 [...]
  192.168.1.3/32 tunnel id 0 src 0.0.0.0 dst 10.0.0.2 [...]

Implement the missing comparison function.

Fixes: 3093fbe7ff4bc ("route: Per route IP tunnel metadata via lightweight tunnel")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_tunnel_core.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index fd6319681c50..1c2389d582a6 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -286,10 +286,17 @@ static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 		+ nla_total_size(2);	/* LWTUNNEL_IP_FLAGS */
 }
 
+static int ip_tun_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b)
+{
+	return memcmp(lwt_tun_info(a), lwt_tun_info(b),
+		      sizeof(struct ip_tunnel_info));
+}
+
 static const struct lwtunnel_encap_ops ip_tun_lwt_ops = {
 	.build_state = ip_tun_build_state,
 	.fill_encap = ip_tun_fill_encap_info,
 	.get_encap_size = ip_tun_encap_nlsize,
+	.cmp_encap = ip_tun_cmp_encap,
 };
 
 void __init ip_tunnel_core_init(void)
-- 
1.8.3.1
