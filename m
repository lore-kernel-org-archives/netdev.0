From: David Miller <davem@davemloft.net>
Subject: Re: TCP event tracking via netlink...
Date: Thu, 06 Dec 2007 02:33:46 -0800 (PST)
Message-ID: <20071206.023346.256200942.davem@davemloft.net>
References: <20071205.053031.87154402.davem@davemloft.net>
	<Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58122
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751946AbXLFKdr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 05:33:47 -0500
In-Reply-To: <Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 6 Dec 2007 01:18:28 +0200 (EET)

> On Wed, 5 Dec 2007, David Miller wrote:
>=20
> > I assume you're using something like carefully crafted printk's,
> > kprobes, or even ad-hoc statistic counters.  That's what I used to =
do
> > :-)
>=20
> No, that's not at all what I do :-). I usually look time-seq graphs=20
> expect for the cases when I just find things out by reading code (or
> by just thinking of it).

Can you briefly detail what graph tools and command lines
you are using?

The last time I did graphing to analyze things, the tools
were hit-or-miss.

> Much of the info is available in tcpdump already, it's just hard to r=
ead=20
> without graphing it first because there are some many overlapping thi=
ngs=20
> to track in two-dimensional space.
>=20
> ...But yes, I have to admit that couple of problems come to my mind
> where having some variable from tcp_sock would have made the problem
> more obvious.

The most important are the cwnd and ssthresh, which you could guess
using graphs but it is important to know on a packet to packet
basis why we might have sent a packet or not because this has
rippling effects down the rest of the RTT.

> Not sure what is the benefit of having distributions with it because=20
> those people hardly report problems anyway to here, they're just too=20
> happy with TCP performance unless we print something to their logs,
> which implies that we must setup a *_ON() condition :-(.

That may be true, but if we could integrate the information with
tcpdumps, we could gather internal state using tools the user
already has available.

Imagine if tcpdump printed out:

02:26:14.865805 IP $SRC > $DEST: . 11226:12686(1460) ack 0 win 108
	ss_thresh: 129 cwnd: 133 packets_out: 132

or something like that.

> Some problems are simply such that things cannot be accurately verifi=
ed=20
> without high processing overhead until it's far too late (eg skb bits=
 vs=20
> *_out counters). Maybe we should start to build an expensive state=20
> validator as well which would automatically check invariants of the w=
rite=20
> queue and tcp_sock in a straight forward, unoptimized manner? That wo=
uld=20
> definately do a lot of work for us, just ask people to turn it on and=
 it=20
> spits out everything that went wrong :-) (unless they really depend o=
n=20
> very high-speed things and are therefore unhappy if we scan thousands=
 of=20
> packets unnecessarily per ACK :-)). ...Early enough! ...That would wo=
rk=20
> also for distros but there's always human judgement needed to decide=20
> whether the bug reporter will be happy when his TCP processing does n=
o=20
> longer scale ;-).

I think it's useful as a TCP_DEBUG config option or similar, sure.

But sometimes the algorithms are working as designed, it's just that
they provide poor pipe utilization and CWND analysis embedded inside
of a tcpdump would be one way to see that as well as determine the
flaw in the algorithm.

> ...Hopefully you found any of my comments useful.

Very much so, thanks.

I put together a sample implementation anyways just to show the idea,
against net-2.6.25 below.

It is untested since I didn't write the userland app yet to see that
proper things get logged.  Basically you could run a daemon that
writes per-connection traces into files based upon the incoming
netlink events.  Later, using the binary pcap file and these traces,
you can piece together traces like the above using the timestamps
etc. to match up pcap packets to ones from the TCP logger.

The userland tools could do analysis and print pre-cooked state diff
logs, like "this ACK raised CWND by one" or whatever else you wanted
to know.

