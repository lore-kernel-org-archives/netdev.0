From: Nicola Padovano <nicola.padovano@gmail.com>
Subject: [PATCH] Tarpit target for the last stable (2.6.35.7)
Date: Fri, 8 Oct 2010 19:01:41 +0200
Message-ID: <AANLkTimAd8F66D-P=h1i7C-CyCFn-OSbJtNRQX=drdgK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel module to capture and hold incoming TCP connections sending a
zero window packet to slow down the worm action.
More informations and newer version at:
http://npadovano.altervista.org/tarpit.html (or in the source code
comments)
Below you can find the patch and the relative userspace library
(compile it and put the .so output in /lib/xtables)

----------tarpit-2.6.35.7.patch------------
diff -rupN linux-2.6.35.7.orig/drivers/char/random.c
linux-2.6.35.7/drivers/char/random.c
--- linux-2.6.35.7.orig/drivers/char/random.c	2010-09-29
03:09:08.000000000 +0200
+++ linux-2.6.35.7/drivers/char/random.c	2010-10-08 02:51:35.000000000 +0200
@@ -1514,6 +1514,8 @@ __u32 secure_ip_id(__be32 daddr)
 	return half_md4_transform(hash, keyptr->secret);
 }

+EXPORT_SYMBOL(secure_ip_id);
+
 #ifdef CONFIG_INET

 __u32 secure_tcp_sequence_number(__be32 saddr, __be32 daddr,
@@ -1551,6 +1553,8 @@ __u32 secure_tcp_sequence_number(__be32
 	return seq;
 }

+EXPORT_SYMBOL(secure_tcp_sequence_number);
+
 /* Generate secure starting point for ephemeral IPV4 transport port search */
 u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport)
 {
diff -rupN linux-2.6.35.7.orig/net/netfilter/Kconfig
linux-2.6.35.7/net/netfilter/Kconfig
--- linux-2.6.35.7.orig/net/netfilter/Kconfig	2010-09-29
03:09:08.000000000 +0200
+++ linux-2.6.35.7/net/netfilter/Kconfig	2010-10-08 12:51:07.000000000 +0200
@@ -548,6 +548,32 @@ config NETFILTER_XT_TARGET_SECMARK

 	  To compile it as a module, choose M here.  If unsure, say N.

+config NETFILTER_XT_TARGET_TARPIT
+	tristate '"TARPIT" target support'
+	depends on NETFILTER_XTABLES
+	default m if NETFILTER_ADVANCED=n
+	---help---
+	  Adds a TARPIT target to iptables, which captures and holds
+	  incoming TCP connections using no local per-connection resources.
+	  Connections are accepted, but immediately switched to the persist
+	  state (0 byte window), in which the remote side stops sending data
+	  and asks to continue every 60-240 seconds (with a probe packet).
+	  Attempts to close the connection are ignored, forcing the remote
+	  side to time out the connection in 12-24 minutes. Any TCP port that
+	  you would normally DROP or REJECT can instead become a tarpit.
+	  Example:
+
+	  1) iptables -A INPUT -p tcp --dport 1111 -j TARPIT
+	  2) iptables -A FORWARD -p tcp -s x.y.z.k --dport 1111 -j TARPIT
+
+ 	  In the first example all the incoming TCP packets sent to the port
+	  1111 will be tarpitted. In the second one, we're tarpitting all the
+	  forwarded packets sent to the host x.y.z.k on the port 1111.
+
+         You can find more informations and newer versions at:
+	  <http://npadovano.altervista.org/tarpit.html>. Reporting bugs and
+	  improvements are welcome.
+
 config NETFILTER_XT_TARGET_TCPMSS
 	tristate '"TCPMSS" target support'
 	depends on (IPV6 || IPV6=n)
diff -rupN linux-2.6.35.7.orig/net/netfilter/Makefile
linux-2.6.35.7/net/netfilter/Makefile
--- linux-2.6.35.7.orig/net/netfilter/Makefile	2010-09-29
03:09:08.000000000 +0200
+++ linux-2.6.35.7/net/netfilter/Makefile	2010-10-08 02:53:44.000000000 +0200
@@ -56,6 +56,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE
 obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
