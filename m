From: James Morris <jmorris@redhat.com>
Subject: Re: [PATCH] Fix checksum bug for multicast/broadcast packets on
 postrouting hook
Date: Mon, 23 Feb 2004 17:19:03 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402231713310.21153-100000@thoron.boston.redhat.com>
References: <20040218172441.2eb117a7.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mika.penttila@kolumbus.fi, Harald Welte <laforge@netfilter.org>,
        <netdev@oss.sgi.com>, Stephen Smalley <sds@epoch.ncsc.mil>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040218172441.2eb117a7.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Feb 2004, David S. Miller wrote:

> Let us look at some of the other users of skb_checksum_help().  The one in dev_queue_xmit()
> and the IPSEC encapsulator xfrm drivers are doing so just to plug up a short lived race where
> a route lookup points to a non-IPSEC checksumming hardware path, but we end up in the IPSEC
> path or to a device which does not support hw checksumming.
> 
> One could argue that what we could do in this case is just drop the packet and let the route
> relookup on retransmit get things right.

This does not seem to be the correct approach.  If you drop packets in 
the ipsec cases at least, the retransmits just keep feeding packets back 
in with hardware checksumming set.

I've included the entire patch so far below (which pushes the checksum
handling further up into Netfilter) for reference.

No data will flow on e.g. an AH connection with this patch.

 include/linux/netdevice.h                      |    1 
 include/linux/netfilter.h                      |    2 +
 include/linux/netfilter_ipv4.h                 |   11 ++++++++
 include/linux/netfilter_ipv4/ip_nat_helper.h   |    3 +-
 include/linux/netfilter_ipv4/ip_nat_protocol.h |    2 -
 include/linux/skbuff.h                         |    6 ++++
 net/core/dev.c                                 |   33 +++----------------------
 net/core/netfilter.c                           |   30 ++++++++++++++++------
 net/ipv4/ah4.c                                 |    4 +--
 net/ipv4/esp4.c                                |    6 ++--
 net/ipv4/ipcomp.c                              |    4 +--
 net/ipv4/netfilter/ip_fw_compat_redir.c        |    5 +++
 net/ipv4/netfilter/ip_nat_core.c               |   12 ++++-----
 net/ipv4/netfilter/ip_nat_helper.c             |   13 ++++++++-
 net/ipv4/netfilter/ip_nat_proto_icmp.c         |    3 +-
 net/ipv4/netfilter/ip_nat_proto_tcp.c          |    3 +-
 net/ipv4/netfilter/ip_nat_proto_udp.c          |    6 +++-
 net/ipv4/netfilter/ip_nat_proto_unknown.c      |    4 +--
 net/ipv4/netfilter/ip_nat_snmp_basic.c         |    5 +++
 net/ipv4/netfilter/ipt_ECN.c                   |   10 ++++++-
 net/ipv4/netfilter/ipt_REJECT.c                |    2 +
 net/ipv4/netfilter/ipt_TCPMSS.c                |    1 
 net/ipv6/ah6.c                                 |    4 +--
 net/ipv6/esp6.c                                |    6 ++--
 net/ipv6/ipcomp6.c                             |    4 +--
 25 files changed, 109 insertions(+), 71 deletions(-)


- James
-- 
James Morris
<jmorris@redhat.com>

diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/netdevice.h linux-2.6.3-mm3.w/include/linux/netdevice.h
--- linux-2.6.3-mm3.o/include/linux/netdevice.h	2004-02-23 10:52:58.000000000 -0500
+++ linux-2.6.3-mm3.w/include/linux/netdevice.h	2004-02-23 15:09:42.000000000 -0500
@@ -929,7 +929,6 @@
 extern unsigned long	netdev_fc_xoff;
 extern atomic_t netdev_dropping;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
-extern struct sk_buff * skb_checksum_help(struct sk_buff *skb);
 #ifdef CONFIG_NET_FASTROUTE
 extern int		netdev_fastroute;
 extern int		netdev_fastroute_obstacles;
diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/netfilter.h linux-2.6.3-mm3.w/include/linux/netfilter.h
--- linux-2.6.3-mm3.o/include/linux/netfilter.h	2003-09-27 20:50:20.000000000 -0400
+++ linux-2.6.3-mm3.w/include/linux/netfilter.h	2004-02-23 15:09:42.000000000 -0500
@@ -159,6 +159,8 @@
 extern void nf_dump_skb(int pf, struct sk_buff *skb);
 #endif
 
+struct sk_buff *nf_skb_checksum_help(struct sk_buff *skb);
+
 /* FIXME: Before cache is ever used, this must be implemented for real. */
 extern void nf_invalidate_cache(int pf);
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/netfilter_ipv4/ip_nat_helper.h linux-2.6.3-mm3.w/include/linux/netfilter_ipv4/ip_nat_helper.h
--- linux-2.6.3-mm3.o/include/linux/netfilter_ipv4/ip_nat_helper.h	2003-09-27 20:50:14.000000000 -0400
+++ linux-2.6.3-mm3.w/include/linux/netfilter_ipv4/ip_nat_helper.h	2004-02-23 15:35:13.000000000 -0500
@@ -60,5 +60,6 @@
 				unsigned int rep_len);
 extern int ip_nat_seq_adjust(struct sk_buff **pskb, 
 			     struct ip_conntrack *ct, 
-			     enum ip_conntrack_info ctinfo);
+			     enum ip_conntrack_info ctinfo,
+			     int hooknum);
 #endif
diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/netfilter_ipv4/ip_nat_protocol.h linux-2.6.3-mm3.w/include/linux/netfilter_ipv4/ip_nat_protocol.h
--- linux-2.6.3-mm3.o/include/linux/netfilter_ipv4/ip_nat_protocol.h	2003-09-27 20:50:26.000000000 -0400
+++ linux-2.6.3-mm3.w/include/linux/netfilter_ipv4/ip_nat_protocol.h	2004-02-23 15:09:42.000000000 -0500
@@ -22,7 +22,7 @@
 	int (*manip_pkt)(struct sk_buff **pskb,
 			 unsigned int hdroff,
 			 const struct ip_conntrack_manip *manip,
-			 enum ip_nat_manip_type maniptype);
+			 enum ip_nat_manip_type maniptype, int hooknum);
 
 	/* Is the manipable part of the tuple between min and max incl? */
 	int (*in_range)(const struct ip_conntrack_tuple *tuple,
diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/netfilter_ipv4.h linux-2.6.3-mm3.w/include/linux/netfilter_ipv4.h
--- linux-2.6.3-mm3.o/include/linux/netfilter_ipv4.h	2004-01-09 09:41:35.000000000 -0500
+++ linux-2.6.3-mm3.w/include/linux/netfilter_ipv4.h	2004-02-23 15:09:42.000000000 -0500
@@ -83,6 +83,17 @@
    Returns true or false. */
 extern int skb_ip_make_writable(struct sk_buff **pskb,
 				unsigned int writable_len);
+
+static inline void nf_ip_skb_checksum_help(struct sk_buff *skb, int hooknum)
+{
+	if (skb->ip_summed == CHECKSUM_HW) {
+		if (hooknum == NF_IP_PRE_ROUTING || hooknum == NF_IP_LOCAL_IN)
+			skb->ip_summed = CHECKSUM_NONE;
+		else
+			nf_skb_checksum_help(skb);
+	}
+}
+
 #endif /*__KERNEL__*/
 
 #endif /*__LINUX_IP_NETFILTER_H*/
diff -urN -X dontdiff linux-2.6.3-mm3.o/include/linux/skbuff.h linux-2.6.3-mm3.w/include/linux/skbuff.h
--- linux-2.6.3-mm3.o/include/linux/skbuff.h	2004-02-23 10:52:59.000000000 -0500
+++ linux-2.6.3-mm3.w/include/linux/skbuff.h	2004-02-23 16:35:28.233857264 -0500
@@ -1220,5 +1220,11 @@
 
 #endif
 
+static inline void skb_invalidate_hw_checksum(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_HW)
+		skb->ip_summed = CHECKSUM_NONE;
+}
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/core/dev.c linux-2.6.3-mm3.w/net/core/dev.c
--- linux-2.6.3-mm3.o/net/core/dev.c	2004-02-23 10:52:59.000000000 -0500
+++ linux-2.6.3-mm3.w/net/core/dev.c	2004-02-23 15:09:42.000000000 -0500
@@ -99,7 +99,6 @@
 #include <linux/divert.h>
 #include <net/dst.h>
 #include <net/pkt_sched.h>
