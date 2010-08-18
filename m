From: Dmitry Kozlov <xeb@mail.ru>
Subject: =?koi8-r?Q?[PATCH_v5]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Wed, 18 Aug 2010 18:14:22 +0400
Message-ID: <E1OljPK-0006rQ-00.xeb-mail-ru@f238.mail.ru>
Reply-To: Dmitry Kozlov <xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from f238.mail.ru ([217.69.128.165]:38247 "EHLO f238.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129Ab0HROOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Aug 2010 10:14:25 -0400
Received: from mail by f238.mail.ru with local
	id 1OljPK-0006rQ-00
	for netdev@vger.kernel.org; Wed, 18 Aug 2010 18:14:22 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains:
1. pptp driver
2. gre demultiplexer driver for demultiplexing gre packets with different gre version
   so ip_gre and pptp may coexists
3. ip_gre modification
4. other stuff

Changes from patch v4:
1. using spinlock instead mutex
2. fixed coding style issues

--
 MAINTAINERS              |   14 +
 drivers/net/Kconfig      |   11 +
 drivers/net/Makefile     |    1 +
 drivers/net/pptp.c       |  714 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_pppox.h |   53 +++--
 include/net/gre.h        |   18 ++
 net/ipv4/Kconfig         |    7 +
 net/ipv4/Makefile        |    1 +
 net/ipv4/gre.c           |  151 ++++++++++
 net/ipv4/ip_gre.c        |   14 +-
 10 files changed, 960 insertions(+), 24 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 02f75fc..cdae013 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6450,6 +6450,20 @@ M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
 F:	drivers/serial/zs.*
 
+GRE DEMULTIPLEXER DRIVER
+M:	Dmitry Kozlov <xeb@mail.ru>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	net/ipv4/gre.c
+F:	include/net/gre.h
+
+PPTP DRIVER
+M:	Dmitry Kozlov <xeb@mail.ru>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/pptp.c
+W:	http://sourceforge.net/projects/accel-pptp
+
 THE REST
 M:	Linus Torvalds <torvalds@linux-foundation.org>
 L:	linux-kernel@vger.kernel.org
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ce2fcdd..2fa0516 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3167,6 +3167,17 @@ config PPPOE
 	  which contains instruction on how to use this driver (under 
 	  the heading "Kernel mode PPPoE").
 
+config PPTP
+	tristate "PPP over IPv4 (PPTP) (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && PPP && NET_IPGRE_DEMUX
+	help
+	  Support for PPP over IPv4.(Point-to-Point Tunneling Protocol)
+
+	  This driver requires pppd plugin to work in client mode or
+	  modified pptpd (poptop) to work in server mode.
+	  See http://accel-pptp.sourceforge.net/ for information how to
+	  utilize this module.
+
 config PPPOATM
 	tristate "PPP over ATM"
 	depends on ATM && PPP
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0a0512a..b33fef1 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -162,6 +162,7 @@ obj-$(CONFIG_PPP_BSDCOMP) += bsd_comp.o
 obj-$(CONFIG_PPP_MPPE) += ppp_mppe.o
 obj-$(CONFIG_PPPOE) += pppox.o pppoe.o
 obj-$(CONFIG_PPPOL2TP) += pppox.o
+obj-$(CONFIG_PPTP) += pppox.o pptp.o
 
 obj-$(CONFIG_SLIP) += slip.o
 obj-$(CONFIG_SLHC) += slhc.o
diff --git a/drivers/net/pptp.c b/drivers/net/pptp.c
new file mode 100644
index 0000000..a71b861
--- /dev/null
+++ b/drivers/net/pptp.c
@@ -0,0 +1,714 @@
+/*
+ *  Point-to-Point Tunneling Protocol for Linux
+ *
+ *	Authors: Dmitry Kozlov <xeb@mail.ru>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/string.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/ppp_channel.h>
+#include <linux/ppp_defs.h>
+#include <linux/if_pppox.h>
+#include <linux/if_ppp.h>
+#include <linux/notifier.h>
+#include <linux/file.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/version.h>
+#include <linux/rcupdate.h>
+#include <linux/spinlock.h>
+
+#include <net/sock.h>
+#include <net/protocol.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/route.h>
+#include <net/gre.h>
+
+#include <linux/uaccess.h>
+
+#define PPTP_DRIVER_VERSION "0.8.5"
+
+#define MAX_CALLID 65535
+
+static DECLARE_BITMAP(callid_bitmap, MAX_CALLID + 1);
+static struct pppox_sock **callid_sock;
+
+static DEFINE_SPINLOCK(chan_lock);
+
+static struct proto pptp_sk_proto __read_mostly;
+static struct ppp_channel_ops pptp_chan_ops;
+static const struct proto_ops pptp_ops;
+
+#define PPP_LCP_ECHOREQ 0x09
+#define PPP_LCP_ECHOREP 0x0A
+#define SC_RCV_BITS	(SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP)
+
+#define MISSING_WINDOW 20
+#define WRAPPED(curseq, lastseq)\
+	((((curseq) & 0xffffff00) == 0) &&\
+	(((lastseq) & 0xffffff00) == 0xffffff00))
+
+#define PPTP_GRE_PROTO  0x880B
+#define PPTP_GRE_VER    0x1
+
+#define PPTP_GRE_FLAG_C	0x80
+#define PPTP_GRE_FLAG_R	0x40
+#define PPTP_GRE_FLAG_K	0x20
+#define PPTP_GRE_FLAG_S	0x10
+#define PPTP_GRE_FLAG_A	0x80
+
+#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
+#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
+#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
+#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
+#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
+
+#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
+struct pptp_gre_header {
+	u8  flags;
+	u8  ver;
+	u16 protocol;
+	u16 payload_len;
+	u16 call_id;
+	u32 seq;
+	u32 ack;
+} __attribute__((packed));
+
+static struct pppox_sock *lookup_chan(__u16 call_id, __be32 s_addr)
+{
+	struct pppox_sock *sock;
+	struct pptp_opt *opt;
+
+	rcu_read_lock();
+	sock = rcu_dereference(callid_sock[call_id]);
+	if (sock) {
+		opt = &sock->proto.pptp;
+		if (opt->dst_addr.sin_addr.s_addr != s_addr)
+			sock = NULL;
+		else
+			sock_hold(sk_pppox(sock));
+	}
+	rcu_read_unlock();
+
+	return sock;
+}
+
+static int lookup_chan_dst(__u16 call_id, __be32 d_addr)
+{
+	struct pppox_sock *sock;
+	struct pptp_opt *opt;
+	int i;
+
+	rcu_read_lock();
+	for (i = find_next_bit(callid_bitmap, MAX_CALLID, 1); i < MAX_CALLID; i = find_next_bit(callid_bitmap, MAX_CALLID, i + 1)) {
+		sock = rcu_dereference(callid_sock[i]);
+		opt = &sock->proto.pptp;
+		if (opt->dst_addr.call_id == call_id &&	opt->dst_addr.sin_addr.s_addr == d_addr)
+			break;
+	}
+	rcu_read_unlock();
+
+	return i < MAX_CALLID;
+}
+
+static int add_chan(struct pppox_sock *sock)
+{
+	static int call_id;
+
+	spin_lock(&chan_lock);
+	if (!sock->proto.pptp.src_addr.call_id)	{
+		call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, call_id + 1);
+		if (call_id == MAX_CALLID) {
+			call_id = find_next_zero_bit(callid_bitmap, MAX_CALLID, 1);
+			if (call_id == MAX_CALLID)
+				goto out_err;
+		}
+		sock->proto.pptp.src_addr.call_id = call_id;
+	} else if (test_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap))
+		goto out_err;
+
+	set_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
+	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], sock);
+	spin_unlock(&chan_lock);
+
+	return 0;
+
+out_err:
+	spin_unlock(&chan_lock);
+	return -1;
+}
+
+static void del_chan(struct pppox_sock *sock)
+{
+	spin_lock(&chan_lock);
+	clear_bit(sock->proto.pptp.src_addr.call_id, callid_bitmap);
+	rcu_assign_pointer(callid_sock[sock->proto.pptp.src_addr.call_id], NULL);
+	spin_unlock(&chan_lock);
+	synchronize_rcu();
+}
+
+static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
+{
+	struct sock *sk = (struct sock *) chan->private;
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pptp_opt *opt = &po->proto.pptp;
+	struct pptp_gre_header *hdr;
+	unsigned int header_len = sizeof(*hdr);
+	int err = 0;
+	int islcp;
+	int len;
+	unsigned char *data;
+	__u32 seq_recv;
+
+
+	struct rtable *rt;
+	struct net_device *tdev;
+	struct iphdr  *iph;
+	int    max_headroom;
+
+	if (sk_pppox(po)->sk_state & PPPOX_DEAD)
+		goto tx_error;
+
+	{
+		struct flowi fl = { .oif = 0,
+			.nl_u = {
+				.ip4_u = {
+					.daddr = opt->dst_addr.sin_addr.s_addr,
+					.saddr = opt->src_addr.sin_addr.s_addr,
+					.tos = RT_TOS(0) } },
+			.proto = IPPROTO_GRE };
+		err = ip_route_output_key(&init_net, &rt, &fl);
+		if (err)
+			goto tx_error;
+	}
+	tdev = rt->u.dst.dev;
+
+	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(*iph) + sizeof(*hdr) + 2;
+
+	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
+		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
+		if (!new_skb) {
+			ip_rt_put(rt);
+			goto tx_error;
+		}
+		if (skb->sk)
+			skb_set_owner_w(new_skb, skb->sk);
+		kfree_skb(skb);
+		skb = new_skb;
+	}
+
+	data = skb->data;
+	islcp = ((data[0] << 8) + data[1]) == PPP_LCP && 1 <= data[2] && data[2] <= 7;
+
+	/* compress protocol field */
+	if ((opt->ppp_flags & SC_COMP_PROT) && data[0] == 0 && !islcp)
+		skb_pull(skb, 1);
+
+	/* Put in the address/control bytes if necessary */
+	if ((opt->ppp_flags & SC_COMP_AC) == 0 || islcp) {
+		data = skb_push(skb, 2);
+		data[0] = PPP_ALLSTATIONS;
+		data[1] = PPP_UI;
+	}
+
+	len = skb->len;
+
+	seq_recv = opt->seq_recv;
+
+	if (opt->ack_sent == seq_recv)
+		header_len -= sizeof(hdr->ack);
+
+	/* Push down and install GRE header */
+	skb_push(skb, header_len);
+	hdr = (struct pptp_gre_header *)(skb->data);
+
+	hdr->flags       = PPTP_GRE_FLAG_K;
+	hdr->ver         = PPTP_GRE_VER;
+	hdr->protocol    = htons(PPTP_GRE_PROTO);
+	hdr->call_id     = htons(opt->dst_addr.call_id);
+
+	hdr->flags      |= PPTP_GRE_FLAG_S;
+	hdr->seq         = htonl(++opt->seq_sent);
+	if (opt->ack_sent != seq_recv)	{
+		/* send ack with this message */
+		hdr->ver |= PPTP_GRE_FLAG_A;
+		hdr->ack  = htonl(seq_recv);
+		opt->ack_sent = seq_recv;
+	}
+	hdr->payload_len = htons(len);
+
+	/*	Push down and install the IP header. */
+
+	skb_reset_transport_header(skb);
+	skb_push(skb, sizeof(*iph));
+	skb_reset_network_header(skb);
+	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED | IPSKB_REROUTED);
+
+	iph =	ip_hdr(skb);
+	iph->version =	4;
+	iph->ihl =	sizeof(struct iphdr) >> 2;
+	if (ip_dont_fragment(sk, &rt->u.dst))
+		iph->frag_off	=	htons(IP_DF);
+	else
+		iph->frag_off	=	0;
+	iph->protocol = IPPROTO_GRE;
+	iph->tos      = 0;
+	iph->daddr    = rt->rt_dst;
+	iph->saddr    = rt->rt_src;
+	iph->ttl      = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
+	iph->tot_len  = htons(skb->len);
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->u.dst);
+
+	nf_reset(skb);
+
+	skb->ip_summed = CHECKSUM_NONE;
+	ip_select_ident(iph, &rt->u.dst, NULL);
+	ip_send_check(iph);
+
+	ip_local_out(skb);
+
+tx_error:
+	return 1;
+}
+
+static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
+{
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pptp_opt *opt = &po->proto.pptp;
+	int headersize, payload_len, seq;
+	__u8 *payload;
+	struct pptp_gre_header *header;
+
+	if (!(sk->sk_state & PPPOX_CONNECTED)) {
+		if (sock_queue_rcv_skb(sk, skb))
+			goto drop;
+		return NET_RX_SUCCESS;
+	}
+
+	header = (struct pptp_gre_header *)(skb->data);
+
+	/* test if acknowledgement present */
+	if (PPTP_GRE_IS_A(header->ver)) {
+		__u32 ack = (PPTP_GRE_IS_S(header->flags)) ?
+				header->ack : header->seq; /* ack in different place if S = 0 */
+
+		ack = ntohl(ack);
+
+		if (ack > opt->ack_recv)
+			opt->ack_recv = ack;
+		/* also handle sequence number wrap-around  */
+		if (WRAPPED(ack, opt->ack_recv))
+			opt->ack_recv = ack;
+	}
+
+	/* test if payload present */
+	if (!PPTP_GRE_IS_S(header->flags))
+		goto drop;
+
+	headersize  = sizeof(*header);
+	payload_len = ntohs(header->payload_len);
+	seq         = ntohl(header->seq);
+
+	/* no ack present? */
+	if (!PPTP_GRE_IS_A(header->ver))
+		headersize -= sizeof(header->ack);
+	/* check for incomplete packet (length smaller than expected) */
+	if (skb->len - headersize < payload_len)
+		goto drop;
+
+	payload = skb->data + headersize;
+	/* check for expected sequence number */
+	if (seq < opt->seq_recv + 1 || WRAPPED(opt->seq_recv, seq)) {
+		if ((payload[0] == PPP_ALLSTATIONS) && (payload[1] == PPP_UI) &&
+		     (PPP_PROTOCOL(payload) == PPP_LCP) &&
+		     ((payload[4] == PPP_LCP_ECHOREQ) || (payload[4] == PPP_LCP_ECHOREP)))
+			goto allow_packet;
+	} else {
+		opt->seq_recv = seq;
+allow_packet:
+		skb_pull(skb, headersize);
+
+		if (payload[0] == PPP_ALLSTATIONS && payload[1] == PPP_UI) {
+			/* chop off address/control */
+			if (skb->len < 3)
+				goto drop;
+			skb_pull(skb, 2);
+		}
+
+		if ((*skb->data) & 1) {
+			/* protocol is compressed */
+			skb_push(skb, 1)[0] = 0;
+		}
+
+		skb->ip_summed = CHECKSUM_NONE;
+		skb_set_network_header(skb, skb->head-skb->data);
+		ppp_input(&po->chan, skb);
+
+		return NET_RX_SUCCESS;
+	}
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static int pptp_rcv(struct sk_buff *skb)
+{
+	struct pppox_sock *po;
+	struct pptp_gre_header *header;
+	struct iphdr *iph;
+
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
+	if (!pskb_may_pull(skb, 12))
+		goto drop;
+
+	iph = ip_hdr(skb);
+
+	header = (struct pptp_gre_header *)skb->data;
+
+	if (ntohs(header->protocol) != PPTP_GRE_PROTO || /* PPTP-GRE protocol for PPTP */
+		PPTP_GRE_IS_C(header->flags) ||                /* flag C should be clear */
+		PPTP_GRE_IS_R(header->flags) ||                /* flag R should be clear */
+		(!PPTP_GRE_IS_K(header->flags)) ||             /* flag K should be set */
+		(header->flags&0xF) != 0)                      /* routing and recursion ctrl = 0 */
+		/* if invalid, discard this packet */
+		goto drop;
+
+	po = lookup_chan(htons(header->call_id), iph->saddr);
+	if (po) {
+		skb_dst_drop(skb);
+		skb_dst_set(skb, NULL);
+		nf_reset(skb);
+		return sk_receive_skb(sk_pppox(po), skb, 0);
+	}
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static int pptp_bind(struct socket *sock, struct sockaddr *uservaddr, int sockaddr_len)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pptp_opt *opt = &po->proto.pptp;
+	int error = 0;
+
+	lock_sock(sk);
+
+	opt->src_addr = sp->sa_addr.pptp;
+	if (add_chan(po)) {
+		release_sock(sk);
+		error = -EBUSY;
+	}
+
+	release_sock(sk);
+	return error;
+}
+
+static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
+		  int sockaddr_len, int flags)
+{
+	struct sock *sk = sock->sk;
+	struct sockaddr_pppox *sp = (struct sockaddr_pppox *) uservaddr;
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pptp_opt *opt = &po->proto.pptp;
+	struct rtable *rt;
+	int error = 0;
+
+	if (sp->sa_protocol != PX_PROTO_PPTP)
+		return -EINVAL;
+
+	if (lookup_chan_dst(sp->sa_addr.pptp.call_id, sp->sa_addr.pptp.sin_addr.s_addr))
+		return -EALREADY;
+
+	lock_sock(sk);
+	/* Check for already bound sockets */
+	if (sk->sk_state & PPPOX_CONNECTED) {
+		error = -EBUSY;
+		goto end;
+	}
+
+	/* Check for already disconnected sockets, on attempts to disconnect */
+	if (sk->sk_state & PPPOX_DEAD) {
+		error = -EALREADY;
+		goto end;
+	}
+
+	if (!opt->src_addr.sin_addr.s_addr || !sp->sa_addr.pptp.sin_addr.s_addr) {
+		error = -EINVAL;
+		goto end;
+	}
+
+	po->chan.private = sk;
+	po->chan.ops = &pptp_chan_ops;
+
+	{
+		struct flowi fl = {
+			.nl_u = {
+				.ip4_u = {
+					.daddr = opt->dst_addr.sin_addr.s_addr,
+					.saddr = opt->src_addr.sin_addr.s_addr,
+					.tos = RT_CONN_FLAGS(sk) } },
+			.proto = IPPROTO_GRE };
+		security_sk_classify_flow(sk, &fl);
+		if (ip_route_output_key(&init_net, &rt, &fl)) {
+			error = -EHOSTUNREACH;
+			goto end;
+		}
+		sk_setup_caps(sk, &rt->u.dst);
+	}
+	po->chan.mtu = dst_mtu(&rt->u.dst);
+	if (!po->chan.mtu)
+		po->chan.mtu = PPP_MTU;
+	ip_rt_put(rt);
+	po->chan.mtu -= PPTP_HEADER_OVERHEAD;
+
+	po->chan.hdrlen = 2 + sizeof(struct pptp_gre_header);
+	error = ppp_register_channel(&po->chan);
+	if (error) {
+		printk(KERN_ERR "PPTP: failed to register PPP channel (%d)\n", error);
+		goto end;
+	}
+
+	opt->dst_addr = sp->sa_addr.pptp;
+	sk->sk_state = PPPOX_CONNECTED;
+
+ end:
+	release_sock(sk);
+	return error;
+}
+
+static int pptp_getname(struct socket *sock, struct sockaddr *uaddr,
+		  int *usockaddr_len, int peer)
+{
+	int len = sizeof(struct sockaddr_pppox);
+	struct sockaddr_pppox sp;
+
+	sp.sa_family	  = AF_PPPOX;
+	sp.sa_protocol  = PX_PROTO_PPTP;
+	sp.sa_addr.pptp = pppox_sk(sock->sk)->proto.pptp.src_addr;
+
+	memcpy(uaddr, &sp, len);
+
+	*usockaddr_len = len;
+
+	return 0;
+}
+
+static int pptp_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+	struct pppox_sock *po;
+	struct pptp_opt *opt;
+	int error = 0;
+
+	if (!sk)
+		return 0;
+
+	lock_sock(sk);
+
+	if (sock_flag(sk, SOCK_DEAD)) {
+		release_sock(sk);
+		return -EBADF;
+	}
+
+	po = pppox_sk(sk);
+	opt = &po->proto.pptp;
+	del_chan(po);
+
+	pppox_unbind_sock(sk);
+	sk->sk_state = PPPOX_DEAD;
+
+	sock_orphan(sk);
+	sock->sk = NULL;
+
+	release_sock(sk);
+	sock_put(sk);
+
+	return error;
+}
+
+static void pptp_sock_destruct(struct sock *sk)
+{
+	if (!(sk->sk_state & PPPOX_DEAD)) {
+		del_chan(pppox_sk(sk));
+		pppox_unbind_sock(sk);
+	}
+	skb_queue_purge(&sk->sk_receive_queue);
+}
+
+static int pptp_create(struct net *net, struct socket *sock)
+{
+	int error = -ENOMEM;
+	struct sock *sk;
+	struct pppox_sock *po;
+	struct pptp_opt *opt;
+
+	sk = sk_alloc(net, PF_PPPOX, GFP_KERNEL, &pptp_sk_proto);
+	if (!sk)
+		goto out;
+
+	sock_init_data(sock, sk);
+
+	sock->state = SS_UNCONNECTED;
+	sock->ops   = &pptp_ops;
+
+	sk->sk_backlog_rcv = pptp_rcv_core;
+	sk->sk_state       = PPPOX_NONE;
+	sk->sk_type        = SOCK_STREAM;
+	sk->sk_family      = PF_PPPOX;
+	sk->sk_protocol    = PX_PROTO_PPTP;
+	sk->sk_destruct    = pptp_sock_destruct;
+
+	po = pppox_sk(sk);
+	opt = &po->proto.pptp;
+
+	opt->seq_sent = 0; opt->seq_recv = 0;
+	opt->ack_recv = 0; opt->ack_sent = 0;
+
+	error = 0;
+out:
+	return error;
+}
+
+static int pptp_ppp_ioctl(struct ppp_channel *chan, unsigned int cmd,
+			   unsigned long arg)
+{
+	struct sock *sk = (struct sock *) chan->private;
+	struct pppox_sock *po = pppox_sk(sk);
+	struct pptp_opt *opt = &po->proto.pptp;
+	void __user *argp = (void __user *)arg;
+	int __user *p = argp;
+	int err, val;
+
+	err = -EFAULT;
+	switch (cmd) {
+	case PPPIOCGFLAGS:
+		val = opt->ppp_flags;
+		if (put_user(val, p))
+			break;
+		err = 0;
+		break;
+	case PPPIOCSFLAGS:
+		if (get_user(val, p))
+			break;
+		opt->ppp_flags = val & ~SC_RCV_BITS;
+		err = 0;
+		break;
+	default:
+		err = -ENOTTY;
+	}
+
+	return err;
+}
+
+static struct ppp_channel_ops pptp_chan_ops = {
+	.start_xmit = pptp_xmit,
+	.ioctl      = pptp_ppp_ioctl,
+};
+
+static struct proto pptp_sk_proto __read_mostly = {
+	.name     = "PPTP",
+	.owner    = THIS_MODULE,
+	.obj_size = sizeof(struct pppox_sock),
+};
+
+static const struct proto_ops pptp_ops = {
+	.family     = AF_PPPOX,
+	.owner      = THIS_MODULE,
+	.release    = pptp_release,
+	.bind       = pptp_bind,
+	.connect    = pptp_connect,
+	.socketpair = sock_no_socketpair,
+	.accept     = sock_no_accept,
+	.getname    = pptp_getname,
+	.poll       = sock_no_poll,
+	.listen     = sock_no_listen,
+	.shutdown   = sock_no_shutdown,
+	.setsockopt = sock_no_setsockopt,
+	.getsockopt = sock_no_getsockopt,
+	.sendmsg    = sock_no_sendmsg,
+	.recvmsg    = sock_no_recvmsg,
+	.mmap       = sock_no_mmap,
+	.ioctl      = pppox_ioctl,
+};
+
+static struct pppox_proto pppox_pptp_proto = {
+	.create = pptp_create,
+	.owner  = THIS_MODULE,
+};
+
+static struct gre_protocol gre_pptp_protocol = {
+	.handler = pptp_rcv,
+};
+
+static int __init pptp_init_module(void)
+{
+	int err = 0;
+	printk(KERN_INFO "PPTP driver version " PPTP_DRIVER_VERSION "\n");
+
+	if (gre_add_protocol(&gre_pptp_protocol, GREPROTO_PPTP) < 0) {
+		printk(KERN_INFO "PPTP: can't add protocol\n");
+		goto out;
+	}
+
+	err = proto_register(&pptp_sk_proto, 0);
+	if (err) {
+		printk(KERN_INFO "PPTP: can't register sk_proto\n");
+		goto out_inet_del_protocol;
+	}
+
+	err = register_pppox_proto(PX_PROTO_PPTP, &pppox_pptp_proto);
+	if (err) {
+		printk(KERN_INFO "PPTP: can't register pppox_proto\n");
+		goto out_unregister_sk_proto;
+	}
+
+	callid_sock = (struct pppox_sock **)vmalloc((MAX_CALLID + 1) * sizeof(void *));
+	memset(callid_sock, 0, (MAX_CALLID + 1) * sizeof(void *));
+
+out:
+	return err;
+out_unregister_sk_proto:
+	proto_unregister(&pptp_sk_proto);
+out_inet_del_protocol:
+	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
+	return err;
+}
+
+static void __exit pptp_exit_module(void)
+{
+	unregister_pppox_proto(PX_PROTO_PPTP);
+	proto_unregister(&pptp_sk_proto);
+	gre_del_protocol(&gre_pptp_protocol, GREPROTO_PPTP);
+	vfree(callid_sock);
+}
+
+module_init(pptp_init_module);
+module_exit(pptp_exit_module);
+
+MODULE_DESCRIPTION("Point-to-Point Tunneling Protocol");
+MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
+MODULE_LICENSE("GPL");
+
diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index a6577af..9b0f883 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -40,26 +40,37 @@
  * PPPoE addressing definition 
  */ 
 typedef __be16 sid_t;