+obj-$(CONFIG_NETFILTER_XT_TARGET_TARPIT) += xt_TARPIT.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) += xt_TPROXY.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPMSS) += xt_TCPMSS.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
diff -rupN linux-2.6.35.7.orig/net/netfilter/xt_TARPIT.c
linux-2.6.35.7/net/netfilter/xt_TARPIT.c
--- linux-2.6.35.7.orig/net/netfilter/xt_TARPIT.c	1970-01-01
01:00:00.000000000 +0100
+++ linux-2.6.35.7/net/netfilter/xt_TARPIT.c	2010-10-08 13:27:54.000000000 +0200
@@ -0,0 +1,304 @@
+/*
+ * Kernel module to capture and hold incoming TCP connections using
+ * no local per-connection resources.
+ *
+ * Based on ipt_REJECT.c and offering functionality similar to
+ * LaBrea <http://labrea.sourceforge.net/>.
+ *
+ * Original idea of:
+ *     Aaron Hopkins, <tools@die.net>
+ *
+ * Version 2.6.35.7 kernel release, written by:
+ *     Nicola Padovano, <nicola.padovano@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ *
+ * Goal:
+ * - Allow incoming TCP connections to be established.
+ * - Passing data should result in the connection being switched to the
+ *   persist state (0 byte window), in which the remote side stops sending
+ *   data and asks to continue every 60-240 seconds.
+ * - Prevent spoofing (don't allow the victim to connect with server worm)
+ * - Attempts to shut down the connection should be ignored completely, so
+ *   the remote side ends up having to time it out.
+ *
+ * This means:
+ * - Reply to TCP SYN,!ACK,!RST,!FIN with SYN-ACK, window 5 bytes
+ * - Reply to TCP !SYN,!RST,!FIN with ACK, window 0 bytes, rate-limited
+ * - Reply to TCP SYN,ACK,!RST,!FIN with RST to prevent spoofing
+ * - No reply to TCP RST or FIN
+ *
+ * More informations and newer versions at:
+ * <http://npadovano.altervista.com/tarpit.html>
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <net/icmp.h>
+#include <net/route.h>
+#include <linux/random.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+
+MODULE_DESCRIPTION("TARPIT iptables target, info at: "
+		    "http://npadovano.altervista.org/tarpit.html");
+MODULE_AUTHOR("Nicola Padovano <nicola.padovano@gmail.com>");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("xt_TARPIT");
+
+/*
+ * send a packet (to L2 output processing function)
+ *
+ * Note: there is also rtable* argument: it's only
+ *       used for debugging reason. Delete it if
+ *       you're sure things work.
+ */
+static int ip_direct_send(struct sk_buff* skb)
+{
+  /* get skb dst_entry pointer */
+  struct dst_entry* dst = skb_dst(skb);
+
+  /* if we already sent a packet to our neighbour */
+  if (dst->hh != NULL)
+    return neigh_hh_output(dst->hh,skb);
+
+  /* if there isn't header cache, send our packet with simple output
function */
+  else if (dst->neighbour != NULL)
+    return dst->neighbour->output(skb);
+
+  /* no neighbour, no header cache: it's impossible send the packet */
+  if (net_ratelimit())	
+    printk(KERN_DEBUG "TARPIT> ip_direct_send: no neighbour, no
header cache\n");
+
+  kfree_skb(skb);
+
+  return -EINVAL;
+}
+
+/*
+ * tarpit service routine: it accepts a pointer to
+ * sk_buff (the received packet) and its (input)
+ * cache entry.
+ * Note: the received packet it's called "old" in
+ *       the comments below. The packet to send
+ *       it's called "new".
+ */
+static void tarpit_tcp(const struct sk_buff *oskb,
+		       struct rtable *ort)
+{
+  struct iphdr    *oiph;             /* old ip header pointer */
+  struct tcphdr   *otcph;            /* old tcp header pointer */
+  unsigned int    oiphlen;           /* old ip header len */
+  unsigned int    otcplen;           /* old tcp (payload + header) len */
+
+  struct sk_buff  *nskb;             /* new skb buffer */
+  struct iphdr    *niph;             /* new ip header pointer */
+  struct tcphdr   *ntcph;            /* new tcp header pointer */
+  struct rtable   *nrt;              /* new routing table */
+
+  struct flowi fl = {};              /* search key used for the cache
lookups */
+
+  u_int32_t tmp32;                   /* swapping variables*/
+  u_int16_t tmp16;
+
+  /* fill old structs */
+  oiph    = ip_hdr(oskb);            /* get old ip header pointer */
+  oiphlen = ip_hdrlen(oskb);
+  otcph   = (void*)oiph + oiphlen;   /* do not use skb_transport_header! */
+  otcplen = oskb->len - oiphlen;
+
+  /* packets to drop */
+  if ( (oskb->len < oiphlen + sizeof(struct tcphdr)) ||
    /* truncate tcp header: 1st too fragmented packet...*/
+       (otcph->fin || otcph->rst) ||
    /* RST or FIN packet*/
+       (!otcph->ack && !otcph->syn) ||
    /* !ACK,!SYN packet */
+       (tcp_v4_check(otcplen, oiph->saddr, oiph->daddr,
    /* bad tcp checksum e ip checksum */
+		    csum_partial((char *)otcph, otcplen, 0))) ||
+       (oiph->frag_off & htons(IP_OFFSET)) ||
    /* fragment packets (after the first one) */
+       (!otcph->syn && otcph->ack && !xrlim_allow(&ort->u.dst,HZ)) ||
    /* rate-limit answer to SYN,ACK packets */
+       (ort == NULL) ||
    /* check for an input routing cache entry */
+       (oskb->pkt_type != PACKET_HOST &&
    /* no replies to physical multi/broadcast */
+        oskb->pkt_type != PACKET_OTHERHOST) ||
+       (ort->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST)) )
   /* check IP multi/broadcast */
+    return;
+
+
+  if (!(nskb = skb_copy(oskb, GFP_ATOMIC)))      /* we start with a
yet-prepared buffer */
+    return;                                      /* return if there's
an error in copy */
+
+  /* This packet will not be the same as the other: clear nf fields */
+  nf_conntrack_put(nskb->nfct);
+  nskb->nfct = NULL;
+#ifdef CONFIG_NETFILTER_DEBUG
+  nskb->nf_debug = 0;
+#endif
+
+  skb_trim(nskb, ip_hdrlen(nskb) + sizeof(struct tcphdr));     /*
trim skb size to IP LEN + TCP LEN*/
+  niph  = (struct iphdr*)skb_network_header(nskb);
+  ntcph = (void*)niph + ip_hdrlen(nskb);
+
+  /* set new ip header */
+  tmp32          = niph->saddr;
+  niph->saddr    = niph->daddr;
+  niph->daddr    = tmp32;
+
+  niph->tot_len  = htons(nskb->len);
+  niph->id       = htons(secure_ip_id(niph->daddr));
+
+  niph->frag_off = htons(IP_DF);            /* set don't frag flag */
+  niph->ttl      = (u32)64;
+
+  niph->check    = 0;
+  niph->check    = ip_fast_csum((unsigned char*)niph ,niph->ihl);
+
+  /* set new tcp header */
+  tmp16         = ntcph->source;
+  ntcph->source = ntcph->dest;
+  ntcph->dest   = tmp16;
+
+  ntcph->doff   = sizeof(struct tcphdr)/4;    /* 20bytes, doff is a
4bit variable */
+
+  ((u_int8_t*)ntcph)[13] = 0;                 /* reset all flag */
+  ntcph->urg_ptr = 0;
+
+   /* 1st goal: new tcp connection */
+  if (otcph->syn && !otcph->ack)
+    {
+      ntcph->syn = 1;
+      ntcph->ack = 1;
+      ntcph->seq = htonl(secure_tcp_sequence_number(niph->saddr,
+						    niph->daddr,
+						    ntcph->source,
+						    ntcph->dest));
+      ntcph->ack_seq = htonl(ntohl(otcph->seq) + 1);
+      ntcph->window = htons(5);
+    }
+
+  /* 2nd goal: RST tcp: RST+ACK */
+  else if (otcph->syn && otcph->ack)
+    {
+      ntcph->syn = 0;
+      ntcph->ack = 1;
+      ntcph->rst = 1;
+
+      ntcph->seq = otcph->ack_seq;
+      ntcph->ack_seq = 0;
+    }
+
+  /* 3rd goal: 0 byte window */
+  else if (!otcph->syn && otcph->ack)
+    {
+      ntcph->syn = 0;
+      ntcph->ack = 1;
+      ntcph->window = 0;
+      ntcph->seq = otcph->ack_seq;
+      ntcph->ack_seq = otcph->seq;   /* it's saying: "i'm not
received anything" */
+    }
+  else                               /* unacknowledged packet: drop it*/
+    return;
+
+  ntcph->check = 0;
+  ntcph->check = tcp_v4_check(sizeof(struct tcphdr),
+			      niph->saddr,
+			      niph->daddr,
+			      csum_partial((char *)ntcph,
+			      sizeof(struct tcphdr), 0));
+
+
+  /* create a search key to find packet route in cache*/
+  fl.nl_u.ip4_u.daddr = niph->daddr;
+  fl.nl_u.ip4_u.saddr = 0;
+  fl.nl_u.ip4_u.tos = RT_TOS(niph->tos) | RTO_CONN;
+  fl.oif = 0;
+
+  if (ip_route_output_key(&init_net, &nrt, &fl))             /* fill
nrt struct */
+    goto free_nskb;                                          /* exit
if errors in filling*/
+
+  dst_release(skb_dst(nskb));
+  nskb->_skb_refdst = ((unsigned long)&(nrt->u.dst));
+
+  ip_direct_send(nskb);                                      /* send
the packet */
+
+  return;
+
+ free_nskb:
+  kfree_skb(nskb);
+}
+
+
+/*
+ * target function, called everyone the rule is satisfied
+ * standard behaviour: NF_DROP
+ */
+static unsigned int xt_tarpit_target(struct sk_buff *skb,
+                                     const struct xt_target_param *par)
+{
+  struct rtable *rt = (void *)skb->_skb_refdst;
+  tarpit_tcp(skb,rt);
+  return NF_DROP;
+}
+
+/*
+ * xt_tarpit_check allows only:
+ * 1. raw table & PRE_ROUTING hook or
+ * 2. filter table & (LOCAL_IN or FORWARD) hook
+ * Note: for new kernels version: returns _false_
+ *       if checking is OK, otherwise returns _true_
+ */
+static bool xt_tarpit_check(const struct xt_mtchk_param *par)
+{
+  if (!strcmp(par->table, "raw") &&
+      par->hook_mask == NF_INET_PRE_ROUTING)
+    return false;
+
+  if (strcmp(par->table, "filter"))
+    return true;
+
+  return (par->hook_mask &  ~((1 << NF_INET_LOCAL_IN) |
+	                      (1 << NF_INET_FORWARD)));
+}
+
+
+static struct xt_target xt_tar_reg = {
+  .name       = "TARPIT",            /* target name */
+  .family     = AF_INET,             /* level 3 protocol */
+  .proto      = IPPROTO_TCP,         /* we recognize only tcp protocol */
+  .target     = xt_tarpit_target,    /* pointer to target function */
+  .checkentry = xt_tarpit_check,     /* pointer to check-entry function */
+  .me         = THIS_MODULE,
+};
+
+/*
+ * initing module function
+ */
+static int __init xt_tarpit_init(void)
+{
+  return xt_register_target(&xt_tar_reg);
+}
+
+/*
+ * delete module
+ */
+static void __exit xt_tarpit_exit(void)
+{
+  xt_unregister_target(&xt_tar_reg);
+}
+
+module_init(xt_tarpit_init);
+module_exit(xt_tarpit_exit);


-------------libxt_TARPIT.c------------
#include <stdio.h>
#include <getopt.h>
#include <xtables.h>

static void tarpit_tg_help(void)
{
	printf("TARPIT takes no options\n\n");
}

static int tarpit_tg_parse(int c, char **argv, int invert, unsigned int *flags,
                           const void *entry, struct xt_entry_target **target)
{
	return 0;
}

static void tarpit_tg_check(unsigned int flags)
{
}

static struct xtables_target tarpit_tg_reg = {
	.version       = XTABLES_VERSION,
	.name          = "TARPIT",
	.family        = AF_INET,
	.help          = tarpit_tg_help,
	.parse         = tarpit_tg_parse,
	.final_check   = tarpit_tg_check,
};

static __attribute__((constructor)) void tarpit_tg_ldr(void)
{
	xtables_register_target(&tarpit_tg_reg);
}

-- 
Nicola Padovano
e-mail: nicola.padovano@gmail.com
web: http://npadovano.altervista.org

"My only ambition is not be anything at all; it seems the most
sensible thing" (C. Bukowski)
