From: Krishna Kumar <krkumar@us.ibm.com>
Subject: O/M flags against 2.6.0-test1
Date: Tue, 22 Jul 2003 14:50:21 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0307221415140.14683-100000@DYN318430.beaverton.ibm.com>
References: <200307210155.FAA31320@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <netdev@oss.sgi.com>,
	<linux-net@vger.kernel.org>, KK <krkumar@us.ibm.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307210155.FAA31320@dub.inr.ac.ru>
List-Id: netdev.vger.kernel.org


> I don't have any knowledge of using this new interface.

<AK> Something like this.

Thanks Alexey, I have modelled the inet6 code on this. Hope this looks
good.

<AK> IFLA_INET6_CONF (and IFLA_INET_CONF). How to encode the values?
> Array of int's is simple, compact and looks good. But I have some
> problem with it. What if one day we want to implement changing the
> values? It will be nasty.

I think this is the simplest method. For changing, isn't it possible to
reverse the direction of memcpy back to the structure ? Ofcourse we need
to make sure the values are legal, or that a 'get' was done prior to the
'put', which does make it nasty.

<DM> Please let us to use some portable types instead of 'int' :-)

I am using sizeof(struct xxx) or __u32, etc in the code, I guess you are
ok with that.

I didn't add the statistics, though it can be implemented :
RTA_PUT(skb, IFLA_INET6_STATS, sizeof(idev->stats.icmpv6),
		&idev->stats.icmpv6[0]);
RTA_PUT(skb, IFLA_INET6_STATS, sizeof(idev->stats.icmpv6),
                &idev->stats.icmpv6[1]);
something like that would work ?

Thanks,

- KK

------------------------------------------------------------------------------
diff -ruN linux-2.6.0-test1.plist/include/linux/rtnetlink.h linux-2.6.0-test1.new/include/linux/rtnetlink.h
--- linux-2.6.0-test1.plist/include/linux/rtnetlink.h	2003-07-22 13:59:17.000000000 -0700
+++ linux-2.6.0-test1.new/include/linux/rtnetlink.h	2003-07-22 10:50:42.000000000 -0700
@@ -477,10 +477,12 @@
 #define IFLA_MASTER IFLA_MASTER
 	IFLA_WIRELESS,		/* Wireless Extension event - see wireless.h */
 #define IFLA_WIRELESS IFLA_WIRELESS
+	IFLA_PROTINFO,
+#define IFLA_PROTINFO IFLA_PROTINFO
 };


-#define IFLA_MAX IFLA_WIRELESS
+#define IFLA_MAX IFLA_PROTINFO

 #define IFLA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
 #define IFLA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
@@ -514,6 +516,18 @@
    for IPIP tunnels, when route to endpoint is allowed to change)
  */

+/* Sub-attribute types for IFLA_PROTINFO */
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
diff -ruN linux-2.6.0-test1.plist/net/ipv6/addrconf.c linux-2.6.0-test1.new/net/ipv6/addrconf.c
--- linux-2.6.0-test1.plist/net/ipv6/addrconf.c	2003-07-22 13:59:17.000000000 -0700
+++ linux-2.6.0-test1.new/net/ipv6/addrconf.c	2003-07-22 13:55:07.000000000 -0700
@@ -2510,7 +2510,77 @@
 	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_IFADDR, GFP_ATOMIC);
 }

+static int inet6_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+			    struct inet6_dev *idev,
+			    int type, u32 pid, u32 seq)
+{
+	struct ifinfomsg *r;
+	struct nlmsghdr  *nlh;
+	unsigned char	 *b = skb->tail;
+	struct rtattr	 *subattr;
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
+	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
+	RTA_PUT(skb, IFLA_INET6_FLAGS, sizeof(__u32), &idev->if_flags);
+	/*
+	 * XXX	- any better way than using 'sizeof(struct) - n' below ?
+	 *	- stats/multicast not implemented
+	 */
+	RTA_PUT(skb, IFLA_INET6_CONF, sizeof(idev->cnf) - sizeof(void *),
+				&idev->cnf);
+	subattr->rta_len = skb->tail - (u8*)subattr;
+
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
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


