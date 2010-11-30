From: David McCullough <david_mccullough@mcafee.com>
Subject: [PATCH] net/ipv6/sit.c: return unhandled skb to tunnel4_rcv
Date: Tue, 30 Nov 2010 15:32:34 +1000
Message-ID: <20101130053234.GA28609@mcafee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sncsmrelay2.nai.com ([67.97.80.206]:33282 "EHLO
	sncsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab0K3FoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 00:44:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

I found a problem using an IPv6 over IPv4 tunnel.  When CONFIG_IPV6_SIT
was enabled, the packets would be rejected as net/ipv6/sit.c was catching
all IPPROTO_IPV6 packets and returning an ICMP port unreachable error.

I think this patch fixes the problem cleanly.  I believe the code in
net/ipv4/tunnel4.c:tunnel4_rcv takes care of it properly if none of the
handlers claim the skb.

Patch is against 2.6.35,  bit still applies to current.

Cheers,
Davidm

Signed-off-by: David McCullough <david_mccullough@mcafee.com>

diff -u -r1.1.1.45 sit.c
--- a/net/ipv6/sit.c	12 Aug 2010 00:16:26 -0000	1.1.1.45
+++ b/net/ipv6/sit.c	30 Nov 2010 05:01:19 -0000
@@ -575,8 +575,9 @@
 		return 0;
 	}
 
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+	/* no tunnel matched,  let upstream know, ipsec may handle it */
 	rcu_read_unlock();
+	return 1;
 out:
 	kfree_skb(skb);
 	return 0;

-- 
David McCullough,      david_mccullough@mcafee.com,  Ph:+61 734352815
McAfee - SnapGear      http://www.mcafee.com         http://www.uCdot.org
