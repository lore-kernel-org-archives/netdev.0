From: Adam Majer <adamm@zombino.com>
Subject: [PATCH 2/2] Retry autoconfiguration on interface after
 NETDEV_CHANGE notification
Date: Sat, 5 Mar 2011 23:20:48 -0600
Message-ID: <20110306052048.GA3146@mira.lan.galacticasoftware.com>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A bridged interface will timeout trying to receive Router Advert as
these packets are not forwarded when bridge is UP but not in the
FORWARDING state (eg. LEARNING state). Bridge code issues
NETDEV_CHANGE when bridge's internal state is changed. It is then
possible to retry Router Solicitation.

Signed-off-by: Adam Majer <adamm@zombino.com>
---
 net/ipv6/addrconf.c |   74 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fd6782e..f8018b3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -152,6 +152,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp, u32 flags);
 static void addrconf_dad_timer(unsigned long data);
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp);
 static void addrconf_dad_run(struct inet6_dev *idev);
+static void addrconf_rs_start(struct inet6_ifaddr *ifp);
 static void addrconf_rs_timer(unsigned long data);
 static void __ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
@@ -2368,6 +2369,18 @@ static void addrconf_add_linklocal(struct inet6_dev *idev, struct in6_addr *addr
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp, 0);
 		in6_ifa_put(ifp);
+	} else if (PTR_ERR(ifp) == -EEXIST &&
+		list_is_singular(&idev->addr_list)) {
+		/*
+		 * first address must be link local, but no router - re-solicit.
+		 * This code path is called when bridge exits LEARNING state
+		 */
+
+		ifp = list_first_entry(&idev->addr_list,
+				       struct inet6_ifaddr,
+				       if_list);
+
+		addrconf_rs_start(ifp);
 	}
 }
 
@@ -2532,8 +2545,11 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			}
 
 			if (idev) {
-				if (idev->if_flags & IF_READY)
-					/* device is already configured. */
+				if (idev->if_flags & IF_READY &&
+				    idev->if_flags & IF_RA_RCVD)
+					/* device is already configured and
+					 * RA was received.
+					 */
 					break;
 				idev->if_flags |= IF_READY;
 			}
@@ -2775,6 +2791,35 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 	return 0;
 }
 
+static void addrconf_rs_start(struct inet6_ifaddr *ifp)
+{
+	/* If added prefix is link local and forwarding is off,
+	   start sending router solicitations.
+	 */
+	struct net_device *dev = ifp->idev->dev;
+
+	if ((ifp->idev->cnf.forwarding == 0 ||
+	     ifp->idev->cnf.forwarding == 2) &&
+	    ifp->idev->cnf.rtr_solicits > 0 &&
+	    (dev->flags&IFF_LOOPBACK) == 0 &&
+	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
+		/*
+		 *	If a host as already performed a random delay
+		 *	[...] as part of DAD [...] there is no need
+		 *	to delay again before sending the first RS
+		 */
+		ndisc_send_rs(ifp->idev->dev, &ifp->addr,
+			      &in6addr_linklocal_allrouters);
+
+		spin_lock_bh(&ifp->lock);
+		ifp->probes = 1;
+		ifp->idev->if_flags |= IF_RS_SENT;
+		addrconf_mod_timer(ifp, AC_RS,
+				   ifp->idev->cnf.rtr_solicit_interval);
+		spin_unlock_bh(&ifp->lock);
+	}
+}
+
 static void addrconf_rs_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
@@ -2935,36 +2980,15 @@ out:
 
 static void addrconf_dad_completed(struct inet6_ifaddr *ifp)
 {
-	struct net_device *dev = ifp->idev->dev;
-
 	/*
 	 *	Configure the address for reception. Now it is valid.
 	 */
 
 	ipv6_ifa_notify(RTM_NEWADDR, ifp);
 
-	/* If added prefix is link local and forwarding is off,
-	   start sending router solicitations.
-	 */
+	/* start sending router solicitations. */
 
-	if ((ifp->idev->cnf.forwarding == 0 ||
-	     ifp->idev->cnf.forwarding == 2) &&
-	    ifp->idev->cnf.rtr_solicits > 0 &&
-	    (dev->flags&IFF_LOOPBACK) == 0 &&
-	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
-		/*
-		 *	If a host as already performed a random delay
-		 *	[...] as part of DAD [...] there is no need
-		 *	to delay again before sending the first RS
-		 */
-		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &in6addr_linklocal_allrouters);
-
-		spin_lock_bh(&ifp->lock);
-		ifp->probes = 1;
-		ifp->idev->if_flags |= IF_RS_SENT;
-		addrconf_mod_timer(ifp, AC_RS, ifp->idev->cnf.rtr_solicit_interval);
-		spin_unlock_bh(&ifp->lock);
-	}
+	addrconf_rs_start(ifp);
 }
 
 static void addrconf_dad_run(struct inet6_dev *idev)
-- 
1.7.2.3
