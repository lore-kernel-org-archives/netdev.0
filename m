From: "C. Scott Ananian" <cscott@laptop.org>
Subject: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Fri, 22 Jun 2007 19:26:19 -0400
Message-ID: <c6d9bea0706221626h434d17d0l6dc3a6a513601546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.251]:27961 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbXFVX0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 19:26:20 -0400
Received: by an-out-0708.google.com with SMTP id d31so210840and
        for <netdev@vger.kernel.org>; Fri, 22 Jun 2007 16:26:20 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Attached is my first draft of a patch to implement RDNSS-in-Router
Advertisements support for IPv6 (
http://tools.ietf.org/html/draft-jeong-dnsop-ipv6-dns-discovery-12 )
as implemented in radvd ( http://www.litech.org/radvd/ ).  It
currently exports the autoconfigured DNS list as /proc/net/ipv6_dns --
ultimately it ought to (a) implement inotify on this file, so that
glibc could use it like /etc/resolv.conf and get notifications when
the DNS list changes, and (b) export the DNS list via netlink as well.

Comments & discussion, please!
 --scott

[ps. i'm copy-and-pasting the patch into gmail, against my better
judgement.  let me know if it doesn't apply for you, and i'll resent
in a less-clever mail agent.]
-- 
                         ( http://cscott.net/ )


diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/include/net/ip6_fib.h
linux-2.6.22-rc5/include/net/ip6_fib.h
--- linux-2.6.22-rc5-orig/include/net/ip6_fib.h	2007-06-16
22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/include/net/ip6_fib.h	2007-06-20 14:17:58.000000000 -0400
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
+++ linux-2.6.22-rc5/include/net/ip6_rdnss.h	2007-06-21 18:16:33.000000000 -0400
@@ -0,0 +1,58 @@
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
+#if defined(__BIG_ENDIAN_BITFIELD)
+	__u8			priority:4,
+				open:1,
+				reserved1:3;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	__u8			reserved1:3,
+				open:1,
+				priority:4;
+#else
+# error not little or big endian
+#endif
+	__u8			reserved2;
+	__be32			lifetime;
+	struct in6_addr		rdnss[1];	/* 1 or more */
+};
+
+struct rdns6_entry {
+	struct rdns6_entry *	next;
+	struct in6_addr		rdnss;
+	__u8			priority;
+	__u8			open;
+	__u32			lifetime;
+	unsigned long		expires;
+};
+
+struct rdns6_info {
+	rwlock_t		lock;
+	struct timer_list	expiry_timer;
+	struct rdns6_entry *	rdnss_list;
+	struct inet6_dev *	in6_dev; /* back pointer for netlink notify */
+	int			expire_all : 1, /* remove entries on ifdown */
+				free_me : 1; /* safely free this struct */
+};
+
+/* Receive and process an RA message with the given RDNSS options. */
+extern void	rdns6_ra_rcv(struct inet6_dev *dev, struct rt6_info *rt,
+			     struct nd_opt_rdnss **opts, int opt_cnt);
+/* Expire all of the dns server info from a route (as on an ifdown). */
+extern void	rdns6_info_expire_all(struct rt6_info *rt);
+/* Delete the DNS list information from a struct rt6_info. */
+extern void	rdns6_info_del(struct rt6_info *rt);
+
+/* Generate the /proc/net/ipv6_dns file. */
+extern int	rdns6_proc_info(char *buffer, char **start,
+				off_t offset, int length);
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
+++ linux-2.6.22-rc5/net/ipv6/ip6_rdnss.c	2007-06-22 13:36:54.000000000 -0400
@@ -0,0 +1,470 @@
+/*
+ *	Recursive DNS Server autoconfiguration for IPv6
+ *      Linux INET6 implementation.  Listens to RDNSS options to
+ *      Router Advertisement messages, as specified in
+ *      http://tools.ietf.org/html/draft-jeong-dnsop-ipv6-dns-discovery-12
+ *      and implemented in radvd (http://www.litech.org/radvd/).
+ *      The published DNS server list is exported via /proc/net/ipv6_dns
+ *      (for human readability) and via netlink.
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
+/* From the specification: */
+#define INFINITY_LIFE_TIME	0xFFFFFFFF
+/* The maximum number of recursive DNS servers we'll remember per
+ * router.  We have to set some limit to prevent an easy DoS, and
+ * 3 DNS servers seems to be standard practice. */
+#define __RDNS6_MAX_ENTRIES	3
+
+static void rdns6_expire(unsigned long);
+
+/* Functions to manage the dns server entry list. */
+
+static void rdns6_entry_del(struct rdns6_entry **p) {
+	struct rdns6_entry *r6e = (*p);
+	*p = (*p)->next;
+	kfree(r6e);
+}
+
+static int rdns6_entry_update(struct rdns6_entry **p, struct in6_addr *addr,
+			      int priority, int open, uint32_t lifetime) {
+	int changed = false;
+	/* if lifetime is zero, delete this entry */
+	if (lifetime == 0) {
+		rdns6_entry_del(p);
+		return true;
+	}
+	/* otherwise, update lifetime and expiration time. */
+	if (priority != (*p)->priority) {
+		(*p)->priority = priority;
+		changed = true;
+	}
+	if (open != (*p)->open) {
+		(*p)->open = open;
+		changed = true;
+	}
+	if (lifetime > (*p)->lifetime) {
+		(*p)->lifetime = lifetime;
+		changed = true;
+	}
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
+static int rdns6_entry_cmp(struct rdns6_entry *a, struct rdns6_entry *b) {
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
+static int rdns6_expire_worse(struct rdns6_info *info,
+			      struct rdns6_entry *nentry){
+	struct rdns6_entry **worst = NULL, **p;
+	for (p = &(info->rdnss_list); *p != NULL; p = &((*p)->next)) {
+		if (worst==NULL ||
+		    rdns6_entry_cmp(*worst, *p) < 0)
+			worst = p;
+	}
+	if (worst && rdns6_entry_cmp(*worst, nentry) < 0) {
+		rdns6_entry_del(worst);
+		return true;
+	}
+	return false;
+}
+
+/* Create a new rdns6_entry entry. */
+static struct rdns6_entry *rdns6_create_entry(struct in6_addr *addr,
+					      int priority, int open,
+					      uint32_t lifetime) {
+	struct rdns6_entry *result;
+	result = kzalloc(sizeof(*result), GFP_KERNEL); /* blocks */
+	if (result) {
+		ipv6_addr_copy(&(result->rdnss), addr);
+		result->priority = priority;
+		result->open = open;
+		result->lifetime = lifetime;
+		result->expires = (lifetime==INFINITY_LIFE_TIME) ? 0 :
+			jiffies + lifetime * HZ;
+	}
+	return result;
+}
+
+/* Create a rdns6_info structure if there isn't already one attached to the
+ * struct rt6_info. */
+static DEFINE_SPINLOCK(init_lock);
+struct rdns6_info *rdns6_info(struct inet6_dev *in6_dev, struct rt6_info *rt){
+	struct rdns6_info *info;
+
+	info = rt->rt6i_rdnss;
+	if (info) return info;
+
+	/* we need to create a new rt6_info structure for this route */
+	info = kzalloc(sizeof(*info), GFP_KERNEL); /* blocks */
+	if (!info) return info; /* failure */
+	info->in6_dev = in6_dev;
+	rwlock_init(&(info->lock));
+	setup_timer(&(info->expiry_timer),
+		    rdns6_expire, (unsigned long) info);
+
+	spin_lock(&init_lock);
+	if (rt->rt6i_rdnss) {
+		kfree(info);
+		info = rt->rt6i_rdnss;
+	} else {
+		rt->rt6i_rdnss = info;
+	}
+	spin_unlock(&init_lock);
+	return info;
+}
+/* Expire all DNS servers attached to this router. */
+void rdns6_info_expire_all(struct rt6_info *rt) {
+	struct rdns6_info *info;
+	info = rt->rt6i_rdnss;
+	write_lock(&(info->lock));
+	info->expire_all = true;
+	/* wake up soon to do the expiry. */
+	mod_timer(&(info->expiry_timer), round_jiffies(jiffies));
+	write_unlock(&(info->lock));
+}
+/* Expire all DNS servers attached to this router, and then free the
+ * rdns6_info struct. */
+void rdns6_info_del(struct rt6_info *rt) {
+	struct rdns6_info *info;
+
+	spin_lock(&init_lock);
+	info = rt->rt6i_rdnss;
+	rt->rt6i_rdnss = NULL;
+	spin_unlock(&init_lock);
+	
+	write_lock(&(info->lock));
+	info->expire_all = true;
+	info->free_me = true;
+	/* wake up soon to free this structure. */
+	mod_timer(&(info->expiry_timer), round_jiffies(jiffies));
+	write_unlock(&(info->lock));
+}
+
+/* Process a newly-received RDNSS option from a Router Advertisement
+ * message. */
+void rdns6_ra_rcv(struct inet6_dev *in6_dev, struct rt6_info *rt,
+		  struct nd_opt_rdnss **opts, int opt_cnt) {
+	/* A word about locking: */
+	/* rdns6_rcv is called from ndisc_router_discovery which is holding
+	 * references to 'in6_dev' and 'rt' (don't need to worry about
+	 * them going away while we're working).  However, we do need to
+	 * protect against concurrent executions of this method, and
+	 * concurrent runs of the expiry routine. We protect the rdnss
+	 * list with a read/write lock in the container, rdns6_info. */
+	struct rdns6_entry **p, **insert_point;
+	struct rdns6_info *info;
+	int i, j, changed = false, num_entries = 0;
+	uint32_t lifetime;
+
+	/* acquire a write lock, since we're almost certainly going to mutate
+	 * our server list, if only to update expiry times. */
+	info = rdns6_info(in6_dev, rt); /* creates if necessary */
+	if (!info) return; /* bail: dns isn't important enough to oops over */
+
+	/* safety check. */
+	if (info->free_me) {
+		printk(KERN_ERR "RA received after route destroyed.\n");
+		return;
+	}
+
+	write_lock(&(info->lock));
+
+	/* first, count the # of dns server list entries we've already got */
+	for (p = &(info->rdnss_list); *p != NULL; p = &((*p)->next)) {
+		num_entries++;
+	}
+	/* now let's process all the RDNSS options in the RA */
+	insert_point = &(info->rdnss_list); /* add to the start of the list */
+	for (i=0; i<opt_cnt; i++) {
+		int len = ((int)opts[i]->length) << 3;
+		if (len < sizeof(struct nd_opt_rdnss)) {
+			printk(KERN_WARNING
+			       "ICMPv6 RA: bad RDNSS option length\n");
+			continue;
+		}
+		lifetime = ntohl(opts[i]->lifetime);
+		for (j=0; (j+1)*sizeof(struct in6_addr) <= len-8; j++) {
+			struct in6_addr *addr = &(opts[i]->rdnss[j]);
+			int priority = opts[i]->priority;
+			int open = opts[i]->open;
+			/* find this entry in the list. */
+			struct rdns6_entry **p;
+			for (p = &(info->rdnss_list);
+			     *p != NULL;
+			     p = &((*p)->next)) {
+				if (ipv6_addr_equal(addr, &((*p)->rdnss)))
+					break;
+			}
+			if (*p) {
+				/* we found an existing entry, update it. */
+				if (rdns6_entry_update(p, addr, priority,
+						       open, lifetime))
+					changed = true;
+				if (lifetime == 0)
+					num_entries--;
+				else
+					insert_point = &((*p)->next);
+			} else if (lifetime) {
+				/* no existing entry. make one. */
+				struct rdns6_entry *nentry =
+					rdns6_create_entry(addr, priority,
+							   open, lifetime);
+				/* make room if we must (and if we can) */
+				if (num_entries >= __RDNS6_MAX_ENTRIES) {
+					/* see if we can expire an entry */
+					if (rdns6_expire_worse(info, nentry))
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
+
+	/* run the expiry timer sometime soon to recompute next expiry time */
+	mod_timer(&(info->expiry_timer), round_jiffies(jiffies));
+
+	write_unlock(&(info->lock)); /* release rdnss list lock */
+
+	/* notify userland if our DNS list changed */
+	if (changed)
+		inet6_ifinfo_notify(RTM_NEWLINK, in6_dev);
+
+#if 0
+	printk(KERN_WARNING "RDNSS RA from gateway %x:%x:%x:%x:%x:%x:%x:%x"
+	       "%s\n",
+	       ntohs(rt->rt6i_gateway.s6_addr16[0]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[1]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[2]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[3]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[4]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[5]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[6]),
+	       ntohs(rt->rt6i_gateway.s6_addr16[7]),
+	       (changed?" (NEW)":""));
+	rdns6_dump(info);
+#endif
+}
+
+/* This callback is called from a timer to check all dns servers in the list
+ * and expire those that need it.  It then resets the timer to the next
+ * expiration time.  The callback is also triggered when a modification to
+ * the server list is made, so that the next expiration time can be computed
+ * and the timer reset. */
+static void rdns6_expire(unsigned long data) {
+	struct rdns6_info *info = (struct rdns6_info *)data;
+	struct rdns6_entry **p;
+	int dont_need_expires = true, expire_all, free_me, changed = false;
+	unsigned long next_expiry = 0;
+	unsigned long now;
+	
+	write_lock(&(info->lock)); /* we'll probably be expiring stuff */
+
+	now = jiffies;
+	del_timer(&(info->expiry_timer));
+	expire_all = info->expire_all;
+	free_me = info->free_me;
+
+	/* find expired DNS entries & delete them, finding next earliest
+	 * expiry time in the process. */
+	for (p = &(info->rdnss_list); *p != NULL; ) {
+		if (expire_all || (*p)->lifetime != INFINITY_LIFE_TIME) {
+			if (expire_all || time_before((*p)->expires, now)) {
+				/* this entry has expired! */
+#if 0
+				printk(KERN_WARNING "Expiring %u %lu %lu\n",
+				       (*p)->lifetime, (*p)->expires, now);
+#endif
+				rdns6_entry_del(p);
+				changed = true;
+				continue;
+			}
+			if (dont_need_expires ||
+			    time_before((*p)->expires, next_expiry)) {
+				/* this entry expires next (so far) */
+				next_expiry = (*p)->expires;
+				dont_need_expires = false;
+			}
+		}
+		p = &((*p)->next);
+	}
+
+	/* reset timer */
+	if (!dont_need_expires)
+		mod_timer(&(info->expiry_timer), round_jiffies(next_expiry));
+
+#if 0
+	printk(KERN_WARNING "Ran expiry callback: %s%s%s%s\n",
expire_all?"expire,":"", free_me?"free,":"", changed?"changed,":"",
dont_need_expires?"dont,":"");
+	rdns6_dump(info);
+#endif
+	write_unlock(&(info->lock));
+
+	if (free_me)
+		/* free this structure if we're done with it */
+		kfree(info);
+	else if (changed)
+		/* notify userland */
+		inet6_ifinfo_notify(RTM_NEWLINK, info->in6_dev);
+}
+
+
+/* ******** Functions to implement the /proc file interface ********* */
+/* We format the /proc file so that it is compatible with the format
+ * of legacy /etc/resolv.conf.  This allows you to symlink /etc/resolv.conf
+ * to /proc if you know you'll always have IPv6 connectivity and DNS
+ * (or just for testing).
+ */
+struct rdns6_proc_arg
+{
+	char *buffer;
+	int offset;
+	int length;
+	int skip;
+	int len;
+};
+#define RDNS6_INFO_LEN	(43 + 1 + 11 + (8*4)+7 + 1)
+
+static int rdns6_info_entry(struct rdns6_entry *entry, int idx,
+			    struct rdns6_proc_arg *arg)
+{
+	if (arg->skip < arg->offset / RDNS6_INFO_LEN) {
+		arg->skip++;
+		return 0; /* keep going */
+	}
+
+	if ((arg->len + RDNS6_INFO_LEN) >= arg->length)
+		return 1; /* stop now */
+
+	if ((arg->len + RDNS6_INFO_LEN) >= PAGE_SIZE)
+		return 1; /* stop now */
+
+	/* dump priority, lifetime, and index information in a comment
+	 * before the nameserver line. */
+	arg->len += sprintf(arg->buffer + arg->len,
+			    "# index %1d, priority %2d, lifetime %10u\n"
+			    "nameserver "
+			    "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x\n",
+			    idx, entry->priority, entry->lifetime,
+			    ntohs(entry->rdnss.s6_addr16[0]),
+			    ntohs(entry->rdnss.s6_addr16[1]),
+			    ntohs(entry->rdnss.s6_addr16[2]),
+			    ntohs(entry->rdnss.s6_addr16[3]),
+			    ntohs(entry->rdnss.s6_addr16[4]),
+			    ntohs(entry->rdnss.s6_addr16[5]),
+			    ntohs(entry->rdnss.s6_addr16[6]),
+			    ntohs(entry->rdnss.s6_addr16[7]));
+}
+static int rdns6_info_rt(struct rt6_info *rt, void *p_arg)
+{
+	struct rdns6_proc_arg *arg = (struct rdns6_proc_arg *) p_arg;
+	struct rdns6_info *info;
+	struct rdns6_entry *entry;
+	int i, retval = 0;
+
+	/* get the info object */
+	info = rt->rt6i_rdnss;
+	if (!info) return 0;
+	/* acquire the read lock. */
+	read_lock(&(info->lock));
+	/* iterate over the entries. */
+	for (i=0, entry=info->rdnss_list; entry; entry=entry->next, i++) {
+		if (rdns6_info_entry(entry, i, arg)) {
+			retval=-1; /* done, stop now */
+			break;
+		}
+	}
+	/* release locks, we're done. */
+	read_unlock(&(info->lock));
+	return retval;
+}
+
+int rdns6_proc_info(char *buffer, char **start, off_t offset, int length)
+{
+	struct rdns6_proc_arg arg = {
+		.buffer = buffer,
+		.offset = offset,
+		.length = length,
+	};
+
+	fib6_clean_all(rdns6_info_rt, 0, &arg);
+
+	*start = buffer;
+	*start += offset % RDNS6_INFO_LEN;
+	arg.len -= offset % RDNS6_INFO_LEN;
+
+	if (arg.len > length)
+		arg.len = length;
+	if (arg.len < 0)
+		arg.len = 0;
+
+	return arg.len;
+}
+
+/**
+ notes on RDNS-over-RA draft:
+   server list should be kept per-router so that the resolv.conf doesn't
+   ping-pong when two routers are broadcasting RAs.
+
+   DNS timeout: like RA, router is responsible for broadcasting w/
+   time < timeout.  What if about to expire?  Can/should give RS?
+
+   No 'search' option?
+
+ To-do list for kernel patch:
+   xxx: implement appropriate fill message to export the server list
+   via netlink.
+
+   xxx: implement inotify for /proc/net/ipv6_dns
+     - allows it to by symlinked from /etc/resolv.conf
+     - then glibc can reload resolver list at appropriate times.
+
+ To-do list for glibc nss-dns:
+   should use inotify to listen for changes to /etc/resolv.conf
+   should listen to changes in /proc/net/ipv6_dns (or netlink)
+
+ To-do list for network-manager:
+   listen to netlink messages, merge into /etc/resolv.conf
+*/
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/net/ipv6/ndisc.c
linux-2.6.22-rc5/net/ipv6/ndisc.c
--- linux-2.6.22-rc5-orig/net/ipv6/ndisc.c	2007-06-16 22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/net/ipv6/ndisc.c	2007-06-21 18:18:45.000000000 -0400
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
@@ -1045,7 +1058,39 @@ static void ndisc_router_discovery(struc
 	/*
 	 * Remember the managed/otherconf flags from most recently
 	 * received RA message (RFC 2462) -- yoshfuji
+	 * XXX: these should really be kept per-RA (instead of per-interface)
+	 *      since we may be getting advertisements from multiple routers.
+	 *      -- csa
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
+		rdns6_ra_rcv(in6_dev, rt,
+			     (struct nd_opt_rdnss **) ndopts.nd_opts_rdnss,
+			     ndopts.nd_opts_rdnss_cnt);
+	}
+
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_pi;
diff -ruHpN -X dontdiff linux-2.6.22-rc5-orig/net/ipv6/route.c
linux-2.6.22-rc5/net/ipv6/route.c
--- linux-2.6.22-rc5-orig/net/ipv6/route.c	2007-06-16 22:09:12.000000000 -0400
+++ linux-2.6.22-rc5/net/ipv6/route.c	2007-06-21 17:24:15.000000000 -0400
@@ -48,6 +48,7 @@
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
+#include <net/ip6_rdnss.h>
 #include <net/ndisc.h>
 #include <net/addrconf.h>
 #include <net/tcp.h>
@@ -215,6 +216,9 @@ static void ip6_dst_destroy(struct dst_e
 		rt->rt6i_idev = NULL;
 		in6_dev_put(idev);
 	}
+
+	if (rt->rt6i_rdnss)
+		rdns6_info_del(rt);
 }

 static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
@@ -229,6 +233,8 @@ static void ip6_dst_ifdown(struct dst_en
 			rt->rt6i_idev = loopback_idev;
 			in6_dev_put(idev);
 		}
+		if (rt->rt6i_rdnss)
+			rdns6_info_expire_all(rt);
 	}
 }

@@ -2565,6 +2571,10 @@ void __init ip6_route_init(void)
 		p->owner = THIS_MODULE;

 	proc_net_fops_create("rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+
+	p = proc_net_create("ipv6_dns", S_IRUGO, rdns6_proc_info);
+	if (p)
+		p->owner = THIS_MODULE;
 #endif
 #ifdef CONFIG_XFRM
 	xfrm6_init();
@@ -2586,6 +2596,7 @@ void ip6_route_cleanup(void)
 #ifdef CONFIG_PROC_FS
 	proc_net_remove("ipv6_route");
 	proc_net_remove("rt6_stats");
+	proc_net_remove("ipv6_dns");
 #endif
 #ifdef CONFIG_XFRM
 	xfrm6_fini();
