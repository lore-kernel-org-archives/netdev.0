From: kuznet@ms2.inr.ac.ru
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast usage)
Date: Thu, 17 Jul 2003 06:23:52 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170223.GAA13064@dub.inr.ac.ru>
References: <no.id>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, mika.liljeberg@welho.com,
   pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@dub.inr.ac.ru (kuznet)
In-Reply-To: <no.id> from "kuznet" at Jul 17, 2003 05:12:47 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Here it is. Please, review and complain.

1. Recognition of reserved anycasts is removed from ipv6_addr_type().
   Flag IPV6_ADDR_ANYCAST is removed as well.
2. Some meaningless noop code checking for anycast which are not going
   to happen is removed from ndisc.c
3. ipv6_unicast_destination() replaces suboptimal ipv6_chk_acast_addr()
   in data paths.

Alexey



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1469  -> 1.1470 
#	  net/ipv6/anycast.c	1.5     -> 1.6    
#	include/net/ip6_route.h	1.10    -> 1.11   
#	     net/ipv6/icmp.c	1.36    -> 1.37   
#	 net/ipv6/tcp_ipv6.c	1.64    -> 1.65   
#	    net/ipv6/ndisc.c	1.52    -> 1.53   
#	    net/ipv6/route.c	1.50    -> 1.51   
#	  include/net/ipv6.h	1.22    -> 1.23   
#	 net/ipv6/addrconf.c	1.58    -> 1.59   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/17	kuznet@oops.inr.ac.ru	1.1470
# Many files:
#   sanitize IPv6 anycast address support
# --------------------------------------------
#
diff -Nru a/include/net/ip6_route.h b/include/net/ip6_route.h
--- a/include/net/ip6_route.h	Thu Jul 17 06:13:09 2003
+++ b/include/net/ip6_route.h	Thu Jul 17 06:13:09 2003
@@ -45,7 +45,8 @@
 					   void *rtattr);
 
 extern int			ip6_rt_addr_add(struct in6_addr *addr,
-						struct net_device *dev);
+						struct net_device *dev,
+						int anycast);
 
 extern int			ip6_rt_addr_del(struct in6_addr *addr,
 						struct net_device *dev);
@@ -116,6 +117,13 @@
 	np->daddr_cache = daddr;
 	np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 	write_unlock(&sk->sk_dst_lock);
+}
+
+static inline int ipv6_unicast_destination(struct sk_buff *skb)
+{
+	struct rt6_info *rt = (struct rt6_info *) skb->dst;
+
+	return rt->rt6_flags & RTF_LOCAL;
 }
 
 #endif
