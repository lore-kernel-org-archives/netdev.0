From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Shrink struct dst_entry a bit
Date: Tue, 13 Mar 2007 15:31:13 +0100
Message-ID: <200703131531.14548.ak@suse.de>
References: <200703131448.15193.ak@suse.de> <200703131510.41651.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:41242 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030405AbXCMObY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 10:31:24 -0400
In-Reply-To: <200703131510.41651.dada1@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 13 March 2007 15:10, Eric Dumazet wrote:
> On Tuesday 13 March 2007 14:48, Andi Kleen wrote:
> > The ICMP rate limiting state can be shorts, we don't send that many ICMPs.
> > Changing flags to short and reorder fields to be sorted by size to avoid
> > holes. Move cold fields towards the end.
> >
> 
> Nope, you cannot break the reordering I've done one month ago.

Ok.  When you do such changes you should always add a comment, otherwise
it will be always destroyed with the next change.

But it seems highly fragile to me anyways because it depends on the exact
value of RTAX_MAX which tends to change regularly when someone invents
a new attribute. You should probably have moved next out of the dst entry.

Anyways here's a new patch with next still at the end and a comment.

-Andi

Shrink dst_entry a bit.

The ICMP rate limiting state can be shorts, we don't send that many ICMPs.
Changing flags to short and reorder fields to be sorted by size to avoid holes.
Move cold fields towards the end.

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux-2.6.21-rc3-net/include/net/dst.h
===================================================================
--- linux-2.6.21-rc3-net.orig/include/net/dst.h
+++ linux-2.6.21-rc3-net/include/net/dst.h
@@ -40,26 +40,24 @@ struct dst_entry
 	struct rcu_head		rcu_head;
 	struct dst_entry	*child;
 	struct net_device       *dev;
-	short			error;
-	short			obsolete;
-	int			flags;
+	unsigned long		expires;
+	short			flags;
 #define DST_HOST		1
 #define DST_NOXFRM		2
 #define DST_NOPOLICY		4
 #define DST_NOHASH		8
 #define DST_BALANCED            0x10
-	unsigned long		expires;
+	short			error;
+	short			obsolete;
 
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		nfheader_len;	/* more non-fragment space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
-	u32			metrics[RTAX_MAX];
-	struct dst_entry	*path;
-
-	unsigned long		rate_last;	/* rate limiting for ICMP */
-	unsigned long		rate_tokens;
+	unsigned short		rate_last;	/* rate limiting for ICMP */
+	unsigned short		rate_tokens;
 
+	struct dst_entry	*path;
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
 	struct xfrm_state	*xfrm;
@@ -67,21 +65,26 @@ struct dst_entry
 	int			(*input)(struct sk_buff*);
 	int			(*output)(struct sk_buff*);
 
-#ifdef CONFIG_NET_CLS_ROUTE
-	__u32			tclassid;
-#endif
-
 	struct  dst_ops	        *ops;
 		
 	unsigned long		lastuse;
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
+	u32			metrics[RTAX_MAX];
+
+#ifdef CONFIG_NET_CLS_ROUTE
+	__u32			tclassid;
+#endif
+
+	/* Should be at the end to be on the same cache line as 
+	   the flow information in rtable.  */
 	union {
 		struct dst_entry *next;
 		struct rtable    *rt_next;
 		struct rt6_info   *rt6_next;
 		struct dn_route  *dn_next;
 	};
+
 	char			info[0];
 };
 