-struct pppoe_addr{ 
-       sid_t           sid;                    /* Session identifier */ 
-       unsigned char   remote[ETH_ALEN];       /* Remote address */ 
-       char            dev[IFNAMSIZ];          /* Local device to use */ 
+struct pppoe_addr {
+	sid_t         sid;                    /* Session identifier */
+	unsigned char remote[ETH_ALEN];       /* Remote address */
+	char          dev[IFNAMSIZ];          /* Local device to use */
 }; 
  
 /************************************************************************ 
- * Protocols supported by AF_PPPOX 
- */ 
+ * PPTP addressing definition
+ */
+struct pptp_addr {
+	u16             call_id;
+	struct in_addr  sin_addr;
+};
+
+/************************************************************************
+ * Protocols supported by AF_PPPOX
+ */
 #define PX_PROTO_OE    0 /* Currently just PPPoE */
 #define PX_PROTO_OL2TP 1 /* Now L2TP also */
-#define PX_MAX_PROTO   2
+#define PX_PROTO_PPTP  2
+#define PX_MAX_PROTO   3
 
-struct sockaddr_pppox { 
-       sa_family_t     sa_family;            /* address family, AF_PPPOX */ 
-       unsigned int    sa_protocol;          /* protocol identifier */ 
-       union{ 
-               struct pppoe_addr       pppoe; 
-       }sa_addr; 
-}__attribute__ ((packed)); 
+struct sockaddr_pppox {
+	sa_family_t     sa_family;            /* address family, AF_PPPOX */
+	unsigned int    sa_protocol;          /* protocol identifier */
+	union {
+		struct pppoe_addr  pppoe;
+		struct pptp_addr   pptp;
+	} sa_addr;
+} __attribute__ ((packed));
+/* hm ... why packed here ? */
 
 /* The use of the above union isn't viable because the size of this
  * struct must stay fixed over time -- applications use sizeof(struct
@@ -70,7 +81,7 @@ struct sockaddr_pppol2tp {
 	sa_family_t     sa_family;      /* address family, AF_PPPOX */
 	unsigned int    sa_protocol;    /* protocol identifier */
 	struct pppol2tp_addr pppol2tp;
-}__attribute__ ((packed));
+} __attribute__ ((packed));
 
 /* The L2TPv3 protocol changes tunnel and session ids from 16 to 32
  * bits. So we need a different sockaddr structure.
@@ -150,15 +161,23 @@ struct pppoe_opt {
 					     relayed to (PPPoE relaying) */
 };
 
