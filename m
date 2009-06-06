From: Sascha Hlusiak <contact@saschahlusiak.de>
Subject: [PATCH 3/3] sit: Translate ICMPv4 errors to ICMPv6, if possible
Date: Sat,  6 Jun 2009 16:02:52 +0200
Message-ID: <1244296972-20748-3-git-send-email-contact@saschahlusiak.de>
References: <1244296972-20748-1-git-send-email-contact@saschahlusiak.de>
 <1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
Cc: Sascha Hlusiak <contact@saschahlusiak.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:62555 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbZFFOA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2009 10:00:56 -0400
In-Reply-To: <1244296972-20748-2-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This partly reimplements, what was removed in 071f92d05.
If we receive enough ICMPv4 payload for an IPv6 header,
send the payload into the tunnel encapsulated in ICMPv6.

If we receive less payload and tunnel has a remote endpoint,
increase tunnel error count, resulting in a dst_link_failure.

If tunnel has no remote (6to4, isatap), we can't do anything
useful with the data, so let's drop it.

Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>
---
 net/ipv6/sit.c |   49 ++++++++++++++++++++++++++++++++++++++-----------
 1 files changed, 38 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 89d8369..c604b59 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -16,6 +16,7 @@
  * Nate Thompson <nate@thebog.net>:		6to4 support
  * Fred Templin <fred.l.templin@boeing.com>:	isatap support
  * Sascha Hlusiak <mail@saschahlusiak.de>:	stateless autoconf for isatap
+ *                                              better ICMPv4 handling
  */
 
 #include <linux/module.h>
@@ -475,16 +476,15 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 
 static int ipip6_err(struct sk_buff *skb, u32 info)
 {
-
-/* All the routers (except for Linux) return only
-   8 bytes of packet payload. It means, that precise relaying of
-   ICMP in the real Internet is absolutely infeasible.
- */
 	struct iphdr *iph = (struct iphdr*)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
 	int err;
+	const int hlen = iph->ihl << 2;
+	int rel_type = 0;
+	int rel_code = 0;
+	int rel_info = 0;
 
 	switch (type) {
 	default:
@@ -504,12 +504,16 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
 			   I believe they are just ether pollution. --ANK
 			 */
+			rel_type = ICMPV6_DEST_UNREACH;
+			rel_code = ICMPV6_ADDR_UNREACH;
 			break;
 		}
 		break;
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
 			return 0;
+		rel_type = ICMPV6_TIME_EXCEED;
+		rel_code = ICMPV6_EXC_HOPLIMIT;
 		break;
 	}
 
@@ -524,12 +528,35 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		goto out;
 
 	err = 0;
-
-	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
-		t->err_count++;
-	else
-		t->err_count = 1;
-	t->err_time = jiffies;
+	/* Most routers return only 8 bytes of packet payload.
+	   It means, that precise relaying of ICMP in the real
+	   Internet is absolutely infeasible
+
+	   If we get rfc1812 compliant ICMP packages, handle them properly,
+	   otherwise set tunnel error state, _if_ it has a remote endpoint.
+	   If it does not (6to4, isatap), possibly unrelated ICMPv6 messages
+	   might be sent in ipip6_tunnel_xmit, so better ignore it.
+	*/
+	if (skb->len - hlen >= sizeof(struct ipv6hdr)) {
+		struct ipv6hdr *iph6 = (struct ipv6hdr *)((u8*)iph + hlen);
+		struct sk_buff *skb2;
+
+		skb2 = skb_clone(skb, GFP_ATOMIC);
+		if (skb2 == NULL)
+			goto out;
+		skb_pull(skb2, (u8 *)iph6 - skb->data);
+		skb_reset_network_header(skb2);
+		skb2->dev = t->dev;
+		icmpv6_send(skb2, rel_type, rel_code, rel_info, skb2->dev);
+
+		kfree_skb(skb2);
+	} else if (t->parms.iph.daddr) {
+		if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
+			t->err_count++;
+		else
+			t->err_count = 1;
+		t->err_time = jiffies;
+	}
 out:
 	read_unlock(&ipip6_lock);
 	return err;
-- 
1.6.3.1

