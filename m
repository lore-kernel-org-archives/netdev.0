From: Patrick McHardy <kaber@trash.net>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Mon, 21 May 2007 19:03:24 +0200
Message-ID: <4651D0DC.6050203@trash.net>
References: <4648AE85.6020608@trash.net>	<4648B656.6030800@trash.net>	<464C884D.4010100@trash.net> <20070519.145042.105428414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070305000007060101090808"
Cc: netdev@vger.kernel.org, jmorris@namei.org, Curtis@GreenKey.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59480 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756883AbXEURFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 13:05:42 -0400
In-Reply-To: <20070519.145042.105428414.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070305000007060101090808
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

David Miller wrote:
> The post ip_output() case is very unfortunate.  Perhaps we
> can tag the call sites, or if that doesn't work we can
> find some way to perhaps tag the dst as an input vs. output
> route in order to avoid this problem.


Tagging call-sites should make sure we don't use an address from the
outgoing device, but we would still not always use an address from
the incoming device.

Thinking again, we can simply perform a lookup on rt->fl.iif, that
should always do the right thing.

Signed-off-by: Patrick McHardy <kaber@trash.net>



--------------070305000007060101090808
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

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
 

--------------070305000007060101090808--
