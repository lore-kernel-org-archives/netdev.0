From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH]Add new IPv6 MIBs counters support through netlink
Date: Wed, 26 May 2004 13:10:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405261308.54281.mashirle@us.ibm.com>
References: <OF3E88B8EA.382D75F6-ON87256E5C.00272BAC-88256E5C.0027A5ED@us.ibm.com> <200403311326.43647.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dmPtAWGpT6TwdRU"
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <200403311326.43647.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_dmPtAWGpT6TwdRU
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch implements both per interface and global new IPv6 MIBs counters 
through netlink based on new IP MIBs draft, 64 bit counters are not supported 
here because of performance issues. It coexists old IPv6 MIBs counters (which 
are through proc file system) for the compatibility.
This patch is against 2.6.6 kernel. It has been tested for IPv6.
Please review it. 



--Boundary-00=_dmPtAWGpT6TwdRU
Content-Type: text/x-diff;
  charset="iso-2022-jp";
  name="linux-2.6.6-newmibs.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.6-newmibs.patch"

diff -urN linux-2.6.6/include/linux/rtnetlink.h linux-2.6.6-newmibs/include/linux/rtnetlink.h
--- linux-2.6.6/include/linux/rtnetlink.h	2004-05-09 19:33:13.000000000 -0700
+++ linux-2.6.6-newmibs/include/linux/rtnetlink.h	2004-05-26 12:05:39.000000000 -0700
@@ -44,6 +44,9 @@
 #define	RTM_DELTFILTER	(RTM_BASE+29)
 #define	RTM_GETTFILTER	(RTM_BASE+30)
 
+#define RTM_NEWIPSTATS (RTM_BASE+32)
+#define RTM_GETIPSTATS (RTM_BASE+34)
+
 #define RTM_NEWPREFIX	(RTM_BASE+36)
 #define RTM_GETPREFIX	(RTM_BASE+38)
 
@@ -637,6 +640,23 @@
 #define TCA_RTA(r)  ((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct tcmsg))))
 #define TCA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct tcmsg))
 
+/********************************************************************
+ *		IP mibs information
+ ****/
+struct ipstatsmsg
+{
+	int	ipstats_family;
+	int	ipstats_ifindex;
+};
+
+enum
+{
+	IPSTATS_IFNAME,
+	IPSTATS_COUNTERS,
+};
+
+#define IPSTATS_MAX IPSTATS_COUNTERS
+
 
 /* SUMMARY: maximal rtattr understood by kernel */
 
diff -urN linux-2.6.6/include/net/if_inet6.h linux-2.6.6-newmibs/include/net/if_inet6.h
--- linux-2.6.6/include/net/if_inet6.h	2004-05-09 19:33:20.000000000 -0700
+++ linux-2.6.6-newmibs/include/net/if_inet6.h	2004-05-26 12:05:39.000000000 -0700
@@ -149,6 +149,7 @@
 struct ipv6_devstat {
 	struct proc_dir_entry	*proc_dir_entry;
 	DEFINE_SNMP_STAT(struct icmpv6_mib, icmpv6);
+	DEFINE_SNMP_STAT(struct ip_stats, ipv6);
 };
 
 struct inet6_dev 
diff -urN linux-2.6.6/include/net/ipv6.h linux-2.6.6-newmibs/include/net/ipv6.h
--- linux-2.6.6/include/net/ipv6.h	2004-05-09 19:33:13.000000000 -0700
+++ linux-2.6.6-newmibs/include/net/ipv6.h	2004-05-26 12:05:39.000000000 -0700
@@ -116,6 +116,44 @@
 #define IP6_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ipv6_statistics, field)
 #define IP6_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(ipv6_statistics, field)
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
+/* new IPv6 MIB */
+DECLARE_SNMP_STAT(struct ip_stats, ipv6_stats);
+#define IPV6_INC_STATS(idev, field)		({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS(ipv6_stats, field);				\
+})
+#define IPV6_INC_STATS_BH(idev, field)		({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS_BH(ipv6_stats, field);			\
+})
+#define IPV6_INC_STATS_USER(idev, field) 	({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_INC_STATS(_idev->stats.ipv6, field);		\
+	SNMP_INC_STATS_USER(ipv6_stats, field);			\
+})
+#define IPV6_ADD_STATS_BH(idev, field, addend)	({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_ADD_STATS_BH(_idev->stats.ipv6, field, addend);	\
+	SNMP_ADD_STATS_BH(ipv6_stats, field, addend);		\
+})
+#define IPV6_ADD_STATS_USER(idev, field, addend) ({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_ADD_STATS_USER(_idev->stats.ipv6, field, addend);	\
+	SNMP_ADD_STATS_USER(ipv6_stats, field, addend);		\
+})
+#define IPV6_ADD_STATS(idev, field, addend)	({			\
+	struct inet6_dev *_idev = (idev);				\
+	if (likely(_idev != NULL))					\
+		SNMP_ADD_STATS(_idev->stats.ipv6, field, addend);	\
+	SNMP_ADD_STATS(ipv6_stats, field, addend);			\
+})	
 #define ICMP6_INC_STATS(idev, field)		({			\
 	struct inet6_dev *_idev = (idev);				\
 	if (likely(_idev != NULL))					\
diff -urN linux-2.6.6/include/net/snmp.h linux-2.6.6-newmibs/include/net/snmp.h
--- linux-2.6.6/include/net/snmp.h	2004-05-09 19:32:28.000000000 -0700
+++ linux-2.6.6-newmibs/include/net/snmp.h	2004-05-26 12:05:39.000000000 -0700
@@ -98,6 +98,43 @@
  	unsigned long	Ip6OutMcastPkts;
 	unsigned long   __pad[0]; 
 };
