From: James Morris <jmorris@namei.org>
Subject: [PATCH][RFC] Security marking
Date: Sun, 16 Apr 2006 01:10:50 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0604160012500.16600@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Chris Wright <chrisw@sous-sol.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.sea5.speakeasy.net ([69.17.117.7]:1759 "EHLO
	mail5.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751210AbWDPFLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 01:11:00 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail5.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 16 Apr 2006 05:10:51 -0000
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last year, I posted a set of patches to allow iptables matching against 
associated processes for incoming packets.  With this patch, I'm proposing 
a much simpler alternative and solictiting feedback on the idea from other 
networking developers.

For the original patches and discussion, see:
http://marc.theaimsgroup.com/?l=linux-netdev&m=113027175208707&w=2
and
http://people.redhat.com/jmorris/selinux/skfilter/

The purpose of the patches was to allow incoming owner matching to work 
cleanly, as well as allow integration of SELinux and Netfilter apps 
(iptables, conntrack etc).  This would also allow the existing SELinux 
networking hooks to be replaced in a more powerful and expressive way.

The skfilter patches posted are quite invasive, and probably require 
moving all Netfilter 'input' processing to the socket layer, with several 
unresolved issues.

Also, from an SELinux point of view, the skfilter patches mean handing all 
of the packet-based network policy to iptables, distinct from the existing 
SELinux policy language constructs and enforcement mechanisms.

At the SELinux developer summit, there was discussion of a different 
approach (sorry, not sure exactly who came up with it initially), where we 
instead use iptables to mark packets with security contexts, then allow 
the core SELinux code to act on those markings.

A nice side-effect of this approach is that it does not require any 
significant changes to the Netfilter code, as the markings are made at the 
network layer via Netfilter and then interpreted at the socket layer via 
the security module.

An initial idea was to make use of nfmark for this, however, it appears to 
be the wrong approach.  nfmark is used for and by the networking code, 
configured by the admin for e.g. routing, packet classification etc.  If 
we also use nfmark for SELinux, then once SELinux is enabled (the default 
case for two distributions), the admin will not be able to reliably use 
nfmark; and nfmark manipulations will also screw up SELinux MAC.  From a 
design point of view, security markings should be distinct from network 
markings: the former are used to implement security policy, the latter to 
implement networking policy (e.g. routing).

So, I propose to introduce a secmark field (per the patch below), which is 
only present when enabled as a sub-feature of LSM.  That is, it does not 
have any effect at all for the default kernel.  As an integer field, it 
also does not require the kind of lifecycle management assoicated with 
security blobs, which becomes invasive for skbs.


Example usage scenario for SELinux:

1) Mark all incoming packets to port 80 with a security context of
   "system_u:system_r:http_packet_t"

This would require implementing an iptables target, say SEL, which
validates the security context, obtains an integer representation 
(Security ID or SID), then marks the packet with it.

# iptables -A INPUT -p tcp -m tcp --dport 80 -j SEL --ctx \
        system_u:system_r:http_packet_t

2) During delivery of the packet to the receiving process, verify that the 
   security context of the associated socket is allowed to receive packets
   with that security context.

The SELinux core code would enforce this policy via 
selinux_socket_sock_rcv_skb(), using a new object class ('packet') and 
associated permissions ('recv', 'send').

# allow httpd_t http_packet_t:packet { recv }

>From an SELinux point of view, this critically allows security policy to 
be enforced within the AVC using a verifiable policy.  It also separates 
marking (labeling) from enforcement in a flexible way, allowing the 
expressiveness of Netfilter apps to be used during marking, as well as
allowing the enforcement code to be greatly simplified.

This scheme does not prevent a fully iptables-based approach (e.g. add a 
SELinux match and you can mark and control entirely via iptables), and 
still allows useful stuff like adding security context support to the LOG 
target.

Before moving ahead with any further of the above development, I'd 
appreciate feedback on whether the patch below looks acceptable from a 
networking point of view.  This is the entirety of the changes required in 
the core networking (not counting the SEL target).


Thanks,

---

 include/linux/skbuff.h          |   22 ++++++++++++++++++++++
 net/core/skbuff.c               |    3 ++-
 net/ipv4/ip_output.c            |    1 +
 net/ipv4/netfilter/ipt_REJECT.c |    1 +
 net/ipv6/ip6_output.c           |    1 +
 security/Kconfig                |    8 ++++++++
 security/selinux/Kconfig        |    2 +-
 7 files changed, 36 insertions(+), 2 deletions(-)

