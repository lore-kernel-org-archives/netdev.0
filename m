From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Sun, 11 Oct 2015 07:31:32 -0600
Message-ID: <561A64B4.5080301@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com> <m21td17d5p.wl@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060205010303060607050305"
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36197 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbJKNb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 09:31:28 -0400
Received: by pablk4 with SMTP id lk4so129994170pab.3
        for <netdev@vger.kernel.org>; Sun, 11 Oct 2015 06:31:27 -0700 (PDT)
In-Reply-To: <m21td17d5p.wl@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060205010303060607050305
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On 10/11/15 7:22 AM, Hajime Tazaki wrote:
>
> At Fri, 9 Oct 2015 11:27:36 -0600,
> David Ahern wrote:
>>
>> [1  <text/plain; windows-1252 (7bit)>]
>> On 10/9/15 1:17 AM, Steffen Klassert wrote:
>>>>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>>>>> index 30caa289c5db..5cedfda4b241 100644
>>>>> --- a/net/ipv6/xfrm6_policy.c
>>>>> +++ b/net/ipv6/xfrm6_policy.c
>>>>> @@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
>>>>>
>>>>>    	memset(&fl6, 0, sizeof(fl6));
>>>>>    	fl6.flowi6_oif = oif;
>>>>> +	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
>>>>>    	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
>>>>>    	if (saddr)
>>>>>    		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
>>>>
>>>> I found that this fix is still not sufficient with the mip6
>>>> (Mobile IPv6) use case.
>>>
>>> It does not even fix the vti case. The behaviour of the vti devices is
>>> the same, with and without the patch.
>>>
>>
>> The attached patch applied to Linus' tree works for me. Currently the
>> above change is not in his tree, so I added it to this patch. Once you
>> confirm that it works for you I'll create the delta-patch for net and
>> send out.
>
> I gave it a try but without any luck unfortunately.
> I may need to look carefully what mip6 does here.
>
> the code path where I'm looking at for MH packet (raw socket
> with IPPROTO_MH) is:
>
> #0  ip6_route_output (net=0x7ffff3a40a40 <rumpns_init_net>, sk=0x7ffff30b5c50, fl6=0x7ffff0ed2fe0) at net/ipv6/route.c:1195
> #1  0x00007ffff35d155f in ip6_dst_lookup_tail (net=0x7ffff3a40a40 <rumpns_init_net>, sk=0x7ffff30b5c50, dst=0x7ffff0ed2f18, fl6=0x7ffff0ed2fe0)
>      at net/ipv6/ip6_output.c:929
> #2  0x00007ffff35d1707 in ip6_dst_lookup_flow (sk=0x7ffff30b5c50, fl6=0x7ffff0ed2fe0, final_dst=0x0) at net/ipv6/ip6_output.c:1024
> #3  0x00007ffff36199f7 in rawv6_sendmsg (sk=0x7ffff30b5c50, msg=0x7ffff0ed3320, len=32) at net/ipv6/raw.c:872
> #4  0x00007ffff3526d21 in inet_sendmsg (sock=0x7ffff30b5810, msg=0x7ffff0ed3320, size=32) at net/ipv4/af_inet.c:737
> #5  0x00007ffff338dc8a in sock_sendmsg_nosec (msg=0x7ffff0ed3320, sock=0x7ffff30b5810) at net/socket.c:610
> #6  sock_sendmsg (sock=0x7ffff30b5810, msg=0x7ffff0ed3320) at net/socket.c:620
>
>
> which (*dst)->error of ip6_route_output gives -22 (EINVAL).
>
> I will be back once I got any findings.

How does a xfrm change affect this code path?

Can you apply this patch, and then run:

perf record -e fib6:* -a -g
perf script

Thanks,
David



--------------060205010303060607050305
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="0001-net-IPv6-fib-and-route-tracepoints.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-net-IPv6-fib-and-route-tracepoints.patch"

>From 5da83796c110d5f2c995b22b38be8e5268a7f573 Mon Sep 17 00:00:00 2001
From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 1 Oct 2015 14:52:58 -0700
Subject: [PATCH net-next] net: IPv6 fib and route tracepoints

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/trace/events/fib6.h | 237 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/net-traces.c       |   7 ++
 net/ipv6/route.c            |  24 ++++-
 3 files changed, 267 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/events/fib6.h

