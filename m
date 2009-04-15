From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: remove superfluous call to synchronize_net()
Date: Wed, 15 Apr 2009 17:38:06 +0200
Message-ID: <49E5FF5E.50409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43716 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbZDOPiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 11:38:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_register_protosw() is adding inet_protosw to inetsw[] with appropriate
locking section and rcu variant. No need to call synchronize_net() to wait
for a RCU grace period. Changes are immediatly visible to other cpus anyway.

This saves about 13 ms on boot time on a HZ=1000 8 cpus machine ;)
(4 calls to inet_register_protosw(), and about 3200 us per call)

But more seriously, we should audit all synchronize_{rcu|net}() calls
to make sure we dont waste time and hide some bugs because of artificial
delays.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f03373..1706896 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1003,8 +1003,6 @@ void inet_register_protosw(struct inet_protosw *p)
 out:
 	spin_unlock_bh(&inetsw_lock);
 
-	synchronize_net();
-
 	return;
 
 out_permanent:
