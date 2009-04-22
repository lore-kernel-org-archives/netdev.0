From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Tue, 21 Apr 2009 21:12:15 -0400
Message-ID: <20090422011214.GA18856@localhost.localdomain>
References: <20090421193937.GC9577@hmsreliant.think-freely.org> <49EE257B.6090600@cosmosbay.com> <20090421200958.GD9577@hmsreliant.think-freely.org> <49EE307D.7050409@cosmosbay.com> <20090421230358.GA13660@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45504 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766AbZDVBM1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 21:12:27 -0400
Content-Disposition: inline
In-Reply-To: <20090421230358.GA13660@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	New patch, taking Erics commentary pointing out my prior stupidity into
account :).


The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastOctets and
OutMcastOctets:
http://tools.ietf.org/html/rfc4293
But it seems we don't track those in any way that easy to separate from other
protocols.  This patch adds those missing counters to the stats file.  Tested
successfully by me

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/snmp.h  |    4 ++++
 include/net/ip.h      |    1 +
 include/net/ipv6.h    |    2 ++
 include/net/snmp.h    |    5 +++++
 net/ipv4/ip_input.c   |    4 ++++
 net/ipv4/ip_output.c  |    3 +++
 net/ipv4/proc.c       |    4 ++++
 net/ipv6/ip6_input.c  |    4 ++++
 net/ipv6/ip6_output.c |    8 ++++++++
 net/ipv6/mcast.c      |    9 +++++++++
 net/ipv6/ndisc.c      |    3 +++
 net/ipv6/proc.c       |    4 ++++
 net/ipv6/raw.c        |    6 ++++++
 13 files changed, 57 insertions(+)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index aee3f1e..95c17f6 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -19,6 +19,8 @@ enum
 {
 	IPSTATS_MIB_NUM = 0,
 	IPSTATS_MIB_INRECEIVES,			/* InReceives */
+	IPSTATS_MIB_INOCTETS,			/* InOctets */
+	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
 	IPSTATS_MIB_INHDRERRORS,		/* InHdrErrors */
 	IPSTATS_MIB_INTOOBIGERRORS,		/* InTooBigErrors */
 	IPSTATS_MIB_INNOROUTES,			/* InNoRoutes */
@@ -29,6 +31,8 @@ enum
 	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
 	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
 	IPSTATS_MIB_OUTREQUESTS,		/* OutRequests */
+	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
+	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
 	IPSTATS_MIB_OUTDISCARDS,		/* OutDiscards */
 	IPSTATS_MIB_OUTNOROUTES,		/* OutNoRoutes */
 	IPSTATS_MIB_REASMTIMEOUT,		/* ReasmTimeout */
diff --git a/include/net/ip.h b/include/net/ip.h
index 4ac7577..4a59ec4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -167,6 +167,7 @@ struct ipv4_config
 
 extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
+#define IP_ADD_STATS(net, field, val) 	SNMP_ADD_STATS((net)->mib.ip_statistics, field, val)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c1f16fc..21c0345 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -130,6 +130,8 @@ extern struct ctl_path net_ipv6_ctl_path[];
 
 #define IP6_INC_STATS(net, idev,field)		\
 		_DEVINC(net, ipv6, , idev, field)
+#define IP6_ADD_STATS(net, idev,field,val)	\
+		_DEVADD(net, ipv6, , idev, field, val)
 #define IP6_INC_STATS_BH(net, idev,field)	\
 		_DEVINC(net, ipv6, _BH, idev, field)
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 57c9362..5189de9 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -153,6 +153,11 @@ struct linux_xfrm_mib {
 		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field]--; \
 		put_cpu(); \
 	} while (0)
+#define SNMP_ADD_STATS(mib, field, addend) 	\
+	do {\
+		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field] += addend; \
+		put_cpu(); \
+	} while(0);
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 1a58a6f..bc9169b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -385,6 +385,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 
 	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INRECEIVES);
+	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INOCTETS, skb->len);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
@@ -396,6 +397,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	iph = ip_hdr(skb);
 
+	if (ipv4_is_multicast(iph->daddr))
+		IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INMCASTOCTETS, skb->len);
+
 	/*
 	 *	RFC1122: 3.2.1.2 MUST silently discard any IP frame that fails the checksum.
 	 *
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3e7e910..fd47d14 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -245,6 +245,8 @@ int ip_mc_output(struct sk_buff *skb)
 	 *	If the indicated interface is up and running, send the packet.
 	 */
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
+	IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
+	IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -299,6 +301,7 @@ int ip_output(struct sk_buff *skb)
 	struct net_device *dev = skb->dst->dev;
 
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
+	IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index cf0cdee..ff75e7d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -91,6 +91,8 @@ static const struct file_operations sockstat_seq_fops = {
 /* snmp items */
 static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("InReceives", IPSTATS_MIB_INRECEIVES),
+	SNMP_MIB_ITEM("InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
 	SNMP_MIB_ITEM("InHdrErrors", IPSTATS_MIB_INHDRERRORS),
 	SNMP_MIB_ITEM("InAddrErrors", IPSTATS_MIB_INADDRERRORS),
 	SNMP_MIB_ITEM("ForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
@@ -98,6 +100,8 @@ static const struct snmp_mib snmp4_ipstats_list[] = {
 	SNMP_MIB_ITEM("InDiscards", IPSTATS_MIB_INDISCARDS),
 	SNMP_MIB_ITEM("InDelivers", IPSTATS_MIB_INDELIVERS),
 	SNMP_MIB_ITEM("OutRequests", IPSTATS_MIB_OUTREQUESTS),
+	SNMP_MIB_ITEM("OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("OutDiscards", IPSTATS_MIB_OUTDISCARDS),
 	SNMP_MIB_ITEM("OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
 	SNMP_MIB_ITEM("ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 8f04bd9..04a7057 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -71,6 +71,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	idev = __in6_dev_get(skb->dev);
 
 	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INRECEIVES);
+	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_INOCTETS, skb->len);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
 	    !idev || unlikely(idev->cnf.disable_ipv6)) {
@@ -98,6 +99,9 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	hdr = ipv6_hdr(skb);
 
+	if (ipv6_addr_is_multicast(&hdr->daddr))
+		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_INMCASTOCTETS, skb->len);
+
 	if (hdr->version != 6)
 		goto err;
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9fb49c3..d618977 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -277,6 +277,11 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
 		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 			      IPSTATS_MIB_OUTREQUESTS);
+		IP6_ADD_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUTOCTETS, skb->len);
+		if (ipv6_addr_is_multicast(&hdr->daddr))
+			IP6_ADD_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
 	}
@@ -1517,6 +1522,9 @@ int ip6_push_pending_frames(struct sock *sk)
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTOCTETS, skb->len);
+	if (ipv6_addr_is_multicast(&hdr->daddr))
+		IP6_ADD_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a51fb33..74b4441 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1450,6 +1450,9 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct flowi fl;
 
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
+
 	payload_len = (skb->tail - skb->network_header) - sizeof(*pip6);
 	mldlen = skb->tail - skb->transport_header;
 	pip6->payload_len = htons(payload_len);
@@ -1776,6 +1779,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	rcu_read_lock();
 	IP6_INC_STATS(net, __in6_dev_get(dev),
 		      IPSTATS_MIB_OUTREQUESTS);
+
 	rcu_read_unlock();
 	if (type == ICMPV6_MGM_REDUCTION)
 		snd_addr = &in6addr_linklocal_allrouters;
@@ -1786,6 +1790,11 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	payload_len = len + sizeof(ra);
 	full_len = sizeof(struct ipv6hdr) + payload_len;
 
+	IP6_ADD_STATS(net, __in6_dev_get(dev),
+		      IPSTATS_MIB_OUTOCTETS, full_len);
+	IP6_ADD_STATS(net, __in6_dev_get(dev),
+		      IPSTATS_MIB_OUTMCASTOCTETS, full_len);
+
 	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + full_len, 1, &err);
 
 	if (skb == NULL) {
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9f061d1..56cbad6 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -534,6 +534,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
@@ -1614,6 +1615,8 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, buff->len);
+
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 97c17fd..aefd40d 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -62,6 +62,8 @@ static const struct file_operations sockstat6_seq_fops = {
 static struct snmp_mib snmp6_ipstats_list[] = {
 /* ipv6 mib according to RFC 2465 */
 	SNMP_MIB_ITEM("Ip6InReceives", IPSTATS_MIB_INRECEIVES),
+	SNMP_MIB_ITEM("Ip6InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("Ip6InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6InHdrErrors", IPSTATS_MIB_INHDRERRORS),
 	SNMP_MIB_ITEM("Ip6InTooBigErrors", IPSTATS_MIB_INTOOBIGERRORS),
 	SNMP_MIB_ITEM("Ip6InNoRoutes", IPSTATS_MIB_INNOROUTES),
@@ -72,6 +74,8 @@ static struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6InDelivers", IPSTATS_MIB_INDELIVERS),
 	SNMP_MIB_ITEM("Ip6OutForwDatagrams", IPSTATS_MIB_OUTFORWDATAGRAMS),
 	SNMP_MIB_ITEM("Ip6OutRequests", IPSTATS_MIB_OUTREQUESTS),
+	SNMP_MIB_ITEM("Ip6OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_ITEM("Ip6OutDiscards", IPSTATS_MIB_OUTDISCARDS),
 	SNMP_MIB_ITEM("Ip6OutNoRoutes", IPSTATS_MIB_OUTNOROUTES),
 	SNMP_MIB_ITEM("Ip6ReasmTimeout", IPSTATS_MIB_REASMTIMEOUT),
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 61f6827..9663483 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -639,6 +639,12 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(sock_net(sk), rt->rt6i_idev,
+		      IPSTATS_MIB_OUTOCTETS, skb->len);
+	if(ipv6_addr_is_multicast(&iph->daddr))
+		IP6_ADD_STATS(sock_net(sk), rt->rt6i_idev,
+		      IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
+
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