+
+/*
+ * New IP MIBs from draft-ietf-ipv6-rfc2011-update-05.txt 
+ */
+struct ip_stats
+{
+	unsigned long	ipStatsInReceives;
+	unsigned long	ipStatsInOctets;
+	unsigned long	ipStatsInHdrErrors;
+	unsigned long	ipStatsInNoRoutes;
+	unsigned long	ipStatsInAddrErrors;
+	unsigned long	ipStatsInUnknownProtos;
+	unsigned long	ipStatsInTruncatedPkts;
+	unsigned long	ipStatsInForwDatagrams;
+	unsigned long	ipStatsReasmReqds;
+	unsigned long	ipStatsReasmOKs;
+	unsigned long	ipStatsReasmFails;
+	unsigned long	ipStatsInDiscards;
+	unsigned long	ipStatsInDelivers;
+	unsigned long	ipStatsOutRequests;
+	unsigned long	ipStatsOutNoRoutes;
+	unsigned long	ipStatsOutForwDatagrams;
+	unsigned long	ipStatsOutDiscards;
+	unsigned long	ipStatsOutFragReqds;
+	unsigned long	ipStatsOutFragOKs;
+	unsigned long	ipStatsOutFragFails;
+	unsigned long	ipStatsOutFragCreates;
+	unsigned long	ipStatsOutTransmits;
+	unsigned long	ipStatsOutOctets;
+	unsigned long	ipStatsInMcastPkts;
+	unsigned long	ipStatsInMcastOctets;
+	unsigned long	ipStatsOutMcastPkts;
+	unsigned long	ipStatsOutMcastOctets;
+	unsigned long	ipStatsInBcastPkts;
+	unsigned long	ipStatsOutBcastPkts;
+	unsigned long   __pad[0]; 
+};
  
 /*
  * RFC 1213:  MIB-II ICMP Group
@@ -335,6 +372,8 @@
 	(per_cpu_ptr(mib[!in_softirq()], smp_processor_id())->field++)
 #define SNMP_DEC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], smp_processor_id())->field--)
+#define SNMP_ADD_STATS(mib, field, addend)	\
+	(per_cpu_ptr(mib[!in_softirq()], smp_processor_id())->field += addend)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], smp_processor_id())->field += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff -urN linux-2.6.6/net/ipv6/addrconf.c linux-2.6.6-newmibs/net/ipv6/addrconf.c
--- linux-2.6.6/net/ipv6/addrconf.c	2004-05-09 19:33:20.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/addrconf.c	2004-05-26 12:05:39.000000000 -0700
@@ -2963,6 +2963,101 @@
 	netlink_broadcast(rtnl, skb, 0, RTMGRP_IPV6_PREFIX, GFP_ATOMIC);
 }
 
+static unsigned long
+fold_field(void *mib[], int offt)
+{
+        unsigned long res = 0;
+        int i;
+ 
+        for (i = 0; i < NR_CPUS; i++) {
+                if (!cpu_possible(i))
+                        continue;
+                res +=
+                    *((unsigned long *) (((void *)per_cpu_ptr(mib[0], i)) +
+                                         offt));
+                res +=
+                    *((unsigned long *) (((void *)per_cpu_ptr(mib[1], i)) +
+                                         offt));
+        }
+        return res;
+}
+
+static int inet6_fill_ipstats(struct sk_buff *skb, struct inet6_dev *idev,
+			       u32 pid, u32 seq, int event)
+{
+	struct ipstatsmsg	*r;
+	struct nlmsghdr 	*nlh;
+	unsigned char		*b = skb->tail;
+	struct ip_stats		ipstats;
+	unsigned long		*array;
+	int 			i, num;
+
+	nlh = NLMSG_PUT(skb, pid, seq, event, sizeof(*r));
+	if (pid) 
+		nlh->nlmsg_flags |= NLM_F_MULTI;
+	r = NLMSG_DATA(nlh);
+	r->ipstats_family = AF_INET6;
+	r->ipstats_ifindex = 0;
+	num = offsetof(struct ip_stats, __pad) / sizeof(unsigned long);
+	memset(&ipstats , 0, sizeof(struct ip_stats));
+	array = (unsigned long *)&ipstats;
+	if (idev == NULL) {
+		/* fill IP mibs system statistics */
+		RTA_PUT(skb, IPSTATS_IFNAME, 3, "all");
+		for (i = 0; i < num; i++, array++) {
+			*array = fold_field((void **)ipv6_stats, 
+					    i * (sizeof(unsigned long)));
+		}
+	} else {
+		/* fill IP mibs interface statistics */
+		r->ipstats_ifindex = idev->dev->ifindex;
+		RTA_PUT(skb, IPSTATS_IFNAME, strlen(idev->dev->name)+1,
+			idev->dev->name);
+		for (i = 0; i < num; i++, array++) {
+			*array = fold_field((void **)idev->stats.ipv6, 
+					    i * (sizeof(unsigned long)));
+		}
+	}
+	RTA_PUT(skb, IPSTATS_COUNTERS, sizeof(struct ip_stats), &ipstats);
+	nlh->nlmsg_len = skb->tail - b;
+	return skb->len;
+
+nlmsg_failure:
+rtattr_failure:
+	skb_trim(skb, b - skb->data);
+	return -1;
+}
+
+static int inet6_dump_ipstats(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err, idx = 0;
+	int s_idx = cb->args[0];
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	/* fill IP mibs system statistics */
+	inet6_fill_ipstats(skb, NULL, NETLINK_CB(cb->skb).pid,
+			    cb->nlh->nlmsg_seq, RTM_NEWIPSTATS);
+	idx += 1;
+	/* fill IP mibs interface statistics */
+	read_lock(&dev_base_lock);
+	for (dev=dev_base; dev; dev = dev->next, idx++) {
+		if (idx < s_idx)
+			continue;
+		if ((idev = in6_dev_get(dev)) == NULL)
+			continue;
+		err = inet6_fill_ipstats(skb, idev, NETLINK_CB(cb->skb).pid, 
+				cb->nlh->nlmsg_seq, RTM_NEWIPSTATS);
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
 	[RTM_GETLINK - RTM_BASE] = { .dumpit	= inet6_dump_ifinfo, },
 	[RTM_NEWADDR - RTM_BASE] = { .doit	= inet6_rtm_newaddr, },
@@ -2974,6 +3069,7 @@
 	[RTM_DELROUTE - RTM_BASE] = { .doit	= inet6_rtm_delroute, },
 	[RTM_GETROUTE - RTM_BASE] = { .doit	= inet6_rtm_getroute,
 				      .dumpit	= inet6_dump_fib, },
+	[RTM_GETIPSTATS - RTM_BASE] = { .dumpit = inet6_dump_ipstats, },
 };
 
 static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
diff -urN linux-2.6.6/net/ipv6/af_inet6.c linux-2.6.6-newmibs/net/ipv6/af_inet6.c
--- linux-2.6.6/net/ipv6/af_inet6.c	2004-05-09 19:32:38.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/af_inet6.c	2004-05-26 12:05:39.000000000 -0700
@@ -670,6 +670,9 @@
 	if (snmp6_mib_init((void **)ipv6_statistics, sizeof (struct ipv6_mib),
 			   __alignof__(struct ipv6_mib)) < 0)
 		goto err_ip_mib;
+	if (snmp6_mib_init((void **)ipv6_stats, sizeof (struct ip_stats),
+			   __alignof__(struct ip_stats)) < 0)
+		goto err_ip6_mib;
 	if (snmp6_mib_init((void **)icmpv6_statistics, sizeof (struct icmpv6_mib),
 			   __alignof__(struct ipv6_mib)) < 0)
 		goto err_icmp_mib;
@@ -681,6 +684,8 @@
 err_udp_mib:
 	snmp6_mib_free((void **)icmpv6_statistics);
 err_icmp_mib:
+	snmp6_mib_free((void **)ipv6_stats);
+err_ip6_mib:
 	snmp6_mib_free((void **)ipv6_statistics);
 err_ip_mib:
 	return -ENOMEM;
@@ -690,6 +695,7 @@
 static void cleanup_ipv6_mibs(void)
 {
 	snmp6_mib_free((void **)ipv6_statistics);
+	snmp6_mib_free((void **)ipv6_stats);
 	snmp6_mib_free((void **)icmpv6_statistics);
 	snmp6_mib_free((void **)udp_stats_in6);
 }
diff -urN linux-2.6.6/net/ipv6/exthdrs.c linux-2.6.6-newmibs/net/ipv6/exthdrs.c
--- linux-2.6.6/net/ipv6/exthdrs.c	2004-05-09 19:31:59.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/exthdrs.c	2004-05-26 12:05:39.000000000 -0700
@@ -156,10 +156,15 @@
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = (struct inet6_skb_parm *)skb->cb;
+	struct inet6_dev *idev = NULL;
+
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -173,6 +178,7 @@
 	}
 
 	IP6_INC_STATS_BH(Ip6InHdrErrors);