-#include <net/checksum.h>
 #include <linux/highmem.h>
 #include <linux/init.h>
 #include <linux/kmod.h>
@@ -1196,30 +1195,6 @@
 	rcu_read_unlock();
 }
 
-/* Calculate csum in the case, when packet is misrouted.
- * If it failed by some reason, ignore and send skb with wrong
- * checksum.
- */
-struct sk_buff *skb_checksum_help(struct sk_buff *skb)
-{
-	unsigned int csum;
-	int offset = skb->h.raw - skb->data;
-
-	if (offset > (int)skb->len)
-		BUG();
-	csum = skb_checksum(skb, offset, skb->len-offset, 0);
-
-	offset = skb->tail - skb->h.raw;
-	if (offset <= 0)
-		BUG();
-	if (skb->csum + 2 > offset)
-		BUG();
-
-	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
-	skb->ip_summed = CHECKSUM_NONE;
-	return skb;
-}
-
 #ifdef CONFIG_HIGHMEM
 /* Actually, we should eliminate this check as soon as we know, that:
  * 1. IOMMU is present and allows to map all the memory.
@@ -1337,14 +1312,15 @@
 		goto out_kfree_skb;
 
 	/* If packet is not checksummed and device does not support
-	 * checksumming for this protocol, complete checksumming here.
+	 * checksumming for this protocol.  Let route lookup on retransmit
+	 * fix things.
 	 */
 	if (skb->ip_summed == CHECKSUM_HW &&
 	    (!(dev->features & (NETIF_F_HW_CSUM | NETIF_F_NO_CSUM)) &&
 	     (!(dev->features & NETIF_F_IP_CSUM) ||
 	      skb->protocol != htons(ETH_P_IP)))) {
-		if ((skb = skb_checksum_help(skb)) == NULL)
-			goto out;
+	      	rc = -EAGAIN;
+	      	goto out_kfree_skb;
 	}
 
 	/* Grab device queue */
@@ -3321,7 +3297,6 @@
 EXPORT_SYMBOL(register_gifconf);
 EXPORT_SYMBOL(register_netdevice);
 EXPORT_SYMBOL(register_netdevice_notifier);
-EXPORT_SYMBOL(skb_checksum_help);
 EXPORT_SYMBOL(synchronize_net);
 EXPORT_SYMBOL(unregister_netdevice);
 EXPORT_SYMBOL(unregister_netdevice_notifier);
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/core/netfilter.c linux-2.6.3-mm3.w/net/core/netfilter.c
--- linux-2.6.3-mm3.o/net/core/netfilter.c	2003-10-15 08:53:19.000000000 -0400
+++ linux-2.6.3-mm3.w/net/core/netfilter.c	2004-02-23 16:27:39.580103464 -0500
@@ -26,6 +26,7 @@
 #include <net/sock.h>
 #include <net/route.h>
 #include <linux/ip.h>
+#include <net/checksum.h>
 
 #define __KERNEL_SYSCALLS__
 #include <linux/unistd.h>
@@ -505,14 +506,6 @@
 	unsigned int verdict;
 	int ret = 0;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
-		if (outdev == NULL) {
-			skb->ip_summed = CHECKSUM_NONE;
-		} else {
-			skb_checksum_help(skb);
-		}
-	}
-
 	/* We may already have this, but read-locks nest anyway */
 	rcu_read_lock();
 
@@ -743,6 +736,26 @@
 EXPORT_SYMBOL(skb_ip_make_writable);
 #endif /*CONFIG_INET*/
 
