From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 03:36:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818033608.35c86539.davem@redhat.com>
References: <200308172329.DAA14889@dub.inr.ac.ru>
	<Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
	<20030818024837.6815f0c2.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru, kazunori@miyazawa.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818024837.6815f0c2.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 02:48:37 -0700
"David S. Miller" <davem@redhat.com> wrote:

> While verifying this patch, I discovered some new dst leaks.

This patch fixes them up.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1209  -> 1.1210 
#	net/ipv6/ip6_output.c	1.42    -> 1.43   
#	     net/ipv6/icmp.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/18	davem@nuts.ninka.net	1.1210
# [IPV6]: Fix some dst cache leaks.
# 1) icmpv6_send() and icmpv6_echo_reply() never release dst.
# 2) ip6_{push,flush}_pending_frames() leak np->cork.rt.
# --------------------------------------------
#
diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	Mon Aug 18 03:39:55 2003
+++ b/net/ipv6/icmp.c	Mon Aug 18 03:39:55 2003
@@ -356,7 +356,8 @@
 		fl.oif = np->mcast_oif;
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
-	if (err) goto out;
+	if (err)
+		goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -375,7 +376,7 @@
 		if (net_ratelimit())
 			printk(KERN_DEBUG "icmp: len problem\n");
 		__skb_push(skb, plen);
-		goto out;
+		goto out_dst_release;
 	}
 
 	idev = in6_dev_get(skb->dev);
@@ -396,6 +397,8 @@
 out_put:
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
+out_dst_release:
+	dst_release(dst);
 out:
 	icmpv6_xmit_unlock();
 }
@@ -435,8 +438,8 @@
 		fl.oif = np->mcast_oif;
 
 	err = ip6_dst_lookup(sk, &dst, &fl);
-
-	if (err) goto out;
+	if (err)
+		goto out;
 
 	if (hlimit < 0) {
 		if (ipv6_addr_is_multicast(&fl.fl6_dst))
@@ -465,6 +468,7 @@
 out_put: 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
+	dst_release(dst);
 out: 
 	icmpv6_xmit_unlock();
 }
diff -Nru a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c	Mon Aug 18 03:39:55 2003
+++ b/net/ipv6/ip6_output.c	Mon Aug 18 03:39:55 2003
@@ -1484,6 +1484,7 @@
 		np->cork.opt = NULL;
 	}
 	if (np->cork.rt) {
+		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
 	if (np->cork.fl) {
@@ -1510,6 +1511,7 @@
 		np->cork.opt = NULL;
 	}
 	if (np->cork.rt) {
+		dst_release(&np->cork.rt->u.dst);
 		np->cork.rt = NULL;
 	}
 	if (np->cork.fl) {