diff -Nru a/include/net/ipv6.h b/include/net/ipv6.h
--- a/include/net/ipv6.h	Thu Jul 17 06:13:09 2003
+++ b/include/net/ipv6.h	Thu Jul 17 06:13:09 2003
@@ -51,7 +51,7 @@
 /*
  *	Addr type
  *	
- *	type	-	unicast | multicast | anycast
+ *	type	-	unicast | multicast
  *	scope	-	local	| site	    | global
  *	v4	-	compat
  *	v4mapped
@@ -63,7 +63,6 @@
 
 #define IPV6_ADDR_UNICAST      	0x0001U	
 #define IPV6_ADDR_MULTICAST    	0x0002U	
-#define IPV6_ADDR_ANYCAST	0x0004U
 
 #define IPV6_ADDR_LOOPBACK	0x0010U
 #define IPV6_ADDR_LINKLOCAL	0x0020U
diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/addrconf.c	Thu Jul 17 06:13:09 2003
@@ -209,15 +209,8 @@
 		};
 		return type;
 	}
-	/* check for reserved anycast addresses */
-	
-	if ((st & htonl(0xE0000000)) &&
-	    ((addr->s6_addr32[2] == htonl(0xFDFFFFFF) &&
-	    (addr->s6_addr32[3] | htonl(0x7F)) == (u32)~0) ||
-	    (addr->s6_addr32[2] == 0 && addr->s6_addr32[3] == 0)))
-		type = IPV6_ADDR_ANYCAST;
-	else
-		type = IPV6_ADDR_UNICAST;
+
+	type = IPV6_ADDR_UNICAST;
 
 	/* Consider all addresses with the first three bits different of
 	   000 and 111 as finished.
@@ -2552,7 +2545,7 @@
 
 	switch (event) {
 	case RTM_NEWADDR:
-		ip6_rt_addr_add(&ifp->addr, ifp->idev->dev);
+		ip6_rt_addr_add(&ifp->addr, ifp->idev->dev, 0);
 		break;
 	case RTM_DELADDR:
 		addrconf_leave_solict(ifp->idev->dev, &ifp->addr);
diff -Nru a/net/ipv6/anycast.c b/net/ipv6/anycast.c
--- a/net/ipv6/anycast.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/anycast.c	Thu Jul 17 06:13:09 2003
@@ -96,6 +96,13 @@
 	return onlink;
 }
 
+static inline ipv6_reserved_anycast(const struct in6_addr *addr)
+{
+	return (addr->s6_addr32[0] & htonl(0xE0000000)) &&
+		((addr->s6_addr32[2] == htonl(0xFDFFFFFF) &&
+		  (addr->s6_addr32[3] | htonl(0x7F)) == (u32)~0) ||
+		 (addr->s6_addr32[2] == 0 && addr->s6_addr32[3] == 0));
+}
 
 /*
  *	socket join an anycast group
@@ -112,6 +119,8 @@
 
 	if (ipv6_addr_type(addr) & IPV6_ADDR_MULTICAST)
 		return -EINVAL;
+	if (ipv6_chk_addr(addr, NULL))
+		return -EINVAL;
 
 	pac = sock_kmalloc(sk, sizeof(struct ipv6_ac_socklist), GFP_KERNEL);
 	if (pac == NULL)
@@ -172,8 +181,7 @@
 			err = -EPERM;
 		if (err)
 			goto out_dev_put;
-	} else if (!(ipv6_addr_type(addr) & IPV6_ADDR_ANYCAST) &&
-		   !capable(CAP_NET_ADMIN)) {
+	} else if (!ipv6_reserved_anycast(addr) && !capable(CAP_NET_ADMIN)) {
 		err = -EPERM;
 		goto out_dev_put;
 	}
@@ -347,7 +355,7 @@
 	idev->ac_list = aca;
 	write_unlock_bh(&idev->lock);
 
-	ip6_rt_addr_add(&aca->aca_addr, dev);
+	ip6_rt_addr_add(&aca->aca_addr, dev, 1);
 
 	addrconf_join_solict(dev, &aca->aca_addr);
 
diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/icmp.c	Thu Jul 17 06:13:09 2003
@@ -415,8 +415,7 @@
 
 	saddr = &skb->nh.ipv6h->daddr;
 
-	if (ipv6_addr_type(saddr) & IPV6_ADDR_MULTICAST ||
-	    ipv6_chk_acast_addr(0, saddr)) 
+	if (!ipv6_unicast_destination(skb))
 		saddr = NULL;
 
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
--- a/net/ipv6/ndisc.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/ndisc.c	Thu Jul 17 06:13:09 2003
@@ -785,8 +785,7 @@
 			ipv6_addr_all_nodes(&maddr);
 			ndisc_send_na(dev, NULL, &maddr, &ifp->addr, 
 				      ifp->idev->cnf.forwarding, 0, 
-				      ipv6_addr_type(&ifp->addr)&IPV6_ADDR_ANYCAST ? 0 : 1, 
-				      1);
+				      1, 1);
 			in6_ifa_put(ifp);
 			return;
 		}
@@ -809,8 +808,7 @@
 			if (neigh || !dev->hard_header) {
 				ndisc_send_na(dev, neigh, saddr, &ifp->addr, 
 					      ifp->idev->cnf.forwarding, 1, 
-					      ipv6_addr_type(&ifp->addr)&IPV6_ADDR_ANYCAST ? 0 : 1, 
-					      1);
+					      1, 1);
 				if (neigh)
 					neigh_release(neigh);
 			}
diff -Nru a/net/ipv6/route.c b/net/ipv6/route.c
--- a/net/ipv6/route.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/route.c	Thu Jul 17 06:13:09 2003
@@ -1256,7 +1256,7 @@
  *	Add address
  */
 
-int ip6_rt_addr_add(struct in6_addr *addr, struct net_device *dev)
+int ip6_rt_addr_add(struct in6_addr *addr, struct net_device *dev, int anycast)
 {
 	struct rt6_info *rt = ip6_dst_alloc();
 
@@ -1275,6 +1275,8 @@
 	rt->u.dst.obsolete = -1;
 
 	rt->rt6i_flags = RTF_UP | RTF_NONEXTHOP;
+	if (!anycast)
+		rt->rt6i_flags |= RTF_LOCAL;
 	rt->rt6i_nexthop = ndisc_get_neigh(rt->rt6i_dev, &rt->rt6i_gateway);
 	if (rt->rt6i_nexthop == NULL) {
 		dst_free((struct dst_entry *) rt);
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Thu Jul 17 06:13:09 2003
+++ b/net/ipv6/tcp_ipv6.c	Thu Jul 17 06:13:09 2003
@@ -971,7 +971,7 @@
 	if (th->rst)
 		return;
 
-	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr))
+	if (!ipv6_unicast_destination(skb))
 		return; 
 
 	/*
@@ -1175,8 +1175,7 @@
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
 
-	/* FIXME: do the same check for anycast */
-	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr))
+	if (!ipv6_unicast_destination(skb))
 		goto drop; 
 
 	/*