It's nice that an expert like you can look at graphs and understand,
but we'd like to create more experts and besides reading code one
way to become an expert is to be able to extrace live real data
from the kernel's working state and try to understand how things
got that way.  This information is permanently lost currently.

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 56342c3..c0e61d0 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -170,6 +170,47 @@ struct tcp_md5sig {
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
=20
+/* TCP netlink event logger.  */
+struct tcp_log_key {
+	union {
+		__be32		a4;
+		__be32		a6[4];
+	} saddr, daddr;
+	__be16	sport;
+	__be16	dport;
+	unsigned short family;
+	unsigned short __pad;
+};
+
+struct tcp_log_stamp {
+	__u32	tv_sec;
+	__u32	tv_usec;
+};
+
+struct tcp_log_payload {
+	struct tcp_log_key	key;
+	struct tcp_log_stamp	stamp;
+	struct tcp_info		info;
+};
+
+enum {
+	TCP_LOG_A_UNSPEC =3D 0,
+	__TCP_LOG_A_MAX,
+};
+#define TCP_LOG_A_MAX		(__TCP_LOG_A_MAX - 1)
+
+#define TCP_LOG_GENL_NAME	"tcp_log"
+#define TCP_LOG_GENL_VERSION	1
+
+enum {
+	TCP_LOG_CMD_UNSPEC =3D 0,
+	TCP_LOG_CMD_HELLO,
+	TCP_LOG_CMD_GOODBYE,
+	TCP_LOG_CMD_EVENT,
+	__TCP_LOG_CMD_MAX,
+};
+#define TCP_LOG_CMD_MAX		(__TCP_LOG_CMD_MAX - 1)
+
 #ifdef __KERNEL__
=20
 #include <linux/skbuff.h>
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9dbed0b..5ac82ea 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1730,6 +1730,19 @@ struct tcp_request_sock_ops {
 #endif
 };
=20
+#define TCP_LOG_PID_INACTIVE	-1
+extern int tcp_log_pid;
+
+extern void tcp_do_log(struct sock *sk, ktime_t stamp);
+
+static inline void tcp_log(struct sock *sk, ktime_t stamp)
+{
+	if (likely(tcp_log_pid =3D=3D TCP_LOG_PID_INACTIVE))
+		return;
+
+	tcp_do_log(sk, stamp);
+}
+
 extern void tcp_v4_init(struct net_proto_family *ops);
 extern void tcp_init(void);
=20
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index ad40ef3..fa0cc1d 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -7,7 +7,7 @@ obj-y     :=3D route.o inetpeer.o protocol.o \
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
 	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
-	     tcp_minisocks.o tcp_cong.o \
+	     tcp_minisocks.o tcp_cong.o tcp_log.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o \
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5fba12..a51cbd2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4577,6 +4577,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 			struct tcphdr *th, unsigned len)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
+	ktime_t stamp =3D skb->tstamp;
=20
 	/*
 	 *	Header prediction.
@@ -4657,6 +4658,7 @@ int tcp_rcv_established(struct sock *sk, struct s=
k_buff *skb,
 				tcp_ack(sk, skb, 0);
 				__kfree_skb(skb);
 				tcp_data_snd_check(sk);
+				tcp_log(sk, stamp);
 				return 0;
 			} else { /* Header too small */
 				TCP_INC_STATS_BH(TCP_MIB_INERRS);
@@ -4748,6 +4750,7 @@ no_ack:
 				__kfree_skb(skb);
 			else
 				sk->sk_data_ready(sk, 0);
+			tcp_log(sk, stamp);
 			return 0;
 		}
 	}
@@ -4800,6 +4803,7 @@ slow_path:
 		TCP_INC_STATS_BH(TCP_MIB_INERRS);
 		NET_INC_STATS_BH(LINUX_MIB_TCPABORTONSYN);
 		tcp_reset(sk);
+		tcp_log(sk, stamp);
 		return 1;
 	}
=20
@@ -4817,6 +4821,7 @@ step5:
=20
 	tcp_data_snd_check(sk);
 	tcp_ack_snd_check(sk);
+	tcp_log(sk, stamp);
 	return 0;
=20
 csum_error:
@@ -4824,6 +4829,7 @@ csum_error:
=20
 discard:
 	__kfree_skb(skb);
+	tcp_log(sk, stamp);
 	return 0;
 }
