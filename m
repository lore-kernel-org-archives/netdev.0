From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: [PATCH][IPV6] keeping dst refcnt correctly with using xfrm
Date: Fri, 6 Jun 2003 14:49:25 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606144925.29ad2a9f.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I observed invalid refcnt incrementation when using IPsec in IPv6.
I configured IPsec and did ping6 then refcnt of dst
was incremented two by two. I observed it with using "route -A inet6".
I also check it with using printk.

This patch fixes dst reference count management.

In dst_pop refernce cound of dsts except for last are incremented in
dst_clone and decremented in next call dst_pop but last dst refernce
count will be never decremented.
All dst are held by xfrm_policy and there is no need to touch the
refernce count here.

In output functions, dst is changed by xfrm_lookup if there is 
any matching policy. Therefore original dst which is held before
calling xfrm_lookup will be never released.
When xfrm_lookup scceeds and dst is changed, original dst should
be release.

Patch-Name: fix dst refcnt with xfrm
Patch-Id: FIX_2_5_70+CS1_1259_DST_REFCNT_WITH_XFRM
Patch-Author: Kazunori Miyazawa / USAGI Project <miyazawa@linux-ipv6.org>
Credit: Kazunori Miyazawa / USAGI Project <miyazawa@linux-ipv6.org>

Index: linux25/include/net/dst.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/net/dst.h,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.22.1
diff -u -r1.1.1.9 -r1.1.1.9.22.1
--- linux25/include/net/dst.h	17 Apr 2003 18:15:56 -0000	1.1.1.9
+++ linux25/include/net/dst.h	6 Jun 2003 05:02:36 -0000	1.1.1.9.22.1
@@ -160,10 +160,7 @@
 
 static inline struct dst_entry *dst_pop(struct dst_entry *dst)
 {
-	struct dst_entry *child = dst_clone(dst->child);
-
-	dst_release(dst);
-	return child;
+	return dst->child;
 }
 
 extern void * dst_alloc(struct dst_ops * ops);
Index: linux25/net/ipv6/ip6_output.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ip6_output.c,v
retrieving revision 1.1.1.16
retrieving revision 1.1.1.16.14.1
diff -u -r1.1.1.16 -r1.1.1.16.14.1
--- linux25/net/ipv6/ip6_output.c	26 May 2003 08:04:10 -0000	1.1.1.16
+++ linux25/net/ipv6/ip6_output.c	6 Jun 2003 05:00:58 -0000	1.1.1.16.14.1
@@ -211,6 +211,8 @@
 	if ((err = xfrm_lookup(&skb->dst, fl, sk, 0)) < 0) {
 		return err;
 	}
+	if (dst != skb->dst)
+		dst_release(dst);
 
 	if (opt) {
 		int head_room;
@@ -595,10 +597,13 @@
 	pktlength = length;
 
         if (dst) {
+		struct dst_entry *dst0 = dst;
 		if ((err = xfrm_lookup(&dst, fl, sk, 0)) < 0) {
 			dst_release(dst);	
 			return -ENETUNREACH;
 		}
+		if (dst0 != dst)
+			dst_release(dst0);
         }
 
 	if (hlimit < 0) {
@@ -1194,10 +1199,13 @@
 	}
 
         if (*dst) {
+		struct dst_entry *dst0 = *dst;
 		if ((err = xfrm_lookup(dst, fl, sk, 0)) < 0) {
 			dst_release(*dst);	
 			return -ENETUNREACH;
 		}
+		if (*dst != dst0)
+			dst_release(dst0);
         }
 
 	return 0;
