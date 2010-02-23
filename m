From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] IPv6: don't forward unspecified frames
Date: Mon, 22 Feb 2010 17:31:53 -0800
Message-ID: <20100222173153.79190176@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48680 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260Ab0BWBcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 20:32:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This showed up during UNH IPv6 conformance tests. It appears kernel
incorrectly forwards packets with unspecified source address.

This looks like the place to fix this, but still not sure and have
no easy way to test it since ping6 won't send packet with unspecified
source address.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/ip6_output.c	2010-02-19 15:05:51.332330381 -0800
+++ b/net/ipv6/ip6_output.c	2010-02-19 15:10:28.400092910 -0800
@@ -436,6 +436,17 @@ int ip6_forward(struct sk_buff *skb)
 	}
 
 	/*
+	 * RFC4291 2.5.2
+	 *
+	 * An IPv6 packet with a source address of unspecified
+	 * must never be forwarded by an IPv6 router.
+	 */
+	if (ipv6_addr_any(&hdr->saddr)) {
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTDISCARDS);
+		goto drop;
+	}
+
+	/*
 	 *	check and decrement ttl
 	 */
 	if (hdr->hop_limit <= 1) {