diff --git a/include/trace/events/fib6.h b/include/trace/events/fib6.h
new file mode 100644
index 000000000000..9f34da0d59a3
--- /dev/null
+++ b/include/trace/events/fib6.h
@@ -0,0 +1,237 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fib6
+
+#if !defined(_TRACE_FIB6_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FIB6_H
+
+#include <linux/in6.h>
+#include <net/flow.h>
+#include <net/ip6_fib.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(fib6_table_lookup,
+
+	TP_PROTO(const struct net *net, const struct rt6_info *rt,
+		 u32 tb_id, const struct flowi6 *flp),
+
+	TP_ARGS(net, rt, tb_id, flp),
+
+	TP_STRUCT__entry(
+		__field(	u32,	tb_id		)
+
+		__field(	int,	oif		)
+		__field(	int,	iif		)
+		__field(	__u8,	tos		)
+		__field(	__u8,	scope		)
+		__field(	__u8,	flags		)
+		__array(	__u8,	src,	16	)
+		__array(	__u8,	dst,	16	)
+
+		__dynamic_array(	char,	name,	IFNAMSIZ )
+		__array(		__u8,	gw,	16	 )
+	),
+
+	TP_fast_assign(
+		struct in6_addr *in6;
+
+		__entry->tb_id = tb_id;
+		__entry->oif = flp->flowi6_oif;
+		__entry->iif = flp->flowi6_iif;
+		__entry->tos = flp->flowi6_tos;
+		__entry->scope = flp->flowi6_scope;
+		__entry->flags = flp->flowi6_flags;
+
+		in6 = (struct in6_addr *)__entry->src;
+		*in6 = flp->saddr;
+
+		in6 = (struct in6_addr *)__entry->dst;
+		*in6 = flp->daddr;
+
+		if (rt->rt6i_idev) {
+			__assign_str(name, rt->rt6i_idev->dev->name);
+		} else {
+			__assign_str(name, "");
+		}
+		if (rt == net->ipv6.ip6_null_entry) {
+			struct in6_addr in6_zero = {};
+
+			in6 = (struct in6_addr *)__entry->gw;
+			*in6 = in6_zero;
+
+		} else if (rt) {
+			in6 = (struct in6_addr *)__entry->gw;
+			*in6 = rt->rt6i_gateway;
+		}
+	),
+
+	TP_printk("table %3u oif %d iif %d src %pI6c dst %pI6c tos %d scope %d flags %x ==> dev %s gw %pI6c",
+		  __entry->tb_id, __entry->oif, __entry->iif,
+		  __entry->src, __entry->dst, __entry->tos, __entry->scope,
+		  __entry->flags, __get_str(name), __entry->gw)
+);
+
+TRACE_EVENT(ip6_route_del,
+
+	TP_PROTO(const struct fib6_config *cfg),
+
+	TP_ARGS(cfg),
+
+	TP_STRUCT__entry(
+		__field(	u32,	tb_id		)
+		__field(	int,	iif		)
+		__field(	int,	src_len		)
+		__field(	int,	dst_len		)
+		__array(	__u8,	src,	 16	)
+		__array(	__u8,	dst,	 16	)
+		__array(	__u8,	prefsrc, 16	)
+		__array(	__u8,	gw,	 16	)
+	),
+
+	TP_fast_assign(
+		struct in6_addr *in6;
+
+		__entry->tb_id = cfg->fc_table;
+		__entry->iif = cfg->fc_ifindex;
+
+		in6 = (struct in6_addr *)__entry->src;
+		*in6 = cfg->fc_src;
+		__entry->src_len = cfg->fc_src_len;
+
+		in6 = (struct in6_addr *)__entry->dst;
+		*in6 = cfg->fc_dst;
+		__entry->dst_len = cfg->fc_dst_len;
+
+		in6 = (struct in6_addr *)__entry->prefsrc;
+		*in6 = cfg->fc_prefsrc;
+
+		in6 = (struct in6_addr *)__entry->gw;
+		*in6 = cfg->fc_gateway;
+	),
+
+	TP_printk("table %u ifindex %d src %pI6c/%d dst %pI6c/%d prefsrc %pI6c gw %pI6c",
+		  __entry->tb_id, __entry->iif, __entry->src, __entry->src_len,
+		  __entry->dst, __entry->dst_len, __entry->prefsrc, __entry->gw)
+);
+
+TRACE_EVENT(ipv6_alloc_dst,
+
+	TP_PROTO(const struct rt6_info *rt),
+
+	TP_ARGS(rt),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	dst		)
+		__field(	void *,	input		)
+		__field(	void *,	output		)
+		__field(	__u32,	flags		)
+		__field(	__u32,	tb_id		)
+		__dynamic_array(	char,	name,	IFNAMSIZ )
+		__array(	__u8,	gw,	16	)
+		__array(	__u8,	addr,	16	)
+		__field(	__u32,	plen		)
+	),
+
+	TP_fast_assign(
+		struct in6_addr *in6;
+
+		__entry->dst = &rt->dst;
+		__entry->input = rt->dst.input;
+		__entry->output = rt->dst.output;
+		__entry->flags = rt->rt6i_flags;
+		if (rt->rt6i_table) {
+			__entry->tb_id = rt->rt6i_table->tb6_id;
+		} else {
+			__entry->tb_id = 0;
+		}
+		in6 = (struct in6_addr *)__entry->gw;
+		*in6 = rt->rt6i_gateway;
+
+		in6 = (struct in6_addr *)__entry->addr;
+		*in6 = rt->rt6i_dst.addr;
+		__entry->plen = rt->rt6i_dst.plen;
+
+		if (rt->rt6i_idev) {
+			__assign_str(name, rt->rt6i_idev->dev->name);
+		} else {
+			__assign_str(name, "<null>");
+		}
+	),
+
+	TP_printk("table %3u flags %x dev %s gw %pI6c addr %pI6c/%d dst %p input %p output %p",
+		  __entry->tb_id, __entry->flags, __get_str(name),
+		  __entry->gw, __entry->addr, __entry->plen,
+		  __entry->dst, __entry->input, __entry->output)
+);
+
+TRACE_EVENT(ipv6_alloc_pcpu_dst,
+
+	TP_PROTO(const struct rt6_info *rt, const struct rt6_info *rt_orig),
+
+	TP_ARGS(rt, rt_orig),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	dst_orig	)
+		__field(	const void *,	dst		)
+	),
+
+	TP_fast_assign(
+		__entry->dst_orig = &rt_orig->dst;
+		__entry->dst = &rt->dst;
+	),
+
+	TP_printk("dst %p dst orig %p",
+		  __entry->dst, __entry->dst_orig)
+);
+
+TRACE_EVENT(fib6_ifdown,
+
+	TP_PROTO(const struct net_device *dev, const struct rt6_info *rt),
+
+	TP_ARGS(dev, rt),
+
+	TP_STRUCT__entry(
+		__field(	const void *,	dst		)
+		__field(	__u32,	flags		)
+		__field(	__u32,	tb_id		)
+		__dynamic_array(	char,	dev,	IFNAMSIZ )
+		__dynamic_array(	char,	rt_dev,	IFNAMSIZ )
+		__array(	__u8,	gw,	16	)
+		__array(	__u8,	addr,	16	)
+		__field(	__u32,	plen		)
+	),
+
+	TP_fast_assign(
+		struct in6_addr *in6;
+
+		__entry->dst = &rt->dst;
+		__entry->flags = rt->rt6i_flags;
+		if (rt->rt6i_table) {
+			__entry->tb_id = rt->rt6i_table->tb6_id;
+		} else {
+			__entry->tb_id = 0;
+		}
+		in6 = (struct in6_addr *)__entry->gw;
+		*in6 = rt->rt6i_gateway;
+
+		in6 = (struct in6_addr *)__entry->addr;
+		*in6 = rt->rt6i_dst.addr;
+		__entry->plen = rt->rt6i_dst.plen;
+
+		__assign_str(dev, dev->name);
+		if (rt->rt6i_idev) {
+			__assign_str(rt_dev, rt->rt6i_idev->dev->name);
+		} else {
+			__assign_str(rt_dev, "<null>");
+		}
+	),
+
+	TP_printk("dev %s table %3u flags %x rt_dev %s gw %pI6c addr %pI6c/%d dst %p",
+		  __get_str(dev), __entry->tb_id, __entry->flags, __get_str(rt_dev),
+		  __entry->gw, __entry->addr, __entry->plen, __entry->dst)
+
+);
+
+#endif /* _TRACE_FIB6_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/net/core/net-traces.c b/net/core/net-traces.c
index adef015b2f41..a4ee389237e5 100644
--- a/net/core/net-traces.c
+++ b/net/core/net-traces.c
@@ -32,6 +32,13 @@
 #include <trace/events/sock.h>
 #include <trace/events/udp.h>
 #include <trace/events/fib.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <trace/events/fib6.h>
