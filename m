From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/2] net: check for underlength tap writes
Date: Sat, 5 Apr 2008 21:54:33 +1000
Message-ID: <200804052154.33636.rusty@rustcorp.com.au>
References: <200804052153.55676.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60837 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbYDELzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Apr 2008 07:55:00 -0400
In-Reply-To: <200804052153.55676.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user gives a packet under 14 bytes, we'll end up reading off the end
of the skb (not oopsing, just reading off the end).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff -r 99132ad16999 drivers/net/tun.c
--- a/drivers/net/tun.c	Sat Apr 05 21:20:32 2008 +1100
+++ b/drivers/net/tun.c	Sat Apr 05 22:47:20 2008 +1100
@@ -286,8 +286,11 @@ static __inline__ ssize_t tun_get_user(s
 			return -EFAULT;
 	}
 
-	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV)
+	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
 		align = NET_IP_ALIGN;
+		if (unlikely(len < ETH_HLEN))
+			return -EINVAL;
+	}
 
 	if (!(skb = alloc_skb(len + align, GFP_KERNEL))) {
 		tun->dev->stats.rx_dropped++;
