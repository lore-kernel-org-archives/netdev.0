From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH/RFC] PATCH: IPV6: Fix multiple leakages (is Re:
 unregister_netdevice: waiting for tun6to4 to become free.)
Date: Sat, 25 Sep 2004 04:05:06 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040925.040506.106641510.yoshfuji@linux-ipv6.org>
References: <41527796.4010204@tomt.net>
	<4152843D.6010204@tomt.net>
	<20040923.172253.125681726.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: andre@tomt.net, tgraf@suug.ch, pp@ee.oulu.fi, jgarzik@pobox.com,
        dwmw2@infradead.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040923.172253.125681726.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20040923.172253.125681726.yoshfuji@linux-ipv6.org> (at Thu, 23 Sep 2004 17:22:53 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> Thank you everyone for tracking down this bug.
> I will fix this bug and come up with patch tomorrow (or so).

Well, I've created changesets which should fix multiple leakages.
Here's the snapshot.  Please review.

Also available at: <bk://bk.skbuff.net:20609/linux-2.6-refcnt/>.

Thanks.

HEADLINES
---------
ChangeSet@1.2005, 2004-09-24 15:54:32+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix device multicast list leakage when forwarding is on.
ChangeSet@1.2006, 2004-09-24 16:29:02+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't multiply join multicast/anycast addresses.
ChangeSet@1.2007, 2004-09-24 17:19:13+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Save number of arguments for __ipv6_dev_mc_dev().
ChangeSet@1.2008, 2004-09-24 17:30:22+09:00, yoshfuji@linux-ipv6.org
 [IPV6] use __ipv6_dev_mc_dec() where appropriate.
ChangeSet@1.2009, 2004-09-24 20:39:28+09:00, yoshfuji@linux-ipv6.org
 [IPV6] leave solicited-node multicast address during device deletion.
ChangeSet@1.2010, 2004-09-24 20:49:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] leave subnet-routers anycast address during device deletion.
ChangeSet@1.2011, 2004-09-24 20:56:13+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Clean up anycast membership management.


CHANGESETS
----------
ChangeSet@1.2005, 2004-09-24 15:54:32+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Fix device multicast list leakage when forwarding is on.
 
 We failed to leave all-routers multicast address.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-09-24 20:57:13 +09:00
+++ b/net/ipv6/mcast.c	2004-09-24 20:57:13 +09:00
@@ -2110,6 +2110,11 @@
 	 */
 	__ipv6_dev_mc_dec(idev->dev, idev, &maddr);
 
+	if (idev->cnf.forwarding) {
+		ipv6_addr_all_routers(&maddr);
+		__ipv6_dev_mc_dec(idev->dev, idev, &maddr);
+	}
+
 	write_lock_bh(&idev->lock);
 	while ((i = idev->mc_list) != NULL) {
 		idev->mc_list = i->next;

ChangeSet@1.2006, 2004-09-24 16:29:02+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Don't multiply join multicast/anycast addresses.
 
 Case 1: if net.ipv6.conf.IFACE.forwarding has been set to 1,
 we multiply join routers' multicast/anycast addresses 
 by setting net.ipv6.conf.all.forwarding to 1.
 
 Noticed by Andre Tomt <andre@tomt.net>.
 
 Case 2: if we change net.ipv6.conf.FOO.forwarding from 1 to 2,
 we multiply join routers' multicast/anycast addresses.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-09-24 20:57:16 +09:00
+++ b/net/ipv6/addrconf.c	2004-09-24 20:57:16 +09:00
@@ -430,22 +430,20 @@
 }
 
 
