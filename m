From: "David S. Miller" <davem@redhat.com>
Subject: Re: multicast IP datagram forwarding bug and fix (fwd)
Date: Sun, 3 Aug 2003 23:05:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030803230552.1aab9411.davem@redhat.com>
References: <Pine.LNX.4.44.0308040905260.11876-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0308040905260.11876-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 4 Aug 2003 09:06:04 +0300 (EEST)
Pekka Savola <pekkas@netcore.fi> wrote:

> I didn't see followups to this, so I'm re-sending to the list just in case 
> it got dropped in the cracks..

I've already checked in a correct fix for this problem from Alexey:

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1584.2.13 -> 1.1584.2.14
#	     net/ipv4/ipmr.c	1.27    -> 1.28   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/02	kuznet@ms2.inr.ac.ru	1.1584.2.14
# [IPV4]: IP options were not updated while forwarding multicasts.
# --------------------------------------------
#
diff -Nru a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
--- a/net/ipv4/ipmr.c	Sun Aug  3 23:07:44 2003
+++ b/net/ipv4/ipmr.c	Sun Aug  3 23:07:44 2003
@@ -1100,6 +1100,7 @@
 
 	skb->h.ipiph = skb->nh.iph;
 	skb->nh.iph = iph;
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 #ifdef CONFIG_NETFILTER
 	nf_conntrack_put(skb->nfct);
 	skb->nfct = NULL;
@@ -1108,12 +1109,14 @@
 
 static inline int ipmr_forward_finish(struct sk_buff *skb)
 {
-	struct dst_entry *dst = skb->dst;
+	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	if (skb->len <= dst_pmtu(dst))
-		return dst_output(skb);
-	else
-		return ip_fragment(skb, dst_output);
+	IP_INC_STATS_BH(IpForwDatagrams);
+
+	if (unlikely(opt->optlen))
+		ip_forward_options(skb);
+
+	return dst_output(skb);
 }
 
 /*
