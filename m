From: Thomas Graf <tgraf@suug.ch>
Subject: Re: netif_rx packet dumping
Date: Thu, 10 Mar 2005 00:57:28 +0100
Message-ID: <20050309235728.GV31837@postel.suug.ch>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net> <42278122.6000000@ev-en.org> <20050303133659.0d224e61.davem@davemloft.net> <42278554.2090902@ev-en.org> <20050303135718.2e1a0170.davem@davemloft.net> <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de> <20050308100902.24b67b2f.davem@davemloft.net> <422DEE85.5010302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Andi Kleen <ak@muc.de>,
        baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <422DEE85.5010302@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <422DEE85.5010302@candelatech.com> 2005-03-08 10:27
> Seems like we might could squish the sk_buff a bit:
> 
> Do we really need 32-bits for the mac-len:
> 
> 	unsigned int		len,
> 				data_len,
> 				mac_len,
> 				csum;

Yes, I guess it can be 16-bits.

> Some of these flags could be collapsed into a single field and we
> could do bit-shift operations for the single flags we care about.
> This would also make it easier to add new flags as desired w/out
> growing the structure.
> 
> 	unsigned char		local_df,
> 				cloned,
> 				pkt_type,
> 				ip_summed;

I changed them to be :1, less work and doesn't have to be atomic anyway.

> The priority could probably be 16 bits as well, do we really need more
> than 65k different priorities:
> 
> 	__u32			priority;

We use skb->priority to map to tc handles which is by definition 32-bits,
not really used at the moment but it will be of use again soon.

> Of course...this might be things for 2.7 since lots of modules will probably
> be accessing these fields.  Maybe to get started we could add macros to grab
> the flags and such so that when we finally do collapse things into a single
> flags field the external code doesn't have to know or care?

I attached a small patch below saving 4 bytes and leaving some room for
additional flags. The removal of security has indeed potential to break
external modules.

diff -Nru linux-2.6.11-bk5.orig/include/linux/skbuff.h linux-2.6.11-bk5/include/linux/skbuff.h
--- linux-2.6.11-bk5.orig/include/linux/skbuff.h	2005-03-09 22:00:23.000000000 +0100
+++ linux-2.6.11-bk5/include/linux/skbuff.h	2005-03-10 00:48:46.000000000 +0100
@@ -250,16 +250,16 @@
 
 	unsigned int		len,
 				data_len,
-				mac_len,
 				csum;
-	unsigned char		local_df,
+	unsigned short		mac_len,
+				protocol;
+	unsigned char		pkt_type,
+				local_df:1,
 				cloned:1,
-				nohdr:1,
-				pkt_type,
-				ip_summed;
+				ip_summed:2,
+				nohdr:1;
+	/* 20 bits spare */
 	__u32			priority;
-	unsigned short		protocol,
-				security;
 
 	void			(*destructor)(struct sk_buff *skb);
 #ifdef CONFIG_NETFILTER
diff -Nru linux-2.6.11-bk5.orig/include/linux/tc_ematch/tc_em_meta.h linux-2.6.11-bk5/include/linux/tc_ematch/tc_em_meta.h
--- linux-2.6.11-bk5.orig/include/linux/tc_ematch/tc_em_meta.h	2005-03-09 22:00:23.000000000 +0100
+++ linux-2.6.11-bk5/include/linux/tc_ematch/tc_em_meta.h	2005-03-09 23:34:28.000000000 +0100
@@ -45,7 +45,7 @@
 	TCF_META_ID_REALDEV,
 	TCF_META_ID_PRIORITY,
 	TCF_META_ID_PROTOCOL,
-	TCF_META_ID_SECURITY,
+	TCF_META_ID_SECURITY, /* obsolete */
 	TCF_META_ID_PKTTYPE,
 	TCF_META_ID_PKTLEN,
 	TCF_META_ID_DATALEN,
diff -Nru linux-2.6.11-bk5.orig/net/core/skbuff.c linux-2.6.11-bk5/net/core/skbuff.c
--- linux-2.6.11-bk5.orig/net/core/skbuff.c	2005-03-09 22:00:39.000000000 +0100
+++ linux-2.6.11-bk5/net/core/skbuff.c	2005-03-09 23:33:54.000000000 +0100
@@ -359,7 +359,6 @@
 	C(ip_summed);
 	C(priority);
 	C(protocol);
-	C(security);
 	n->destructor = NULL;
 #ifdef CONFIG_NETFILTER
 	C(nfmark);
@@ -427,7 +426,6 @@
 	new->pkt_type	= old->pkt_type;
 	new->stamp	= old->stamp;
 	new->destructor = NULL;
-	new->security	= old->security;
 #ifdef CONFIG_NETFILTER
 	new->nfmark	= old->nfmark;
 	new->nfcache	= old->nfcache;
diff -Nru linux-2.6.11-bk5.orig/net/ipv4/ip_output.c linux-2.6.11-bk5/net/ipv4/ip_output.c
--- linux-2.6.11-bk5.orig/net/ipv4/ip_output.c	2005-03-09 22:00:40.000000000 +0100
+++ linux-2.6.11-bk5/net/ipv4/ip_output.c	2005-03-09 23:41:40.000000000 +0100
@@ -388,7 +388,6 @@
 	to->pkt_type = from->pkt_type;
 	to->priority = from->priority;
 	to->protocol = from->protocol;
-	to->security = from->security;
 	dst_release(to->dst);
 	to->dst = dst_clone(from->dst);
 	to->dev = from->dev;
diff -Nru linux-2.6.11-bk5.orig/net/ipv6/ip6_output.c linux-2.6.11-bk5/net/ipv6/ip6_output.c
--- linux-2.6.11-bk5.orig/net/ipv6/ip6_output.c	2005-03-09 22:00:42.000000000 +0100
+++ linux-2.6.11-bk5/net/ipv6/ip6_output.c	2005-03-09 23:46:01.000000000 +0100
@@ -462,7 +462,6 @@
 	to->pkt_type = from->pkt_type;
 	to->priority = from->priority;
 	to->protocol = from->protocol;
-	to->security = from->security;
 	dst_release(to->dst);
 	to->dst = dst_clone(from->dst);
 	to->dev = from->dev;
diff -Nru linux-2.6.11-bk5.orig/net/sched/em_meta.c linux-2.6.11-bk5/net/sched/em_meta.c
--- linux-2.6.11-bk5.orig/net/sched/em_meta.c	2005-03-09 22:00:41.000000000 +0100
+++ linux-2.6.11-bk5/net/sched/em_meta.c	2005-03-09 23:34:16.000000000 +0100
@@ -204,11 +204,6 @@
 	dst->value = skb->protocol;
 }
 
-META_COLLECTOR(int_security)
-{
-	dst->value = skb->security;
-}
-
 META_COLLECTOR(int_pkttype)
 {
 	dst->value = skb->pkt_type;
@@ -311,7 +306,6 @@
 		[TCF_META_ID_REALDEV]	= { .get = meta_int_realdev },
 		[TCF_META_ID_PRIORITY]	= { .get = meta_int_priority },
 		[TCF_META_ID_PROTOCOL]	= { .get = meta_int_protocol },
-		[TCF_META_ID_SECURITY]	= { .get = meta_int_security },
 		[TCF_META_ID_PKTTYPE]	= { .get = meta_int_pkttype },
 		[TCF_META_ID_PKTLEN]	= { .get = meta_int_pktlen },
 		[TCF_META_ID_DATALEN]	= { .get = meta_int_datalen },