-static void addrconf_forward_change(struct inet6_dev *idev)
+static void addrconf_forward_change(void)
 {
 	struct net_device *dev;
-
-	if (idev) {
-		dev_forward_change(idev);
-		return;
-	}
+	struct inet6_dev *idev;
 
 	read_lock(&dev_base_lock);
 	for (dev=dev_base; dev; dev=dev->next) {
 		read_lock(&addrconf_lock);
 		idev = __in6_dev_get(dev);
 		if (idev) {
+			int changed = (!idev->cnf.forwarding) ^ (!ipv6_devconf.forwarding);
 			idev->cnf.forwarding = ipv6_devconf.forwarding;
-			dev_forward_change(idev);
+			if (changed)
+				dev_forward_change(idev);
 		}
 		read_unlock(&addrconf_lock);
 	}
@@ -3025,18 +3023,18 @@
 
 	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
 
-	if (write && *valp != val && valp != &ipv6_devconf_dflt.forwarding) {
-		struct inet6_dev *idev = NULL;
-
+	if (write && valp != &ipv6_devconf_dflt.forwarding) {
 		if (valp != &ipv6_devconf.forwarding) {
-			idev = (struct inet6_dev *)ctl->extra1;
-			if (idev == NULL)
-				return ret;
-		} else
+			if ((!*valp) ^ (!val)) {
+				struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
+				if (idev == NULL)
+					return ret;
+				dev_forward_change(idev);
+			}
+		} else {
 			ipv6_devconf_dflt.forwarding = ipv6_devconf.forwarding;
-
-		addrconf_forward_change(idev);
-
+			addrconf_forward_change();
+		}
 		if (*valp)
 			rt6_purge_dflt_routers(0);
 	}
@@ -3077,15 +3075,19 @@
 	}
 
 	if (valp != &ipv6_devconf_dflt.forwarding) {
-		struct inet6_dev *idev;
 		if (valp != &ipv6_devconf.forwarding) {
-			idev = (struct inet6_dev *)table->extra1;
+			struct inet6_dev *idev = (struct inet6_dev *)table->extra1;
+			int changed;
 			if (unlikely(idev == NULL))
 				return -ENODEV;
-		} else
-			idev = NULL;
-		*valp = new;
-		addrconf_forward_change(idev);
+			changed = (!*valp) ^ (!new);
+			*valp = new;
+			if (changed)
+				dev_forward_change(idev);
+		} else {
+			*valp = new;
+			addrconf_forward_change();
+		}
 
 		if (*valp)
 			rt6_purge_dflt_routers(0);

ChangeSet@1.2007, 2004-09-24 17:19:13+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Save number of arguments for __ipv6_dev_mc_dev().
 
 dev is unused in the function.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-09-24 20:57:19 +09:00
+++ b/net/ipv6/mcast.c	2004-09-24 20:57:19 +09:00
@@ -870,7 +870,7 @@
 /*
  *	device multicast group del
  */
-static int __ipv6_dev_mc_dec(struct net_device *dev, struct inet6_dev *idev, struct in6_addr *addr)
+static int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr)
 {
 	struct ifmcaddr6 *ma, **map;
 
@@ -903,7 +903,7 @@
 	if (!idev)
 		return -ENODEV;
 
-	err = __ipv6_dev_mc_dec(dev, idev, addr);
+	err = __ipv6_dev_mc_dec(idev, addr);
 
 	in6_dev_put(idev);
 
@@ -2108,11 +2108,11 @@
 	 * addrconf.c has NULL'd out dev->ip6_ptr so in6_dev_get() will
 	 * fail.
 	 */
-	__ipv6_dev_mc_dec(idev->dev, idev, &maddr);
+	__ipv6_dev_mc_dec(idev, &maddr);
 
 	if (idev->cnf.forwarding) {
 		ipv6_addr_all_routers(&maddr);
-		__ipv6_dev_mc_dec(idev->dev, idev, &maddr);
+		__ipv6_dev_mc_dec(idev, &maddr);
 	}
 
 	write_lock_bh(&idev->lock);

ChangeSet@1.2008, 2004-09-24 17:30:22+09:00, yoshfuji@linux-ipv6.org
 [IPV6] use __ipv6_dev_mc_dec() where appropriate.
 
 Use __ipv6_dev_mc_dec() instead where the caller knows idev.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-09-24 20:57:22 +09:00
+++ b/net/ipv6/mcast.c	2004-09-24 20:57:22 +09:00
@@ -128,6 +128,8 @@
 
 static struct socket *igmp6_socket;
 
+static int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
+
 static void igmp6_join_group(struct ifmcaddr6 *ma);
 static void igmp6_leave_group(struct ifmcaddr6 *ma);
 static void igmp6_timer_handler(unsigned long data);
@@ -256,9 +258,9 @@
 
 				if (idev) {
 					(void) ip6_mc_leave_src(sk,mc_lst,idev);
+					__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 					in6_dev_put(idev);
 				}
-				ipv6_dev_mc_dec(dev, &mc_lst->addr);
 				dev_put(dev);
 			}
 			sock_kfree_s(sk, mc_lst, sizeof(*mc_lst));
@@ -322,9 +324,9 @@
 
 			if (idev) {
 				(void) ip6_mc_leave_src(sk, mc_lst, idev);
+				__ipv6_dev_mc_dec(idev, &mc_lst->addr);
 				in6_dev_put(idev);
 			}
-			ipv6_dev_mc_dec(dev, &mc_lst->addr);
 			dev_put(dev);
 		}
 

ChangeSet@1.2009, 2004-09-24 20:39:28+09:00, yoshfuji@linux-ipv6.org
 [IPV6] leave solicited-node multicast address during device deletion.
 
 Because in6_dev_get() fails during device deletion,
 we failed to leave solicited-node multicast address.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	2004-09-24 20:57:26 +09:00