+struct sk_buff *nf_skb_checksum_help(struct sk_buff *skb)
+{
+	unsigned int csum;
+	int offset = skb->h.raw - skb->data;
+
+	if (offset > (int)skb->len)
+		BUG();
+	csum = skb_checksum(skb, offset, skb->len-offset, 0);
+
+	offset = skb->tail - skb->h.raw;
+	if (offset <= 0)
+		BUG();
+	if (skb->csum + 2 > offset)
+		BUG();
+
+	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
+	skb->ip_summed = CHECKSUM_NONE;
+	return skb;
+}
+
 
 /* This does not belong here, but ipt_REJECT needs it if connection
    tracking in use: without this, connection may not be in hash table,
@@ -773,3 +786,4 @@
 EXPORT_SYMBOL(nf_unregister_hook);
 EXPORT_SYMBOL(nf_unregister_queue_handler);
 EXPORT_SYMBOL(nf_unregister_sockopt);
+EXPORT_SYMBOL(nf_skb_checksum_help);
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/ah4.c linux-2.6.3-mm3.w/net/ipv4/ah4.c
--- linux-2.6.3-mm3.o/net/ipv4/ah4.c	2004-02-04 08:39:07.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/ah4.c	2004-02-23 15:09:42.000000000 -0500
@@ -67,8 +67,8 @@
 		char 		buf[60];
 	} tmp_iph;
 
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/esp4.c linux-2.6.3-mm3.w/net/ipv4/esp4.c
--- linux-2.6.3-mm3.o/net/ipv4/esp4.c	2003-09-27 20:50:29.000000000 -0400
+++ linux-2.6.3-mm3.w/net/ipv4/esp4.c	2004-02-23 15:09:42.000000000 -0500
@@ -41,9 +41,9 @@
 		char 		buf[60];
 	} tmp_iph;
 
-	/* First, if the skb is not checksummed, complete checksum. */
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	/* First, if the skb is not checksummed, allow retrans to fix . */
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/ipcomp.c linux-2.6.3-mm3.w/net/ipv4/ipcomp.c
--- linux-2.6.3-mm3.o/net/ipv4/ipcomp.c	2004-02-04 08:39:07.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/ipcomp.c	2004-02-23 15:09:42.000000000 -0500
@@ -157,8 +157,8 @@
 	} tmp_iph;
 	int hdr_len = 0;
 
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_fw_compat_redir.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_fw_compat_redir.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_fw_compat_redir.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_fw_compat_redir.c	2004-02-23 16:33:19.715395040 -0500
@@ -109,6 +109,7 @@
 	struct tcphdr *tcph = (struct tcphdr *)((u_int32_t *)iph
 						+ iph->ihl);
 
+	skb_invalidate_hw_checksum(skb);
 	tcph->check = cheat_check(~redir->core.orig_dstip,
 				  redir->core.new_dstip,
 				  cheat_check(redir->core.orig_dport ^ 0xFFFF,
@@ -197,11 +198,13 @@
 		if (skb->len < iph->ihl*4 + sizeof(*udph))
 			return NF_DROP;
 
-		if (udph->check) /* 0 is a special case meaning no checksum */
+		if (udph->check) /* 0 is a special case meaning no checksum */ {
+			skb_invalidate_hw_checksum(skb);
 			udph->check = cheat_check(~iph->daddr, newdst,
 					  cheat_check(udph->dest ^ 0xFFFF,
 						      redirpt,
 						      udph->check));
+		}
 		iph->check = cheat_check(~iph->daddr, newdst, iph->check);
 		udph->dest = redirpt;
 		iph->daddr = newdst;
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_core.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_core.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_core.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_core.c	2004-02-23 15:34:41.000000000 -0500
@@ -721,7 +721,7 @@
 	  struct sk_buff **pskb,
 	  unsigned int iphdroff,
 	  const struct ip_conntrack_manip *manip,
-	  enum ip_nat_manip_type maniptype)
+	  enum ip_nat_manip_type maniptype, int hooknum)
 {
 	struct iphdr *iph;
 
@@ -734,7 +734,7 @@
 	/* Manipulate protcol part. */
 	if (!find_nat_proto(proto)->manip_pkt(pskb,
 					      iphdroff + iph->ihl*4,
-					      manip, maniptype))
+					      manip, maniptype, hooknum))
 		return 0;
 
 	iph = (void *)(*pskb)->data + iphdroff;
@@ -793,7 +793,7 @@
 			       htons(info->manips[i].manip.u.all));
 			if (!manip_pkt(proto, pskb, 0,
 				       &info->manips[i].manip,
-				       info->manips[i].maniptype)) {
+				       info->manips[i].maniptype, hooknum)) {
 				READ_UNLOCK(&ip_nat_lock);
 				return NF_DROP;
 			}
