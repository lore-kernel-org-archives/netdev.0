From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Tue, 29 Jul 2003 17:33:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307291659190.7490-100000@DYN318430>
References: <20030724000705.4662df54.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030724000705.4662df54.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Another idea is to define the user structure:
>
> struct ipv6_kernel_devconf {
> 	struct ipv6_user_devconf vals;
> 	void *sysctl;
> };

After the latest suggestion to use array instead of a structure,
the patch being submitted doesn't make this change. I hope that is
acceptable.

> > > 3) Change "int" members of struct "ipv6_devconf" to "s32".
> >
> > All members (except use_tempaddr) seem to be >=0, should I change
> > the definition to __u32 instead ?
>
> __u32 sounds fine.

Since use_tempaddr can be -1, I am for the time being keeping all
the variables as s32. If this is changed to __u32, then some code in
addrconf.c needs to be modified.

> I think something more like route metrics, ie. an array is more appropriate

I guess you mean only the user interface to use route type metrics, not
modify the existing cnf implementation to use this concept (eg remove the
structure and define cnf_metrics[] with code similar to RTAX_HOPLIMIT,
etc). So this patch doesn't change the usage in kernel, except now the
user interface returns the config params in an array format.

This patch applies on top of the prefix list patch.

Thanks,

- KK

PS : Alexey's patch for ipv4 defines IFLA_INET_MAX as IFLA_INET_CONF,
probably that should be IFLA_INET_MCAST. Another thing that confused me
is that there is no addrconf_sysctl_register for ipv6_devconf, while it
is being unregister'd (which would fail?).

------------------------------------------------------------------------------
diff -ruN 1/linux-2.6.0-test1.plist/include/linux/ipv6.h linux-2.6.0-test1.new/include/linux/ipv6.h
--- 1/linux-2.6.0-test1.plist/include/linux/ipv6.h	2003-07-13 20:36:33.000000000 -0700
+++ linux-2.6.0-test1.new/include/linux/ipv6.h	2003-07-29 17:02:57.000000000 -0700
@@ -122,6 +122,30 @@
 	struct	in6_addr	daddr;
 };

+/*
+ * This structure contains configuration options per IPv6 link.
+ */
+struct ipv6_devconf {
+	s32		forwarding;
+	s32		hop_limit;
+	s32		mtu6;
+	s32		accept_ra;
+	s32		accept_redirects;
+	s32		autoconf;
+	s32		dad_transmits;
+	s32		rtr_solicits;
+	s32		rtr_solicit_interval;
+	s32		rtr_solicit_delay;
+#ifdef CONFIG_IPV6_PRIVACY
+	s32		use_tempaddr;
+	s32		temp_valid_lft;
+	s32		temp_prefered_lft;
+	s32		regen_max_retry;
+	s32		max_desync_factor;
+#endif
+	void		*sysctl;
+};
+
 #ifdef __KERNEL__
 #include <linux/in6.h>          /* struct sockaddr_in6 */
 #include <linux/icmpv6.h>
diff -ruN 1/linux-2.6.0-test1.plist/include/linux/rtnetlink.h linux-2.6.0-test1.new/include/linux/rtnetlink.h
--- 1/linux-2.6.0-test1.plist/include/linux/rtnetlink.h	2003-07-29 12:05:26.000000000 -0700
+++ linux-2.6.0-test1.new/include/linux/rtnetlink.h	2003-07-29 14:49:16.000000000 -0700
@@ -477,10 +477,12 @@
 #define IFLA_MASTER IFLA_MASTER
 	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
 #define IFLA_WIRELESS IFLA_WIRELESS
+	IFLA_PROTINFO,		/* Protocol specific information per link */
+#define IFLA_PROTINFO IFLA_PROTINFO
 };


-#define IFLA_MAX IFLA_WIRELESS
+#define IFLA_MAX IFLA_PROTINFO

 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
@@ -514,6 +516,18 @@
    for IPIP tunnels, when route to endpoint is allowed to change)
  */

+/* Subtype attributes for IFLA_PROTINFO */
+enum
+{
+	IFLA_INET6_UNSPEC,
+	IFLA_INET6_FLAGS,	/* link flags			*/
+	IFLA_INET6_CONF,	/* sysctl parameters		*/
+	IFLA_INET6_STATS,	/* statistics			*/
+	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
+};
+
+#define IFLA_INET6_MAX	IFLA_INET6_MCAST
+
 /*****************************************************************
  *		Traffic control messages.
  ****/
diff -ruN 1/linux-2.6.0-test1.plist/include/net/if_inet6.h linux-2.6.0-test1.new/include/net/if_inet6.h
--- 1/linux-2.6.0-test1.plist/include/net/if_inet6.h	2003-07-13 20:38:43.000000000 -0700
+++ linux-2.6.0-test1.new/include/net/if_inet6.h	2003-07-29 16:28:56.000000000 -0700
@@ -16,6 +16,7 @@
 #define _NET_IF_INET6_H

 #include <net/snmp.h>
