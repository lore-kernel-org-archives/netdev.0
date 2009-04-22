From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 12:50:34 -0400
Message-ID: <20090422165034.GC17947@hmsreliant.think-freely.org>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33746 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZDVQus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 12:50:48 -0400
Content-Disposition: inline
In-Reply-To: <20090422.025003.92631170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:50:03AM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 22 Apr 2009 11:35:45 +0200
> 
> > So RFC4293 tells corresponding Octets variables should be supported :
> > 
> >  InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOctets
> > 
> > And I dont see them in /proc/net/snmp or /proc/net/netstat
> > 
> > Mitsuru added :
> > 
> >        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
> >        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
> >        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
> >        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
> >        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
> >        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
> > 
> > And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOctets
> > 
> > Neil, you forgot OutBcastOctets :)
> 
> Fair enough.  Neil I wait for an updated patch :-)
> 

As promised, new patch, tested and ready to go.  This variant puts all the stats
at the end of the IpExt stats line in /proc/net/snmp, and at the end of
/proc/net/dev_snmp6/<iface>, so it shouldn't break any readers of those files.

Also, Eric, I know you mentioned the need for OutBcastOctets, and intuitively I
thought it should be there as well, but looking at RFC 4293, [In|Out]BcastOctets
isn't defined.  I started to wonder if perhaps the RFC assumed that McastOctets
was assumed to include broadcast frames (i.e. all hosts multicast), but I
decided that the smartest thing to do was correlate McastPkts and McastOctets.
If someone wants to make an argument for including broadcast explicitly in both
counters, then we can deal with that in a subsequent patch.

Thanks!
Neil


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
 net/ipv4/ip_input.c   |    7 +++++--
 net/ipv4/ip_output.c  |    9 ++++++---
 net/ipv4/proc.c       |    4 ++++
 net/ipv6/ip6_input.c  |    5 +++++
 net/ipv6/ip6_output.c |    5 +++++
 net/ipv6/mcast.c      |    6 ++++++
 net/ipv6/ndisc.c      |    2 ++
 net/ipv6/proc.c       |    4 ++++
 net/ipv6/raw.c        |    2 ++
 13 files changed, 51 insertions(+), 5 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index aee3f1e..144bdc9 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -42,6 +42,10 @@ enum
 	IPSTATS_MIB_OUTMCASTPKTS,		/* OutMcastPkts */
 	IPSTATS_MIB_INBCASTPKTS,		/* InBcastPkts */
 	IPSTATS_MIB_OUTBCASTPKTS,		/* OutBcastPkts */
+	IPSTATS_MIB_INOCTETS,			/* InOctets */
+	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
+	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
+	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
 	__IPSTATS_MIB_MAX
 };
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 4ac7577..278408e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -168,6 +168,7 @@ struct ipv4_config
 extern struct ipv4_config ipv4_config;
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.ip_statistics, field)
 #define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.ip_statistics, field)
+#define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.ip_statistics, field, val)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS_BH((net)->mib.ip_statistics, field, val)
 #define NET_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.net_statistics, field)
 #define NET_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.net_statistics, field)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c1f16fc..3ec6030 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -132,6 +132,8 @@ extern struct ctl_path net_ipv6_ctl_path[];
 		_DEVINC(net, ipv6, , idev, field)
 #define IP6_INC_STATS_BH(net, idev,field)	\
 		_DEVINC(net, ipv6, _BH, idev, field)
+#define IP6_ADD_STATS(net, idev,field,val)	\
+		_DEVADD(net, ipv6, , idev, field, val)
 #define IP6_ADD_STATS_BH(net, idev,field,val)	\
 		_DEVADD(net, ipv6, _BH, idev, field, val)
 
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 57c9362..814f876 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -153,6 +153,11 @@ struct linux_xfrm_mib {
 		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field]--; \
 		put_cpu(); \
 	} while (0)
+#define SNMP_ADD_STATS(mib, field, addend) 	\
+	do { \
+		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field] += addend; \
+		put_cpu(); \
+	} while (0)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 1a58a6f..9eeecfd 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -358,9 +358,11 @@ static int ip_rcv_finish(struct sk_buff *skb)
 		goto drop;
 
 	rt = skb->rtable;
-	if (rt->rt_type == RTN_MULTICAST)
+	if (rt->rt_type == RTN_MULTICAST) {
 		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCASTPKTS);
-	else if (rt->rt_type == RTN_BROADCAST)
+		IP_ADD_STATS_BH(dev_net(rt->u.dst.dev),
+				IPSTATS_MIB_INMCASTOCTETS, skb->len);
+	} else if (rt->rt_type == RTN_BROADCAST)
 		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCASTPKTS);
 
 	return dst_input(skb);
@@ -390,6 +392,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
+	IP_ADD_STATS_BH(dev_net(dev), IPSTATS_MIB_INOCTETS, skb->len);
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto inhdr_error;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3e7e910..08f02de 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -181,9 +181,10 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct net_device *dev = dst->dev;
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
 
-	if (rt->rt_type == RTN_MULTICAST)
+	if (rt->rt_type == RTN_MULTICAST) {
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTMCASTPKTS);
-	else if (rt->rt_type == RTN_BROADCAST)
+		IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
+	} else if (rt->rt_type == RTN_BROADCAST)
 		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTBCASTPKTS);
 
 	/* Be paranoid, rather than too clever. */
@@ -245,7 +246,8 @@ int ip_mc_output(struct sk_buff *skb)
 	 *	If the indicated interface is up and running, send the packet.
 	 */
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
-
+	IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
+	
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
@@ -299,6 +301,7 @@ int ip_output(struct sk_buff *skb)
 	struct net_device *dev = skb->dst->dev;
 
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_OUTREQUESTS);
+	IP_ADD_STATS(dev_net(dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index cf0cdee..6d2029d 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -118,6 +118,10 @@ static const struct snmp_mib snmp4_ipextstats_list[] = {
 	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
 	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
 	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
+	SNMP_MIB_ITEM("InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
+	SNMP_MIB_ITEM("OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 8f04bd9..75d740b 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -78,6 +78,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 		goto drop;
 	}
 
+	IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_INOCTETS, skb->len);
+
 	memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
 
 	/*
@@ -244,6 +246,9 @@ int ip6_mc_input(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(dev_net(skb->dst->dev),
 			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
+	IP6_ADD_STATS_BH(dev_net(skb->dst->dev),
+			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTOCTETS,
+			 skb->len);
 
 	hdr = ipv6_hdr(skb);
 	deliver = ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9fb49c3..0fcbeb9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -160,6 +160,8 @@ static int ip6_output2(struct sk_buff *skb)
 		}
 
 		IP6_INC_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_ADD_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCASTOCTETS,
+				skb->len);
 	}
 
 	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
@@ -277,6 +279,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
 		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 			      IPSTATS_MIB_OUTREQUESTS);
+		IP6_ADD_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_OUTOCTETS, skb->len);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
 	}
@@ -1517,6 +1521,7 @@ int ip6_push_pending_frames(struct sock *sk)
 
 	skb->dst = dst_clone(&rt->u.dst);
 	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTOCTETS, skb->len);
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a51fb33..3e41dcc 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1450,6 +1450,8 @@ static void mld_sendpack(struct sk_buff *skb)
 	struct flowi fl;
 
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
+
 	payload_len = (skb->tail - skb->network_header) - sizeof(*pip6);
 	mldlen = skb->tail - skb->transport_header;
 	pip6->payload_len = htons(payload_len);
@@ -1480,6 +1482,7 @@ out:
 		ICMP6MSGOUT_INC_STATS_BH(net, idev, ICMPV6_MLD2_REPORT);
 		ICMP6_INC_STATS_BH(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_ADD_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
 	} else
 		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
@@ -1776,6 +1779,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	rcu_read_lock();
 	IP6_INC_STATS(net, __in6_dev_get(dev),
 		      IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, __in6_dev_get(dev),
+		      IPSTATS_MIB_OUTOCTETS, skb->len);
 	rcu_read_unlock();
 	if (type == ICMPV6_MGM_REDUCTION)
 		snd_addr = &in6addr_linklocal_allrouters;
@@ -1845,6 +1850,7 @@ out:
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTMCASTOCTETS, skb->len);
 	} else
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 9f061d1..fd93524 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -534,6 +534,7 @@ void ndisc_send_skb(struct sk_buff *skb,
 
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
@@ -1614,6 +1615,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
 	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(net, idev, IPSTATS_MIB_OUTOCTETS, skb->len);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 97c17fd..ba5ebad 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -83,6 +83,10 @@ static struct snmp_mib snmp6_ipstats_list[] = {
 	SNMP_MIB_ITEM("Ip6FragCreates", IPSTATS_MIB_FRAGCREATES),
 	SNMP_MIB_ITEM("Ip6InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
 	SNMP_MIB_ITEM("Ip6OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("Ip6InOctets", IPSTATS_MIB_INOCTETS),
+	SNMP_MIB_ITEM("Ip6OutOctets", IPSTATS_MIB_OUTOCTETS),
+	SNMP_MIB_ITEM("Ip6InMcastOctets", IPSTATS_MIB_INMCASTOCTETS),
+	SNMP_MIB_ITEM("Ip6OutMcastOctets", IPSTATS_MIB_OUTMCASTOCTETS),
 	SNMP_MIB_SENTINEL
 };
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 61f6827..1e1feb9 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -639,6 +639,8 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_ADD_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTOCTETS,
+			skb->len);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
