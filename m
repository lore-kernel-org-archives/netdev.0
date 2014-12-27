From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netlink: call cond_resched after broadcasting updates
Date: Sat, 27 Dec 2014 09:54:33 -0800
Message-ID: <20141227095433.00333deb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36146 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaL0Rym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 12:54:42 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so14715516pad.24
        for <netdev@vger.kernel.org>; Sat, 27 Dec 2014 09:54:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a netlink event is posted to a socket, the receiving process maybe
waiting to wakeup. Reduce the latency by calling cond_resched() in this
loop. This reduces the problems with missed events during a netlink
storm such as when a routing daemon does mass update in response to
a link transition.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/netlink/af_netlink.c	2014-12-27 09:43:06.705792634 -0800
+++ b/net/netlink/af_netlink.c	2014-12-27 09:43:06.705792634 -0800
@@ -1983,8 +1983,10 @@ int netlink_broadcast_filtered(struct so
 
 	netlink_lock_table();
 
-	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list)
+	sk_for_each_bound(sk, &nl_table[ssk->sk_protocol].mc_list) {
 		do_one_broadcast(sk, &info);
+		cond_resched();
+	}
 
 	consume_skb(skb);
 
