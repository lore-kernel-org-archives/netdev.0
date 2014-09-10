From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] ipv6: clean up anycast when an interface is destroyed
Date: Wed, 10 Sep 2014 12:27:14 +0200
Message-ID: <20140910102714.GB21267@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:25923 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbaIJK1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2014 06:27:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we try to rmmod the driver for an interface while sockets with
setsockopt(JOIN_ANYCAST) are alive, some refcounts aren't cleaned up
and we get stuck on:

  unregister_netdevice: waiting for ens3 to become free. Usage count = 1

If we LEAVE_ANYCAST/close everything before rmmod'ing, there is no
problem.

We need to perform a cleanup similar to the one for multicast in
addrconf_ifdown(how == 1).

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
The problem is also present on a 3.2 and 3.16 kernel, and most likely
everything in between.

 include/net/addrconf.h |  1 +
 net/ipv6/addrconf.c    |  8 +++++---
 net/ipv6/anycast.c     | 22 ++++++++++++++++++++++
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f679877bb601..ec51e673b4b6 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -204,6 +204,7 @@ void ipv6_sock_ac_close(struct sock *sk);
 
 int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
 int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
+void ipv6_ac_destroy_dev(struct inet6_dev *idev);
 bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 			 const struct in6_addr *addr);
 bool ipv6_chk_acast_addr_src(struct net *net, struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fc1fac2a0528..3342ee64f2e3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3094,11 +3094,13 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 	write_unlock_bh(&idev->lock);
 
-	/* Step 5: Discard multicast list */
-	if (how)
+	/* Step 5: Discard anycast and multicast list */
+	if (how) {
+		ipv6_ac_destroy_dev(idev);
 		ipv6_mc_destroy_dev(idev);
-	else
+	} else {
 		ipv6_mc_down(idev);
+	}
 
 	idev->tstamp = jiffies;
 
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index ff2de7d9d8e6..a1bf80574bfe 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -351,6 +351,28 @@ static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr)
 	return __ipv6_dev_ac_dec(idev, addr);
 }
 
+/* Device is being destroyed: clean up */
+void ipv6_ac_destroy_dev(struct inet6_dev *idev)
+{
+	struct ifacaddr6 *aca;
+
+	write_lock_bh(&idev->lock);
+	while ((aca = idev->ac_list) != NULL) {
+		idev->ac_list = aca->aca_next;
+		write_unlock_bh(&idev->lock);
+
+		addrconf_leave_solict(idev, &aca->aca_addr);
+
+		dst_hold(&aca->aca_rt->dst);
+		ip6_del_rt(aca->aca_rt);
+
+		aca_put(aca);
+
+		write_lock_bh(&idev->lock);
+	}
+	write_unlock_bh(&idev->lock);
+}
+
 /*
  *	check if the interface has this anycast address
  *	called with rcu_read_lock()
-- 
2.1.0
