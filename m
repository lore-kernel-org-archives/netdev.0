From: "C. Scott Ananian" <cscott@cscott.net>
Subject: ip6_fib.c locking protocol.
Date: Wed, 20 Jun 2007 00:17:04 -0400
Message-ID: <c6d9bea0706192117m6272ab81q997187eec959b89f@mail.gmail.com>
References: <c6d9bea0706191608p6352c200n830fbe0810dcb94@mail.gmail.com>
	 <c6d9bea0706191612k58470cf0scf6f78b8a790b2dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:30255 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbXFTERE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 00:17:04 -0400
Received: by an-out-0708.google.com with SMTP id d31so7688and
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 21:17:04 -0700 (PDT)
In-Reply-To: <c6d9bea0706191612k58470cf0scf6f78b8a790b2dd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm working on a patch to implement RDNSS options
in Router Advertisement messages in IPv6.  (Draft RFC at:
http://tools.ietf.org/html/draft-jeong-dnsop-ipv6-dns-discovery-12
Support is already in radvd.)

I don't quite understand how 'struct rt6_info' allocation/deallocation
and locking are happening.   For example, where are rt6_info
deallocated?  I couldn't find a call to any sort of free any of the
places I expected.  When I'm writing to rt6_info during
autoconfiguration, how do I ensure that it is not concurrently mutated
or deallocated?  It didn't seem like there was a per-struct lock, but
none of the coarser locks I found seemed quite right.

Any help or pointers you could give would be appreciated.  My
(partial, unfinished) patch is appended, so you can get an idea of
what I'm doing.

Thanks!
 --scott
---------

diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ip6_fib.h
linux-2.6.22-rc5/include/net/ip6_fib.h
--- linux-2.6.22-rc5-orig/include/net/ip6_fib.h	2007-06-16
22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/include/net/ip6_fib.h	2007-06-19 12:00:57.000000000 -0400
@@ -79,6 +79,7 @@ struct rt6key
 };

 struct fib6_table;
+struct rdns6_info;

 struct rt6_info
 {
@@ -105,6 +106,8 @@ struct rt6_info
 	struct rt6key			rt6i_src;

 	u8				rt6i_protocol;
+
+        struct rdns6_info               *rt6i_rdnss;
 };

 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h
linux-2.6.22-rc5/include/net/ip6_rdnss.h
--- linux-2.6.22-rc5-orig/include/net/ip6_rdnss.h	1969-12-31
19:00:00.000000000 -0500
+++ linux-2.6.22-rc5/include/net/ip6_rdnss.h	2007-06-19 16:42:26.000000000 -0400
@@ -0,0 +1,27 @@
+#ifndef _NET_IP6_RDNSS_H
+#define _NET_IP6_RDNSS_H
+
+#ifdef __KERNEL__
+
+#include <linux/in6.h>
+
+struct nd_opt_rdnss {
+	__u8			type;
+	__u8			length;
+	__u16			reserved;
+	__be32			lifetime;
+	struct in6_addr		rdnss[1];	/* 1 or more */
+};
+
+struct rdns6_info {
+	struct rdns6_info *	next;
+	struct in6_addr		rdnss;
+	__u32			lifetime;
+	unsigned long		expires;
+};
+
+extern void	rdns6_rcv(struct inet6_dev *dev, struct rt6_info *rt,
+			  struct nd_opt_rdnss **opts, int opt_cnt);
+
+#endif
+#endif
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ndisc.h
linux-2.6.22-rc5/include/net/ndisc.h
--- linux-2.6.22-rc5-orig/include/net/ndisc.h	2007-06-16
22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/include/net/ndisc.h	2007-06-18 15:30:00.000000000 -0400
@@ -24,6 +24,7 @@ enum {
 	ND_OPT_MTU = 5,			/* RFC2461 */
 	__ND_OPT_ARRAY_MAX,
 	ND_OPT_ROUTE_INFO = 24,		/* RFC4191 */
+	ND_OPT_RDNSS_INFO = 25,         /* draft/radvd */
 	__ND_OPT_MAX
 };

diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/net/ipv6/Makefile
linux-2.6.22-rc5/net/ipv6/Makefile
--- linux-2.6.22-rc5-orig/net/ipv6/Makefile	2007-06-16 22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/net/ipv6/Makefile	2007-06-18 16:39:02.000000000 -0400
@@ -8,7 +8,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_ou
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o \
-		ip6_flowlabel.o inet6_connection_sock.o
+		ip6_flowlabel.o inet6_connection_sock.o ip6_rdnss.o

 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/net/ipv6/ip6_rdnss.c
linux-2.6.22-rc5/net/ipv6/ip6_rdnss.c
--- linux-2.6.22-rc5-orig/net/ipv6/ip6_rdnss.c	1969-12-31
19:00:00.000000000 -0500
+++ linux-2.6.22-rc5/net/ipv6/ip6_rdnss.c	2007-06-19 19:01:04.000000000 -0400
@@ -0,0 +1,260 @@
+/*
+ *	Recursive DNS Server autoconfiguration for IPv6
+ *      Linux INET6 implementation.
+ *
+ *	Authors:
+ *	C. Scott Ananian	<cananian@alumni.princeton.edu>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/timer.h>
+#include <linux/spinlock.h>
+
+#include <linux/in6.h>
+#include <linux/ipv6.h>
+#include <linux/icmpv6.h>
+
+#include <net/ipv6.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_rdnss.h>
+
+#define INFINITY_LIFE_TIME	0xFFFFFFFF
+/* the maximum number of recursive DNS servers we'll remember per
+ * router.  we have to set some limit to prevent an easy DoS, and
+ * 3 DNS servers seems to be standard practice. */
+#define __RDNS6_MAX_ENTRIES	3
+
+static void rdns6_expire(unsigned long);
+
+static DEFINE_TIMER(rdns6_chk_timer, rdns6_expire, 0, 0);
+static DEFINE_SPINLOCK(rdns6_expire_lock);
+
+static int rdns6_update_entry(struct rdns6_info **p, struct in6_addr *addr,
+			      uint32_t lifetime) {
+	int changed = false;
+	/* if lifetime is zero, delete this entry */
+	if (lifetime == 0) {
+		struct rdns6_info *r6i = (*p);
+		*p = (*p)->next;
+		kfree(r6i);
+		return true;
+	}
+	/* otherwise, update lifetime and expiration time. */
+	if (lifetime > (*p)->lifetime)
+		(*p)->lifetime = lifetime;
+	if ((*p)->lifetime != INFINITY_LIFE_TIME) {
+		unsigned long nexpires = jiffies + lifetime * HZ;
+		if (time_before((*p)->expires, nexpires))
+			(*p)->expires = nexpires;
+	}
+	return changed;
+}
+
+/* According to the draft RFC, if we need to delete an entry, "delete the
+ * entry with the smallest expiration time that will expire first". */
+static int rdns6_cmp_entry(struct rdns6_info *a, struct rdns6_info *b) {
+	if ( a->lifetime != b->lifetime )
+		return a->lifetime < b->lifetime ? -1 : 1;
+	if (time_before( a->expires, b->expires ))
+		return -1;
+	if (time_after( a->expires, b->expires ))
+		return 1;
+	return 0;
+}
+
+/* Look for an entry in the DNS server list which is 'worse' than this one;
+ * delete it if found. */
+static int rdns6_expire_worse(struct rt6_info *rt, struct rdns6_info *nentry){
+	struct rdns6_info **worst = NULL, **p;
+	for (p = &(rt->rt6i_rdnss); *p != NULL; p = &((*p)->next)) {
+		if (worst==NULL ||
+		    rdns6_cmp_entry(*worst, *p) < 0)
+			worst = p;
+	}
+	if (worst && rdns6_cmp_entry(*worst, nentry) < 0) {
+		struct rdns6_info *r6i = (*worst);
+		*worst = (*worst)->next; /* delete it */
+		kfree(r6i);
+		return true;
+	}
+	return false;
+}
+
+/* Create a new rdns6_info entry. */
+static struct rdns6_info *rdns6_create_entry(struct in6_addr *addr,
+					     uint32_t lifetime) {
+	struct rdns6_info *result;
+	result = kzalloc(sizeof(*result), GFP_KERNEL);
+	if (result) {
+		ipv6_addr_copy(&(result->rdnss), addr);
+		result->lifetime = lifetime;
+		result->expires = (lifetime==INFINITY_LIFE_TIME) ? 0 :
+			jiffies + lifetime * HZ;
+	}
+	return result;
+}
+
+/* Process a newly-received RDNSS option from a RAdv message. */
+void rdns6_rcv(struct inet6_dev *dev, struct rt6_info *rt,
+	       struct nd_opt_rdnss **opts, int opt_cnt) {
+	struct rdns6_info **p, **insert_point;
+	int i, j, changed = false, num_entries = 0, dont_need_expires = true;
+	unsigned long next_expiry;
+	uint32_t lifetime;
+	/* first, count the # of dns server list entries we've already got */
+	for (p = &(rt->rt6i_rdnss); *p != NULL; p = &((*p)->next)) {
+		num_entries++;
+	}
+	/* now let's process all the RDNSS options in the RA */
+	insert_point = &(rt->rt6i_rdnss); /* add to the start of the list */
+	for (i=0; i<opt_cnt; i++) {
+		int len = opts[i]->length << 3;
+		if (len < sizeof(struct nd_opt_rdnss)) {
+			printk(KERN_WARNING
+			       "ICMPv6 RA: bad RDNSS option length\n");
+			continue;
+		}
+		lifetime = opts[i]->lifetime;
+		printk(KERN_WARNING
+		       "Got an RDNSS message via RA, lifetime: %u\n",
+		       lifetime);
+		for (j=0; (j+1)*sizeof(struct in6_addr) <= len-8; j++) {
+			struct in6_addr *addr = &(opts[i]->rdnss[j]);
+			/* find this entry in the list. */
+			struct rdns6_info **p;
+			for (p = &(rt->rt6i_rdnss);
+			     *p != NULL;
+			     p = &((*p)->next)) {
+				if (ipv6_addr_equal(addr, &((*p)->rdnss)))
+					break;
+			}
+			if (*p) {
+				/* we found an existing entry, update it. */
+				if (rdns6_update_entry(p, addr, lifetime))
+					changed = true;
+				if (lifetime == 0)
+					num_entries--;
+			} else if (lifetime) {
+				/* no existing entry. make one. */
+				struct rdns6_info *nentry =
+					rdns6_create_entry(addr, lifetime);
+				/* make room if we must (and if we can) */
+				if (num_entries >= __RDNS6_MAX_ENTRIES) {
+					/* see if we can expire an entry */
+					if (rdns6_expire_worse(rt, nentry))
+						num_entries--;
+				}
+				/* if we have room now, add an entry. */
+				if (num_entries < __RDNS6_MAX_ENTRIES) {
+					nentry->next = *insert_point;
+					*insert_point = nentry;
+					insert_point = &(nentry->next);
+					changed = true;
+					num_entries++;
+				}
+			}
+		}
+	}
+	/* okay, we're done looking at this batch of options. */
+	/* find earliest expiration time */
+	for (p = &(rt->rt6i_rdnss); *p != NULL; p = &((*p)->next)) {
+		if ((*p)->lifetime != INFINITY_LIFE_TIME) {
+			if (dont_need_expires ||
+			    time_before((*p)->expires, next_expiry)) {
+				next_expiry = (*p)->expires;
+				dont_need_expires = false;
+			}
+		}
+	}
+	/* reset expiration timer */
+	if (dont_need_expires)
+		del_timer(&rdns6_chk_timer);
+	else
+		mod_timer(&rdns6_chk_timer, next_expiry);
+
+	/* notify userland if our DNS list has changed */
+	if (changed)
+		inet6_ifinfo_notify(RTM_NEWLINK, dev);
+
+	/* DEBUGGING */
+	printk(KERN_WARNING "RDNSS RA from gateway %x:%x:%x:%x:%x:%x:%x:%x\n",
+	       ntohs(rt->rt6i_gateway.s6_addr16[0]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[1]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[2]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[3]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[4]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[5]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[6]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[7]));
+	for (p = &(rt->rt6i_rdnss); *p != NULL; p = &((*p)->next)) {
+		printk(KERN_WARNING " - %x:%x:%x:%x:%x:%x:%x:%x "
+		       "(lifetime %d)\n",
+		       ntohs((*p)->rdnss.s6_addr16[0]),
+		       ntohs((*p)->rdnss.s6_addr16[1]),
+		       ntohs((*p)->rdnss.s6_addr16[2]),
+		       ntohs((*p)->rdnss.s6_addr16[3]),
+		       ntohs((*p)->rdnss.s6_addr16[4]),
+		       ntohs((*p)->rdnss.s6_addr16[5]),
+		       ntohs((*p)->rdnss.s6_addr16[6]),
+		       ntohs((*p)->rdnss.s6_addr16[7]),
+		       (*p)->lifetime);
+	}
+}
+
+static void rdns6_expire(unsigned long _ignore) {
+	struct rdns6_info **p;
+	unsigned long now;
+	
+	//spin_lock_bh(&rdns6_expire_lock);
+	now = jiffies;
+
+	del_timer(&rdns6_chk_timer);
+
+	/* find expired DNS entries & delete them */
+	for (p = &(rt->rt6i_rdnss); *p != NULL; ) {
+		if (time_before((*p)->expires, now)) {
+			struct rdns6_info *r6i = (*p);
+			*p = (*p)->next;
+			kfree(r6i);
+			continue;
+		}
+		p = &((*p)->next);
+	}
+	/* reset */
+	add_timer(&rdns6_chk_timer);
+}
+/**
+ notes on draft:
+   server list should be kept per-router so that the resolv.conf doesn't
+   ping-pong when two routers are broadcasting RAs.
+
+   DNS timeout: like RA, router is responsible for broadcasting w/
+   time < timeout.  What if about to expire?  Can/should give RS?
+
+   use fib6_clean_all to implement rdns6_expire?  this will walk all routes.
+   (maybe overkill)
+
+   bug: how to lock rt6_info while we're mutating dns entries?
+
+   bug: how to update timer appropriately; when we modify one rt6_info,
+   we don't want to scan all.  so only shorten timer (which means sometimes
+   we'll trigger timer when it's not needed).  At some point
+   we need to del_timer (when?)
+
+   bug: when route is deleted (RA times out?) we need to free the
+   DNS server list.  (can't find where the rt6_info is deallocated?)
+
+   bug: use expire_lock to ensure we don't run expiry multiple times
+   concurrently.
+
+   xxx: implement appropriate fill message to export the server list
+   via netlink.
+
+   xxx: use round_jiffies?
+*/
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/net/ipv6/ndisc.c
linux-2.6.22-rc5/net/ipv6/ndisc.c
--- linux-2.6.22-rc5-orig/net/ipv6/ndisc.c	2007-06-16 22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/net/ipv6/ndisc.c	2007-06-19 16:02:36.000000000 -0400
@@ -15,6 +15,8 @@
 /*
  *	Changes:
  *
+ *	C. Scott Ananian		:	RDNSS-in-RA support.
+ *
  *	Lars Fenneberg			:	fixed MTU setting on receipt
  *						of an RA.
  *
@@ -75,6 +77,7 @@
 #include <net/protocol.h>
 #include <net/ndisc.h>
 #include <net/ip6_route.h>
+#include <net/ip6_rdnss.h>
 #include <net/addrconf.h>
 #include <net/icmp.h>

@@ -155,12 +158,16 @@ struct neigh_table nd_tbl = {
 };

 /* ND options */