+EXPORT_TRACEPOINT_SYMBOL_GPL(fib6_table_lookup);
+EXPORT_TRACEPOINT_SYMBOL_GPL(ipv6_alloc_pcpu_dst);
+EXPORT_TRACEPOINT_SYMBOL_GPL(ipv6_alloc_dst);
+EXPORT_TRACEPOINT_SYMBOL_GPL(ip6_route_del);
+#endif
 
 EXPORT_TRACEPOINT_SYMBOL_GPL(kfree_skb);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 63446bae7f5f..781651a2cf01 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -62,6 +62,7 @@
 #include <net/lwtunnel.h>
 #include <net/ip_tunnels.h>
 #include <net/l3mdev.h>
+#include <trace/events/fib6.h>
 
 #include <asm/uaccess.h>
 
@@ -857,6 +858,9 @@ static struct rt6_info *ip6_pol_route_lookup(struct net *net,
 	}
 	dst_use(&rt->dst, jiffies);
 	read_unlock_bh(&table->tb6_lock);
+
+	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
+
 	return rt;
 
 }
@@ -958,6 +962,7 @@ static struct rt6_info *ip6_rt_cache_alloc(struct rt6_info *ort,
 #endif
 	}
 
+	trace_ipv6_alloc_dst(rt);
 	return rt;
 }
 