+struct pptp_opt {
+	struct pptp_addr src_addr;
+	struct pptp_addr dst_addr;
+	u32 ack_sent, ack_recv;
+	u32 seq_sent, seq_recv;
+	int ppp_flags;
+};
 #include <net/sock.h>
 
 struct pppox_sock {
 	/* struct sock must be the first member of pppox_sock */
-	struct sock		sk;
-	struct ppp_channel	chan;
+	struct sock sk;
+	struct ppp_channel chan;
 	struct pppox_sock	*next;	  /* for hash table */
 	union {
 		struct pppoe_opt pppoe;
+		struct pptp_opt  pptp;
 	} proto;
 	__be16			num;
 };
diff --git a/include/net/gre.h b/include/net/gre.h
new file mode 100644
index 0000000..8266547
--- /dev/null
+++ b/include/net/gre.h
@@ -0,0 +1,18 @@
+#ifndef __LINUX_GRE_H
+#define __LINUX_GRE_H
+
+#include <linux/skbuff.h>
+
+#define GREPROTO_CISCO		0
+#define GREPROTO_PPTP		1
+#define GREPROTO_MAX		2
+
+struct gre_protocol {
+	int  (*handler)(struct sk_buff *skb);
+	void (*err_handler)(struct sk_buff *skb, u32 info);
+};
+
+int gre_add_protocol(const struct gre_protocol *proto, u8 version);
+int gre_del_protocol(const struct gre_protocol *proto, u8 version);
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7c3a7d1..7458bda 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -215,8 +215,15 @@ config NET_IPIP
 	  be inserted in and removed from the running kernel whenever you
 	  want). Most people won't need this and can say N.
 
