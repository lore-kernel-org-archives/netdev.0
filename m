From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: CLOCK_MONOTONIC datagram timestamps by the kernel
Date: Thu, 1 Mar 2007 12:30:50 +0100
Message-ID: <200703011230.50596.dada1@cosmosbay.com>
References: <45E5570E.7050301@free.fr> <200702281555.10309.dada1@cosmosbay.com> <45E5A8AE.3030606@free.fr>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_qlr5FDqyV0ypBpR"
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: John find <linux.kernel@free.fr>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <45E5A8AE.3030606@free.fr>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_qlr5FDqyV0ypBpR
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 28 February 2007 17:07, John wrote:

>
> Consider an idle Linux 2.6.20-rt8 system, equipped with a single PCI-E
> gigabit Ethernet NIC, running on a modern CPU (e.g. Core 2 Duo E6700).
> All this system does is time stamp 1000 packets per second.
>
> Are you claiming that this platform *cannot* handle most packets within
> less than 1 microsecond of their arrival?

Yes I claim it.

You expect too much of this platform, unless "most" means 10 % for 
you ;)

If you replace "1 us" by "50 us", then yes, it probably can do it, if "most" 
means 99%, (not 99.999 %)

Anyway, if you want to play, you can apply this patch on top of 
linux-2.6.21-rc2  (nanosecond resolution infrastruture needs 2.6.21)
I let you do the adjustments for rt kernel.

I compiled it on my i386 machine, and tested it with a patched libpcap/tcpdump

[PATCH] NET : introduce nanosecond time infrastructure and SIOCGSTAMPNS

It appears some machines are *really* fast and that micro second resolution is 
a limiting factor.

This patch converts sk_buff timestamp to use new nanosecond infra (added in 
2.6.21), and introduces a new ioctl SIOCGSTAMPNS to let applications access 
nanosecond resolution (ie a timespec instead of timeval)


Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 fs/compat_ioctl.c                       |   17 ++++++++
 include/asm-alpha/sockios.h             |    1 
 include/asm-arm26/sockios.h             |    3 +
 include/asm-avr32/sockios.h             |    3 +
 include/asm-cris/sockios.h              |    3 +
 include/asm-frv/sockios.h               |    3 +
 include/asm-h8300/sockios.h             |    3 +
 include/asm-i386/sockios.h              |    3 +
 include/asm-ia64/sockios.h              |    3 +
 include/asm-m32r/sockios.h              |    3 +
 include/asm-m68k/sockios.h              |    3 +
 include/asm-mips/sockios.h              |    3 +
 include/asm-parisc/sockios.h            |    3 +
 include/asm-powerpc/sockios.h           |    3 +
 include/asm-s390/sockios.h              |    3 +
 include/asm-sh/sockios.h                |    1 
 include/asm-sh64/sockios.h              |    1 
 include/asm-sparc/sockios.h             |    3 +
 include/asm-sparc64/sockios.h           |    3 +
 include/asm-v850/sockios.h              |    3 +
 include/asm-x86_64/sockios.h            |    3 +
 include/asm-xtensa/sockios.h            |    3 +
 include/linux/skbuff.h                  |   42 +++++++++++++++-------
 include/net/compat.h                    |    1 
 include/net/sock.h                      |   16 +++++---
 net/appletalk/ddp.c                     |    3 +
 net/atm/ioctl.c                         |    3 +
 net/ax25/af_ax25.c                      |    4 ++
 net/bridge/netfilter/ebt_ulog.c         |    2 -
 net/compat.c                            |   31 +++++++++++++---
 net/core/dev.c                          |   14 +++----
 net/core/skbuff.c                       |    4 +-
 net/core/sock.c                         |   28 +++++++++++---
 net/econet/af_econet.c                  |    4 +-
 net/ipv4/af_inet.c                      |    3 +
 net/ipv4/ip_fragment.c                  |    6 +--
 net/ipv4/tcp_output.c                   |    2 -
 net/ipv6/af_inet6.c                     |    3 +
 net/ipv6/netfilter/nf_conntrack_reasm.c |    6 +--
 net/ipv6/reassembly.c                   |    6 +--
 net/ipx/af_ipx.c                        |    2 -
 net/netrom/af_netrom.c                  |    5 ++
 net/packet/af_packet.c                  |    8 ++--
 net/rose/af_rose.c                      |    2 +
 net/sunrpc/svcsock.c                    |    9 ++--
 net/wanrouter/af_wanpipe.c              |    3 +
 net/x25/af_x25.c                        |   12 ++++++
 47 files changed, 216 insertions(+), 77 deletions(-)


