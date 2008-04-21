From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS]: The ip6_fib_timer can work with garbage on net namespace
 stop.
Date: Mon, 21 Apr 2008 17:05:50 +0400
Message-ID: <480C912E.70900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33054 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756463AbYDUNH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 09:07:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The del_timer() function doesn't guarantee, that the timer callback
is not active by the time it exits.

Thus, the fib6_net_exit() may kfree() all the data, that is required
by the fib6_run_gc(). The race window is tiny, but slab poisoning can
trigger this bug.

Using del_timer_sync() will cure this.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 50f3f8f..1ee4fa1 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1543,7 +1543,7 @@ out_timer:
 static void fib6_net_exit(struct net *net)
 {
 	rt6_ifdown(net, NULL);
-	del_timer(net->ipv6.ip6_fib_timer);
+	del_timer_sync(net->ipv6.ip6_fib_timer);
 	kfree(net->ipv6.ip6_fib_timer);
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 	kfree(net->ipv6.fib6_local_tbl);
