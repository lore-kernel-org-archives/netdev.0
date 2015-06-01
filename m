From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 14/14] arp: Associate ARP requests with tunnel info
Date: Mon,  1 Jun 2015 16:27:38 +0200
Message-ID: <d78d2546705d07a7ea4b0fa017e1c21f2cf3745c.1433167296.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51082 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981AbbFAO14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:56 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ARP performs its own route lookup call, eventually
returned tunnel metadata must be attached manually.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/arp.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 933a928..6cf0502 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -489,6 +489,7 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	unsigned char *arp_ptr;
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
+	struct rtable *rt;
 
 	/*
 	 *	Allocate a buffer
@@ -577,6 +578,13 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	}
 	memcpy(arp_ptr, &dest_ip, 4);
 
+	rt = ip_route_output(dev_net(dev), dest_ip, src_ip, 0, dev->ifindex);
+	if (!IS_ERR(rt)) {
+		if (rt->rt_tun_info)
+			skb_attach_tunnel_info(skb, rt->rt_tun_info);
+		ip_rt_put(rt);
+	}
+
 	return skb;
 
 out:
-- 
2.3.5