--Boundary-00=_qlr5FDqyV0ypBpR
Content-Type: text/plain;
  charset="iso-8859-1";
  name="net_nanosec_stamp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="net_nanosec_stamp.patch"

--- linux-2.6.21-rc2/include/linux/skbuff.h	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/linux/skbuff.h	2007-03-01 13:15:07.000000000 +0100
@@ -156,9 +156,13 @@ struct skb_shared_info {
 #define SKB_DATAREF_SHIFT 16
 #define SKB_DATAREF_MASK ((1 << SKB_DATAREF_SHIFT) - 1)
 
-struct skb_timeval {
+/*
+ * We use a special timespec like structure, because ABI constraints 
+ * make 'struct timespec' being 16 bytes on 64bit platforms.
+ */
+struct skb_timespec {
 	u32	off_sec;
-	u32	off_usec;
+	u32	off_nsec;
 };
 
 
@@ -186,7 +190,7 @@ enum {
  *	@next: Next buffer in list
  *	@prev: Previous buffer in list
  *	@sk: Socket we are owned by
- *	@tstamp: Time we arrived
+ *	@tstampns: Time we arrived
  *	@dev: Device we arrived on/are leaving by
  *	@input_dev: Device we arrived on
  *	@h: Transport layer header
@@ -233,7 +237,7 @@ struct sk_buff {
 	struct sk_buff		*prev;
 
 	struct sock		*sk;
-	struct skb_timeval	tstamp;
+	struct skb_timespec	tstampns;
 	struct net_device	*dev;
 	struct net_device	*input_dev;
 
@@ -1350,6 +1354,20 @@ extern void skb_init(void);
 extern void skb_add_mtu(int mtu);
 
 /**
+ *	skb_get_timestampns - get timestamp from a skb
+ *	@skb: skb to get stamp from
+ *	@stampns: pointer to struct timespec to store stamp in
+ *
+ *	Timestamps are stored in the skb as offsets to a base timestamp.
+ *	This function converts the offset back to a struct timespec and stores
+ *	it in stamp.
+ */
+static inline void skb_get_timestampns(const struct sk_buff *skb, struct timespec *stampns)
+{
+	stampns->tv_sec  = skb->tstampns.off_sec;
+	stampns->tv_nsec = skb->tstampns.off_nsec;
+}
+/**
  *	skb_get_timestamp - get timestamp from a skb
  *	@skb: skb to get stamp from
  *	@stamp: pointer to struct timeval to store stamp in
@@ -1360,23 +1378,23 @@ extern void skb_add_mtu(int mtu);
  */
 static inline void skb_get_timestamp(const struct sk_buff *skb, struct timeval *stamp)
 {
-	stamp->tv_sec  = skb->tstamp.off_sec;
-	stamp->tv_usec = skb->tstamp.off_usec;
+	stamp->tv_sec  = skb->tstampns.off_sec;
+	stamp->tv_usec = skb->tstampns.off_nsec/1000;
 }
 
 /**
- * 	skb_set_timestamp - set timestamp of a skb
+ * 	skb_set_timestampns - set timestamp of a skb
  *	@skb: skb to set stamp of
- *	@stamp: pointer to struct timeval to get stamp from
+ *	@stamp: pointer to struct timespec to get stamp from
  *
  *	Timestamps are stored in the skb as offsets to a base timestamp.
- *	This function converts a struct timeval to an offset and stores
+ *	This function converts a struct timespec to an offset and stores
  *	it in the skb.
  */
-static inline void skb_set_timestamp(struct sk_buff *skb, const struct timeval *stamp)
+static inline void skb_set_timestampns(struct sk_buff *skb, const struct timespec *stampns)
 {
-	skb->tstamp.off_sec  = stamp->tv_sec;
-	skb->tstamp.off_usec = stamp->tv_usec;
+	skb->tstampns.off_sec  = stampns->tv_sec;
+	skb->tstampns.off_nsec = stampns->tv_nsec;
 }
 
 extern void __net_timestamp(struct sk_buff *skb);
--- linux-2.6.21-rc2/include/net/sock.h	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/net/sock.h	2007-03-01 11:37:34.000000000 +0100
@@ -244,7 +244,7 @@ struct sock {
 	struct sk_filter      	*sk_filter;
 	void			*sk_protinfo;
 	struct timer_list	sk_timer;
-	struct timeval		sk_stamp;
+	struct timespec		sk_stampns;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct page		*sk_sndmsg_page;
@@ -1307,19 +1307,22 @@ static inline int sock_intr_errno(long t
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
+	struct timespec stampns;
 	struct timeval stamp;
 
-	skb_get_timestamp(skb, &stamp);
+	skb_get_timestampns(skb, &stampns);
 	if (sock_flag(sk, SOCK_RCVTSTAMP)) {
 		/* Race occurred between timestamp enabling and packet
 		   receiving.  Fill in the current time for now. */
-		if (stamp.tv_sec == 0)
-			do_gettimeofday(&stamp);
-		skb_set_timestamp(skb, &stamp);
+		if (stampns.tv_sec == 0)
+			getnstimeofday(&stampns);
+		skb_set_timestampns(skb, &stampns);
+		stamp.tv_sec = stampns.tv_sec;
+		stamp.tv_usec = stampns.tv_nsec/1000;
 		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(struct timeval),
 			 &stamp);
 	} else
-		sk->sk_stamp = stamp;
+		sk->sk_stampns = stampns;
 }
 
 /**
@@ -1350,6 +1353,7 @@ static inline void sk_eat_skb(struct soc
 
 extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
+extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
 /* 
  *	Enable debug/info messages 
--- linux-2.6.21-rc2/include/net/compat.h	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/net/compat.h	2007-02-28 20:54:35.000000000 +0100
@@ -25,6 +25,7 @@ struct compat_cmsghdr {
 };
 
 extern int compat_sock_get_timestamp(struct sock *, struct timeval __user *);
+extern int compat_sock_get_timestampns(struct sock *, struct timespec __user *);
 
 #else /* defined(CONFIG_COMPAT) */
 #define compat_msghdr	msghdr		/* to avoid compiler warnings */
--- linux-2.6.21-rc2/net/core/sock.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/core/sock.c	2007-02-28 21:16:43.000000000 +0100
@@ -1512,8 +1512,8 @@ void sock_init_data(struct socket *sock,
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
-	sk->sk_stamp.tv_sec     = -1L;
-	sk->sk_stamp.tv_usec    = -1L;
+	sk->sk_stampns.tv_sec     = -1L;
+	sk->sk_stampns.tv_nsec    = -1L;
 
 	atomic_set(&sk->sk_refcnt, 1);
 }
@@ -1554,17 +1554,33 @@ EXPORT_SYMBOL(release_sock);
 
 int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
+	struct timeval tstamp;
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
 		sock_enable_timestamp(sk);
-	if (sk->sk_stamp.tv_sec == -1)
+	if (sk->sk_stampns.tv_sec == -1)
 		return -ENOENT;
-	if (sk->sk_stamp.tv_sec == 0)
-		do_gettimeofday(&sk->sk_stamp);
-	return copy_to_user(userstamp, &sk->sk_stamp, sizeof(struct timeval)) ?
+	if (sk->sk_stampns.tv_sec == 0)
+		getnstimeofday(&sk->sk_stampns);
+	tstamp.tv_sec = sk->sk_stampns.tv_sec;
+	tstamp.tv_usec = sk->sk_stampns.tv_nsec/1000;
+	return copy_to_user(userstamp, &tstamp, sizeof(struct timeval)) ?
 		-EFAULT : 0;
 }
 EXPORT_SYMBOL(sock_get_timestamp);
 
+int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
+{
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	if (sk->sk_stampns.tv_sec == -1)
+		return -ENOENT;
+	if (sk->sk_stampns.tv_sec == 0)
+		getnstimeofday(&sk->sk_stampns);
+	return copy_to_user(userstamp, &sk->sk_stampns, sizeof(struct timespec)) ?
+		-EFAULT : 0;
+}
+EXPORT_SYMBOL(sock_get_timestampns);
+
 void sock_enable_timestamp(struct sock *sk)
 {
 	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
--- linux-2.6.21-rc2/net/core/dev.c	2007-02-28 21:16:43.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/core/dev.c	2007-03-01 11:43:38.000000000 +0100
@@ -1036,10 +1036,10 @@ void net_disable_timestamp(void)
 
 void __net_timestamp(struct sk_buff *skb)
 {
-	struct timeval tv;
+	struct timespec ts;
 
-	do_gettimeofday(&tv);
-	skb_set_timestamp(skb, &tv);
+	getnstimeofday(&ts);
+	skb_set_timestampns(skb, &ts);
 }
 EXPORT_SYMBOL(__net_timestamp);
 
@@ -1048,8 +1048,8 @@ static inline void net_timestamp(struct 
 	if (atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
 	else {
-		skb->tstamp.off_sec = 0;
-		skb->tstamp.off_usec = 0;
+		skb->tstampns.off_sec = 0;
+		skb->tstampns.off_nsec = 0;
 	}
 }
 
@@ -1580,7 +1580,7 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.off_sec)
+	if (!skb->tstampns.off_sec)
 		net_timestamp(skb);
 
 	/*
@@ -1772,7 +1772,7 @@ int netif_receive_skb(struct sk_buff *sk
 	if (skb->dev->poll && netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.off_sec)
+	if (!skb->tstampns.off_sec)
 		net_timestamp(skb);
 
 	if (!skb->input_dev)
--- linux-2.6.21-rc2/net/core/skbuff.c	2007-03-01 11:41:01.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/core/skbuff.c	2007-03-01 11:41:25.000000000 +0100
@@ -449,7 +449,7 @@ struct sk_buff *skb_clone(struct sk_buff
 
 	n->next = n->prev = NULL;
 	n->sk = NULL;
-	C(tstamp);
+	C(tstampns);
 	C(dev);
 	C(h);
 	C(nh);
@@ -534,7 +534,7 @@ static void copy_skb_header(struct sk_bu
 	new->local_df	= old->local_df;
 	new->fclone	= SKB_FCLONE_UNAVAILABLE;
 	new->pkt_type	= old->pkt_type;
-	new->tstamp	= old->tstamp;
+	new->tstampns	= old->tstampns;
 	new->destructor = NULL;
 	new->mark	= old->mark;
 #ifdef CONFIG_NETFILTER
--- linux-2.6.21-rc2/net/ipv4/ip_fragment.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv4/ip_fragment.c	2007-03-01 11:45:09.000000000 +0100
@@ -92,7 +92,7 @@ struct ipq {
 	spinlock_t	lock;
 	atomic_t	refcnt;
 	struct timer_list timer;	/* when will this queue expire?		*/
-	struct timeval	stamp;
+	struct timespec	stampns;
 	int             iif;
 	unsigned int    rid;
 	struct inet_peer *peer;
@@ -592,7 +592,7 @@ static void ip_frag_queue(struct ipq *qp
 	if (skb->dev)
 		qp->iif = skb->dev->ifindex;
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &qp->stamp);
+	skb_get_timestampns(skb, &qp->stampns);
 	qp->meat += skb->len;
 	atomic_add(skb->truesize, &ip_frag_mem);
 	if (offset == 0)
@@ -674,7 +674,7 @@ static struct sk_buff *ip_frag_reasm(str
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &qp->stamp);
+	skb_set_timestampns(head, &qp->stampns);
 
 	iph = head->nh.iph;
 	iph->frag_off = 0;
--- linux-2.6.21-rc2/net/ipv4/af_inet.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv4/af_inet.c	2007-02-28 20:54:35.000000000 +0100
@@ -755,6 +755,9 @@ int inet_ioctl(struct socket *sock, unsi
 		case SIOCGSTAMP:
 			err = sock_get_timestamp(sk, (struct timeval __user *)arg);
 			break;
+		case SIOCGSTAMPNS:
+			err = sock_get_timestampns(sk, (struct timespec __user *)arg);
+			break;
 		case SIOCADDRT:
 		case SIOCDELRT:
 		case SIOCRTMSG:
--- linux-2.6.21-rc2/net/ipv4/tcp_output.c	2007-03-01 11:45:09.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv4/tcp_output.c	2007-03-01 11:45:09.000000000 +0100
@@ -661,7 +661,7 @@ int tcp_fragment(struct sock *sk, struct
 	 * skbs, which it never sent before. --ANK
 	 */
 	TCP_SKB_CB(buff)->when = TCP_SKB_CB(skb)->when;
-	buff->tstamp = skb->tstamp;
+	buff->tstampns = skb->tstampns;
 
 	old_factor = tcp_skb_pcount(skb);
 
--- linux-2.6.21-rc2/net/ipv6/af_inet6.c	2007-03-01 12:34:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv6/af_inet6.c	2007-03-01 12:34:35.000000000 +0100
@@ -437,6 +437,9 @@ int inet6_ioctl(struct socket *sock, uns
 	case SIOCGSTAMP:
 		return sock_get_timestamp(sk, (struct timeval __user *)arg);
 
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *)arg);
+
 	case SIOCADDRT:
 	case SIOCDELRT:
 
--- linux-2.6.21-rc2/net/packet/af_packet.c	2007-02-28 21:23:12.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/packet/af_packet.c	2007-03-01 12:32:56.000000000 +0100
@@ -656,12 +656,12 @@ static int tpacket_rcv(struct sk_buff *s
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
-	if (skb->tstamp.off_sec == 0) {
+	if (skb->tstampns.off_sec == 0) {
 		__net_timestamp(skb);
 		sock_enable_timestamp(sk);
 	}
-	h->tp_sec = skb->tstamp.off_sec;
-	h->tp_usec = skb->tstamp.off_usec;
+	h->tp_sec = skb->tstampns.off_sec;
+	h->tp_usec = skb->tstampns.off_nsec/1000;
 
 	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
 	sll->sll_halen = 0;
@@ -1543,6 +1543,8 @@ static int packet_ioctl(struct socket *s
 		}
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, (struct timeval __user *)arg);
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, (struct timespec __user *)arg);
 
 #ifdef CONFIG_INET
 		case SIOCADDRT:
--- linux-2.6.21-rc2/net/sunrpc/svcsock.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/sunrpc/svcsock.c	2007-03-01 13:15:07.000000000 +0100
@@ -806,15 +806,14 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
 	if (skb->tstamp.off_sec == 0) {
-		struct timeval tv;
+		struct timespec ts;
 
-		tv.tv_sec = xtime.tv_sec;
-		tv.tv_usec = xtime.tv_nsec / NSEC_PER_USEC;
-		skb_set_timestamp(skb, &tv);
+		ts = current_kernel_time();
+		skb_set_timestampns(skb, &ts);
 		/* Don't enable netstamp, sunrpc doesn't
 		   need that much accuracy */
 	}
-	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
+	skb_get_timestampns(skb, &svsk->sk_sk->sk_stampns);
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
 	/*
--- linux-2.6.21-rc2/net/compat.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/compat.c	2007-03-01 12:56:02.000000000 +0100
@@ -545,20 +545,41 @@ int compat_sock_get_timestamp(struct soc
 	struct compat_timeval __user *ctv =
 			(struct compat_timeval __user*) userstamp;
 	int err = -ENOENT;
+	long usec;
 
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
 		sock_enable_timestamp(sk);
-	if (sk->sk_stamp.tv_sec == -1)
+	if (sk->sk_stampns.tv_sec == -1)
 		return err;
-	if (sk->sk_stamp.tv_sec == 0)
-		do_gettimeofday(&sk->sk_stamp);
-	if (put_user(sk->sk_stamp.tv_sec, &ctv->tv_sec) ||
-			put_user(sk->sk_stamp.tv_usec, &ctv->tv_usec))
+	if (sk->sk_stampns.tv_sec == 0)
+		getnstimeofday(&sk->sk_stampns);
+	usec = sk->sk_stampns.tv_nsec / 1000;
+	if (put_user(sk->sk_stampns.tv_sec, &ctv->tv_sec) ||
+			put_user(usec, &ctv->tv_usec))
 		err = -EFAULT;
 	return err;
 }
 EXPORT_SYMBOL(compat_sock_get_timestamp);
 
+int compat_sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
+{
+	struct compat_timespec __user *ctv =
+			(struct compat_timespec __user*) userstamp;
+	int err = -ENOENT;
+
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	if (sk->sk_stampns.tv_sec == -1)
+		return err;
+	if (sk->sk_stampns.tv_sec == 0)
+		getnstimeofday(&sk->sk_stampns);
+	if (put_user(sk->sk_stampns.tv_sec, &ctv->tv_sec) ||
+			put_user(sk->sk_stampns.tv_nsec, &ctv->tv_nsec))
+		err = -EFAULT;
+	return err;
+}
+EXPORT_SYMBOL(compat_sock_get_timestampns);
+
 asmlinkage long compat_sys_getsockopt(int fd, int level, int optname,
 				char __user *optval, int __user *optlen)
 {
--- linux-2.6.21-rc2/fs/compat_ioctl.c	2007-03-01 13:01:27.000000000 +0100
+++ linux-2.6.21-rc2-ed/fs/compat_ioctl.c	2007-03-01 13:01:27.000000000 +0100
@@ -265,6 +265,22 @@ static int do_siocgstamp(unsigned int fd
 	}
 	return err;
 }
+static int do_siocgstampns(unsigned int fd, unsigned int cmd, unsigned long arg)
+{
+	struct compat_timespec __user *up = compat_ptr(arg);
+	struct timespec ktv;
+	mm_segment_t old_fs = get_fs();
+	int err;
+
+	set_fs(KERNEL_DS);
+	err = sys_ioctl(fd, cmd, (unsigned long)&ktv);
+	set_fs(old_fs);
+	if(!err) {
+		err = put_user(ktv.tv_sec, &up->tv_sec);
+		err |= __put_user(ktv.tv_nsec, &up->tv_nsec);
+	}
+	return err;
+}
 
 struct ifmap32 {
 	compat_ulong_t mem_start;
@@ -2437,6 +2453,7 @@ HANDLE_IOCTL(SIOCBRDELIF, dev_ifsioc)
 /* Note SIOCRTMSG is no longer, so this is safe and * the user would have seen just an -EINVAL anyways. */
 HANDLE_IOCTL(SIOCRTMSG, ret_einval)
 HANDLE_IOCTL(SIOCGSTAMP, do_siocgstamp)
+HANDLE_IOCTL(SIOCGSTAMPNS, do_siocgstampns)
 #endif
 #ifdef CONFIG_BLOCK
 HANDLE_IOCTL(HDIO_GETGEO, hdio_getgeo)
--- linux-2.6.21-rc2/net/appletalk/ddp.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/appletalk/ddp.c	2007-03-01 12:56:02.000000000 +0100
@@ -1768,6 +1768,9 @@ static int atalk_ioctl(struct socket *so
 		case SIOCGSTAMP:
 			rc = sock_get_timestamp(sk, argp);
 			break;
+		case SIOCGSTAMPNS:
+			rc = sock_get_timestampns(sk, argp);
+			break;
 		/* Routing */
 		case SIOCADDRT:
 		case SIOCDELRT:
--- linux-2.6.21-rc2/net/ax25/af_ax25.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ax25/af_ax25.c	2007-03-01 12:56:02.000000000 +0100
@@ -1711,6 +1711,10 @@ static int ax25_ioctl(struct socket *soc
 		res = sock_get_timestamp(sk, argp);
 		break;
 
+	case SIOCGSTAMPNS:
+		res = sock_get_timestampns(sk, argp);
+		break;
+
 	case SIOCAX25ADDUID:	/* Add a uid to the uid/call map table */
 	case SIOCAX25DELUID:	/* Delete a uid from the uid/call map table */
 	case SIOCAX25GETUID: {
--- linux-2.6.21-rc2/net/atm/ioctl.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/atm/ioctl.c	2007-03-01 12:56:02.000000000 +0100
@@ -82,6 +82,9 @@ int vcc_ioctl(struct socket *sock, unsig
 		case SIOCGSTAMP: /* borrowed from IP */
 			error = sock_get_timestamp(sk, argp);
 			goto done;
+		case SIOCGSTAMPNS: /* borrowed from IP */
+			error = sock_get_timestampns(sk, argp);
+			goto done;
 		case ATM_SETSC:
 			printk(KERN_WARNING "ATM_SETSC is obsolete\n");
 			error = 0;
--- linux-2.6.21-rc2/net/econet/af_econet.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/econet/af_econet.c	2007-03-01 12:56:02.000000000 +0100
@@ -162,7 +162,7 @@ static int econet_recvmsg(struct kiocb *
 	err = memcpy_toiovec(msg->msg_iov, skb->data, copied);
 	if (err)
 		goto out_free;
-	skb_get_timestamp(skb, &sk->sk_stamp);
+	skb_get_timestampns(skb, &sk->sk_stampns);
 
 	if (msg->msg_name)
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
@@ -726,6 +726,8 @@ static int econet_ioctl(struct socket *s
 	switch(cmd) {
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, argp);
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, argp);
 
 		case SIOCSIFADDR:
 		case SIOCGIFADDR:
--- linux-2.6.21-rc2/net/ipx/af_ipx.c	2007-02-28 20:54:35.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipx/af_ipx.c	2007-03-01 11:34:07.000000000 +0100
@@ -1808,7 +1808,7 @@ static int ipx_recvmsg(struct kiocb *ioc
 	if (rc)
 		goto out_free;
 	if (skb->tstamp.off_sec)
-		skb_get_timestamp(skb, &sk->sk_stamp);
+		skb_get_timestampns(skb, &sk->sk_stampns);
 
 	msg->msg_namelen = sizeof(*sipx);
 
--- linux-2.6.21-rc2/net/netrom/af_netrom.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/netrom/af_netrom.c	2007-03-01 12:56:02.000000000 +0100
@@ -1208,6 +1208,11 @@ static int nr_ioctl(struct socket *sock,
 		ret = sock_get_timestamp(sk, argp);
 		release_sock(sk);
 		return ret;
+	case SIOCGSTAMPNS:
+		lock_sock(sk);
+		ret = sock_get_timestampns(sk, argp);
+		release_sock(sk);
+		return ret;
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
--- linux-2.6.21-rc2/net/rose/af_rose.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/rose/af_rose.c	2007-03-01 12:56:02.000000000 +0100
@@ -1271,6 +1271,8 @@ static int rose_ioctl(struct socket *soc
 
 	case SIOCGSTAMP:
 		return sock_get_timestamp(sk, (struct timeval __user *) argp);
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *) argp);
 
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
--- linux-2.6.21-rc2/net/wanrouter/af_wanpipe.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/wanrouter/af_wanpipe.c	2007-03-01 12:56:02.000000000 +0100
@@ -1770,6 +1770,9 @@ static int wanpipe_ioctl(struct socket *
 		case SIOCGSTAMP:
 			return sock_get_timestamp(sk, (struct timeval __user *)arg);
 
+		case SIOCGSTAMPNS:
+			return sock_get_timestampns(sk, (struct timespec __user *)arg);
+
 		case SIOC_WANPIPE_CHECK_TX:
 
 			return atomic_read(&sk->sk_wmem_alloc);
--- linux-2.6.21-rc2/net/x25/af_x25.c	2007-03-01 12:56:02.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/x25/af_x25.c	2007-03-01 12:56:02.000000000 +0100
@@ -1280,6 +1280,12 @@ static int x25_ioctl(struct socket *sock
 				rc = sock_get_timestamp(sk,
 						(struct timeval __user *)argp);
 			break;
+		case SIOCGSTAMP:
+			rc = -EINVAL;
+			if (sk)
+				rc = sock_get_timestampns(sk,
+						(struct timespec __user *)argp);
+			break;
 		case SIOCGIFADDR:
 		case SIOCSIFADDR:
 		case SIOCGIFDSTADDR:
@@ -1521,6 +1527,12 @@ static int compat_x25_ioctl(struct socke
 			rc = compat_sock_get_timestamp(sk,
 					(struct timeval __user*)argp);
 		break;
+	case SIOCGSTAMP:
+		rc = -EINVAL;
+		if (sk)
+			rc = compat_sock_get_timestampns(sk,
+					(struct timespec __user*)argp);
+		break;
 	case SIOCGIFADDR:
 	case SIOCSIFADDR:
 	case SIOCGIFDSTADDR:
--- linux-2.6.21-rc2/net/bridge/netfilter/ebt_ulog.c	2007-03-01 13:09:56.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/bridge/netfilter/ebt_ulog.c	2007-03-01 13:09:56.000000000 +0100
@@ -166,7 +166,7 @@ static void ebt_ulog_packet(unsigned int
 	pm->version = EBT_ULOG_VERSION;
 	do_gettimeofday(&pm->stamp);
 	if (ub->qlen == 1)
-		skb_set_timestamp(ub->skb, &pm->stamp);
+		skb_set_timestampus(ub->skb, &pm->stamp);
 	pm->data_len = copy_len;
 	pm->mark = skb->mark;
 	pm->hook = hooknr;
--- linux-2.6.21-rc2/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-03-01 13:09:56.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv6/netfilter/nf_conntrack_reasm.c	2007-03-01 13:15:07.000000000 +0100
@@ -82,7 +82,7 @@ struct nf_ct_frag6_queue
 	struct sk_buff		*fragments;
 	int			len;
 	int			meat;
-	struct timeval		stamp;
+	struct timespec		stamp;
 	unsigned int		csum;
 	__u8			last_in;	/* has first/last segment arrived? */
 #define COMPLETE		4
@@ -542,7 +542,7 @@ static int nf_ct_frag6_queue(struct nf_c
 		fq->fragments = skb;
 
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &fq->stamp);
+	skb_get_timestampns(skb, &fq->stamp);
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &nf_ct_frag6_mem);
 
@@ -648,7 +648,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &fq->stamp);
+	skb_set_timestampns(head, &fq->stamp);
 	head->nh.ipv6h->payload_len = htons(payload_len);
 
 	/* Yes, and fold redundant checksum back. 8) */
--- linux-2.6.21-rc2/net/ipv6/reassembly.c	2007-03-01 13:15:07.000000000 +0100
+++ linux-2.6.21-rc2-ed/net/ipv6/reassembly.c	2007-03-01 13:15:07.000000000 +0100
@@ -88,7 +88,7 @@ struct frag_queue
 	int			len;
 	int			meat;
 	int			iif;
-	struct timeval		stamp;
+	struct timespec		stamp;
 	unsigned int		csum;
 	__u8			last_in;	/* has first/last segment arrived? */
 #define COMPLETE		4
@@ -562,7 +562,7 @@ static void ip6_frag_queue(struct frag_q
 	if (skb->dev)
 		fq->iif = skb->dev->ifindex;
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &fq->stamp);
+	skb_get_timestampns(skb, &fq->stamp);
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &ip6_frag_mem);
 
@@ -663,7 +663,7 @@ static int ip6_frag_reasm(struct frag_qu
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &fq->stamp);
+	skb_set_timestampns(head, &fq->stamp);
 	head->nh.ipv6h->payload_len = htons(payload_len);
 	IP6CB(head)->nhoff = nhoff;
 
--- linux-2.6.21-rc2/include/asm-i386/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-i386/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-x86_64/sockios.h	2007-02-28 21:19:22.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-x86_64/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-alpha/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-alpha/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -11,5 +11,6 @@
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
 #define SIOCGSTAMP	0x8906		/* Get stamp - linux-specific */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_ALPHA_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-arm26/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-arm26/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-avr32/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-avr32/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ASM_AVR32_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-cris/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-cris/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-frv/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-frv/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,7 +7,8 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_SOCKIOS__ */
 
--- linux-2.6.21-rc2/include/asm-h8300/sockios.h	2007-03-01 11:53:45.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-h8300/sockios.h	2007-03-01 11:53:45.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ARCH_H8300_SOCKIOS__ */
--- linux-2.6.21-rc2/include/asm-ia64/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-ia64/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -14,6 +14,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_IA64_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-m32r/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-m32r/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif  /* _ASM_M32R_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-m68k/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-m68k/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __ARCH_M68K_SOCKIOS__ */
--- linux-2.6.21-rc2/include/asm-mips/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-mips/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -20,6 +20,7 @@
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	0x8906			/* Get stamp - linux-specific */
+#define SIOCGSTAMP	0x8906			/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* _ASM_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-parisc/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-parisc/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-powerpc/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-powerpc/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -14,6 +14,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif	/* _ASM_POWERPC_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-s390/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-s390/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -15,6 +15,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif
--- linux-2.6.21-rc2/include/asm-sh/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-sh/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -10,4 +10,5 @@
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
 #define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp - linux-specific */
+#define SIOCGSTAMPNS	_IOR('s', 101, struct timespec) /* Get stamp - linux-specific */
 #endif /* __ASM_SH_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-sh64/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-sh64/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -21,4 +21,5 @@
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
 #define SIOCGSTAMP	_IOR('s', 100, struct timeval) /* Get stamp - linux-specific */
+#define SIOCGSTAMPNS	_IOR('s', 101, struct timespec) /* Get stamp - linux-specific */
 #endif /* __ASM_SH64_SOCKIOS_H */
--- linux-2.6.21-rc2/include/asm-sparc/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-sparc/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,7 +7,8 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* !(_ASM_SPARC_SOCKIOS_H) */
 
--- linux-2.6.21-rc2/include/asm-sparc64/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-sparc64/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,7 +7,8 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* !(_ASM_SPARC64_SOCKIOS_H) */
 
--- linux-2.6.21-rc2/include/asm-v850/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-v850/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -7,6 +7,7 @@
 #define FIOGETOWN	0x8903
 #define SIOCGPGRP	0x8904
 #define SIOCATMARK	0x8905
-#define SIOCGSTAMP	0x8906		/* Get stamp */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif /* __V850_SOCKIOS_H__ */
--- linux-2.6.21-rc2/include/asm-xtensa/sockios.h	2007-03-01 11:11:33.000000000 +0100
+++ linux-2.6.21-rc2-ed/include/asm-xtensa/sockios.h	2007-03-01 11:11:33.000000000 +0100
@@ -25,6 +25,7 @@
 #define SIOCSPGRP	_IOW('s', 8, pid_t)
 #define SIOCGPGRP	_IOR('s', 9, pid_t)
 
-#define SIOCGSTAMP	0x8906		/* Get stamp - linux-specific */
+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
 
 #endif	/* _XTENSA_SOCKIOS_H */

--Boundary-00=_qlr5FDqyV0ypBpR--