+	IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 	return -1;
 }
 
@@ -224,10 +230,15 @@
 
 	struct ipv6_rt_hdr *hdr;
 	struct rt0_hdr *rthdr;
+	struct inet6_dev *idev = NULL;
+
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -237,6 +248,7 @@
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
 		IP6_INC_STATS_BH(Ip6InAddrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInAddrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -253,12 +265,14 @@
 
 	if (hdr->type != IPV6_SRCRT_TYPE_0) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->type) - skb->nh.raw);
 		return -1;
 	}
 	
 	if (hdr->hdrlen & 0x01) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->hdrlen) - skb->nh.raw);
 		return -1;
 	}
@@ -272,6 +286,7 @@
 
 	if (hdr->segments_left > n) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, (&hdr->segments_left) - skb->nh.raw);
 		return -1;
 	}
@@ -284,7 +299,8 @@
 		kfree_skb(skb);
 		/* the copy is a forwarded packet */
 		if (skb2 == NULL) {
-			IP6_INC_STATS_BH(Ip6OutDiscards);	
+			IP6_INC_STATS_BH(Ip6OutDiscards);
+			IPV6_INC_STATS_BH(idev, ipStatsOutDiscards);
 			return -1;
 		}
 		*skbp = skb = skb2;
@@ -303,6 +319,7 @@
 
 	if (ipv6_addr_is_multicast(addr)) {
 		IP6_INC_STATS_BH(Ip6InAddrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInAddrErrors);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -320,6 +337,7 @@
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
 		if (skb->nh.ipv6h->hop_limit <= 1) {
 			IP6_INC_STATS_BH(Ip6InHdrErrors);
+			IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0, skb->dev);
 			kfree_skb(skb);
@@ -432,28 +450,36 @@
 static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 {
 	u32 pkt_len;
+	struct inet6_dev *idev = NULL;
+
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
 		LIMIT_NETDEBUG(
 			 printk(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n", skb->nh.raw[optoff+1]));
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(u32*)(skb->nh.raw+optoff+2));
 	if (pkt_len <= IPV6_MAXPLEN) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
 	if (skb->nh.ipv6h->payload_len) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return 0;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
 		IP6_INC_STATS_BH(Ip6InTruncatedPkts);
+		IPV6_INC_STATS_BH(idev, ipStatsInTruncatedPkts);
 		goto drop;
 	}
 	if (pkt_len + sizeof(struct ipv6hdr) < skb->len) {
diff -urN linux-2.6.6/net/ipv6/icmp.c linux-2.6.6-newmibs/net/ipv6/icmp.c
--- linux-2.6.6/net/ipv6/icmp.c	2004-05-09 19:32:27.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/icmp.c	2004-05-26 12:05:39.000000000 -0700
@@ -158,6 +158,7 @@
 {
 	struct dst_entry *dst;
 	int res = 0;
+	struct inet6_dev *idev = NULL;
 
 	/* Informational messages are not limited. */
 	if (type & ICMPV6_INFOMSG_MASK)
@@ -173,8 +174,12 @@
 	 * this lookup should be more aggressive (not longer than timeout).
 	 */
 	dst = ip6_route_output(sk, fl);
+	/* idev reference for IP MIBs */
+	if (likely(dst->dev))
+		idev = in6_dev_get(dst->dev);
 	if (dst->error) {
 		IP6_INC_STATS(Ip6OutNoRoutes);
+		IPV6_INC_STATS(idev, ipStatsOutNoRoutes);
 	} else if (dst->dev && (dst->dev->flags&IFF_LOOPBACK)) {
 		res = 1;
 	} else {
@@ -187,6 +192,9 @@
 
 		res = xrlim_allow(dst, tmo);
 	}
+	/* release the idev reference for IP MIBs */
+	if (likely(idev))
+		in6_dev_put(idev);
 	dst_release(dst);
 	return res;
 }
diff -urN linux-2.6.6/net/ipv6/ip6_input.c linux-2.6.6-newmibs/net/ipv6/ip6_input.c
--- linux-2.6.6/net/ipv6/ip6_input.c	2004-05-09 19:32:54.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/ip6_input.c	2004-05-26 12:34:10.000000000 -0700
@@ -60,14 +60,22 @@
 {
 	struct ipv6hdr *hdr;
 	u32 		pkt_len;
+	struct inet6_dev *idev = NULL;
+	int		err = 0;
+	
+	/* idev reference for input IP MIBs */
+	if (likely(skb->dev))
+		idev = in6_dev_get(skb->dev);
 
 	if (skb->pkt_type == PACKET_OTHERHOST)
 		goto drop;
 
 	IP6_INC_STATS_BH(Ip6InReceives);
+	IPV6_INC_STATS_BH(idev, ipStatsInReceives);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
 		IP6_INC_STATS_BH(Ip6InDiscards);
+		IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
 		goto out;
 	}
 
@@ -81,6 +89,7 @@
 
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr))) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		goto drop;
 	}
 
@@ -90,6 +99,7 @@
 		goto err;
 
 	pkt_len = ntohs(hdr->payload_len);
+	IPV6_ADD_STATS_BH(idev, ipStatsInOctets, skb->len);
 
 	/* pkt_len may be zero if Jumbo payload option is present */
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
@@ -98,6 +108,7 @@
 		if (pkt_len + sizeof(struct ipv6hdr) < skb->len) {
 			if (__pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr))){
 				IP6_INC_STATS_BH(Ip6InHdrErrors);
+				IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 				goto drop;
 			}
 			hdr = skb->nh.ipv6h;
