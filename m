From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 2/2] Prefix List and O/M flags against 2.4.21
Date: Mon, 21 Jul 2003 05:55:04 +0400 (MSD)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200307210155.FAA31320@dub.inr.ac.ru>
References: <3F17245D.9040806@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, krkumar@us.ibm.com, davem@redhat.com,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com (Krishna Kumar)
In-Reply-To: <3F17245D.9040806@us.ibm.com> from "Krishna Kumar" at Jul 17, 2003 03:34:05 PM
List-Id: netdev.vger.kernel.org

Hello!

>								I don't
> have any knowledge of using this new interface.

Something like this.

See? I just substitute into xxx_rtnetlink_table() entry for RTM_GETLINK
with IPv4 specific function which outputs the same message, but, maybe,
with some attributes removed and with new protocol-specific attribute.

The patch is not quite complete: except for those two questions,
I forgot to add MTU truncated to its IPv4 value, did nothing
for multicast things (I still cannot figure out, what information is
really useful) and did not add active notifications which would be good
to be made after sysctl parameters are changed.

Alexey


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1469  -> 1.1470 
#	  net/ipv4/devinet.c	1.19    -> 1.20   
#	include/linux/rtnetlink.h	1.18    -> 1.19   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/21	kuznet@oops.inr.ac.ru	1.1470
# Reporting INET config via rtnetlink
# --------------------------------------------
#
diff -Nru a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h	Mon Jul 21 05:47:01 2003
+++ b/include/linux/rtnetlink.h	Mon Jul 21 05:47:01 2003
@@ -476,10 +476,12 @@
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
@@ -512,6 +514,16 @@
    or maybe 0, what means, that real media is unknown (usual
    for IPIP tunnels, when route to endpoint is allowed to change)
  */
+
+enum
+{
+	IFLA_INET_UNSPEC,
+	IFLA_INET_CONF,		/* sysctl parameters	*/
+	IFLA_INET_NEIGH,	/* ARP parameters	*/
+	IFLA_INET_MCAST,	/* MC things. What of them? */
+};
+
+#define IFLA_INET_MAX IFLA_INET_CONF
 
 /*****************************************************************
  *		Traffic control messages.
diff -Nru a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c	Mon Jul 21 05:47:01 2003
+++ b/net/ipv4/devinet.c	Mon Jul 21 05:47:01 2003
@@ -1008,17 +1008,88 @@
 	}
 }
 
+static int inet_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+			    struct in_device *in_dev,
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
+	r->ifi_family = AF_INET;
+	r->ifi_type = dev->type;
+	r->ifi_index = dev->ifindex;
+	r->ifi_flags = dev->flags;
+	r->ifi_change = 0;
+
+	if (!netif_running(dev) || !netif_carrier_ok(dev))
+		r->ifi_flags &= ~IFF_RUNNING;
+	else
+		r->ifi_flags |= IFF_RUNNING;
+
+	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+
+	/* Some more IFLA_* attribute fr convenience? IPv4-ized MTU
+	 * would be good idea.
+	 */
+
+	subattr = (struct rtattr*)skb->tail;
+	RTA_PUT(skb, IFLA_PROTINFO, 0, NULL);
+	RTA_PUT(skb, IFLA_INET_CONF, sizeof(int)*16, &in_dev->cnf);
+	RTA_PUT(skb, IFLA_INET_NEIGH, sizeof(int)*13, &in_dev->arp_parms->base_reachable_time);
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
+
+int inet_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int idx, err;
+	int s_idx = cb->args[0];
+	struct net_device *dev;
+	struct in_device *in_dev;
+
+	read_lock(&dev_base_lock);
+	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
+		if (idx < s_idx)
+			continue;
+		if ((in_dev = in_dev_get(dev)) == NULL)
+			continue;
+		err = inet_fill_ifinfo(skb, dev, in_dev, RTM_NEWLINK, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq);
+		in_dev_put(in_dev);
+		if (err <= 0)
+			break;
+	}
+	read_unlock(&dev_base_lock);
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+
 static struct rtnetlink_link inet_rtnetlink_table[RTM_MAX - RTM_BASE + 1] = {
-	 [4] = { .doit	 = inet_rtm_newaddr,  },
-	 [5] = { .doit	 = inet_rtm_deladdr,  },
-	 [6] = { .dumpit = inet_dump_ifaddr,  },
-	 [8] = { .doit	 = inet_rtm_newroute, },
-	 [9] = { .doit	 = inet_rtm_delroute, },
-	[10] = { .doit	 = inet_rtm_getroute, .dumpit = inet_dump_fib, },
+	[RTM_GETLINK  - RTM_BASE] = { .dumpit	= inet_dump_ifinfo,  },
+	[RTM_NEWADDR  - RTM_BASE] = { .doit	= inet_rtm_newaddr,  },
+	[RTM_DELADDR  - RTM_BASE] = { .doit	= inet_rtm_deladdr,  },
+	[RTM_GETADDR  - RTM_BASE] = { .dumpit	= inet_dump_ifaddr,  },
+	[RTM_NEWROUTE  - RTM_BASE] = { .doit	= inet_rtm_newroute, },
+	[RTM_DELROUTE  - RTM_BASE] = { .doit	= inet_rtm_delroute, },
+	[RTM_GETROUTE  - RTM_BASE] = { .doit	= inet_rtm_getroute, .dumpit = inet_dump_fib, },
 #ifdef CONFIG_IP_MULTIPLE_TABLES
-	[16] = { .doit	 = inet_rtm_newrule, },
-	[17] = { .doit	 = inet_rtm_delrule, },
-	[18] = { .dumpit = inet_dump_rules,  },
+	[RTM_NEWRULE  - RTM_BASE] = { .doit	= inet_rtm_newrule, },
+	[RTM_DELRULE  - RTM_BASE] = { .doit	= inet_rtm_delrule, },
+	[RTM_GETRULE  - RTM_BASE] = { .dumpit	= inet_dump_rules,  },
 #endif
 };
 
