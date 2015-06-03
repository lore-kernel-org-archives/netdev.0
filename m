From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: [PATCH v2] ipv4/udp: Verify multicast group is ours in upd_v4_early_demux()
Date: Wed,  3 Jun 2015 16:27:38 -0500
Message-ID: <1433366858-14317-1-git-send-email-shawn.bohrer@gmail.com>
References: <556CBC7E.2050005@cogentembedded.com>
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	Alexandra.Kossovsky@oktetlabs.ru,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Oliver Graff <oliver.e.graff@gmail.com>, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:32781 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbbFCV1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 17:27:49 -0400
Received: by obbea3 with SMTP id ea3so18647363obb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 14:27:47 -0700 (PDT)
In-Reply-To: <556CBC7E.2050005@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>

421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
demux" introduced a regression that allowed sockets bound to INADDR_ANY
to receive packets from multicast groups that the socket had not joined.
For example a socket that had joined 224.168.2.9 could also receive
packets from 225.168.2.9 despite not having joined that group if
ip_early_demux is enabled.

Fix this by calling ip_check_mc_rcu() in udp_v4_early_demux() to verify
that the multicast packet is indeed ours.

Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
---

Coding style fixes.  Added braces around if branches, and inverted logic
to avoid long lines.

 net/ipv4/udp.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d10b7e0..df1b285 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -90,6 +90,7 @@
 #include <linux/socket.h>
 #include <linux/sockios.h>
 #include <linux/igmp.h>
+#include <linux/inetdevice.h>
 #include <linux/in.h>
 #include <linux/errno.h>
 #include <linux/timer.h>
@@ -1962,6 +1963,7 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	struct sock *sk;
 	struct dst_entry *dst;
 	int dif = skb->dev->ifindex;
+	int ours;
 
 	/* validate the packet */
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + sizeof(struct udphdr)))
@@ -1971,14 +1973,24 @@ void udp_v4_early_demux(struct sk_buff *skb)
 	uh = udp_hdr(skb);
 
 	if (skb->pkt_type == PACKET_BROADCAST ||
-	    skb->pkt_type == PACKET_MULTICAST)
+	    skb->pkt_type == PACKET_MULTICAST) {
+		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+
+		if (!in_dev)
+			return;
+
+		ours = ip_check_mc_rcu(in_dev, iph->daddr, iph->saddr,
+				       iph->protocol);
+		if (!ours)
+			return;
 		sk = __udp4_lib_mcast_demux_lookup(net, uh->dest, iph->daddr,
 						   uh->source, iph->saddr, dif);
-	else if (skb->pkt_type == PACKET_HOST)
+	} else if (skb->pkt_type == PACKET_HOST) {
 		sk = __udp4_lib_demux_lookup(net, uh->dest, iph->daddr,
 					     uh->source, iph->saddr, dif);
-	else
+	} else {
 		return;
+	}
 
 	if (!sk)
 		return;
-- 
1.9.3
