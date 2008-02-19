From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Tue, 19 Feb 2008 14:51:43 +0800
Message-ID: <1203403903.3248.29.camel@ymzhang>
References: <47B52B95.3070607@cosmosbay.com>
	 <1203057044.3027.134.camel@ymzhang> <47B59FFC.4030603@cosmosbay.com>
	 <20080215.152200.145584182.davem@davemloft.net>
	 <1203322358.3027.200.camel@ymzhang>
	 <20040.1203356033@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:11920 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753718AbYBSGyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 01:54:21 -0500
In-Reply-To: <20040.1203356033@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-18 at 12:33 -0500, Valdis.Kletnieks@vt.edu wrote: 
> On Mon, 18 Feb 2008 16:12:38 +0800, "Zhang, Yanmin" said:
> 
> > I also think __refcnt is the key. I did a new testing by adding 2 unsigned long
> > pading before lastuse, so the 3 members are moved to next cache line. The performance is
> > recovered.
> > 
> > How about below patch? Almost all performance is recovered with the new patch.
> > 
> > Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> 
> Could you add a comment someplace that says "refcnt wants to be on a different
> cache line from input/output/ops or performance tanks badly", to warn some
> future kernel hacker who starts adding new fields to the structure?
Ok. Below is the new patch.

1) Move tclassid under ops in case CONFIG_NET_CLS_ROUTE=y. So sizeof(dst_entry)=200
no matter if CONFIG_NET_CLS_ROUTE=y/n. I tested many patches on my 16-core tigerton by
moving tclassid to different place. It looks like tclassid could also have impact on
performance.
If moving tclassid before metrics, or just don't move tclassid, the performance isn't
good. So I move it behind metrics.

2) Add comments before __refcnt.

If CONFIG_NET_CLS_ROUTE=y, the result with below patch is about 18% better than
the one without the patch.

If CONFIG_NET_CLS_ROUTE=n, the result with below patch is about 30% better than
the one without the patch.

Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>

---

--- linux-2.6.25-rc1/include/net/dst.h	2008-02-21 14:33:43.000000000 +0800
+++ linux-2.6.25-rc1_work/include/net/dst.h	2008-02-22 12:52:19.000000000 +0800
@@ -52,15 +52,10 @@ struct dst_entry
 	unsigned short		header_len;	/* more space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
-	u32			metrics[RTAX_MAX];
-	struct dst_entry	*path;
-
-	unsigned long		rate_last;	/* rate limiting for ICMP */
 	unsigned int		rate_tokens;
+	unsigned long		rate_last;	/* rate limiting for ICMP */
 
-#ifdef CONFIG_NET_CLS_ROUTE
-	__u32			tclassid;
-#endif
+	struct dst_entry	*path;
 
 	struct neighbour	*neighbour;
 	struct hh_cache		*hh;
@@ -70,10 +65,20 @@ struct dst_entry
 	int			(*output)(struct sk_buff*);
 
 	struct  dst_ops	        *ops;
-		
-	unsigned long		lastuse;
+
+	u32			metrics[RTAX_MAX];
+
+#ifdef CONFIG_NET_CLS_ROUTE
+	__u32			tclassid;
+#endif
+
+	/*
+	 * __refcnt wants to be on a different cache line from
+	 * input/output/ops or performance tanks badly
+	 */
 	atomic_t		__refcnt;	/* client references	*/
 	int			__use;
+	unsigned long		lastuse;
 	union {
 		struct dst_entry *next;
 		struct rtable    *rt_next;