@@ -973,6 +978,8 @@ static struct rt6_info *ip6_rt_pcpu_alloc(struct rt6_info *rt)
 	ip6_rt_copy_init(pcpu_rt, rt);
 	pcpu_rt->rt6i_protocol = rt->rt6i_protocol;
 	pcpu_rt->rt6i_flags |= RTF_PCPU;
+
+	trace_ipv6_alloc_pcpu_dst(pcpu_rt, rt);
 	return pcpu_rt;
 }
 
@@ -1070,6 +1077,8 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 		read_unlock_bh(&table->tb6_lock);
 
 		rt6_dst_from_metrics_check(rt);
+
+		trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 		return rt;
 	} else if (unlikely((fl6->flowi6_flags & FLOWI_FLAG_KNOWN_NH) &&
 			    !(rt->rt6i_flags & RTF_GATEWAY))) {
@@ -1093,6 +1102,8 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			uncached_rt = net->ipv6.ip6_null_entry;
 
 		dst_hold(&uncached_rt->dst);
+
+		trace_fib6_table_lookup(net, uncached_rt, table->tb6_id, fl6);
 		return uncached_rt;
 
 	} else {
@@ -1117,6 +1128,7 @@ static struct rt6_info *ip6_pol_route(struct net *net, struct fib6_table *table,
 			dst_release(&rt->dst);
 		}
 
+		trace_fib6_table_lookup(net, pcpu_rt, table->tb6_id, fl6);
 		return pcpu_rt;
 
 	}
@@ -1460,6 +1472,7 @@ static struct rt6_info *__ip6_route_redirect(struct net *net,
 
 	read_unlock_bh(&table->tb6_lock);
 
+	trace_fib6_table_lookup(net, rt, table->tb6_id, fl6);
 	return rt;
 };
 
@@ -1600,6 +1613,8 @@ struct dst_entry *icmp6_dst_alloc(struct net_device *dev,
 	rt->rt6i_idev     = idev;
 	dst_metric_set(&rt->dst, RTAX_HOPLIMIT, 0);
 
+	trace_ipv6_alloc_dst(rt);
+
 	spin_lock_bh(&icmp6_dst_lock);
 	rt->dst.next = icmp6_dst_gc_list;
 	icmp6_dst_gc_list = &rt->dst;
@@ -1967,6 +1982,8 @@ int ip6_route_info_create(struct fib6_config *cfg, struct rt6_info **rt_ret)
 
 	cfg->fc_nlinfo.nl_net = dev_net(dev);
 
+	trace_ipv6_alloc_dst(rt);
+
 	*rt_ret = rt;
 
 	return 0;
@@ -2046,6 +2063,8 @@ static int ip6_route_del(struct fib6_config *cfg)
 	struct rt6_info *rt;
 	int err = -ESRCH;
 
+	trace_ip6_route_del(cfg);
+
 	table = fib6_get_table(cfg->fc_nlinfo.nl_net, cfg->fc_table);
 	if (!table)
 		return err;
@@ -2510,6 +2529,7 @@ struct rt6_info *addrconf_dst_alloc(struct inet6_dev *idev,
 
 	atomic_set(&rt->dst.__refcnt, 1);
 
+	trace_ipv6_alloc_dst(rt);
 	return rt;
 }
 
@@ -2595,8 +2615,10 @@ static int fib6_ifdown(struct rt6_info *rt, void *arg)
 	const struct net_device *dev = adn->dev;
 
 	if ((rt->dst.dev == dev || !dev) &&
-	    rt != adn->net->ipv6.ip6_null_entry)
+	    rt != adn->net->ipv6.ip6_null_entry) {
+		trace_fib6_ifdown(dev, rt);
 		return -1;
+	}
 
 	return 0;
 }
-- 
1.9.1


--------------060205010303060607050305--
