From: Julian Anastasov <ja@ssi.bg>
Subject: [2.4/2.6 PATCHES] Change some ip_fragment checks to help IPVS
Date: Sat, 11 Oct 2003 20:18:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310111956070.31823-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wensong Zhang <wensong@linux-vs.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	The included changes help IPVS to correctly forward
fragmented packets. The first problem is that IPVS relies on
skb->nfcache to contain valid information in all hooks but
ip_fragment does not copy this field, both in 2.4 and 2.6.
I just realize that this is the cause for the problem one
IPVS user reported for 2.4.

	The second problem is that 2.6 does not allow IPVS to
transmit fragmented skbs, they are reassembled just because one of
the frags has no owner. Now we add check to avoid the
reassembling if the first skb is not owned and by this way we
have reason to be happy with all recent non-linear handling
changes.

	First is the nfcache patch for 2.4, followed by 2 csets
for 2.6:

--- linux/net/ipv4/ip_output.c.orig	Mon Aug 25 22:06:13 2003
+++ linux/net/ipv4/ip_output.c	Sat Oct 11 19:54:34 2003
@@ -879,6 +879,7 @@
 #endif
 #ifdef CONFIG_NETFILTER
 		skb2->nfmark = skb->nfmark;
+		skb2->nfcache = skb->nfcache;
 		/* Connection association is same as pre-frag packet */
 		skb2->nfct = skb->nfct;
 		nf_conntrack_get(skb2->nfct);



===

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1502  -> 1.1503 
#	net/ipv4/ip_output.c	1.45    -> 1.46   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/11	ja@ssi.bg	1.1503
# [IPV4]: ip_copy_metadata must copy the nfcache field
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Sat Oct 11 19:35:15 2003
+++ b/net/ipv4/ip_output.c	Sat Oct 11 19:35:15 2003
@@ -412,6 +412,7 @@
 #endif
 #ifdef CONFIG_NETFILTER
 	to->nfmark = from->nfmark;
+	to->nfcache = from->nfcache;
 	/* Connection association is same as pre-frag packet */
 	to->nfct = from->nfct;
 	nf_conntrack_get(to->nfct);



===


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1503  -> 1.1504 
#	net/ipv4/ip_output.c	1.46    -> 1.47   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/11	ja@ssi.bg	1.1504
# [IPV4]: ip_fragment should not reassemble if all frags do not have owner
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c	Sat Oct 11 19:49:38 2003
+++ b/net/ipv4/ip_output.c	Sat Oct 11 19:49:38 2003
@@ -493,7 +493,7 @@
 			    goto slow_path;
 
 			/* Correct socket ownership. */
-			if (frag->sk == NULL)
+			if (frag->sk == NULL && skb->sk)
 				goto slow_path;
 
 			/* Partially cloned skb? */

===

Regards

--
Julian Anastasov <ja@ssi.bg>