+#include <linux/ipv6.h>

 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10
@@ -132,28 +133,6 @@
 #define	IFA_SITE	IPV6_ADDR_SITELOCAL
 #define	IFA_GLOBAL	0x0000U

-struct ipv6_devconf
-{
-	int		forwarding;
-	int		hop_limit;
-	int		mtu6;
-	int		accept_ra;
-	int		accept_redirects;
-	int		autoconf;
-	int		dad_transmits;
-	int		rtr_solicits;
-	int		rtr_solicit_interval;
-	int		rtr_solicit_delay;
-#ifdef CONFIG_IPV6_PRIVACY
-	int		use_tempaddr;
-	int		temp_valid_lft;
-	int		temp_prefered_lft;
-	int		regen_max_retry;
-	int		max_desync_factor;
-#endif
-	void		*sysctl;
-};
-
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;
 	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6);
diff -ruN 1/linux-2.6.0-test1.plist/net/ipv6/addrconf.c linux-2.6.0-test1.new/net/ipv6/addrconf.c
--- 1/linux-2.6.0-test1.plist/net/ipv6/addrconf.c	2003-07-29 12:05:26.000000000 -0700
+++ linux-2.6.0-test1.new/net/ipv6/addrconf.c	2003-07-29 15:54:42.000000000 -0700
@@ -2510,7 +2510,112 @@
 	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
 }

+static int inline ipv6_store_devconf(struct ipv6_devconf *cnf, int *array)
+{
+	int i = 0;
+
+	array[i++] = cnf->forwarding;
+	array[i++] = cnf->hop_limit;
+	array[i++] = cnf->mtu6;
+	array[i++] = cnf->accept_ra;
+	array[i++] = cnf->accept_redirects;
+	array[i++] = cnf->autoconf;
+	array[i++] = cnf->dad_transmits;
+	array[i++] = cnf->rtr_solicits;
+	array[i++] = cnf->rtr_solicit_interval;
+	array[i++] = cnf->rtr_solicit_delay;
+#ifdef CONFIG_IPV6_PRIVACY
+	array[i++] = cnf->use_tempaddr;
+	array[i++] = cnf->temp_valid_lft;
+	array[i++] = cnf->temp_prefered_lft;
+	array[i++] = cnf->regen_max_retry;
+	array[i++] = cnf->max_desync_factor;
+#endif
+	return i;	/* actual number of elements */
+}
+
+static int inet6_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+			    struct inet6_dev *idev,
+			    int type, u32 pid, u32 seq)
+{
+	int			num_items;
+	int			*array = NULL;
+	struct ifinfomsg	*r;
+	struct nlmsghdr 	*nlh;
+	unsigned char		*b = skb->tail;
+	struct rtattr		*subattr;
+
+	nlh = NLMSG_PUT(skb, pid, seq, type, sizeof(*r));
+	if (pid) nlh->nlmsg_flags |= NLM_F_MULTI;
+	r = NLMSG_DATA(nlh);
+	r->ifi_family = AF_INET6;
+	r->ifi_type = dev->type;
+	r->ifi_index = dev->ifindex;
+	r->ifi_flags = dev->flags;
+	r->ifi_change = 0;
+	if (!netif_running(dev) || !netif_carrier_ok(dev))
+		r->ifi_flags &= ~IFF_RUNNING;
+	else
+		r->ifi_flags |= IFF_RUNNING;
+
+	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+
+	subattr = (struct rtattr*)skb->tail;
+
+	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
+	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
+
+	/*
+	 * using sizeof(struct) can be wrong due to padding, but it is the
+	 * the maximum possible number of items, which gets corrected later.
+	 */
+	num_items = sizeof(struct ipv6_devconf) / sizeof(*array);
+	if ((array = kmalloc(num_items, GFP_KERNEL)) == NULL)
+		goto rtattr_failure;
+	num_items = ipv6_store_devconf(&idev->cnf, array);
+	RTA_PUT(skb, IFLA_INET6_CONF, num_items * sizeof(*array), array);
+	/* XXX stats/MC not implemented */
+	subattr->rta_len = skb->tail - (u8*)subattr;
+
+	nlh->nlmsg_len = skb->tail - b;
+	kfree(array);
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	if (array)
+		kfree(array);
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int inet6_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx, err;
+	int s_idx = cb->args[0];
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	read_lock(&dev_base_lock);
+	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
+		if (idx < s_idx)
+			continue;
+		if ((idev = in6_dev_get(dev)) == NULL)
+			continue;
+		err = inet6_fill_ifinfo(skb, dev, idev, RTM_NEWLINK,
+				NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq);
+		in6_dev_put(idev);
+		if (err <= 0)
+			break;
+	}
+	read_unlock(&dev_base_lock);
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
+	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
 	[RTM_DELADDR - RTM_BASE] = { .doit	= inet6_rtm_deladdr, },
 	[RTM_GETADDR - RTM_BASE] = { .dumpit	= inet6_dump_ifaddr, },
