From: "David S. Miller" <davem@redhat.com>
Subject: ipv6 UDP MSG_MORE oops fix
Date: Thu, 7 Aug 2003 22:34:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030807223421.70497d61.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Yoshfuji-san, I found the MSG_MORE udp bug.

If "np->pending" is true, we call ip_dst_store() with uninitialized
dst, it could be any kind of garbage.  This is dereferenced and we
crash.

If np->pending, we have some 'dst' stored into the socket already.
So no need to relookup dst or anything like that.

This is the fix I am using, on top of Miyazawa-san's ah6_input
and authentication error patches.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1167  -> 1.1168 
#	net/ipv6/ip6_output.c	1.40    -> 1.41   
#	      net/ipv6/raw.c	1.38    -> 1.39   
#	      net/ipv6/udp.c	1.45    -> 1.46   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/07	davem@nuts.ninka.net	1.1168
# [IPV6]: Make sure errors propagate properly in {udp,raw} sendmsg.
# --------------------------------------------
#
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	Thu Aug  7 22:34:06 2003
+++ b/net/ipv6/ip6_output.c	Thu Aug  7 22:34:06 2003
@@ -209,7 +209,6 @@
 	int seg_len = skb->len;
 	int hlimit;
 	u32 mtu;
-	int err = 0;
 
 	if (opt) {
 		int head_room;
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Thu Aug  7 22:34:06 2003
+++ b/net/ipv6/raw.c	Thu Aug  7 22:34:06 2003
@@ -659,7 +659,7 @@
 		fl.oif = np->mcast_oif;
 
 	dst = ip6_dst_lookup(sk, &fl);
-	if (dst->error)
+	if ((err = dst->error))
 		goto out;
 
 	if (hlimit < 0) {
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	Thu Aug  7 22:34:06 2003
+++ b/net/ipv6/udp.c	Thu Aug  7 22:34:06 2003
@@ -811,8 +811,10 @@
 		 * The socket lock must be held while it's corked.
 		 */
 		lock_sock(sk);
-		if (likely(up->pending))
+		if (likely(up->pending)) {
+			dst = NULL;
 			goto do_append_data;
+		}
 		release_sock(sk);
 	}
 	ulen += sizeof(struct udphdr);
@@ -929,7 +931,7 @@
 		fl.oif = np->mcast_oif;
 
 	dst = ip6_dst_lookup(sk, &fl);
-	if (dst->error)
+	if ((err = dst->error))
 		goto out;
 
 	if (hlimit < 0) {
@@ -968,9 +970,10 @@
 	else if (!corkreq)
 		err = udp_v6_push_pending_frames(sk, up);
 
-	ip6_dst_store(sk, dst,
-		      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
-		      &np->daddr : NULL);
+	if (dst)
+		ip6_dst_store(sk, dst,
+			      !ipv6_addr_cmp(&fl.fl6_dst, &np->daddr) ?
+			      &np->daddr : NULL);
 	if (err > 0)
 		err = np->recverr ? net_xmit_errno(err) : 0;
 	release_sock(sk);