diff -purN -X dontdiff linux-2.6.17-rc1.o/include/linux/skbuff.h linux-2.6.17-rc1.w/include/linux/skbuff.h
--- linux-2.6.17-rc1.o/include/linux/skbuff.h	2006-04-15 19:57:58.000000000 -0400
+++ linux-2.6.17-rc1.w/include/linux/skbuff.h	2006-04-15 23:36:07.000000000 -0400
@@ -209,6 +209,7 @@ enum {
  *	@nf_bridge: Saved data about a bridged frame - see br_netfilter.c
  *	@tc_index: Traffic control index
  *	@tc_verd: traffic control verdict
+ *	@secmark: security marking
  */
 
 struct sk_buff {
@@ -285,6 +286,9 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
+#ifdef CONFIG_SECURITY_NETWORK_MARK
+	__u32			secmark;
+#endif
 
 
 	/* These elements must be at the end, see alloc_skb() for details.  */
@@ -1389,5 +1393,23 @@ static inline void nf_reset(struct sk_bu
 static inline void nf_reset(struct sk_buff *skb) {}
 #endif /* CONFIG_NETFILTER */
 
+#ifdef CONFIG_SECURITY_NETWORK_MARK
+static inline void skb_copy_secmark(struct sk_buff *to, struct sk_buff *from)
+{
+	to->secmark = from->secmark;
+}
+
+static inline void skb_init_secmark(struct sk_buff *skb)
+{
+	skb->secmark = 0;
+}
+#else
+static inline void skb_copy_secmark(struct sk_buff *to, struct sk_buff *from)
+{ }
+
+static inline void skb_init_secmark(struct sk_buff *skb)
+{ }
+#endif
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff -purN -X dontdiff linux-2.6.17-rc1.o/net/core/skbuff.c linux-2.6.17-rc1.w/net/core/skbuff.c
--- linux-2.6.17-rc1.o/net/core/skbuff.c	2006-04-15 19:57:58.000000000 -0400
+++ linux-2.6.17-rc1.w/net/core/skbuff.c	2006-04-15 23:40:32.000000000 -0400
@@ -456,7 +456,7 @@ struct sk_buff *skb_clone(struct sk_buff
 	n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
 	C(input_dev);
 #endif
-
+	skb_copy_secmark(n, skb);
 #endif
 	C(truesize);
 	atomic_set(&n->users, 1);
@@ -518,6 +518,7 @@ static void copy_skb_header(struct sk_bu
 #endif
 	new->tc_index	= old->tc_index;
 #endif
+	skb_copy_secmark(new, old);
 	atomic_set(&new->users, 1);
 	skb_shinfo(new)->tso_size = skb_shinfo(old)->tso_size;
 	skb_shinfo(new)->tso_segs = skb_shinfo(old)->tso_segs;
diff -purN -X dontdiff linux-2.6.17-rc1.o/net/ipv4/ip_output.c linux-2.6.17-rc1.w/net/ipv4/ip_output.c
--- linux-2.6.17-rc1.o/net/ipv4/ip_output.c	2006-04-15 19:57:58.000000000 -0400
+++ linux-2.6.17-rc1.w/net/ipv4/ip_output.c	2006-04-15 23:34:14.000000000 -0400
@@ -412,6 +412,7 @@ static void ip_copy_metadata(struct sk_b
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 /*
diff -purN -X dontdiff linux-2.6.17-rc1.o/net/ipv4/netfilter/ipt_REJECT.c linux-2.6.17-rc1.w/net/ipv4/netfilter/ipt_REJECT.c
--- linux-2.6.17-rc1.o/net/ipv4/netfilter/ipt_REJECT.c	2006-04-15 19:57:58.000000000 -0400
+++ linux-2.6.17-rc1.w/net/ipv4/netfilter/ipt_REJECT.c	2006-04-15 23:35:20.000000000 -0400
@@ -154,6 +154,7 @@ static void send_reset(struct sk_buff *o
 	/* This packet will not be the same as the other: clear nf fields */
 	nf_reset(nskb);
 	nskb->nfmark = 0;
+	skb_init_secmark(nskb);
 
 	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
 
diff -purN -X dontdiff linux-2.6.17-rc1.o/net/ipv6/ip6_output.c linux-2.6.17-rc1.w/net/ipv6/ip6_output.c
--- linux-2.6.17-rc1.o/net/ipv6/ip6_output.c	2006-04-15 19:57:58.000000000 -0400
+++ linux-2.6.17-rc1.w/net/ipv6/ip6_output.c	2006-04-15 23:33:49.000000000 -0400
@@ -458,6 +458,7 @@ static void ip6_copy_metadata(struct sk_
 	nf_bridge_get(to->nf_bridge);
 #endif
 #endif
+	skb_copy_secmark(to, from);
 }
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
diff -purN -X dontdiff linux-2.6.17-rc1.o/security/Kconfig linux-2.6.17-rc1.w/security/Kconfig
--- linux-2.6.17-rc1.o/security/Kconfig	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc1.w/security/Kconfig	2006-04-15 23:11:56.000000000 -0400
@@ -67,6 +67,14 @@ config SECURITY_NETWORK_XFRM
 	  IPSec.
 	  If you are unsure how to answer this question, answer N.
 
+config SECURITY_NETWORK_MARK
+	bool "Security Marking"
+	depends on SECURITY_NETWORK
+	help
+	  This enables security marking of network packets, similar
+	  to nfmark, but designated for security purposes.
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY_CAPABILITIES
 	tristate "Default Linux Capabilities"
 	depends on SECURITY
diff -purN -X dontdiff linux-2.6.17-rc1.o/security/selinux/Kconfig linux-2.6.17-rc1.w/security/selinux/Kconfig
--- linux-2.6.17-rc1.o/security/selinux/Kconfig	2006-03-20 00:53:29.000000000 -0500
+++ linux-2.6.17-rc1.w/security/selinux/Kconfig	2006-04-15 23:19:11.000000000 -0400
@@ -1,6 +1,6 @@
 config SECURITY_SELINUX
 	bool "NSA SELinux Support"
-	depends on SECURITY_NETWORK && AUDIT && NET && INET
+	depends on AUDIT && NET && INET && SECURITY_NETWORK_MARK
 	default n
 	help
 	  This selects NSA Security-Enhanced Linux (SELinux).
