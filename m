From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Thu, 03 Mar 2011 11:23:28 -0800 (PST)
Message-ID: <20110303.112328.59677094.davem@davemloft.net>
References: <20110302.165421.258093056.davem@davemloft.net>
	<alpine.LFD.2.00.1103031414240.1677@ja.ssi.bg>
	<alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758536Ab1CCTWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 14:22:52 -0500
In-Reply-To: <alpine.LFD.2.00.1103031454060.2113@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 3 Mar 2011 15:09:22 +0200 (EET)

> On Thu, 3 Mar 2011, Julian Anastasov wrote:
> 
>> 	May be the problem is in inet_hash_insert(), it should
>> hash ifa_local, not ifa_address. May be they are equal for
> 
> 	... and of course the new __ip_dev_find should use
> ifa_local too.

Thanks for looking into this Julian.  I will look at the other
cases you found later.

Stephen, is this sufficient to fix your problem?  I suspect it is
not because fib_add_addr() adds prefixes with RTN_LOCAL to the
local routing table too :-/

I suspect that even if we need to handle prefixes, we can still use
the hash for optimistic lookup, and fallback to a local table FIB
inspection if that fails.

--------------------
ipv4: Fix __ip_dev_find() to use ifa_local instead of ifa_address.

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 9038928..ff53860 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -111,7 +111,7 @@ static inline unsigned int inet_addr_hash(struct net *net, __be32 addr)
 
 static void inet_hash_insert(struct net *net, struct in_ifaddr *ifa)
 {
-	unsigned int hash = inet_addr_hash(net, ifa->ifa_address);
+	unsigned int hash = inet_addr_hash(net, ifa->ifa_local);
 
 	spin_lock(&inet_addr_hash_lock);
 	hlist_add_head_rcu(&ifa->hash, &inet_addr_lst[hash]);
@@ -146,7 +146,7 @@ struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 
 		if (!net_eq(dev_net(dev), net))
 			continue;
-		if (ifa->ifa_address == addr) {
+		if (ifa->ifa_local == addr) {
 			result = dev;
 			break;
 		}