@@ -858,7 +858,7 @@
 			DEBUGP("ip_nat_core: adjusting sequence number\n");
 			/* future: put this in a l4-proto specific function,
 			 * and call this function here. */
-			if (!ip_nat_seq_adjust(pskb, ct, ctinfo))
+			if (!ip_nat_seq_adjust(pskb, ct, ctinfo, hooknum))
 				ret = NF_DROP;
 		}
 
@@ -952,7 +952,7 @@
 				       (*pskb)->nh.iph->ihl*4
 				       + sizeof(inside->icmp),
 				       &info->manips[i].manip,
-				       !info->manips[i].maniptype))
+				       !info->manips[i].maniptype, hooknum))
 				goto unlock_fail;
 
 			/* Outer packet needs to have IP header NATed like
@@ -966,7 +966,7 @@
 			       NIPQUAD(info->manips[i].manip.ip));
 			if (!manip_pkt(0, pskb, 0,
 				       &info->manips[i].manip,
-				       info->manips[i].maniptype))
+				       info->manips[i].maniptype, hooknum))
 				goto unlock_fail;
 		}
 	}
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_helper.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_helper.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_helper.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_helper.c	2004-02-23 16:32:06.392541808 -0500
@@ -187,6 +187,7 @@
 	mangle_contents(*pskb, iph->ihl*4 + tcph->doff*4,
 			match_offset, match_len, rep_buffer, rep_len);
 
+	skb_invalidate_hw_checksum(*pskb);
 	datalen = (*pskb)->len - iph->ihl*4;
 	tcph->check = 0;
 	tcph->check = tcp_v4_check(tcph, datalen, iph->saddr, iph->daddr,
@@ -245,6 +246,8 @@
 	/* fix udp checksum if udp checksum was previously calculated */
 	if (udph->check) {
 		int datalen = (*pskb)->len - iph->ihl * 4;
+		
+		skb_invalidate_hw_checksum(*pskb);
 		udph->check = 0;
 		udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
 		                                datalen, IPPROTO_UDP,
@@ -255,7 +258,11 @@
 	return 1;
 }
 
