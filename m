From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: fix dst leakage caused by rt6_cow()
Date: Mon, 18 Aug 2003 11:13:13 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308051642460.31172-100000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
Content-ID: <Pine.LNX.4.44.0308061039421.1401@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

since rt6_cow() calls dst_hold() it looks like we're leaking refcounts in
three places in route.c. The patch below should fix this.

--- linux-2.5.OLD/net/ipv6/route.c	2003-08-18 10:04:24.000000000 +0300
+++ linux-2.5/net/ipv6/route.c	2003-08-15 16:20:19.000000000 +0300
@@ -432,6 +432,7 @@
 		/* Race condition! In the gap, when rt6_lock was
 		   released someone could insert this route.  Relookup.
 		*/
+		dst_release(&rt->u.dst);
 		goto relookup;
 	}
 	dst_hold(&rt->u.dst);
@@ -486,6 +487,7 @@
 		/* Race condition! In the gap, when rt6_lock was
 		   released someone could insert this route.  Relookup.
 		*/
+		dst_release(&rt->u.dst);
 		goto relookup;
 	}
 	dst_hold(&rt->u.dst);
@@ -1094,8 +1096,8 @@
 			 */
 			dst_set_expires(&nrt->u.dst, ip6_rt_mtu_expires);
 			nrt->rt6i_flags |= RTF_DYNAMIC|RTF_EXPIRES;
-			dst_release(&nrt->u.dst);
 		}
+		dst_release(&nrt->u.dst);
 	} else {
 		nrt = ip6_rt_copy(rt);
 		if (nrt == NULL)

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
