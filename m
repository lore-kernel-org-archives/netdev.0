From: "David S. Miller" <davem@redhat.com>
Subject: Re: Missing routes cause BUG() in icmpv6_xmit_lock().
Date: Mon, 1 Sep 2003 01:30:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901013020.189fe564.davem@redhat.com>
References: <1062341789.2785.11.camel@imladris.demon.co.uk>
	<20030831224454.349a6a53.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dwmw2@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030831224454.349a6a53.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 31 Aug 2003 22:44:54 -0700
"David S. Miller" <davem@redhat.com> wrote:

> I'll see what I can do about this one.

Ok, here is the fix I'm going to use.  I actually inadvertantly
added this problem when I converted net/ipv6/icmp.c over to
per-cpu sockets.

There is nothing we could do with such ICMP destination unreachable
packets anyways, so dropping them is the right thing to do.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1614  -> 1.1615 
#	     net/ipv6/icmp.c	1.26    -> 1.27   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/01	davem@nuts.ninka.net	1.1615
# [IPV6]: Do not BUG() on icmp6 socket contention, just drop.
# --------------------------------------------
#
diff -Nru a/net/ipv6/icmp.c b/net/ipv6/icmp.c
--- a/net/ipv6/icmp.c	Mon Sep  1 01:36:39 2003
+++ b/net/ipv6/icmp.c	Mon Sep  1 01:36:39 2003
@@ -95,8 +95,15 @@
 static void icmpv6_xmit_lock(void)
 {
 	local_bh_disable();
-	if (unlikely(!spin_trylock(&icmpv6_socket->sk->lock.slock)))
-		BUG();
+	if (unlikely(!spin_trylock(&icmpv6_socket->sk->lock.slock))) {
+		/* This can happen if the output path (f.e. SIT or
+		 * ip6ip6 tunnel) signals dst_link_failure() for an
+		 * outgoing ICMP6 packet.
+		 */
+		local_bh_enable();
+		return 1;
+	}
+	return 0;
 }
 
 static void icmpv6_xmit_unlock(void)
@@ -340,7 +347,8 @@
 	fl.fl_icmp_type = type;
 	fl.fl_icmp_code = code;
 
-	icmpv6_xmit_lock();
+	if (icmpv6_xmit_lock())
+		return;
 
 	if (!icmpv6_xrlim_allow(sk, type, &fl))
 		goto out;
@@ -423,7 +431,8 @@
 	fl.oif = skb->dev->ifindex;
 	fl.fl_icmp_type = ICMPV6_ECHO_REPLY;
 
-	icmpv6_xmit_lock();
+	if (icmpv6_xmit_lock())
+		return;
 
 	if (!fl.oif && ipv6_addr_is_multicast(&fl.fl6_dst))
 		fl.oif = np->mcast_oif;