@@ -110,20 +121,26 @@
 		skb->h.raw = (u8*)(hdr+1);
 		if (ipv6_parse_hopopts(skb, offsetof(struct ipv6hdr, nexthdr)) < 0) {
 			IP6_INC_STATS_BH(Ip6InHdrErrors);
-			return 0;
+			IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
+			goto out;
 		}
 		hdr = skb->nh.ipv6h;
 	}
 
-	return NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
+	err = NF_HOOK(PF_INET6,NF_IP6_PRE_ROUTING, skb, dev, NULL, ip6_rcv_finish);
+	goto out;
 truncated:
 	IP6_INC_STATS_BH(Ip6InTruncatedPkts);
+	IPV6_INC_STATS_BH(idev, ipStatsInTruncatedPkts);
 err:
 	IP6_INC_STATS_BH(Ip6InHdrErrors);
+	IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 drop:
 	kfree_skb(skb);
 out:
-	return 0;
+	if (likely(idev))
+		in6_dev_put(idev);
+	return err;
 }
 
 /*
@@ -139,6 +156,10 @@
 	int nexthdr;
 	u8 hash;
 	int cksum_sub = 0;
+	struct inet6_dev *idev = NULL;
+
+	if (skb->dev)
+		idev = __in6_dev_get(skb->dev);
 
 	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
 
@@ -193,16 +214,20 @@
 		ret = ipprot->handler(&skb, &nhoff);
 		if (ret > 0)
 			goto resubmit;
-		else if (ret == 0)
+		else if (ret == 0) {
 			IP6_INC_STATS_BH(Ip6InDelivers);
+			IPV6_INC_STATS_BH(idev, ipStatsInDelivers);
+		}
 	} else {
 		if (!raw_sk) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 				IP6_INC_STATS_BH(Ip6InUnknownProtos);
+				IPV6_INC_STATS_BH(idev, ipStatsInUnknownProtos);
 				icmpv6_param_prob(skb, ICMPV6_UNK_NEXTHDR, nhoff);
 			}
 		} else {
 			IP6_INC_STATS_BH(Ip6InDelivers);
+			IPV6_INC_STATS_BH(idev, ipStatsInDelivers);
 			kfree_skb(skb);
 		}
 	}
@@ -211,6 +236,7 @@
 
 discard:
 	IP6_INC_STATS_BH(Ip6InDiscards);
+	IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
 	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
@@ -226,8 +252,13 @@
 {
 	struct ipv6hdr *hdr;
 	int deliver;
+	struct inet6_dev *idev = NULL;
 
+	if (skb->dev)
+		idev = __in6_dev_get(skb->dev);
 	IP6_INC_STATS_BH(Ip6InMcastPkts);
+	IPV6_INC_STATS_BH(idev, ipStatsInMcastPkts);
+	IPV6_ADD_STATS_BH(idev, ipStatsInMcastOctets, skb->len);
 
 	hdr = skb->nh.ipv6h;
 	deliver = likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI))) ||
diff -urN linux-2.6.6/net/ipv6/ip6_output.c linux-2.6.6-newmibs/net/ipv6/ip6_output.c
--- linux-2.6.6/net/ipv6/ip6_output.c	2004-05-09 19:31:59.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/ip6_output.c	2004-05-26 12:13:36.000000000 -0700
@@ -74,6 +74,10 @@
 
 	struct dst_entry *dst = skb->dst;
 	struct hh_cache *hh = dst->hh;
+	struct inet6_dev *idev = NULL;
+
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 
 	if (hh) {
 		int hh_alen;
@@ -83,11 +87,15 @@
 		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
 		read_unlock_bh(&hh->hh_lock);
 	        skb_push(skb, hh->hh_len);
+		IPV6_INC_STATS_BH(idev, ipStatsOutTransmits);
 		return hh->hh_output(skb);
-	} else if (dst->neighbour)
+	} else if (dst->neighbour) {
+		IPV6_INC_STATS_BH(idev, ipStatsOutTransmits);
 		return dst->neighbour->output(skb);
+	}
 
 	IP6_INC_STATS_BH(Ip6OutNoRoutes);
+	IPV6_INC_STATS_BH(idev, ipStatsOutDiscards);
 	kfree_skb(skb);
 	return -EINVAL;
 
@@ -111,9 +119,12 @@
 {
 	struct dst_entry *dst = skb->dst;
 	struct net_device *dev = dst->dev;
+	struct inet6_dev *idev = NULL;
 
 	skb->protocol = htons(ETH_P_IPV6);
 	skb->dev = dev;
+	if (likely(dev)) 
+		idev = __in6_dev_get(dev);
 
 	if (ipv6_addr_is_multicast(&skb->nh.ipv6h->daddr)) {
 		struct ipv6_pinfo* np = skb->sk ? inet6_sk(skb->sk) : NULL;
@@ -133,12 +144,15 @@
 
 			if (skb->nh.ipv6h->hop_limit == 0) {
 				IP6_INC_STATS(Ip6OutDiscards);
+				IPV6_INC_STATS(idev, ipStatsOutDiscards);
 				kfree_skb(skb);
 				return 0;
 			}
 		}
 
 		IP6_INC_STATS(Ip6OutMcastPkts);
+		IPV6_INC_STATS(idev, ipStatsOutMcastPkts);
+		IPV6_ADD_STATS(idev, ipStatsOutMcastOctets, skb->len);
 	}
 
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb,NULL, skb->dev,ip6_output_finish);
@@ -157,6 +171,7 @@
 {
 	struct ipv6hdr *iph = skb->nh.ipv6h;
 	struct dst_entry *dst;
+	struct inet6_dev *idev = NULL;
 	struct flowi fl = {
 		.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0,
 		.nl_u =
@@ -167,18 +182,26 @@
 	};
 
 	dst = ip6_route_output(skb->sk, &fl);
-
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 	if (dst->error) {
 		IP6_INC_STATS(Ip6OutNoRoutes);
+		IPV6_INC_STATS_BH(idev, ipStatsOutNoRoutes);
 		LIMIT_NETDEBUG(
 			printk(KERN_DEBUG "ip6_route_me_harder: No more route.\n"));
 		dst_release(dst);
 		return -EINVAL;
 	}
 
+	/* drop the IP MIBs reference for old idev */
+	if (likely(skb->dst))
+		in6_dev_put(__in6_dev_get(skb->dst->dev));
 	/* Drop old route. */
 	dst_release(skb->dst);
 
+	/* IP MIBs refer to the new dst idev */
+	if (likely(dst->dev))
+		idev = in6_dev_get(dst->dev);
 	skb->dst = dst;
 	return 0;
 }
@@ -212,7 +235,13 @@
 	int seg_len = skb->len;
 	int hlimit;
 	u32 mtu;