=20
--- a/net/ipv4/tcp_log.c	2007-10-24 01:07:28.000000000 -0700
+++ b/net/ipv4/tcp_log.c	2007-12-06 01:06:26.000000000 -0800
@@ -0,0 +1,149 @@
+/* tcp_log.c: Netlink based TCP state change logger.
+ *
+ * Copyright (C) 2007 David S. Miller <davem@davemloft.net>
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/time.h>
+#include <linux/ipv6.h>
+#include <linux/tcp.h>
+
+#include <net/genetlink.h>
+#include <net/inet_sock.h>
+#include <net/tcp.h>
+
+static struct genl_family tcp_log_family =3D {
+	.id		=3D	GENL_ID_GENERATE,
+	.name		=3D	TCP_LOG_GENL_NAME,
+	.version	=3D	TCP_LOG_GENL_VERSION,
+	.hdrsize	=3D	sizeof(struct tcp_log_payload),
+	.maxattr	=3D	TCP_LOG_A_MAX,
+};
+
+static unsigned int tcp_log_seqnum;
+
+int tcp_log_pid =3D TCP_LOG_PID_INACTIVE;
+EXPORT_SYMBOL(tcp_log_pid);
+
+static int tcp_log_hello(struct sk_buff *skb, struct genl_info *info)
+{
+	tcp_log_pid =3D info->snd_pid;
+	return 0;
+}
+
+static int tcp_log_goodbye(struct sk_buff *skb, struct genl_info *info=
)
+{
+	tcp_log_pid =3D TCP_LOG_PID_INACTIVE;
+	return 0;
+}
+
+static struct genl_ops tcp_log_hello_ops =3D {
+	.cmd		=3D	TCP_LOG_CMD_HELLO,
+	.doit		=3D	tcp_log_hello,
+};
+
+static struct genl_ops tcp_log_goodbye_ops =3D {
+	.cmd		=3D	TCP_LOG_CMD_GOODBYE,
+	.doit		=3D	tcp_log_goodbye,
+};
+
+static void fill_key(struct tcp_log_key *key, struct sock *sk)
+{
+	struct inet_sock *inet =3D inet_sk(sk);
+	struct ipv6_pinfo *np =3D inet6_sk(sk);
+
+	switch (sk->sk_family) {
+	case AF_INET:
+		key->saddr.a4 =3D inet->saddr;
+		key->daddr.a4 =3D inet->daddr;
+		break;
+	case AF_INET6:
+		memcpy(&key->saddr.a6, &np->saddr, sizeof(key->saddr.a6));
+		memcpy(&key->daddr.a6, &np->daddr, sizeof(key->daddr.a6));
+		break;
+	default:
+		BUG();
+		break;
+	}
+	key->sport =3D inet->sport;
+	key->dport =3D inet->dport;
+}
+
+void tcp_do_log(struct sock *sk, ktime_t stamp)
+{
+	struct tcp_log_payload *p;
+	struct sk_buff *skb;
+	struct timeval tv;
+	void *data;
+	int size;
+
+	size =3D nla_total_size(sizeof(struct tcp_log_payload));
+	skb =3D genlmsg_new(size, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	data =3D genlmsg_put(skb, 0, tcp_log_seqnum++,
+			   &tcp_log_family, 0, TCP_LOG_CMD_EVENT);
+	if (!data) {
+		nlmsg_free(skb);
+		return;
+	}
+	p =3D data;
+
+	fill_key(&p->key, sk);
+
+	if (stamp.tv64)
+		tv =3D ktime_to_timeval(stamp);
+	else
+		do_gettimeofday(&tv);
+
+	p->stamp.tv_sec =3D tv.tv_sec;
+	p->stamp.tv_usec =3D tv.tv_usec;
+
+	tcp_get_info(sk, &p->info);
+
+	if (genlmsg_end(skb, data) < 0) {
+		nlmsg_free(skb);
+		return;
+	}
+
+	genlmsg_unicast(skb, tcp_log_pid);
+}
+EXPORT_SYMBOL(tcp_do_log);
+
+static int __init tcp_log_init(void)
+{
+	int err =3D genl_register_family(&tcp_log_family);
+
+	if (err)
+		return err;
+
+	err =3D genl_register_ops(&tcp_log_family, &tcp_log_hello_ops);
+	if (err)
+		goto out_unregister_family;
+
+	err =3D genl_register_ops(&tcp_log_family, &tcp_log_goodbye_ops);
+	if (err)
+		goto out_unregister_hello;
+
+	return 0;
+
+out_unregister_hello:
+	genl_unregister_ops(&tcp_log_family, &tcp_log_hello_ops);
+
+out_unregister_family:
+	genl_unregister_family(&tcp_log_family);
+
+	return err;
+}
+
+static void __exit tcp_log_exit(void)
+{
+	genl_unregister_ops(&tcp_log_family, &tcp_log_goodbye_ops);
+	genl_unregister_ops(&tcp_log_family, &tcp_log_hello_ops);
+	genl_unregister_family(&tcp_log_family);
+}
+
+module_init(tcp_log_init);
+module_exit(tcp_log_exit);