+config NET_IPGRE_DEMUX
+	tristate "IP: GRE demultiplexer"
+	help
+	 This is helper module to demultiplex GRE packets on GRE version field criteria.
+	 Required by ip_gre and pptp modules.
+
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
+	depends on NET_IPGRE_DEMUX
 	help
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 80ff87c..4978d22 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
+obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
 obj-$(CONFIG_INET_AH) += ah4.o
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
new file mode 100644
index 0000000..472c178
--- /dev/null
+++ b/net/ipv4/gre.c
@@ -0,0 +1,151 @@
+/*
+ *	GRE over IPv4 demultiplexer driver
+ *
+ *	Authors: Dmitry Kozlov (xeb@mail.ru)
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/skbuff.h>
+#include <linux/in.h>
+#include <linux/netdevice.h>
+#include <linux/version.h>
+#include <linux/spinlock.h>
+#include <net/protocol.h>
+#include <net/gre.h>
+
+
+const struct gre_protocol *gre_proto[GREPROTO_MAX] __read_mostly;
+static DEFINE_SPINLOCK(gre_proto_lock);
+
+int gre_add_protocol(const struct gre_protocol *proto, u8 version)
+{
+	if (version >= GREPROTO_MAX)
+		goto err_out;
+
+	spin_lock(&gre_proto_lock);
+	if (gre_proto[version])
+		goto err_out_unlock;
+
+	rcu_assign_pointer(gre_proto[version], proto);
+	spin_unlock(&gre_proto_lock);
+	return 0;
+
+err_out_unlock:
+	spin_unlock(&gre_proto_lock);
+err_out:
+	return -1;
+}
+EXPORT_SYMBOL_GPL(gre_add_protocol);
+
+int gre_del_protocol(const struct gre_protocol *proto, u8 version)
+{
+	if (version >= GREPROTO_MAX)
+		goto err_out;
+
+	spin_lock(&gre_proto_lock);
+	if (gre_proto[version] != proto)
+		goto err_out_unlock;
+	rcu_assign_pointer(gre_proto[version], NULL);
+	spin_unlock(&gre_proto_lock);
+	synchronize_rcu();
+	return 0;
+
+err_out_unlock:
+	spin_unlock(&gre_proto_lock);
+err_out:
+	return -1;
+}
+EXPORT_SYMBOL_GPL(gre_del_protocol);
+
+static int gre_rcv(struct sk_buff *skb)
+{
+	const struct gre_protocol *proto;
+	u8 ver;
+	int ret;
+
+	if (!pskb_may_pull(skb, 12))
+		goto drop;
+
+	ver = skb->data[1]&0x7f;
+	if (ver >= GREPROTO_MAX)
+		goto drop;
+
+	rcu_read_lock();
+	proto = rcu_dereference(gre_proto[ver]);
+	if (!proto || !proto->handler)
+		goto drop_unlock;
+	ret = proto->handler(skb);
+	rcu_read_unlock();
+	return ret;
+
+drop_unlock:
+	rcu_read_unlock();
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static void gre_err(struct sk_buff *skb, u32 info)
+{
+	const struct gre_protocol *proto;
+	u8 ver;
+
+	if (!pskb_may_pull(skb, 12))
+		goto drop;
+
+	ver = skb->data[1]&0x7f;
+	if (ver >= GREPROTO_MAX)
+		goto drop;
+
+	rcu_read_lock();
+	proto = rcu_dereference(gre_proto[ver]);
+	if (!proto || !proto->err_handler)
+		goto drop_unlock;
+	proto->err_handler(skb, info);
+	rcu_read_unlock();
+	return;
+
+drop_unlock:
+	rcu_read_unlock();
+drop:
+	kfree_skb(skb);
+}
+
+static const struct net_protocol net_gre_protocol = {
+	.handler     = gre_rcv,
+	.err_handler = gre_err,
+	.netns_ok    = 1,
+};
+
+static int __init gre_init(void)
+{
+	printk(KERN_INFO "GRE over IPv4 demultiplexor driver");
+
+	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
+		printk(KERN_INFO "gre: can't add protocol\n");
+		return -EAGAIN;
+	}
+
+	return 0;
+}
+
+static void __exit gre_exit(void)
+{
+	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+}
+
+module_init(gre_init);
+module_exit(gre_exit);
+
+MODULE_DESCRIPTION("GRE over IPv4 demultiplexer driver");
+MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
+MODULE_LICENSE("GPL");
+
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 32618e1..5a01d86 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -44,6 +44,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/gre.h>
 
 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -1276,10 +1277,9 @@ static void ipgre_fb_tunnel_init(struct net_device *dev)
 }
 
 
-static const struct net_protocol ipgre_protocol = {
-	.handler	=	ipgre_rcv,
-	.err_handler	=	ipgre_err,
-	.netns_ok	=	1,
+static const struct gre_protocol ipgre_protocol = {
+	.handler     = ipgre_rcv,
+	.err_handler = ipgre_err,
 };
 
 static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
@@ -1661,7 +1661,7 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
-	err = inet_add_protocol(&ipgre_protocol, IPPROTO_GRE);
+	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	if (err < 0) {
 		printk(KERN_INFO "ipgre init: can't add protocol\n");
 		goto add_proto_failed;
@@ -1681,7 +1681,7 @@ out:
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	inet_del_protocol(&ipgre_protocol, IPPROTO_GRE);
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 add_proto_failed:
 	unregister_pernet_device(&ipgre_net_ops);
 	goto out;
@@ -1691,7 +1691,7 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
-	if (inet_del_protocol(&ipgre_protocol, IPPROTO_GRE) < 0)
+	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
 		printk(KERN_INFO "ipgre close: can't remove protocol\n");
 	unregister_pernet_device(&ipgre_net_ops);
 }
