From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Fri, 12 Sep 2003 15:36:50 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309121534240.1445-100000@linux-udp12861866uds>
References: <20030911192507.0b3f2633.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>,
   KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030911192507.0b3f2633.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Yes, rebuild the patch against current 2.6.x

Patch against 2.6.0-test5 follows.

Thanks,

- KK

diff -ruN linux-2.6.0-test5.org/include/linux/ipv6.h linux-2.6.0-test5/include/linux/ipv6.h
--- linux-2.6.0-test5.org/include/linux/ipv6.h	2003-09-08 12:50:17.000000000 -0700
+++ linux-2.6.0-test5/include/linux/ipv6.h	2003-09-12 12:33:14.000000000 -0700
@@ -122,6 +122,52 @@
 	struct	in6_addr	daddr;
 };

+/*
+ * This structure contains configuration options per IPv6 link.
+ */
+struct ipv6_devconf {
+	__s32		forwarding;
+	__s32		hop_limit;
+	__s32		mtu6;
+	__s32		accept_ra;
+	__s32		accept_redirects;
+	__s32		autoconf;
+	__s32		dad_transmits;
+	__s32		rtr_solicits;
+	__s32		rtr_solicit_interval;
+	__s32		rtr_solicit_delay;
+#ifdef CONFIG_IPV6_PRIVACY
+	__s32		use_tempaddr;
+	__s32		temp_valid_lft;
+	__s32		temp_prefered_lft;
+	__s32		regen_max_retry;
+	__s32		max_desync_factor;
+#endif
+	void		*sysctl;
+};
+
+/* index values for the variables in ipv6_devconf */
+enum {
+	DEVCONF_FORWARDING = 0,
+	DEVCONF_HOPLIMIT,
+	DEVCONF_MTU6,
+	DEVCONF_ACCEPT_RA,
+	DEVCONF_ACCEPT_REDIRECTS,
+	DEVCONF_AUTOCONF,
+	DEVCONF_DAD_TRANSMITS,
+	DEVCONF_RTR_SOLICITS,
+	DEVCONF_RTR_SOLICIT_INTERVAL,
+	DEVCONF_RTR_SOLICIT_DELAY,
+#ifdef CONFIG_IPV6_PRIVACY
+	DEVCONF_USE_TEMPADDR,
+	DEVCONF_TEMP_VALID_LFT,
+	DEVCONF_TEMP_PREFERED_LFT,
+	DEVCONF_REGEN_MAX_RETRY,
+	DEVCONF_MAX_DESYNC_FACTOR,
+#endif
+	DEVCONF_MAX
+};
+
 #ifdef __KERNEL__
 #include <linux/in6.h>          /* struct sockaddr_in6 */
 #include <linux/icmpv6.h>
diff -ruN linux-2.6.0-test5.org/include/linux/rtnetlink.h linux-2.6.0-test5/include/linux/rtnetlink.h
--- linux-2.6.0-test5.org/include/linux/rtnetlink.h	2003-09-08 12:50:21.000000000 -0700
+++ linux-2.6.0-test5/include/linux/rtnetlink.h	2003-09-12 12:33:14.000000000 -0700
@@ -508,10 +508,12 @@
 #define IFLA_MASTER IFLA_MASTER
 	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
 #define IFLA_WIRELESS IFLA_WIRELESS
+	IFLA_PROTINFO,		/* Protocol specific information for a link */
+#define IFLA_PROTINFO IFLA_PROTINFO
 };


-#define IFLA_MAX IFLA_WIRELESS
+#define IFLA_MAX IFLA_PROTINFO

 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
@@ -545,6 +547,18 @@
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
diff -ruN linux-2.6.0-test5.org/include/net/if_inet6.h linux-2.6.0-test5/include/net/if_inet6.h
--- linux-2.6.0-test5.org/include/net/if_inet6.h	2003-09-08 12:50:33.000000000 -0700
+++ linux-2.6.0-test5/include/net/if_inet6.h	2003-09-12 12:33:14.000000000 -0700
@@ -16,7 +16,12 @@
 #define _NET_IF_INET6_H

 #include <net/snmp.h>
