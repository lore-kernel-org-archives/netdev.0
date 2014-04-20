From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: [PATCH net-next] ipv6: support IFA_F_MANAGETEMPADDR for address deletion
 too
Date: Sun, 20 Apr 2014 21:29:36 +0200
Message-ID: <53542020.8070904@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:50231 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751603AbaDTT3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2014 15:29:45 -0400
Received: from [192.168.178.101] ([84.142.80.96]) by smtp.web.de (mrweb103)
 with ESMTPSA (Nemesis) id 0MOArg-1WWTn0354W-005c2X for
 <netdev@vger.kernel.org>; Sun, 20 Apr 2014 21:29:42 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Userspace applications can use IFA_F_MANAGETEMPADDR with RTM_NEWADDR
already to indicate that the kernel should take care of temporary
address management.

This patch adds related functionality to RTM_DELADDR. By setting
IFA_F_MANAGETEMPADDR a userspace application can indicate that the kernel
should delete all related temporary addresses as well.

A corresponding patch for the "ip addr del" command has been applied to
iproute2 already.

Signed-off-by: Heiner Kallweit <heiner.kallweit@web.de>
---
 net/ipv6/addrconf.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c7fa08..fc203db 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2504,8 +2504,8 @@ static int inet6_addr_add(struct net *net, int ifindex,
 	return PTR_ERR(ifp);
 }
 
-static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *pfx,
-			  unsigned int plen)
+static int inet6_addr_del(struct net *net, int ifindex, u32 ifa_flags,
+			  const struct in6_addr *pfx, unsigned int plen)
 {
 	struct inet6_ifaddr *ifp;
 	struct inet6_dev *idev;
@@ -2528,7 +2528,12 @@ static int inet6_addr_del(struct net *net, int ifindex, const struct in6_addr *p
 			in6_ifa_hold(ifp);
 			read_unlock_bh(&idev->lock);
 
+			if (!(ifp->flags & IFA_F_TEMPORARY) &&
+			    (ifa_flags & IFA_F_MANAGETEMPADDR))
+				manage_tempaddrs(idev, ifp, 0, 0, false,
+						 jiffies);
 			ipv6_del_addr(ifp);
+			addrconf_verify_rtnl();
 			return 0;
 		}
 	}
@@ -2568,7 +2573,7 @@ int addrconf_del_ifaddr(struct net *net, void __user *arg)
 		return -EFAULT;
 
 	rtnl_lock();
-	err = inet6_addr_del(net, ireq.ifr6_ifindex, &ireq.ifr6_addr,
+	err = inet6_addr_del(net, ireq.ifr6_ifindex, 0, &ireq.ifr6_addr,
 			     ireq.ifr6_prefixlen);
 	rtnl_unlock();
 	return err;
@@ -3743,6 +3748,7 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct ifaddrmsg *ifm;
 	struct nlattr *tb[IFA_MAX+1];
 	struct in6_addr *pfx, *peer_pfx;
+	u32 ifa_flags;
 	int err;
 
 	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFA_MAX, ifa_ipv6_policy);
@@ -3754,7 +3760,13 @@ inet6_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (pfx == NULL)
 		return -EINVAL;
 
-	return inet6_addr_del(net, ifm->ifa_index, pfx, ifm->ifa_prefixlen);
+	ifa_flags = tb[IFA_FLAGS] ? nla_get_u32(tb[IFA_FLAGS]) : ifm->ifa_flags;
+
+	/* We ignore other flags so far. */
+	ifa_flags &= IFA_F_MANAGETEMPADDR;
+
+	return inet6_addr_del(net, ifm->ifa_index, ifa_flags, pfx,
+			      ifm->ifa_prefixlen);
 }
 
 static int inet6_addr_modify(struct inet6_ifaddr *ifp, u32 ifa_flags,
-- 
1.9.1.315.g3f09db0.dirty