+++ b/include/net/addrconf.h	2004-09-24 20:57:26 +09:00
@@ -74,7 +74,7 @@
 						      const struct sock *sk2);
 extern void			addrconf_join_solict(struct net_device *dev,
 					struct in6_addr *addr);
-extern void			addrconf_leave_solict(struct net_device *dev,
+extern void			addrconf_leave_solict(struct inet6_dev *idev,
 					struct in6_addr *addr);
 
 /*
@@ -89,6 +89,7 @@
 		struct in6_addr *src_addr);
 
 extern int ipv6_dev_mc_inc(struct net_device *dev, struct in6_addr *addr);
+extern int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
 extern int ipv6_dev_mc_dec(struct net_device *dev, struct in6_addr *addr);
 extern void ipv6_mc_up(struct inet6_dev *idev);
 extern void ipv6_mc_down(struct inet6_dev *idev);
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-09-24 20:57:26 +09:00
+++ b/net/ipv6/addrconf.c	2004-09-24 20:57:26 +09:00
@@ -1060,15 +1060,15 @@
 	ipv6_dev_mc_inc(dev, &maddr);
 }
 
-void addrconf_leave_solict(struct net_device *dev, struct in6_addr *addr)
+void addrconf_leave_solict(struct inet6_dev *idev, struct in6_addr *addr)
 {
 	struct in6_addr maddr;
 
-	if (dev->flags&(IFF_LOOPBACK|IFF_NOARP))
+	if (idev->dev->flags&(IFF_LOOPBACK|IFF_NOARP))
 		return;
 
 	addrconf_addr_solict_mult(addr, &maddr);
-	ipv6_dev_mc_dec(dev, &maddr);
+	__ipv6_dev_mc_dec(idev, &maddr);
 }
 
 
@@ -2994,7 +2994,7 @@
 			dst_release(&ifp->rt->u.dst);
 		break;
 	case RTM_DELADDR:
-		addrconf_leave_solict(ifp->idev->dev, &ifp->addr);
+		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		if (ifp->idev->cnf.forwarding) {
 			struct in6_addr addr;
 
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	2004-09-24 20:57:26 +09:00
+++ b/net/ipv6/anycast.c	2004-09-24 20:57:26 +09:00
@@ -408,7 +408,7 @@
 	else
 		idev->ac_list = aca->aca_next;
 	write_unlock_bh(&idev->lock);
-	addrconf_leave_solict(dev, &aca->aca_addr);
+	addrconf_leave_solict(idev, &aca->aca_addr);
 
 	dst_hold(&aca->aca_rt->u.dst);
 	if (ip6_del_rt(aca->aca_rt, NULL, NULL))
diff -Nru a/net/ipv6/mcast.c b/net/ipv6/mcast.c
--- a/net/ipv6/mcast.c	2004-09-24 20:57:26 +09:00
+++ b/net/ipv6/mcast.c	2004-09-24 20:57:26 +09:00
@@ -128,7 +128,7 @@
 
 static struct socket *igmp6_socket;
 
-static int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
+int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr);
 
 static void igmp6_join_group(struct ifmcaddr6 *ma);
 static void igmp6_leave_group(struct ifmcaddr6 *ma);
@@ -872,7 +872,7 @@
 /*
  *	device multicast group del
  */
-static int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr)
+int __ipv6_dev_mc_dec(struct inet6_dev *idev, struct in6_addr *addr)
 {
 	struct ifmcaddr6 *ma, **map;
 

ChangeSet@1.2010, 2004-09-24 20:49:10+09:00, yoshfuji@linux-ipv6.org
 [IPV6] leave subnet-routers anycast address during device deletion.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/include/net/addrconf.h b/include/net/addrconf.h
--- a/include/net/addrconf.h	2004-09-24 20:57:29 +09:00
+++ b/include/net/addrconf.h	2004-09-24 20:57:29 +09:00
@@ -112,6 +112,7 @@
 extern int inet6_ac_check(struct sock *sk, struct in6_addr *addr, int ifindex);
 
 extern int ipv6_dev_ac_inc(struct net_device *dev, struct in6_addr *addr);
+extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr);
 extern int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr);
 extern int ipv6_chk_acast_addr(struct net_device *dev, struct in6_addr *addr);
 
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-09-24 20:57:29 +09:00
+++ b/net/ipv6/addrconf.c	2004-09-24 20:57:29 +09:00
@@ -3000,7 +3000,7 @@
 
 			ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 			if (!ipv6_addr_any(&addr))
-				ipv6_dev_ac_dec(ifp->idev->dev, &addr);
+				__ipv6_dev_ac_dec(ifp->idev, &addr);
 		}
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_del_rt(ifp->rt, NULL, NULL))
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	2004-09-24 20:57:29 +09:00
+++ b/net/ipv6/anycast.c	2004-09-24 20:57:29 +09:00
@@ -377,15 +377,10 @@
 /*
  *	device anycast group decrement
  */