+#include <linux/ipv6.h>

+/* inet6_dev.if_flags */
+
+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10

@@ -132,28 +137,6 @@
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
diff -ruN linux-2.6.0-test5.org/net/ipv6/addrconf.c linux-2.6.0-test5/net/ipv6/addrconf.c
--- linux-2.6.0-test5.org/net/ipv6/addrconf.c	2003-09-08 12:50:29.000000000 -0700
+++ linux-2.6.0-test5/net/ipv6/addrconf.c	2003-09-12 15:01:10.000000000 -0700
@@ -2529,7 +2529,109 @@
 	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
 }

+static void inline ipv6_store_devconf(struct ipv6_devconf *cnf,
+				__s32 *array, int bytes)
+{
+	memset(array, 0, bytes);
+	array[DEVCONF_FORWARDING] = cnf->forwarding;
+	array[DEVCONF_HOPLIMIT] = cnf->hop_limit;
+	array[DEVCONF_MTU6] = cnf->mtu6;
+	array[DEVCONF_ACCEPT_RA] = cnf->accept_ra;
+	array[DEVCONF_ACCEPT_REDIRECTS] = cnf->accept_redirects;
+	array[DEVCONF_AUTOCONF] = cnf->autoconf;
+	array[DEVCONF_DAD_TRANSMITS] = cnf->dad_transmits;
+	array[DEVCONF_RTR_SOLICITS] = cnf->rtr_solicits;
+	array[DEVCONF_RTR_SOLICIT_INTERVAL] = cnf->rtr_solicit_interval;
+	array[DEVCONF_RTR_SOLICIT_DELAY] = cnf->rtr_solicit_delay;
+#ifdef CONFIG_IPV6_PRIVACY
+	array[DEVCONF_USE_TEMPADDR] = cnf->use_tempaddr;
+	array[DEVCONF_TEMP_VALID_LFT] = cnf->temp_valid_lft;
+	array[DEVCONF_TEMP_PREFERED_LFT] = cnf->temp_prefered_lft;
+	array[DEVCONF_REGEN_MAX_RETRY] = cnf->regen_max_retry;
+	array[DEVCONF_MAX_DESYNC_FACTOR] = cnf->max_desync_factor;
+#endif
+}
+
+static int inet6_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+			    struct inet6_dev *idev,
+			    int type, u32 pid, u32 seq)
+{
+	__s32			*array = NULL;
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
+
+	/* return the device flags */
+	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
+
+	/* return the device sysctl params */
+	if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_ATOMIC)) == NULL)
+		goto rtattr_failure;
+	ipv6_store_devconf(&idev->cnf, array, DEVCONF_MAX * sizeof(*array));
+	RTA_PUT(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(*array), array);
+
+	/* XXX - Statistics/MC not implemented */
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
diff -ruN linux-2.6.0-test5.org/net/ipv6/ndisc.c linux-2.6.0-test5/net/ipv6/ndisc.c
--- linux-2.6.0-test5.org/net/ipv6/ndisc.c	2003-09-08 12:50:07.000000000 -0700
+++ linux-2.6.0-test5/net/ipv6/ndisc.c	2003-09-12 12:33:14.000000000 -0700
@@ -1044,6 +1044,17 @@
 		in6_dev->if_flags |= IF_RA_RCVD;
 	}

+	/*
+	 * Remember the managed/otherconf flags from most recently
+	 * received RA message (RFC 2462) -- yoshfuji
+	 */
+	in6_dev->if_flags = (in6_dev->if_flags & ~(IF_RA_MANAGED |
+				IF_RA_OTHERCONF)) |
+				(ra_msg->icmph.icmp6_addrconf_managed ?
+					IF_RA_MANAGED : 0) |
+				(ra_msg->icmph.icmp6_addrconf_other ?
+					IF_RA_OTHERCONF : 0);
+
 	lifetime = ntohs(ra_msg->icmph.icmp6_rt_lifetime);

 	rt = rt6_get_dflt_router(&skb->nh.ipv6h->saddr, skb->dev);