+#define __ND_OPT_RDNSS_MAX	6 /* 3 new servers + 3 cancellations */
+
 struct ndisc_options {
 	struct nd_opt_hdr *nd_opt_array[__ND_OPT_ARRAY_MAX];
 #ifdef CONFIG_IPV6_ROUTE_INFO
 	struct nd_opt_hdr *nd_opts_ri;
 	struct nd_opt_hdr *nd_opts_ri_end;
 #endif
+	int                nd_opts_rdnss_cnt;
+	struct nd_opt_hdr *nd_opts_rdnss[__ND_OPT_RDNSS_MAX];
 };

 #define nd_opts_src_lladdr	nd_opt_array[ND_OPT_SOURCE_LL_ADDR]
@@ -266,6 +273,12 @@ static struct ndisc_options *ndisc_parse
 				ndopts->nd_opts_ri = nd_opt;
 			break;
 #endif
+		case ND_OPT_RDNSS_INFO:
+			/* limit # of RDNSS options accepted to prevent DoS */
+			if (ndopts->nd_opts_rdnss_cnt < __ND_OPT_RDNSS_MAX)
+				ndopts->nd_opts_rdnss
+					[ndopts->nd_opts_rdnss_cnt++]= nd_opt;
+			break;
 		default:
 			/*
 			 * Unknown options must be silently ignored,
@@ -1045,7 +1058,36 @@ static void ndisc_router_discovery(struc
 	/*
 	 * Remember the managed/otherconf flags from most recently
 	 * received RA message (RFC 2462) -- yoshfuji
 	 */