-
+	struct inet6_dev *idev = NULL;
+	int errno = 0;
+	
+	/* idev reference for IP MIBs */
+	if (likely(skb->dst))
+		idev = in6_dev_get(skb->dst->dev);
+	
 	if (opt) {
 		int head_room;
 
@@ -229,7 +258,9 @@
 			skb = skb2;
 			if (skb == NULL) {	
 				IP6_INC_STATS(Ip6OutDiscards);
-				return -ENOBUFS;
+				IPV6_INC_STATS(idev, ipStatsOutDiscards);
+				errno = -ENOBUFS;
+				goto out;
 			}
 			if (sk)
 				skb_set_owner_w(skb, sk);
@@ -263,7 +294,10 @@
 	mtu = dst_pmtu(dst);
 	if ((skb->len <= mtu) || ipfragok) {
 		IP6_INC_STATS(Ip6OutRequests);
-		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_maybe_reroute);
+		IPV6_INC_STATS(idev, ipStatsOutRequests);
+		IPV6_ADD_STATS(idev, ipStatsOutOctets, skb->len);
+		errno = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, ip6_maybe_reroute);
+		goto out;
 	}
 
 	if (net_ratelimit())
@@ -271,8 +305,13 @@
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
 	IP6_INC_STATS(Ip6FragFails);
+	IPV6_INC_STATS(idev, ipStatsOutDiscards);
 	kfree_skb(skb);
-	return -EMSGSIZE;
+	errno = -EMSGSIZE;
+out:
+	if (likely(idev))
+		in6_dev_put(idev);
+	return errno;
 }
 
 /*
@@ -347,12 +386,22 @@
 	struct dst_entry *dst = skb->dst;
 	struct ipv6hdr *hdr = skb->nh.ipv6h;
 	struct inet6_skb_parm *opt =(struct inet6_skb_parm*)skb->cb;
+	struct inet6_dev *idev = NULL;
+	int errno = 0;
+	
+	/* idev reference for IP MIBs*/
+	if (likely(dst))
+		idev = in6_dev_get(dst->dev);
 	
-	if (ipv6_devconf.forwarding == 0)
+	if (ipv6_devconf.forwarding == 0) {
+		errno = -EINVAL;
 		goto error;
+	}
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
 		IP6_INC_STATS(Ip6InDiscards);
+		IPV6_INC_STATS(idev, ipStatsInDiscards);
+		errno = -EINVAL;
 		goto drop;
 	}
 
@@ -374,7 +423,7 @@
 	if (opt->ra) {
 		u8 *ptr = skb->nh.raw + opt->ra;
 		if (ip6_call_ra_chain(skb, (ptr[2]<<8) + ptr[3]))
-			return 0;
+			goto out;
 	}
 
 	/*
@@ -385,13 +434,17 @@
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 			    0, skb->dev);
-
+		IP6_INC_STATS(Ip6InDiscards);
+		IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
 		kfree_skb(skb);
-		return -ETIMEDOUT;
+		errno = -ETIMEDOUT;
+		goto out;
 	}
 
 	if (!xfrm6_route_forward(skb)) {
 		IP6_INC_STATS(Ip6InDiscards);
+		IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
+		errno = -EINVAL;
 		goto drop;
 	}
 
@@ -422,6 +475,7 @@
 	} else if (ipv6_addr_type(&hdr->saddr)&(IPV6_ADDR_MULTICAST|IPV6_ADDR_LOOPBACK
 						|IPV6_ADDR_LINKLOCAL)) {
 		/* This check is security critical. */
+		errno = -EINVAL;
 		goto error;
 	}
 
@@ -431,12 +485,16 @@
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_pmtu(dst), skb->dev);
 		IP6_INC_STATS_BH(Ip6InTooBigErrors);
 		IP6_INC_STATS_BH(Ip6FragFails);
+		IPV6_INC_STATS_BH(idev, ipStatsOutFragFails);
 		kfree_skb(skb);
-		return -EMSGSIZE;
+		errno = -EMSGSIZE;
+		goto out;
 	}
 
 	if (skb_cow(skb, dst->dev->hard_header_len)) {
 		IP6_INC_STATS(Ip6OutDiscards);
+		IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
+		errno = -EINVAL;
 		goto drop;
 	}
 
@@ -447,13 +505,18 @@
 	hdr->hop_limit--;
 
 	IP6_INC_STATS_BH(Ip6OutForwDatagrams);
-	return NF_HOOK(PF_INET6,NF_IP6_FORWARD, skb, skb->dev, dst->dev, ip6_forward_finish);
-
+	IPV6_INC_STATS_BH(idev, ipStatsOutForwDatagrams);
+	errno = NF_HOOK(PF_INET6,NF_IP6_FORWARD, skb, skb->dev, dst->dev, ip6_forward_finish);
+	goto out;
 error:
 	IP6_INC_STATS_BH(Ip6InAddrErrors);
+	IPV6_INC_STATS_BH(idev, ipStatsInAddrErrors);
 drop:
 	kfree_skb(skb);
-	return -EINVAL;
+out:
+	if (likely(idev))
+		in6_dev_put(idev);
+	return errno;
 }
 
 static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
@@ -524,8 +587,11 @@
 	u32 frag_id = 0;
 	int ptr, offset = 0, err=0;
 	u8 *prevhdr, nexthdr = 0;
+	struct inet6_dev *idev = NULL;
 
 	dev = rt->u.dst.dev;
+	if (likely(dev))
+		idev = __in6_dev_get(dev);	
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
 
@@ -564,6 +630,7 @@
 		tmp_hdr = kmalloc(hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
 			IP6_INC_STATS(Ip6FragFails);
+			IPV6_INC_STATS(idev, ipStatsOutFragFails);
 			return -ENOMEM;
 		}
 
@@ -619,6 +686,7 @@
 
 		if (err == 0) {
 			IP6_INC_STATS(Ip6FragOKs);
+			IPV6_INC_STATS(idev, ipStatsOutFragOKs);
 			return 0;
 		}
 
@@ -629,6 +697,7 @@
 		}
 
 		IP6_INC_STATS(Ip6FragFails);
+		IPV6_INC_STATS(idev, ipStatsOutFragFails);
 		return err;
 	}
 
@@ -662,6 +731,7 @@
 		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_RESERVED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(printk(KERN_INFO "IPv6: frag: no memory for new fragment!\n"));
 			IP6_INC_STATS(Ip6FragFails);
+			IPV6_INC_STATS(idev, ipStatsOutFragFails);
 			err = -ENOMEM;
 			goto fail;
 		}
@@ -720,6 +790,7 @@
 		 */
 
 		IP6_INC_STATS(Ip6FragCreates);
+		IPV6_INC_STATS(idev, ipStatsOutFragCreates);
 
 		err = output(frag);
 		if (err)
@@ -727,11 +798,13 @@
 	}
 	kfree_skb(skb);
 	IP6_INC_STATS(Ip6FragOKs);
