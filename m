From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 19:40:46 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.194046.29425359.yoshfuji@wide.ad.jp>
References: <20030609.030334.02284330.davem@redhat.com>
	<20030609101302.GA9643@wotan.suse.de>
	<20030609.031341.77044985.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, sim@netnation.com, xerox@foonet.net, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru,
   Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030609.031341.77044985.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030609.031341.77044985.davem@redhat.com> (at Mon, 09 Jun 2003 03:13:41 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

>    It's unlikely to be the reason for the profile hit on a modern x86.
>    They are all really fast at reading/writing L1. 
:
> This is also why the net/core/skbuff.c initialization hacks are so
> effective as well.
> 
> Trust me, this has every symptom of excess store buffer traffic :)

Ok, how about this?

Index: linux25/include/net/dst.h
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux25/include/net/dst.h,v
retrieving revision 1.7
diff -u -r1.7 dst.h
--- linux25/include/net/dst.h	20 Apr 2003 14:55:48 -0000	1.7
+++ linux25/include/net/dst.h	9 Jun 2003 10:26:30 -0000
@@ -38,7 +38,7 @@
 struct dst_entry
 {
 	struct dst_entry        *next;
-	atomic_t		__refcnt;	/* client references	*/
+	
 	int			__use;
 	struct dst_entry	*child;
 	struct net_device       *dev;
@@ -48,14 +48,12 @@
 #define DST_NOXFRM		2
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
-	unsigned long		lastuse;
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
 	u32			metrics[RTAX_MAX];
-	struct dst_entry	*path;
 
 	unsigned long		rate_last;	/* rate limiting for ICMP */
 	unsigned long		rate_tokens;
@@ -66,16 +64,24 @@
 	struct hh_cache		*hh;
 	struct xfrm_state	*xfrm;
 
-	int			(*input)(struct sk_buff*);
-	int			(*output)(struct sk_buff*);
-
 #ifdef CONFIG_NET_CLS_ROUTE
 	__u32			tclassid;
 #endif
 
-	struct  dst_ops	        *ops;
 	struct rcu_head		rcu_head;
-		
+
+	/* These elements should be at the end of dst_entry{}; 
+	 * see net/core/dst.c:dst_alloc() -- yoshfuji */
+	u32			__dst_memset_tail[0];
+
+	atomic_t		__refcnt;	/* client references	*/
+	unsigned long		lastuse;
+
+	struct dst_entry	*path;
+	int			(*input)(struct sk_buff*);
+	int			(*output)(struct sk_buff*);
+	struct dst_ops	        *ops;
+
 	char			info[0];
 };
 
Index: linux25/net/core/dst.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux25/net/core/dst.c,v
retrieving revision 1.1.1.9
diff -u -r1.1.1.9 dst.c
--- linux25/net/core/dst.c	27 May 2003 02:59:54 -0000	1.1.1.9
+++ linux25/net/core/dst.c	9 Jun 2003 10:26:30 -0000
@@ -122,13 +122,16 @@
 	dst = kmem_cache_alloc(ops->kmem_cachep, SLAB_ATOMIC);
 	if (!dst)
 		return NULL;
-	memset(dst, 0, ops->entry_size);
+	memset(dst, 0, offsetof(struct dst_entry, __dst_memset_tail));
 	atomic_set(&dst->__refcnt, 0);
-	dst->ops = ops;
 	dst->lastuse = jiffies;
 	dst->path = dst;
 	dst->input = dst_discard;
 	dst->output = dst_blackhole;
+	dst->ops = ops;
+	if (ops->entry_size > offsetof(struct dst_entry, info))
+		memset(&dst->info, 0, ops->entry_size - offsetof(struct dst_entry, info));
+
 #if RT_CACHE_DEBUG >= 2 
 	atomic_inc(&dst_total);
 #endif

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