-/* Adjust one found SACK option including checksum correction */
+/* Adjust one found SACK option including checksum correction.
+ *
+ * NOTE: if this is called by a path other than ip_nat_seq_adjust(), it wil
+ * need to be updated to take hardware checksumming into account
+ */
 static void
 sack_adjust(struct sk_buff *skb,
 	    struct tcphdr *tcph, 
@@ -350,7 +357,8 @@
 int
 ip_nat_seq_adjust(struct sk_buff **pskb, 
 		  struct ip_conntrack *ct, 
-		  enum ip_conntrack_info ctinfo)
+		  enum ip_conntrack_info ctinfo,
+		  int hooknum)
 {
 	struct tcphdr *tcph;
 	int dir, newseq, newack;
@@ -383,6 +391,7 @@
 		newack = ntohl(tcph->ack_seq) - other_way->offset_before;
 	newack = htonl(newack);
 
+	nf_ip_skb_checksum_help(*pskb, hooknum);
 	tcph->check = ip_nat_cheat_check(~tcph->seq, newseq,
 					 ip_nat_cheat_check(~tcph->ack_seq, 
 					 		    newack, 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_icmp.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_icmp.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_icmp.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_icmp.c	2004-02-23 16:21:11.785057272 -0500
@@ -55,7 +55,7 @@
 icmp_manip_pkt(struct sk_buff **pskb,
 	       unsigned int hdroff,
 	       const struct ip_conntrack_manip *manip,
-	       enum ip_nat_manip_type maniptype)
+	       enum ip_nat_manip_type maniptype, int hooknum)
 {
 	struct icmphdr *hdr;
 
@@ -64,6 +64,7 @@
 
 	hdr = (void *)(*pskb)->data + hdroff;
 
+	nf_ip_skb_checksum_help(*pskb, hooknum);
 	hdr->checksum = ip_nat_cheat_check(hdr->un.echo.id ^ 0xFFFF,
 					    manip->u.icmp.id,
 					    hdr->checksum);
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_tcp.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_tcp.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_tcp.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_tcp.c	2004-02-23 16:21:06.464866064 -0500
@@ -86,7 +86,7 @@
 tcp_manip_pkt(struct sk_buff **pskb,
 	      unsigned int hdroff,
 	      const struct ip_conntrack_manip *manip,
-	      enum ip_nat_manip_type maniptype)
+	      enum ip_nat_manip_type maniptype, int hooknum)
 {
 	struct tcphdr *hdr;
 	u_int32_t oldip;
@@ -120,6 +120,7 @@
 	if (hdrsize < sizeof(*hdr))
 		return 1;
 
+	nf_ip_skb_checksum_help(*pskb, hooknum);
 	hdr->check = ip_nat_cheat_check(~oldip, manip->ip,
 					ip_nat_cheat_check(oldport ^ 0xFFFF,
 							   manip->u.tcp.port,
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_udp.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_udp.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_udp.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_udp.c	2004-02-23 16:21:00.952704040 -0500
@@ -85,7 +85,7 @@
 udp_manip_pkt(struct sk_buff **pskb,
 	      unsigned int hdroff,
 	      const struct ip_conntrack_manip *manip,
-	      enum ip_nat_manip_type maniptype)
+	      enum ip_nat_manip_type maniptype, int hooknum)
 {
 	struct udphdr *hdr;
 	u_int32_t oldip;
@@ -104,11 +104,13 @@
 		oldip = (*pskb)->nh.iph->daddr;
 		portptr = &hdr->dest;
 	}
-	if (hdr->check) /* 0 is a special case meaning no checksum */
+	if (hdr->check) /* 0 is a special case meaning no checksum */ {
+		nf_ip_skb_checksum_help(*pskb, hooknum);
 		hdr->check = ip_nat_cheat_check(~oldip, manip->ip,
 					ip_nat_cheat_check(*portptr ^ 0xFFFF,
 							   manip->u.udp.port,
 							   hdr->check));
+	}
 	*portptr = manip->u.udp.port;
 	return 1;
 }
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_unknown.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_unknown.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_proto_unknown.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_proto_unknown.c	2004-02-23 16:41:13.425380176 -0500
@@ -41,7 +41,7 @@
 unknown_manip_pkt(struct sk_buff **pskb,
 		  unsigned int hdroff,
 		  const struct ip_conntrack_manip *manip,
-		  enum ip_nat_manip_type maniptype)
+		  enum ip_nat_manip_type maniptype, int hooknum)
 {
 	return 1;
 }
@@ -49,7 +49,7 @@
 static unsigned int
 unknown_print(char *buffer,
 	      const struct ip_conntrack_tuple *match,
-	      const struct ip_conntrack_tuple *mask)
+	      const struct ip_conntrack_tuple *mask, int hooknum)
 {
 	return 0;
 }
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_snmp_basic.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_snmp_basic.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ip_nat_snmp_basic.c	2003-09-27 20:50:48.000000000 -0400
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ip_nat_snmp_basic.c	2004-02-23 15:09:42.000000000 -0500
@@ -1231,6 +1231,8 @@
 	if (map.from == map.to)
 		return NF_ACCEPT;
 	
+	nf_ip_skb_checksum_help(*pskb, hooknum);
+
 	if (!snmp_parse_mangle((unsigned char *)udph + sizeof(struct udphdr),
 	                       paylen, &map, &udph->check)) {
 		printk(KERN_WARNING "bsalg: parser failed\n");
@@ -1252,6 +1254,9 @@
 	int dir = CTINFO2DIR(ctinfo);
 	struct iphdr *iph = (*pskb)->nh.iph;
 	struct udphdr *udph = (struct udphdr *)((u_int32_t *)iph + iph->ihl);
+	
+	if (!skb_ip_make_writable(pskb, (*pskb)->len))
+		return NF_DROP;
 
 	spin_lock_bh(&snmp_lock);
 	
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_ECN.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_ECN.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_ECN.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_ECN.c	2004-02-23 15:09:42.000000000 -0500
@@ -50,7 +50,7 @@
 
 /* Return 0 if there was an error. */
 static inline int
-set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo)
+set_ect_tcp(struct sk_buff **pskb, const struct ipt_ECN_info *einfo, int inward)
 {
 	struct tcphdr tcph;
 	u_int16_t diffs[2];
@@ -74,6 +74,12 @@
 		if (!skb_ip_make_writable(pskb,
 					  (*pskb)->nh.iph->ihl*4+sizeof(tcph)))
 			return 0;
+		if ((*pskb)->ip_summed == CHECKSUM_HW) {
+			if (inward)
+				(*pskb)->ip_summed = CHECKSUM_NONE;
+			else
+				nf_skb_checksum_help(*pskb);
+		}
 		tcph.check = csum_fold(csum_partial((char *)diffs,
 		                                    sizeof(diffs),
 		                                    tcph.check^0xFFFF));
@@ -100,7 +106,7 @@
 
 	if (einfo->operation & (IPT_ECN_OP_SET_ECE | IPT_ECN_OP_SET_CWR)
 	    && (*pskb)->nh.iph->protocol == IPPROTO_TCP)
-		if (!set_ect_tcp(pskb, einfo))
+		if (!set_ect_tcp(pskb, einfo, out == NULL))
 			return NF_DROP;
 
 	return IPT_CONTINUE;
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_REJECT.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_REJECT.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_REJECT.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_REJECT.c	2004-02-23 16:33:50.132770896 -0500
@@ -374,6 +374,8 @@
 	if ((*pskb)->nh.iph->ihl<<2 != sizeof(struct iphdr))
 		return NF_DROP;
 
+	skb_invalidate_hw_checksum(*pskb);
+
 	/* WARNING: This code causes reentry within iptables.
 	   This means that the iptables jump stack is now crap.  We
 	   must return an absolute verdict. --RR */
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_TCPMSS.c linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_TCPMSS.c
--- linux-2.6.3-mm3.o/net/ipv4/netfilter/ipt_TCPMSS.c	2004-02-18 00:17:09.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv4/netfilter/ipt_TCPMSS.c	2004-02-23 16:34:27.815042320 -0500
@@ -114,6 +114,7 @@
 			opt[i+2] = (newmss & 0xff00) >> 8;
 			opt[i+3] = (newmss & 0x00ff);
 
+			skb_invalidate_hw_checksum(*pskb);
 			tcph->check = cheat_check(htons(oldmss)^0xFFFF,
 						  htons(newmss),
 						  tcph->check);
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv6/ah6.c linux-2.6.3-mm3.w/net/ipv6/ah6.c
--- linux-2.6.3-mm3.o/net/ipv6/ah6.c	2004-02-04 08:39:07.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv6/ah6.c	2004-02-23 15:09:42.000000000 -0500
@@ -156,8 +156,8 @@
 	u16 nh_offset = 0;
 	u8 nexthdr;
 
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv6/esp6.c linux-2.6.3-mm3.w/net/ipv6/esp6.c
--- linux-2.6.3-mm3.o/net/ipv6/esp6.c	2003-09-27 20:50:30.000000000 -0400
+++ linux-2.6.3-mm3.w/net/ipv6/esp6.c	2004-02-23 15:09:42.000000000 -0500
@@ -58,9 +58,9 @@
 	u8 *prevhdr;
 	u8 nexthdr = 0;
 
-	/* First, if the skb is not checksummed, complete checksum. */
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	/* First, if the skb is not checksummed, allow retrans to fix. */
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
diff -urN -X dontdiff linux-2.6.3-mm3.o/net/ipv6/ipcomp6.c linux-2.6.3-mm3.w/net/ipv6/ipcomp6.c
--- linux-2.6.3-mm3.o/net/ipv6/ipcomp6.c	2003-12-01 15:27:04.000000000 -0500
+++ linux-2.6.3-mm3.w/net/ipv6/ipcomp6.c	2004-02-23 15:09:42.000000000 -0500
@@ -132,8 +132,8 @@
 	int plen, dlen;
 	u8 *start, *scratch = ipcd->scratch;
 
-	if (skb->ip_summed == CHECKSUM_HW && skb_checksum_help(skb) == NULL) {
-		err = -EINVAL;
+	if (skb->ip_summed == CHECKSUM_HW) {
+		err = -EAGAIN;
 		goto error_nolock;
 	}
 
