From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] reduce sizeof(struct flow)
Date: Wed, 18 Oct 2006 07:30:32 +0200
Message-ID: <4535BBF8.7000304@cosmosbay.com>
References: <4415A4C1.1030906@cosmosbay.com> <452EA214.7080905@cosmosbay.com>
 <4535B6B7.4070107@cosmosbay.com>
 <20061018.141752.92593935.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_zrrn/KwLpXVq/b6aytyRFg)"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003mt.neufgp.fr ([84.96.92.56]:13305 "EHLO smTp.neuf.fr")
	by vger.kernel.org with ESMTP id S1751397AbWJRFad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2006 01:30:33 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604003mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7B00CM0GMVYQ41@sp604003mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Wed, 18 Oct 2006 07:30:32 +0200 (CEST)
In-reply-to: <20061018.141752.92593935.yoshfuji@linux-ipv6.org>
To: =?windows-1252?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_zrrn/KwLpXVq/b6aytyRFg)
Content-type: text/plain; charset=windows-1252; format=flowed
Content-transfer-encoding: 8BIT

YOSHIFUJI Hideaki / ???? a écrit :
> In article <4535B6B7.4070107@cosmosbay.com> (at Wed, 18 Oct 2006 07:08:07 +0200), Eric Dumazet <dada1@cosmosbay.com> says:
> 
>>  		
>> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>  		struct {
>>  			struct in6_addr		daddr;
>>  			struct in6_addr		saddr;
> 
> #ifdef CONFIG_IPV6_ROUTE_FWMARK
> 
>>  			__u32			fwmark;
> 
> #endif
> 
>>  			__u32			flowlabel;
>>  		} ip6_u;
>> +#endif
>>  
>>  		struct {
>>  			__le16			daddr;
> 
> --yoshfuji

Thank you Yoshfuji

New patch version follows :

Each route entry includes a 'struct flow'. This structure has a current size 
of 80 bytes. This patch makes a size reduction depending on 
CONFIG_IPV6/CONFIG_IPV6_MODULE/CONFIG_DECNET/CONFIG_IP_ROUTE_FWMARK/CONFIG_IPV6_ROUTE_FWMARK

For a platform doing IPV4 only, the new size is 36 bytes (instead of 80)
As many routers are base on PIII (L1_CACHE_SIZE=32), this saves one cache line 
per rtable entry.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--Boundary_(ID_zrrn/KwLpXVq/b6aytyRFg)
Content-type: text/plain; name=shrink_flow.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=shrink_flow.patch

--- linux-2.6.19-rc2/include/net/flow.h	2006-10-18 06:03:08.000000000 +0200
+++ linux-2.6.19-rc2-ed/include/net/flow.h	2006-10-18 07:26:59.000000000 +0200
@@ -18,17 +18,23 @@
 		struct {
 			__be32			daddr;
 			__be32			saddr;
+#if defined(CONFIG_IP_ROUTE_FWMARK)
 			__u32			fwmark;
+#endif
 			__u8			tos;
 			__u8			scope;
 		} ip4_u;
 		
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		struct {
 			struct in6_addr		daddr;
 			struct in6_addr		saddr;
+#if defined(CONFIG_IPV6_ROUTE_FWMARK)
 			__u32			fwmark;
+#endif
 			__u32			flowlabel;
 		} ip6_u;
+#endif
 
 		struct {
 			__le16			daddr;
@@ -65,6 +71,7 @@
 			__u8	code;
 		} icmpt;
 
+#if defined(CONFIG_DECNET)
 		struct {
 			__le16	sport;
 			__le16	dport;
@@ -72,6 +79,7 @@
 			__u8	objnamel; /* Not 16 bits since max val is 16 */
 			__u8	objname[16]; /* Not zero terminated */
 		} dnports;
+#endif
 
 		__be32		spi;
 
--- linux-2.6.19-rc2/include/net/xfrm.h	2006-10-18 06:21:19.000000000 +0200
+++ linux-2.6.19-rc2-ed/include/net/xfrm.h	2006-10-18 06:53:41.000000000 +0200
@@ -517,6 +517,7 @@
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int
 __xfrm6_selector_match(struct xfrm_selector *sel, struct flowi *fl)
 {
@@ -527,6 +528,7 @@
 		(fl->proto == sel->proto || !sel->proto) &&
 		(fl->oif == sel->ifindex || !sel->ifindex);
 }
+#endif
 
 static inline int
 xfrm_selector_match(struct xfrm_selector *sel, struct flowi *fl,
@@ -535,8 +537,10 @@
 	switch (family) {
 	case AF_INET:
 		return __xfrm4_selector_match(sel, fl);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return __xfrm6_selector_match(sel, fl);
+#endif
 	}
 	return 0;
 }
@@ -577,7 +581,9 @@
 		struct xfrm_dst		*next;
 		struct dst_entry	dst;
 		struct rtable		rt;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		struct rt6_info		rt6;
+#endif
 	} u;
 	struct dst_entry *route;
 	u32 genid;
@@ -650,12 +656,14 @@
 		 tmpl->saddr.a4 != x->props.saddr.a4);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline int
 __xfrm6_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x)
 {
 	return	(!ipv6_addr_any((struct in6_addr*)&tmpl->saddr) &&
 		 ipv6_addr_cmp((struct in6_addr *)&tmpl->saddr, (struct in6_addr*)&x->props.saddr));
 }
+#endif
 
 static inline int
 xfrm_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x, unsigned short family)
@@ -663,8 +671,10 @@
 	switch (family) {
 	case AF_INET:
 		return __xfrm4_state_addr_cmp(tmpl, x);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return __xfrm6_state_addr_cmp(tmpl, x);
+#endif
 	}
 	return !0;
 }
@@ -762,8 +772,10 @@
 	switch (family){
 	case AF_INET:
 		return (xfrm_address_t *)&fl->fl4_dst;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return (xfrm_address_t *)&fl->fl6_dst;
+#endif
 	}
 	return NULL;
 }
@@ -774,8 +786,10 @@
 	switch (family){
 	case AF_INET:
 		return (xfrm_address_t *)&fl->fl4_src;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return (xfrm_address_t *)&fl->fl6_src;
+#endif
 	}
 	return NULL;
 }
@@ -790,6 +804,7 @@
 	return 0;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static __inline__ int
 __xfrm6_state_addr_check(struct xfrm_state *x,
 			 xfrm_address_t *daddr, xfrm_address_t *saddr)
@@ -801,6 +816,7 @@
 		return 1;
 	return 0;
 }
+#endif
 
 static __inline__ int
 xfrm_state_addr_check(struct xfrm_state *x,
@@ -810,8 +826,10 @@
 	switch (family) {
 	case AF_INET:
 		return __xfrm4_state_addr_check(x, daddr, saddr);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return __xfrm6_state_addr_check(x, daddr, saddr);
+#endif
 	}
 	return 0;
 }
@@ -825,10 +843,12 @@
 		return __xfrm4_state_addr_check(x,
 						(xfrm_address_t *)&fl->fl4_dst,
 						(xfrm_address_t *)&fl->fl4_src);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return __xfrm6_state_addr_check(x,
 						(xfrm_address_t *)&fl->fl6_dst,
 						(xfrm_address_t *)&fl->fl6_src);
+#endif
 	}
 	return 0;
 }

--Boundary_(ID_zrrn/KwLpXVq/b6aytyRFg)--