+	IPV6_INC_STATS(idev, ipStatsOutFragOKs);
 	return err;
 
 fail:
 	kfree_skb(skb); 
 	IP6_INC_STATS(Ip6FragFails);
+	IPV6_INC_STATS(idev, ipStatsOutFragFails);
 	return err;
 }
 
@@ -822,6 +895,7 @@
 	int err;
 	int offset = 0;
 	int csummode = CHECKSUM_NONE;
+	struct inet6_dev *idev = NULL;
 
 	if (flags&MSG_PROBE)
 		return 0;
@@ -1016,7 +1090,10 @@
 	return 0;
 error:
 	inet->cork.length -= length;
+	if (likely(skb->dev))
+		idev = __in6_dev_get(skb->dev);
 	IP6_INC_STATS(Ip6OutDiscards);
+	IPV6_INC_STATS(idev, ipStatsOutDiscards);
 	return err;
 }
 
@@ -1033,6 +1110,7 @@
 	struct flowi *fl = &inet->cork.fl;
 	unsigned char proto = fl->proto;
 	int err = 0;
+	struct inet6_dev *idev = NULL;
 
 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
@@ -1076,7 +1154,12 @@
 	ipv6_addr_copy(&hdr->daddr, final_dst);
 
 	skb->dst = dst_clone(&rt->u.dst);
-	IP6_INC_STATS(Ip6OutRequests);	
+	/* idev reference for IP MIBs */
+	if (likely(skb->dst))
+		idev = in6_dev_get(skb->dst->dev);
+	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
+	IPV6_ADD_STATS(idev, ipStatsOutOctets, skb->len);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
 	if (err) {
 		if (err > 0)
@@ -1096,6 +1179,8 @@
 		np->cork.rt = NULL;
 	}
 	memset(&inet->cork.fl, 0, sizeof(inet->cork.fl));
+	if (likely(idev))
+		in6_dev_put(idev);
 	return err;
 error:
 	goto out;
@@ -1106,11 +1191,22 @@
 	struct inet_opt *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
+	struct inet6_dev *idev = NULL;
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		if (skb->dst) {
+			if (!idev || skb->dst->dev != idev->dev) {
+				if (idev)
+					in6_dev_put(idev);
+				idev = in6_dev_get(skb->dst->dev);
+			}
+		}
 		IP6_INC_STATS(Ip6OutDiscards);
+		IPV6_INC_STATS(idev, ipStatsOutDiscards);
 		kfree_skb(skb);
 	}
+	if (idev)
+		in6_dev_put(idev);
 
 	inet->cork.flags &= ~IPCORK_OPT;
 
diff -urN linux-2.6.6/net/ipv6/ipv6_sockglue.c linux-2.6.6-newmibs/net/ipv6/ipv6_sockglue.c
--- linux-2.6.6/net/ipv6/ipv6_sockglue.c	2004-05-09 19:32:00.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/ipv6_sockglue.c	2004-05-26 12:05:39.000000000 -0700
@@ -56,6 +56,7 @@
 #include <asm/uaccess.h>
 
 DEFINE_SNMP_STAT(struct ipv6_mib, ipv6_statistics);
+DEFINE_SNMP_STAT(struct ip_stats, ipv6_stats);
 
 static struct packet_type ipv6_packet_type = {
 	.type = __constant_htons(ETH_P_IPV6), 
diff -urN linux-2.6.6/net/ipv6/mcast.c linux-2.6.6-newmibs/net/ipv6/mcast.c
--- linux-2.6.6/net/ipv6/mcast.c	2004-05-09 19:33:13.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/mcast.c	2004-05-26 12:35:27.000000000 -0700
@@ -1318,6 +1318,8 @@
 	int err;
 
 	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
+	IPV6_ADD_STATS(idev, ipStatsOutOctets, skb->len);
 	payload_len = skb->tail - (unsigned char *)skb->nh.ipv6h -
 		sizeof(struct ipv6hdr);
 	mldlen = skb->tail - skb->h.raw;
@@ -1330,10 +1332,13 @@
 	if (!err) {
 		ICMP6_INC_STATS(idev,Icmp6OutMsgs);
 		IP6_INC_STATS(Ip6OutMcastPkts);
-	} else
+		IPV6_INC_STATS(idev, ipStatsOutMcastPkts);
+		IPV6_ADD_STATS(idev, ipStatsOutMcastOctets, skb->len);
+	} else {
 		IP6_INC_STATS(Ip6OutDiscards);
-
-	if (likely(idev != NULL))
+		IPV6_INC_STATS(idev, ipStatsOutDiscards);
+	}
+	if (idev)
 		in6_dev_put(idev);
 }
 
@@ -1613,7 +1618,9 @@
 		     IPV6_TLV_ROUTERALERT, 2, 0, 0,
 		     IPV6_TLV_PADN, 0 };
 
+	idev = in6_dev_get(dev);
 	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
 	snd_addr = addr;
 	if (type == ICMPV6_MGM_REDUCTION) {
 		snd_addr = &all_routers;
@@ -1628,9 +1635,13 @@
 
 	if (skb == NULL) {
 		IP6_INC_STATS(Ip6OutDiscards);
+		IPV6_INC_STATS(idev, ipStatsOutDiscards);
+		if (idev)
+			in6_dev_put(idev);
 		return;
 	}
 
+	IPV6_ADD_STATS(idev, ipStatsOutOctets, skb->len);
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	if (dev->hard_header) {
 		unsigned char ha[MAX_ADDR_LEN];
@@ -1662,8 +1673,6 @@
 					   IPPROTO_ICMPV6,
 					   csum_partial((__u8 *) hdr, len, 0));
 
-	idev = in6_dev_get(skb->dev);
-
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dev,
 		dev_queue_xmit);
 	if (!err) {
@@ -1673,16 +1682,22 @@
 			ICMP6_INC_STATS(idev, Icmp6OutGroupMembResponses);
 		ICMP6_INC_STATS(idev, Icmp6OutMsgs);
 		IP6_INC_STATS(Ip6OutMcastPkts);
-	} else
+		IPV6_INC_STATS(idev, ipStatsOutMcastPkts);
+		IPV6_ADD_STATS(idev, ipStatsOutMcastOctets, skb->len);
+	} else {
 		IP6_INC_STATS(Ip6OutDiscards);
-
+		IPV6_INC_STATS(idev, ipStatsOutDiscards);
+	}
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
 	return;
 
 out:
 	IP6_INC_STATS(Ip6OutDiscards);
+	IPV6_INC_STATS(idev, ipStatsOutDiscards);
 	kfree_skb(skb);
+	if (likely(idev != NULL))
+		in6_dev_put(idev);
 }
 
 static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
