From: Patrick McHardy <kaber@trash.net>
Subject: [ICMP]: Fix icmp_errors_use_inbound_ifaddr sysctl
Date: Fri, 01 Jun 2007 19:24:18 +0200
Message-ID: <46605642.7060803@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040709040207000504020601"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36778 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759055AbXFARZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2007 13:25:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040709040207000504020601
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

It seems like you missed this patch in the previous thread discussing
the problem, so here's a resend.


--------------040709040207000504020601
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[ICMP]: Fix icmp_errors_use_inbound_ifaddr sysctl

Currently when icmp_errors_use_inbound_ifaddr is set and an ICMP error is
sent after the packet passed through ip_output(), an address from the
outgoing interface is chosen as ICMP source address since skb->dev doesn't
point to the incoming interface anymore.

Fix this by doing an interface lookup on rt->dst.iif and using that device.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit f680f41a1c6b2c358a4725e763132b3c61c1685a
tree 81f9cd86744aca6e7c2bc647639f7868d7ceb1d3
parent 19b6cbad06d246d48168fc6c493a7c3d9db58e1f
author Patrick McHardy <kaber@trash.net> Fri, 01 Jun 2007 19:22:21 +0200
committer Patrick McHardy <kaber@trash.net> Fri, 01 Jun 2007 19:22:21 +0200

 net/ipv4/icmp.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e238b17..02a899b 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -514,12 +514,15 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 
 	saddr = iph->daddr;
 	if (!(rt->rt_flags & RTCF_LOCAL)) {
-		/* This is broken, skb_in->dev points to the outgoing device
-		 * after the packet passes through ip_output().
-		 */
-		if (skb_in->dev && sysctl_icmp_errors_use_inbound_ifaddr)
-			saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
-		else
+		struct net_device *dev = NULL;
+
+		if (rt->fl.iif && sysctl_icmp_errors_use_inbound_ifaddr)
+			dev = dev_get_by_index(rt->fl.iif);
+
+		if (dev) {
+			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
+			dev_put(dev);
+		} else
 			saddr = 0;
 	}
 

--------------040709040207000504020601--
