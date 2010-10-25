From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related to POSTDAD state
Date: Mon, 25 Oct 2010 11:06:43 +0200
Message-ID: <20101025090716.315678235@linux.vnet.ibm.com>
References: <20101025090642.958260964@linux.vnet.ibm.com>
Cc: vosburgh@de.ibm.com, Ursula Braun <ursula.braun@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:54986 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663Ab0JYJHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 05:07:18 -0400
Content-Disposition: inline; filename=addrconf.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [patch 1/1] [PATCH BUG_FIX] ipv6: fix refcnt problem related to POSTDAD state

From: Ursula Braun <ursula.braun@de.ibm.com>

After running this bonding setup script
    modprobe bonding miimon=100 mode=0 max_bonds=1
    ifconfig bond0 10.1.1.1/16
    ifenslave bond0 eth1
    ifenslave bond0 eth3
on s390 with qeth-driven slaves, modprobe -r fails with this message
    unregister_netdevice: waiting for bond0 to become free. Usage count = 1
due to twice detection of duplicate address.
Problem is caused by a missing decrease of ifp->refcnt in addrconf_dad_failure.
An extra call of in6_ifa_put(ifp) solves it.
Problem has been introduced with commit f2344a131bccdbfc5338e17fa71a807dee7944fa.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Herbert Xu <herbert@gondor.apana.org.au>

---
 net/ipv6/addrconf.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1426,8 +1426,10 @@ void addrconf_dad_failure(struct inet6_i
 {
 	struct inet6_dev *idev = ifp->idev;
 
-	if (addrconf_dad_end(ifp))
+	if (addrconf_dad_end(ifp)) {
+		in6_ifa_put(ifp);
 		return;
+	}
 
 	if (net_ratelimit())
 		printk(KERN_INFO "%s: IPv6 duplicate address %pI6c detected!\n",