diff -urN linux-2.6.6/net/ipv6/ndisc.c linux-2.6.6-newmibs/net/ipv6/ndisc.c
--- linux-2.6.6/net/ipv6/ndisc.c	2004-05-09 19:32:39.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/ndisc.c	2004-05-26 12:05:40.000000000 -0700
@@ -453,6 +453,7 @@
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutNeighborAdvertisements);
@@ -537,6 +538,7 @@
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutNeighborSolicits);
@@ -609,7 +611,8 @@
 	/* send it! */
 	skb->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(Ip6OutRequests);	
+	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutRouterSolicits);
@@ -1336,6 +1339,7 @@
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, buff, NULL, dst->dev, dst_output);
 	if (!err) {
 		ICMP6_INC_STATS(idev, Icmp6OutRedirects);
diff -urN linux-2.6.6/net/ipv6/proc.c linux-2.6.6-newmibs/net/ipv6/proc.c
--- linux-2.6.6/net/ipv6/proc.c	2004-05-09 19:32:28.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/proc.c	2004-05-26 12:05:40.000000000 -0700
@@ -227,6 +227,9 @@
 	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
 			   __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
+	if (snmp6_mib_init((void **)idev->stats.ipv6, sizeof(struct ip_stats),
+			   __alignof__(struct ip_stats)) < 0)
+		goto err_ip;
 
 	if (!proc_net_devsnmp6) {
 		err = -ENOENT;
@@ -242,8 +245,11 @@
 	return 0;
 
 err_proc:
+	snmp6_mib_free((void **)idev->stats.ipv6);
+err_ip:
 	snmp6_mib_free((void **)idev->stats.icmpv6);
 err_icmp:
+	
 	return err;
 }
 
@@ -256,6 +262,7 @@
 	remove_proc_entry(idev->stats.proc_dir_entry->name,
 			  proc_net_devsnmp6);
 	snmp6_mib_free((void **)idev->stats.icmpv6);
+	snmp6_mib_free((void **)idev->stats.ipv6);
 
 	return 0;
 }
@@ -305,9 +312,13 @@
 	if (snmp6_mib_init((void **)idev->stats.icmpv6, sizeof(struct icmpv6_mib),
 			   __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
+	if (snmp6_mib_init((void **)idev->stats.ipv6, sizeof(struct ip_stats),
+			   __alignof__(struct ip_stats)) < 0)
+		goto err_ip;
 
 	return 0;
-
+err_ip:
+	snmp6_mib_free((void **)idev->stats.icmpv6);
 err_icmp:
 	return err;
 }
@@ -315,6 +326,7 @@
 int snmp6_unregister_dev(struct inet6_dev *idev)
 {
 	snmp6_mib_free((void **)idev->stats.icmpv6);
+	snmp6_mib_free((void **)idev->stats.ipv6);
 	return 0;
 }
 
diff -urN linux-2.6.6/net/ipv6/raw.c linux-2.6.6-newmibs/net/ipv6/raw.c
--- linux-2.6.6/net/ipv6/raw.c	2004-05-09 19:32:28.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/raw.c	2004-05-26 12:18:55.000000000 -0700
@@ -498,11 +498,15 @@
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	unsigned int hh_len;
-	int err;
+	int err = 0;
+	struct inet6_dev *idev = NULL;
+
+	/* hold reference for IP MIBs */
 
 	if (length > rt->u.dst.dev->mtu) {
 		ipv6_local_error(sk, EMSGSIZE, fl, rt->u.dst.dev->mtu);
-		return -EMSGSIZE;
+		err = -EMSGSIZE;
+		goto out;
 	}
 	if (flags&MSG_PROBE)
 		goto out;
@@ -518,6 +522,9 @@
 	skb->priority = sk->sk_priority;
 	skb->dst = dst_clone(&rt->u.dst);
 
+	if (skb->dst)
+		idev = in6_dev_get(skb->dst->dev);
+
 	skb->nh.ipv6h = iph = (struct ipv6hdr *)skb_put(skb, length);
 
 	skb->ip_summed = CHECKSUM_NONE;
@@ -527,21 +534,27 @@
 	if (err)
 		goto error_fault;
 
-	IP6_INC_STATS(Ip6OutRequests);		
+	IP6_INC_STATS(Ip6OutRequests);
+	IPV6_INC_STATS(idev, ipStatsOutRequests);
+	IPV6_ADD_STATS(idev, ipStatsOutOctets, skb->len);
+
 	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
 		err = inet->recverr ? net_xmit_errno(err) : 0;
 	if (err)
 		goto error;
-out:
-	return 0;
-
+	else
+		goto out;
 error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
 	IP6_INC_STATS(Ip6OutDiscards);
+	IPV6_INC_STATS(idev, ipStatsOutDiscards);
+out:
+	if (idev)
+		in6_dev_put(idev);
 	return err; 
 }
 static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
diff -urN linux-2.6.6/net/ipv6/reassembly.c linux-2.6.6-newmibs/net/ipv6/reassembly.c
--- linux-2.6.6/net/ipv6/reassembly.c	2004-05-09 19:32:27.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/reassembly.c	2004-05-26 12:05:40.000000000 -0700
@@ -264,6 +264,7 @@
 {
 	struct frag_queue *fq;
 	struct list_head *tmp;
+	struct inet6_dev *idev = NULL;
 
 	for(;;) {
 		if (atomic_read(&ip6_frag_mem) <= sysctl_ip6frag_low_thresh)
@@ -285,12 +286,18 @@
 
 		fq_put(fq);
 		IP6_INC_STATS_BH(Ip6ReasmFails);
+		/* idev might be pointed to NULL */
+		if (fq->fragments)
+			idev = __in6_dev_get(fq->fragments->dev);
+		IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 	}
 }
 
 static void ip6_frag_expire(unsigned long data)
 {
 	struct frag_queue *fq = (struct frag_queue *) data;
+	struct net_device *dev;
+	struct inet6_dev *idev = NULL;
 
 	spin_lock(&fq->lock);
 
@@ -301,10 +308,14 @@
 
 	IP6_INC_STATS_BH(Ip6ReasmTimeout);
 	IP6_INC_STATS_BH(Ip6ReasmFails);
+	dev = dev_get_by_index(fq->iif);
+	if (dev)
+		idev = __in6_dev_get(dev);
+	IPV6_INC_STATS_BH(idev, ipStatsInDiscards);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 
 	/* Send error only if the first segment arrived. */
 	if (fq->last_in&FIRST_IN && fq->fragments) {
-		struct net_device *dev = dev_get_by_index(fq->iif);
 
 		/*
 		   But use as source device on which LAST ARRIVED
@@ -315,9 +326,10 @@
 			fq->fragments->dev = dev;
 			icmpv6_send(fq->fragments, ICMPV6_TIME_EXCEED, ICMPV6_EXC_FRAGTIME, 0,
 				    dev);
-			dev_put(dev);
 		}
 	}
+	if (dev)
+		dev_put(dev);
 out:
 	spin_unlock(&fq->lock);
 	fq_put(fq);
@@ -367,6 +379,7 @@
 ip6_frag_create(unsigned int hash, u32 id, struct in6_addr *src, struct in6_addr *dst)
 {
 	struct frag_queue *fq;
+	struct inet6_dev *idev = NULL;
 
 	if ((fq = frag_alloc_queue()) == NULL)
 		goto oom;
@@ -387,6 +400,7 @@
 
 oom:
 	IP6_INC_STATS_BH(Ip6ReasmFails);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 	return NULL;
 }
 
@@ -417,7 +431,10 @@
 {
 	struct sk_buff *prev, *next;
 	int offset, end;
+	struct inet6_dev *idev = NULL;
 
+	if (skb->dev)
+		idev = __in6_dev_get(skb->dev);
 	if (fq->last_in & COMPLETE)
 		goto err;
 
@@ -427,6 +444,7 @@
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
 		IP6_INC_STATS_BH(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
  		icmpv6_param_prob(skb,ICMPV6_HDR_FIELD, (u8*)&fhdr->frag_off - skb->nh.raw);
  		return;
 	}
@@ -454,6 +472,7 @@
 			 * this case. -DaveM
 			 */
 			IP6_INC_STATS_BH(Ip6InHdrErrors);
+			IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, 
 					  offsetof(struct ipv6hdr, payload_len));
 			return;
@@ -573,6 +592,7 @@
 
 err:
 	IP6_INC_STATS(Ip6ReasmFails);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 	kfree_skb(skb);
 }
 