+	/* From RFC2462, section 5.5.3:
+	  On receipt of a valid Router Advertisement (as defined in
+   [DISCOVERY]), a host copies the value of the advertisement's M bit
+   into ManagedFlag. If the value of ManagedFlag changes from FALSE to
+   TRUE, and the host is not already running the stateful address
+   autoconfiguration protocol, the host should invoke the stateful
+   address autoconfiguration protocol, requesting both address
+   information and other information.  If the value of the ManagedFlag
+   changes from TRUE to FALSE, the host should continue running the
+   stateful address autoconfiguration, i.e., the change in the value of
+   the ManagedFlag has no effect.  If the value of the flag stays
+   unchanged, no special action takes place. In particular, a host MUST
+   NOT reinvoke stateful address configuration if it is already
+   participating in the stateful protocol as a result of an earlier
+   advertisement.
+
+   An advertisement's O flag field is processed in an analogous manner.
+   A host copies the value of the O flag into OtherConfigFlag. If the
+   value of OtherConfigFlag changes from FALSE to TRUE, the host should
+   invoke the stateful autoconfiguration protocol, requesting
+   information (excluding addresses if ManagedFlag is set to FALSE).  If
+   the value of the OtherConfigFlag changes from TRUE to FALSE, the host
+   should continue running the stateful address autoconfiguration
+   protocol, i.e., the change in the value of OtherConfigFlag has no
+   effect. If the value of the flag stays unchanged, no special action
+   takes place. In particular, a host MUST NOT reinvoke stateful
+   configuration if it is already participating in the stateful protocol
+   as a result of an earlier advertisement.
+	*/
 	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED |
 				IF_RA_OTHERCONF)) |
 				(ra_msg->icmph.icmp6_addrconf_managed ?
@@ -1187,6 +1232,12 @@ skip_defrtr:
 	}
 #endif

+	if (rt && ndopts.nd_opts_rdnss_cnt) {
+		rdns6_rcv(in6_dev, rt,
+			  (struct nd_opt_rdnss **) ndopts.nd_opts_rdnss,
+			  ndopts.nd_opts_rdnss_cnt);
+	}
+
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_pi;

--
                         ( http://cscott.net/ )
