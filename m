From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] IPv6: Change addrconf code to deal with link changes better
Date: Fri, 10 Sep 2010 16:58:31 -0400
Message-ID: <4C8A9BF7.2090102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:32202 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453Ab0IJU6f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Sep 2010 16:58:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I recently started noticing that sometimes I wasn't seeing all the "normal"
IPv6 packets (DAD, MLD, Router Solicit) when I was bringing-up interfaces.
I found that sometimes the link on some NICs was going up-down-up like
this:

 ADDRCONF(NETDEV_UP): eth3: link is not ready
 e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
 ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
 (DAD queued here)
 e1000e: eth3 NIC Link is Down
 e1000e: eth3 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None

This is all tcpdump showed on a remote system:

 IP6 fe80::21f:29ff:fe59:fac9 > ff02::2: ICMP6, router solicitation, length 16
 IP6 fe80::21f:29ff:fe59:fac9 > ff02::2: ICMP6, router solicitation, length 16

The addrconf code isn't written to handle this case, and won't restart DAD.
With the patch below I get this (DAD_KICK was for debugging):

 ADDRCONF(NETDEV_UP): eth6: link is not ready
 e1000e: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
 ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
 DAD_KICK(fe80::21f:29ff:fe59:faca): eth6
 e1000e: eth6 NIC Link is Down
 ADDRCONF(NETDEV_CHANGE): eth6: link is not ready
 e1000e: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
 ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready
 DAD_KICK(fe80::21f:29ff:fe59:faca): eth6

And corresponding tcpdump:

 IP6 :: > ff02::1:ff59:faca: ICMP6, neighbor solicitation, who has fe80::21f:29ff:fe59:faca, length 24
 IP6 :: > ff02::16: HBH ICMP6, multicast listener report v2, 1 group record(s), length 28
 IP6 fe80::21f:29ff:fe59:faca > ff02::2: ICMP6, router solicitation, length 16

I also noticed that sometimes during these blips that addrconf_dad_kick()
could be called twice, transmitting two DAD packets and resetting the
timer another second into the future, so I introduced a "Need DAD" state
to signify that DAD has not been started yet.  With both of these applied
the behavior is much better.

--

Change the IPv6 addrconf code to handle the case where the NIC link
state goes UP-DOWN-UP by removing all the autoconfigured addresses
when it goes down, so that when it comes back up they will get added
again and DAD will be triggered.  Also added a "Need DAD" state so that
we don't accidentally start it twice for the same address, sending a
duplicate packet and delaying when the address is available for use.

Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index f95ff8d..57432f1 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -33,6 +33,7 @@
 #ifdef __KERNEL__
 
 enum {
+	INET6_IFADDR_STATE_NEEDDAD,
 	INET6_IFADDR_STATE_DAD,
 	INET6_IFADDR_STATE_POSTDAD,
 	INET6_IFADDR_STATE_UP,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5bc893e..fabafc7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2517,13 +2517,27 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
 			if (!idev && dev->mtu >= IPV6_MIN_MTU)
 				idev = ipv6_add_dev(dev);
 
-			if (idev) {
-				idev->if_flags |= IF_READY;
+			/*
+			 * Only start DAD if the device is ready, IF_READY
+			 * will have been set by ipv6_add_dev() if so.
+			 */
+			if (idev && idev->if_flags & IF_READY)
 				run_pending = 1;
-			}
 		} else {
 			if (!addrconf_qdisc_ok(dev)) {
-				/* device is still not ready. */
+				/*
+				 * Device is still not ready.  If we've already
+				 * configured addresses, remove them now as
+				 * we'll need to start DAD all over again.
+				 */
+				printk(KERN_INFO
+					"ADDRCONF(NETDEV_CHANGE): %s: "
+					"link is not ready\n",
+					dev->name);
+
+				if (idev && idev->if_flags & IF_READY)
+					addrconf_ifdown(dev, 0);
+
 				break;
 			}
 
@@ -2736,7 +2750,7 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 
 			/* Flag it for later restoration when link comes up */
 			ifa->flags |= IFA_F_TENTATIVE;
-			ifa->state = INET6_IFADDR_STATE_DAD;
+			ifa->state = INET6_IFADDR_STATE_NEEDDAD;
 
 			write_unlock_bh(&idev->lock);
 
@@ -2847,6 +2861,7 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
 
 	ifp->probes = idev->cnf.dad_transmits;
+	ifp->state = INET6_IFADDR_STATE_DAD;
 	addrconf_mod_timer(ifp, AC_DAD, rand_num);
 }
 
@@ -2992,7 +3007,7 @@ static void addrconf_dad_run(struct inet6_dev *idev)
 	list_for_each_entry(ifp, &idev->addr_list, if_list) {
 		spin_lock(&ifp->lock);
 		if (ifp->flags & IFA_F_TENTATIVE &&
-		    ifp->state == INET6_IFADDR_STATE_DAD)
+		    ifp->state == INET6_IFADDR_STATE_NEEDDAD)
 			addrconf_dad_kick(ifp);
 		spin_unlock(&ifp->lock);
 	}