@@ -592,7 +612,10 @@
 	struct sk_buff *fp, *head = fq->fragments;
 	int    payload_len;
 	unsigned int nhoff;
-
+	struct inet6_dev *idev = NULL;
+	
+	if (dev)
+		idev = __in6_dev_get(dev);
 	fq_kill(fq);
 
 	BUG_TRAP(head != NULL);
@@ -667,6 +690,7 @@
 		head->csum = csum_partial(head->nh.raw, head->h.raw-head->nh.raw, head->csum);
 
 	IP6_INC_STATS_BH(Ip6ReasmOKs);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmOKs);
 	fq->fragments = NULL;
 	*nhoffp = nhoff;
 	return 1;
@@ -680,6 +704,7 @@
 		printk(KERN_DEBUG "ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
 	IP6_INC_STATS_BH(Ip6ReasmFails);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 	return -1;
 }
 
@@ -690,19 +715,25 @@
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
+	struct inet6_dev *idev = NULL;
 
+	if (dev)
+		idev = __in6_dev_get(dev);
 	hdr = skb->nh.ipv6h;
 
 	IP6_INC_STATS_BH(Ip6ReasmReqds);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmReqds);
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len==0) {
 		IP6_INC_STATS(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+sizeof(struct frag_hdr))) {
 		IP6_INC_STATS(Ip6InHdrErrors);
+		IPV6_INC_STATS_BH(idev, ipStatsInHdrErrors);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb->h.raw-skb->nh.raw);
 		return -1;
 	}
@@ -714,6 +745,7 @@
 		/* It is not a fragmented frame */
 		skb->h.raw += sizeof(struct frag_hdr);
 		IP6_INC_STATS_BH(Ip6ReasmOKs);
+		IPV6_INC_STATS_BH(idev, ipStatsReasmOKs);
 
 		*nhoffp = (u8*)fhdr - skb->nh.raw;
 		return 1;
@@ -739,6 +771,7 @@
 	}
 
 	IP6_INC_STATS_BH(Ip6ReasmFails);
+	IPV6_INC_STATS_BH(idev, ipStatsReasmFails);
 	kfree_skb(skb);
 	return -1;
 }
diff -urN linux-2.6.6/net/ipv6/route.c linux-2.6.6-newmibs/net/ipv6/route.c
--- linux-2.6.6/net/ipv6/route.c	2004-05-09 19:33:05.000000000 -0700
+++ linux-2.6.6-newmibs/net/ipv6/route.c	2004-05-26 12:05:40.000000000 -0700
@@ -85,7 +85,8 @@
 static struct dst_entry *ip6_negative_advice(struct dst_entry *);
 static int		 ip6_dst_gc(void);
 
-static int		ip6_pkt_discard(struct sk_buff *skb);
+static int		ip6_pkt_indiscard(struct sk_buff *skb);
+static int		ip6_pkt_outdiscard(struct sk_buff *skb);
 static void		ip6_link_failure(struct sk_buff *skb);
 static void		ip6_rt_update_pmtu(struct dst_entry *dst, u32 mtu);
 
@@ -110,8 +111,8 @@
 			.obsolete	= -1,
 			.error		= -ENETUNREACH,
 			.metrics	= { [RTAX_HOPLIMIT - 1] = 255, },
-			.input		= ip6_pkt_discard,
-			.output		= ip6_pkt_discard,
+			.input		= ip6_pkt_indiscard,
+			.output		= ip6_pkt_outdiscard,
 			.ops		= &ip6_dst_ops,
 			.path		= (struct dst_entry*)&ip6_null_entry,
 		}
@@ -767,8 +768,8 @@
 			dev_put(dev);
 		dev = &loopback_dev;
 		dev_hold(dev);
-		rt->u.dst.output = ip6_pkt_discard;
-		rt->u.dst.input = ip6_pkt_discard;
+		rt->u.dst.output = ip6_pkt_outdiscard;
+		rt->u.dst.input = ip6_pkt_indiscard;
 		rt->u.dst.error = -ENETUNREACH;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
 		goto install_route;
@@ -1255,9 +1256,30 @@
  *	Drop the packet on the floor
  */
 
-int ip6_pkt_discard(struct sk_buff *skb)
+static int ip6_pkt_indiscard(struct sk_buff *skb)
 {
+	struct inet6_dev *idev = NULL;
+
+	if (skb->dev)
+		idev = __in6_dev_get(skb->dev);
+	
+	IP6_INC_STATS(Ip6InNoRoutes);
+	IPV6_INC_STATS(idev, ipStatsInNoRoutes);
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
+	kfree_skb(skb);
+	return 0;
+}
+
+
+static int ip6_pkt_outdiscard(struct sk_buff *skb)
+{
+	struct inet6_dev *idev = NULL;
+	
+	if (skb->dev)
+		idev = __in6_dev_get(skb->dev);
+	
 	IP6_INC_STATS(Ip6OutNoRoutes);
+	IPV6_INC_STATS(idev, ipStatsOutNoRoutes);
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_NOROUTE, 0, skb->dev);
 	kfree_skb(skb);
 	return 0;

--Boundary-00=_dmPtAWGpT6TwdRU--
