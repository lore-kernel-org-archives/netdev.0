From: Krishna Kumar <krkumar@us.ibm.com>
Subject: Re: O/M flags for 2.4.22 (was "Re: O/M flags against 2.6.0-test1")
Date: Tue, 16 Sep 2003 15:06:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309161503110.10766-100000@linux-udp12861866uds>
References: <20030912171921.37cab171.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>,
   KK <krkumar@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030912171921.37cab171.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I applied the 2.6.x version, but this 2.4.x version does
> not apply cleanly, there are a bunch of rejects.

Sorry about that, will remember to use the latest version.

The patch is against 2.4.22-bk19.

Thanks,

- KK

diff -ruN linux-2.4.22.org/include/linux/ipv6.h linux-2.4.22/include/linux/ipv6.h
--- linux-2.4.22.org/include/linux/ipv6.h	2003-09-16 14:32:11.000000000 -0700
+++ linux-2.4.22/include/linux/ipv6.h	2003-09-16 14:33:10.000000000 -0700
@@ -100,6 +100,52 @@
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

 /*
diff -ruN linux-2.4.22.org/include/linux/rtnetlink.h linux-2.4.22/include/linux/rtnetlink.h
--- linux-2.4.22.org/include/linux/rtnetlink.h	2003-09-16 14:32:11.000000000 -0700
+++ linux-2.4.22/include/linux/rtnetlink.h	2003-09-16 14:33:10.000000000 -0700
@@ -445,10 +445,12 @@
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
@@ -482,6 +484,18 @@
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
diff -ruN linux-2.4.22.org/include/net/if_inet6.h linux-2.4.22/include/net/if_inet6.h
--- linux-2.4.22.org/include/net/if_inet6.h	2003-08-25 04:44:44.000000000 -0700
+++ linux-2.4.22/include/net/if_inet6.h	2003-09-16 14:33:10.000000000 -0700
@@ -15,6 +15,10 @@
 #ifndef _NET_IF_INET6_H
 #define _NET_IF_INET6_H

+#include <linux/ipv6.h>
+
+#define IF_RA_OTHERCONF	0x80
+#define IF_RA_MANAGED	0x40
 #define IF_RA_RCVD	0x20
 #define IF_RS_SENT	0x10

@@ -124,22 +128,6 @@
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
-
-	void		*sysctl;
-};
-
 struct inet6_dev
 {
 	struct net_device		*dev;
diff -ruN linux-2.4.22.org/net/ipv6/addrconf.c linux-2.4.22/net/ipv6/addrconf.c
--- linux-2.4.22.org/net/ipv6/addrconf.c	2003-09-16 14:32:13.000000000 -0700
+++ linux-2.4.22/net/ipv6/addrconf.c	2003-09-16 14:33:10.000000000 -0700
@@ -1981,11 +1981,112 @@
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
 static struct rtnetlink_link inet6_rtnetlink_table[RTM_MAX-RTM_BASE+1] =
 {
 	{ NULL,			NULL,			},
 	{ NULL,			NULL,			},
-	{ NULL,			NULL,			},
+	{ NULL,			inet6_dump_ifinfo,	},
 	{ NULL,			NULL,			},

 	{ inet6_rtm_newaddr,	NULL,			},
diff -ruN linux-2.4.22.org/net/ipv6/ndisc.c linux-2.4.22/net/ipv6/ndisc.c
--- linux-2.4.22.org/net/ipv6/ndisc.c	2003-09-16 14:32:13.000000000 -0700
+++ linux-2.4.22/net/ipv6/ndisc.c	2003-09-16 14:33:10.000000000 -0700
@@ -944,6 +944,17 @@
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