-int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
+int __ipv6_dev_ac_dec(struct inet6_dev *idev, struct in6_addr *addr)
 {
-	struct inet6_dev *idev;
 	struct ifacaddr6 *aca, *prev_aca;
 
-	idev = in6_dev_get(dev);
-	if (idev == NULL)
-		return -ENODEV;
-
 	write_lock_bh(&idev->lock);
 	prev_aca = NULL;
 	for (aca = idev->ac_list; aca; aca = aca->aca_next) {
@@ -395,12 +390,10 @@
 	}
 	if (!aca) {
 		write_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 		return -ENOENT;
 	}
 	if (--aca->aca_users > 0) {
 		write_unlock_bh(&idev->lock);
-		in6_dev_put(idev);
 		return 0;
 	}
 	if (prev_aca)
@@ -417,10 +410,20 @@
 		dst_release(&aca->aca_rt->u.dst);
 
 	aca_put(aca);
-	in6_dev_put(idev);
 	return 0;
 }
 
+int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr)
+{
+	int ret;
+	struct inet6_dev *idev = in6_dev_get(dev);
+	if (idev == NULL)
+		return -ENODEV;
+	ret = __ipv6_dev_ac_dec(idev, addr);
+	in6_dev_put(idev);
+	return ret;
+}
+	
 /*
  *	check if the interface has this anycast address
  */

ChangeSet@1.2011, 2004-09-24 20:56:13+09:00, yoshfuji@linux-ipv6.org
 [IPV6] Clean up anycast membership management.
 
 Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	2004-09-24 20:57:32 +09:00
+++ b/net/ipv6/addrconf.c	2004-09-24 20:57:32 +09:00
@@ -128,6 +128,9 @@
 			TIMER_INITIALIZER(addrconf_verify, 0, 0);
 static spinlock_t addrconf_verify_lock = SPIN_LOCK_UNLOCKED;
 
+static void addrconf_join_anycast(struct inet6_ifaddr *ifp);
+static void addrconf_leave_anycast(struct inet6_ifaddr *ifp);
+
 static int addrconf_ifdown(struct net_device *dev, int how);
 
 static void addrconf_dad_start(struct inet6_ifaddr *ifp, int flags);
@@ -419,13 +422,10 @@
 			ipv6_dev_mc_dec(dev, &addr);
 	}
 	for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
-		ipv6_addr_prefix(&addr, &ifa->addr, ifa->prefix_len);
-		if (ipv6_addr_any(&addr))
-			continue;
 		if (idev->cnf.forwarding)
-			ipv6_dev_ac_inc(idev->dev, &addr);
+			addrconf_join_anycast(ifa);
 		else
-			ipv6_dev_ac_dec(idev->dev, &addr);
+			addrconf_leave_anycast(ifa);
 	}
 }
 
@@ -1071,6 +1071,23 @@
 	__ipv6_dev_mc_dec(idev, &maddr);
 }
 
+void addrconf_join_anycast(struct inet6_ifaddr *ifp)
+{
+	struct in6_addr addr;
+	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
+	if (ipv6_addr_any(&addr))
+		return;
+	ipv6_dev_ac_inc(ifp->idev->dev, &addr);
+}
+
+void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
+{
+	struct in6_addr addr;
+	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
+	if (ipv6_addr_any(&addr))
+		return;
+	__ipv6_dev_ac_dec(ifp->idev, &addr);
+}
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
@@ -2223,14 +2240,6 @@
 		addrconf_mod_timer(ifp, AC_RS, ifp->idev->cnf.rtr_solicit_interval);
 		spin_unlock_bh(&ifp->lock);
 	}
-
-	if (ifp->idev->cnf.forwarding) {
-		struct in6_addr addr;
-
-		ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
-		if (!ipv6_addr_any(&addr))
-			ipv6_dev_ac_inc(ifp->idev->dev, &addr);
-	}
 }
 
 #ifdef CONFIG_PROC_FS
@@ -2992,16 +3001,13 @@
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_ins_rt(ifp->rt, NULL, NULL))
 			dst_release(&ifp->rt->u.dst);
+		if (ifp->idev->cnf.forwarding)
+			addrconf_join_anycast(ifp);
 		break;
 	case RTM_DELADDR:
+		if (ifp->idev->cnf.forwarding)
+			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
-		if (ifp->idev->cnf.forwarding) {
-			struct in6_addr addr;
-
-			ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
-			if (!ipv6_addr_any(&addr))
-				__ipv6_dev_ac_dec(ifp->idev, &addr);
-		}
 		dst_hold(&ifp->rt->u.dst);
 		if (ip6_del_rt(ifp->rt, NULL, NULL))
 			dst_free(&ifp->rt->u.dst);



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
