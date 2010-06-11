From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Fri, 11 Jun 2010 15:10:38 +0200
Message-ID: <20100611131038.GB1739@jolsa.Belkin>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
 <4C08EB85.3050900@trash.net>
 <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com>
 <4C0FA24A.7060907@trash.net>
 <20100610065631.GA1915@jolsa.lab.eng.brq.redhat.com>
 <4C10ACDC.6010108@trash.net>
 <20100610095312.GC1915@jolsa.lab.eng.brq.redhat.com>
 <4C10B8C8.2050201@trash.net>
 <20100611081604.GA1739@jolsa.Belkin>
 <alpine.LSU.2.01.1006111152230.30433@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1006111152230.30433@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 11, 2010 at 11:53:32AM +0200, Jan Engelhardt wrote:
> 
> On Friday 2010-06-11 10:16, Jiri Olsa wrote:
> >
> >I prepared the patch implementing IP_NODEFRAG option for IPv4 socket.
> >
> >Also I just got an idea, that there could be no reassembly if there are
> >no rules for connection tracing set.. not sure how can I check that best
> >so far.. any idea?
> >
> >@@ -572,6 +572,14 @@ static int do_ip_setsockopt(struct sock *sk, int level,
> > 		}
> > 		inet->hdrincl = val ? 1 : 0;
> > 		break;
> >+	case IP_NODEFRAG:
> >+		if (sk->sk_type != SOCK_RAW) {
> >+			err = -ENOPROTOOPT;
> >+			break;
> >+		}
> >+		inet->nodefrag = val ? 1 : 0;
> >+		printk("IP_NODEFRAG %p -> %d\n", inet, inet->nodefrag);
> >+		break;
> 
> You want to get rid of this printk otherwise it spews the logs.

oops, I forgot to remove this one... thanks

new patch is attached

wbr,
jirka


---
diff --git a/include/linux/in.h b/include/linux/in.h
index 583c76f..41d88a4 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -85,6 +85,7 @@ struct in_addr {
 #define IP_RECVORIGDSTADDR   IP_ORIGDSTADDR
 
 #define IP_MINTTL       21
+#define IP_NODEFRAG     22
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 1653de5..1989cfd 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -137,7 +137,8 @@ struct inet_sock {
 				hdrincl:1,
 				mc_loop:1,
 				transparent:1,
-				mc_all:1;
+				mc_all:1,
+				nodefrag:1;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist	*mc_list;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 551ce56..84d2c8e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -355,6 +355,8 @@ lookup_protocol:
 	inet = inet_sk(sk);
 	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
+	inet->nodefrag = 0;
+
 	if (SOCK_RAW == sock->type) {
 		inet->inet_num = protocol;
 		if (IPPROTO_RAW == protocol)
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index ce23178..d8196e1 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -449,7 +449,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
-			     (1<<IP_MINTTL))) ||
+			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
@@ -572,6 +572,13 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		inet->hdrincl = val ? 1 : 0;
 		break;
+	case IP_NODEFRAG:
+		if (sk->sk_type != SOCK_RAW) {
+			err = -ENOPROTOOPT;
+			break;
+		}
+		inet->nodefrag = val ? 1 : 0;
+		break;
 	case IP_MTU_DISCOVER:
 		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
 			goto e_inval;
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index cb763ae..eab8de3 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -66,6 +66,11 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 					  const struct net_device *out,
 					  int (*okfn)(struct sk_buff *))
 {
+	struct inet_sock *inet = inet_sk(skb->sk);
+
+	if (inet && inet->nodefrag)
+		return NF_ACCEPT;
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
 	/* Previously seen (loopback)?  Ignore.  Do this before
