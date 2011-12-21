From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] netlink: wake up netlink listeners sooner
Date: Wed, 21 Dec 2011 13:49:44 -0800
Message-ID: <20111221134944.52223cdf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50874 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab1LUVuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Dec 2011 16:50:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A netlink listening task (such as Quagga/zebra) can easily get overrun
when lots of events happen such as a link state transition with full BGP route
table. This happens because the sender does not yield to the receiver
(unless socket queue is full). The problem is exacerbated because it is
typical for listeners to set large receive buffer to attempt to keep up.

This patch changes it to yield sooner at halfway instead. Still not a cure-all
for listener overrun if listener is slow, but works much reliably.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/netlink/af_netlink.c	2011-12-20 10:25:19.364247598 -0800
+++ b/net/netlink/af_netlink.c	2011-12-20 10:25:46.756570010 -0800
@@ -960,7 +960,7 @@ static int netlink_broadcast_deliver(str
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
-		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf;
+		return atomic_read(&sk->sk_rmem_alloc) > sk->sk_rcvbuf / 2;
 	}
 	return -1;
 }
