From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : convert network timestamps to ktime_t
Date: Mon, 05 Mar 2007 08:40:03 +0100
Message-ID: <45EBC953.30905@cosmosbay.com>
References: <200703021538.41284.dada1@cosmosbay.com>	<20070302130210.57883edc@freekitty>	<45E8A936.9050908@cosmosbay.com> <20070304.161924.55508971.davem@davemloft.net> <45EBBF21.1000209@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040707040200070202070100"
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:57330 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbXCEHkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 02:40:24 -0500
In-Reply-To: <45EBBF21.1000209@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040707040200070202070100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David

Here is the second version of this patch, including missing bits spoted by 
Stephen. This is against net-2.6.22

Thank you

[PATCH] NET : convert network timestamps to ktime_t

We currently use a special structure (struct skb_timeval) and plain 'struct
timeval' to store packet timestamps in sk_buffs and struct sock.

This has some drawbacks :
- Fixed resolution of micro second.
- Waste of space on 64bit platforms where sizeof(struct timeval)=16

I suggest using ktime_t that is a nice abstraction of high resolution time
services, currently capable of nanosecond resolution.

As sizeof(ktime_t) is 8 bytes, using ktime_t in 'struct sock' permits a 8 byte
shrink of this structure on 64bit architectures. Some other structures also
benefit from this size reduction (struct ipq in ipv4/ip_fragment.c, struct
frag_queue in ipv6/reassembly.c, ...)


Once this ktime infrastructure adopted, we can more easily provide nanosecond
resolution on top of it. (ioctl SIOCGSTAMPNS and/or
SO_TIMESTAMPNS/SCM_TIMESTAMPNS)

Note : this patch includes a bug correction in compat_sock_get_timestamp()
where a "err = 0;" was missing (so this syscall returned -ENOENT instead of
0)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
CC: Stephen Hemminger <shemminger@linux-foundation.org>
CC: John find <linux.kernel@free.fr>

  include/linux/skbuff.h                  |   26 ++++------------------
  include/net/sock.h                      |   18 +++++++--------
  kernel/time.c                           |    1
  net/bridge/netfilter/ebt_ulog.c         |    6 +++--
  net/compat.c                            |   15 ++++++++----
  net/core/dev.c                          |   19 +++-------------
  net/core/sock.c                         |   16 +++++++------
  net/econet/af_econet.c                  |    2 -
  net/ipv4/ip_fragment.c                  |    8 +++---
  net/ipv4/netfilter/ip_queue.c           |    6 +++--
  net/ipv4/netfilter/ipt_ULOG.c           |    8 ++++--
  net/ipv6/exthdrs.c                      |    2 -
  net/ipv6/netfilter/ip6_queue.c          |    6 +++--
  net/ipv6/netfilter/nf_conntrack_reasm.c |    6 ++---
  net/ipv6/reassembly.c                   |    6 ++---
  net/ipx/af_ipx.c                        |    4 +--
  net/netfilter/nfnetlink_log.c           |    8 +++---
  net/netfilter/nfnetlink_queue.c         |    8 +++---
  net/packet/af_packet.c                  |    8 ++++--
  net/sunrpc/svcsock.c                    |   10 ++------
  20 files changed, 85 insertions(+), 98 deletions(-)

--------------040707040200070202070100
Content-Type: text/plain;
 name="net_stamp_ktime_2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net_stamp_ktime_2.patch"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..24dcbb3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -27,6 +27,7 @@ #include <linux/textsearch.h>
 #include <net/checksum.h>
 #include <linux/rcupdate.h>
 #include <linux/dmaengine.h>
+#include <linux/hrtimer.h>
 
 #define HAVE_ALLOC_SKB		/* For the drivers to know */
 #define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
@@ -156,11 +157,6 @@ struct skb_shared_info {
 #define SKB_DATAREF_SHIFT 16
 #define SKB_DATAREF_MASK ((1 << SKB_DATAREF_SHIFT) - 1)
 
-struct skb_timeval {
-	u32	off_sec;
-	u32	off_usec;
-};
-
 
 enum {
 	SKB_FCLONE_UNAVAILABLE,
@@ -233,7 +229,7 @@ struct sk_buff {
 	struct sk_buff		*prev;
 
 	struct sock		*sk;
-	struct skb_timeval	tstamp;
+	ktime_t			tstamp;
 	struct net_device	*dev;
 	struct net_device	*input_dev;
 
@@ -1360,26 +1356,14 @@ extern void skb_add_mtu(int mtu);
  */
 static inline void skb_get_timestamp(const struct sk_buff *skb, struct timeval *stamp)
 {
-	stamp->tv_sec  = skb->tstamp.off_sec;
-	stamp->tv_usec = skb->tstamp.off_usec;
+	*stamp = ktime_to_timeval(skb->tstamp);
 }
 
-/**
- * 	skb_set_timestamp - set timestamp of a skb
- *	@skb: skb to set stamp of
- *	@stamp: pointer to struct timeval to get stamp from
- *
- *	Timestamps are stored in the skb as offsets to a base timestamp.
- *	This function converts a struct timeval to an offset and stores
- *	it in the skb.
- */
-static inline void skb_set_timestamp(struct sk_buff *skb, const struct timeval *stamp)
+static inline void __net_timestamp(struct sk_buff *skb)
 {
-	skb->tstamp.off_sec  = stamp->tv_sec;
-	skb->tstamp.off_usec = stamp->tv_usec;
+	skb->tstamp = ktime_get_real();
 }
 
-extern void __net_timestamp(struct sk_buff *skb);
 
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
diff --git a/include/net/sock.h b/include/net/sock.h
index f352d22..59af9fc 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -244,7 +244,7 @@ #define sk_prot			__sk_common.skc_prot
 	struct sk_filter      	*sk_filter;
 	void			*sk_protinfo;
 	struct timer_list	sk_timer;
-	struct timeval		sk_stamp;
+	ktime_t			sk_stamp;
 	struct socket		*sk_socket;
 	void			*sk_user_data;
 	struct page		*sk_sndmsg_page;
@@ -1307,19 +1307,19 @@ static inline int sock_intr_errno(long t
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
-	struct timeval stamp;
+	ktime_t kt = skb->tstamp;
 
-	skb_get_timestamp(skb, &stamp);
 	if (sock_flag(sk, SOCK_RCVTSTAMP)) {
+		struct timeval tv;
 		/* Race occurred between timestamp enabling and packet
 		   receiving.  Fill in the current time for now. */
-		if (stamp.tv_sec == 0)
-			do_gettimeofday(&stamp);
-		skb_set_timestamp(skb, &stamp);
-		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(struct timeval),
-			 &stamp);
+		if (kt.tv64 == 0)
+			kt = ktime_get_real();
+		skb->tstamp = kt;
+		tv = ktime_to_timeval(kt);
+		put_cmsg(msg, SOL_SOCKET, SO_TIMESTAMP, sizeof(tv), &tv);
 	} else
-		sk->sk_stamp = stamp;
+		sk->sk_stamp = kt;
 }
 
 /**
diff --git a/kernel/time.c b/kernel/time.c
index c6c80ea..ec5b10c 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -469,6 +469,7 @@ struct timeval ns_to_timeval(const s64 n
 
 	return tv;
 }
+EXPORT_SYMBOL(ns_to_timeval);
 
 /*
  * Convert jiffies to milliseconds and back.
diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 8e15cc4..259f5c3 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -130,6 +130,7 @@ static void ebt_ulog_packet(unsigned int
 	unsigned int group = uloginfo->nlgroup;
 	ebt_ulog_buff_t *ub = &ulog_buffers[group];
 	spinlock_t *lock = &ub->lock;
+	ktime_t kt;
 
 	if ((uloginfo->cprange == 0) ||
 	    (uloginfo->cprange > skb->len + ETH_HLEN))
@@ -164,9 +165,10 @@ static void ebt_ulog_packet(unsigned int
 
 	/* Fill in the ulog data */
 	pm->version = EBT_ULOG_VERSION;
-	do_gettimeofday(&pm->stamp);
+	kt = ktime_get_real();
+	pm->stamp = ktime_to_timeval(kt);
 	if (ub->qlen == 1)
-		skb_set_timestamp(ub->skb, &pm->stamp);
+		ub->skb->tstamp = kt;
 	pm->data_len = copy_len;
 	pm->mark = skb->mark;
 	pm->hook = hooknr;
diff --git a/net/compat.c b/net/compat.c
index 1f32866..17c2710 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -545,15 +545,20 @@ int compat_sock_get_timestamp(struct soc
 	struct compat_timeval __user *ctv =
 			(struct compat_timeval __user*) userstamp;
 	int err = -ENOENT;
+	struct timeval tv;
 
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
 		sock_enable_timestamp(sk);
-	if (sk->sk_stamp.tv_sec == -1)
+	tv = ktime_to_timeval(sk->sk_stamp);
+	if (tv.tv_sec == -1)
 		return err;
-	if (sk->sk_stamp.tv_sec == 0)
-		do_gettimeofday(&sk->sk_stamp);
-	if (put_user(sk->sk_stamp.tv_sec, &ctv->tv_sec) ||
-			put_user(sk->sk_stamp.tv_usec, &ctv->tv_usec))
+	if (tv.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		tv = ktime_to_timeval(sk->sk_stamp);
+	}
+	err = 0;
+	if (put_user(tv.tv_sec, &ctv->tv_sec) ||
+			put_user(tv.tv_usec, &ctv->tv_usec))
 		err = -EFAULT;
 	return err;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index cf71614..833ca92 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1034,23 +1034,12 @@ void net_disable_timestamp(void)
 	atomic_dec(&netstamp_needed);
 }
 
-void __net_timestamp(struct sk_buff *skb)
-{
-	struct timeval tv;
-
-	do_gettimeofday(&tv);
-	skb_set_timestamp(skb, &tv);
-}
-EXPORT_SYMBOL(__net_timestamp);
-
 static inline void net_timestamp(struct sk_buff *skb)
 {
 	if (atomic_read(&netstamp_needed))
 		__net_timestamp(skb);
-	else {
-		skb->tstamp.off_sec = 0;
-		skb->tstamp.off_usec = 0;
-	}
+	else
+		skb->tstamp.tv64 = 0;
 }
 
 /*
@@ -1580,7 +1569,7 @@ int netif_rx(struct sk_buff *skb)
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.off_sec)
+	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
 	/*
@@ -1772,7 +1761,7 @@ int netif_receive_skb(struct sk_buff *sk
 	if (skb->dev->poll && netpoll_rx(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.off_sec)
+	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
 
 	if (!skb->input_dev)
diff --git a/net/core/sock.c b/net/core/sock.c
index 16ef004..95062a7 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1512,8 +1512,7 @@ #endif
 	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
 	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
 
-	sk->sk_stamp.tv_sec     = -1L;
-	sk->sk_stamp.tv_usec    = -1L;
+	sk->sk_stamp = ktime_set(-1L, -1L);
 
 	atomic_set(&sk->sk_refcnt, 1);
 }
@@ -1554,14 +1553,17 @@ EXPORT_SYMBOL(release_sock);
 
 int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
 {
+	struct timeval tv;
 	if (!sock_flag(sk, SOCK_TIMESTAMP))
 		sock_enable_timestamp(sk);
-	if (sk->sk_stamp.tv_sec == -1)
+	tv = ktime_to_timeval(sk->sk_stamp);
+	if (tv.tv_sec == -1)
 		return -ENOENT;
-	if (sk->sk_stamp.tv_sec == 0)
-		do_gettimeofday(&sk->sk_stamp);
-	return copy_to_user(userstamp, &sk->sk_stamp, sizeof(struct timeval)) ?
-		-EFAULT : 0;
+	if (tv.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		tv = ktime_to_timeval(sk->sk_stamp);
+	}
+	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
 }
 EXPORT_SYMBOL(sock_get_timestamp);
 
diff --git a/net/econet/af_econet.c b/net/econet/af_econet.c
index bc12e36..f573edd 100644
--- a/net/econet/af_econet.c
+++ b/net/econet/af_econet.c
@@ -162,7 +162,7 @@ static int econet_recvmsg(struct kiocb *
 	err = memcpy_toiovec(msg->msg_iov, skb->data, copied);
 	if (err)
 		goto out_free;
-	skb_get_timestamp(skb, &sk->sk_stamp);
+	sk->sk_stamp = skb->tstamp;
 
 	if (msg->msg_name)
 		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index b6f0553..e10be7d 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -92,7 +92,7 @@ #define LAST_IN			1
 	spinlock_t	lock;
 	atomic_t	refcnt;
 	struct timer_list timer;	/* when will this queue expire?		*/
-	struct timeval	stamp;
+	ktime_t		stamp;
 	int             iif;
 	unsigned int    rid;
 	struct inet_peer *peer;
@@ -592,7 +592,7 @@ static void ip_frag_queue(struct ipq *qp
 	if (skb->dev)
 		qp->iif = skb->dev->ifindex;
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &qp->stamp);
+	qp->stamp = skb->tstamp;
 	qp->meat += skb->len;
 	atomic_add(skb->truesize, &ip_frag_mem);
 	if (offset == 0)
@@ -674,7 +674,7 @@ static struct sk_buff *ip_frag_reasm(str
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &qp->stamp);
+	head->tstamp = qp->stamp;
 
 	iph = head->nh.iph;
 	iph->frag_off = 0;
@@ -734,7 +734,7 @@ struct sk_buff *ip_defrag(struct sk_buff
 	return NULL;
 }
 
-void ipfrag_init(void)
+void __init ipfrag_init(void)
 {
 	ipfrag_hash_rnd = (u32) ((num_physpages ^ (num_physpages>>7)) ^
 				 (jiffies ^ (jiffies >> 6)));
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index a14798a..5842f1a 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -197,6 +197,7 @@ ipq_build_packet_message(struct ipq_queu
 	struct sk_buff *skb;
 	struct ipq_packet_msg *pmsg;
 	struct nlmsghdr *nlh;
+	struct timeval tv;
 
 	read_lock_bh(&queue_lock);
 
@@ -241,8 +242,9 @@ ipq_build_packet_message(struct ipq_queu
 
 	pmsg->packet_id       = (unsigned long )entry;
 	pmsg->data_len        = data_len;
-	pmsg->timestamp_sec   = entry->skb->tstamp.off_sec;
-	pmsg->timestamp_usec  = entry->skb->tstamp.off_usec;
+	tv = ktime_to_timeval(entry->skb->tstamp);
+	pmsg->timestamp_sec   = tv.tv_sec;
+	pmsg->timestamp_usec  = tv.tv_usec;
 	pmsg->mark            = entry->skb->mark;
 	pmsg->hook            = entry->info->hook;
 	pmsg->hw_protocol     = entry->skb->protocol;
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index a26404d..e78c9d7 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -186,6 +186,7 @@ static void ipt_ulog_packet(unsigned int
 	ulog_packet_msg_t *pm;
 	size_t size, copy_len;
 	struct nlmsghdr *nlh;
+	struct timeval tv;
 
 	/* ffs == find first bit set, necessary because userspace
 	 * is already shifting groupnumber, but we need unshifted.
@@ -231,13 +232,14 @@ static void ipt_ulog_packet(unsigned int
 	pm = NLMSG_DATA(nlh);
 
 	/* We might not have a timestamp, get one */
-	if (skb->tstamp.off_sec == 0)
+	if (skb->tstamp.tv64 == 0)
 		__net_timestamp((struct sk_buff *)skb);
 
 	/* copy hook, prefix, timestamp, payload, etc. */
 	pm->data_len = copy_len;
-	pm->timestamp_sec = skb->tstamp.off_sec;
-	pm->timestamp_usec = skb->tstamp.off_usec;
+	tv = ktime_to_timeval(skb->tstamp);
+	pm->timestamp_sec = tv.tv_sec;
+	pm->timestamp_usec = tv.tv_usec;
 	pm->mark = skb->mark;
 	pm->hook = hooknum;
 	if (prefix != NULL)
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 28e0c65..0dc0ca0 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -255,7 +255,7 @@ static int ipv6_dest_hao(struct sk_buff 
 	ipv6_addr_copy(&ipv6h->saddr, &hao->addr);
 	ipv6_addr_copy(&hao->addr, &tmp_addr);
 
-	if (skb->tstamp.off_sec == 0)
+	if (skb->tstamp.tv64 == 0)
 		__net_timestamp(skb);
 
 	return 1;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index fdb30a5..66a2c41 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -195,6 +195,7 @@ ipq_build_packet_message(struct ipq_queu
 	struct sk_buff *skb;
 	struct ipq_packet_msg *pmsg;
 	struct nlmsghdr *nlh;
+	struct timeval tv;
 
 	read_lock_bh(&queue_lock);
 
@@ -239,8 +240,9 @@ ipq_build_packet_message(struct ipq_queu
 
 	pmsg->packet_id       = (unsigned long )entry;
 	pmsg->data_len        = data_len;
-	pmsg->timestamp_sec   = entry->skb->tstamp.off_sec;
-	pmsg->timestamp_usec  = entry->skb->tstamp.off_usec;
+	tv = ktime_to_timeval(entry->skb->tstamp);
+	pmsg->timestamp_sec   = tv.tv_sec;
+	pmsg->timestamp_usec  = tv.tv_usec;
 	pmsg->mark            = entry->skb->mark;
 	pmsg->hook            = entry->info->hook;
 	pmsg->hw_protocol     = entry->skb->protocol;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 15ab1e3..c311b9a 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -82,7 +82,7 @@ struct nf_ct_frag6_queue
 	struct sk_buff		*fragments;
 	int			len;
 	int			meat;
-	struct timeval		stamp;
+	ktime_t			stamp;
 	unsigned int		csum;
 	__u8			last_in;	/* has first/last segment arrived? */
 #define COMPLETE		4
@@ -542,7 +542,7 @@ static int nf_ct_frag6_queue(struct nf_c
 		fq->fragments = skb;
 
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &fq->stamp);
+	fq->stamp = skb->tstamp;
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &nf_ct_frag6_mem);
 
@@ -648,7 +648,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_que
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &fq->stamp);
+	head->tstamp = fq->stamp;
 	head->nh.ipv6h->payload_len = htons(payload_len);
 
 	/* Yes, and fold redundant checksum back. 8) */
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 7034c54..1dde449 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -88,7 +88,7 @@ struct frag_queue
 	int			len;
 	int			meat;
 	int			iif;
-	struct timeval		stamp;
+	ktime_t			stamp;
 	unsigned int		csum;
 	__u8			last_in;	/* has first/last segment arrived? */
 #define COMPLETE		4
@@ -562,7 +562,7 @@ static void ip6_frag_queue(struct frag_q
 	if (skb->dev)
 		fq->iif = skb->dev->ifindex;
 	skb->dev = NULL;
-	skb_get_timestamp(skb, &fq->stamp);
+	fq->stamp = skb->tstamp;
 	fq->meat += skb->len;
 	atomic_add(skb->truesize, &ip6_frag_mem);
 
@@ -663,7 +663,7 @@ static int ip6_frag_reasm(struct frag_qu
 
 	head->next = NULL;
 	head->dev = dev;
-	skb_set_timestamp(head, &fq->stamp);
+	head->tstamp = fq->stamp;
 	head->nh.ipv6h->payload_len = htons(payload_len);
 	IP6CB(head)->nhoff = nhoff;
 
diff --git a/net/ipx/af_ipx.c b/net/ipx/af_ipx.c
index cac35a7..6c6c0a3 100644
--- a/net/ipx/af_ipx.c
+++ b/net/ipx/af_ipx.c
@@ -1807,8 +1807,8 @@ #endif	/* CONFIG_IPX_INTERN */
 				     copied);
 	if (rc)
 		goto out_free;
-	if (skb->tstamp.off_sec)
-		skb_get_timestamp(skb, &sk->sk_stamp);
+	if (skb->tstamp.tv64)
+		sk->sk_stamp = skb->tstamp;
 
 	msg->msg_namelen = sizeof(*sipx);
 
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index b8eab0d..2f7872e 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -510,11 +510,11 @@ #endif
 		NFA_PUT(inst->skb, NFULA_HWADDR, sizeof(phw), &phw);
 	}
 
-	if (skb->tstamp.off_sec) {
+	if (skb->tstamp.tv64) {
 		struct nfulnl_msg_packet_timestamp ts;
-
-		ts.sec = cpu_to_be64(skb->tstamp.off_sec);
-		ts.usec = cpu_to_be64(skb->tstamp.off_usec);
+		struct timeval tv = ktime_to_timeval(skb->tstamp);
+		ts.sec = cpu_to_be64(tv.tv_sec);
+		ts.usec = cpu_to_be64(tv.tv_usec);
 
 		NFA_PUT(inst->skb, NFULA_TIMESTAMP, sizeof(ts), &ts);
 	}
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index d9ce4a7..cfbee39 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -495,11 +495,11 @@ #endif
 		NFA_PUT(skb, NFQA_HWADDR, sizeof(phw), &phw);
 	}
 
-	if (entskb->tstamp.off_sec) {
+	if (entskb->tstamp.tv64) {
 		struct nfqnl_msg_packet_timestamp ts;
-
-		ts.sec = cpu_to_be64(entskb->tstamp.off_sec);
-		ts.usec = cpu_to_be64(entskb->tstamp.off_usec);
+		struct timeval tv = ktime_to_timeval(entskb->tstamp);
+		ts.sec = cpu_to_be64(tv.tv_sec);
+		ts.usec = cpu_to_be64(tv.tv_usec);
 
 		NFA_PUT(skb, NFQA_TIMESTAMP, sizeof(ts), &ts);
 	}
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 28d47e8..f9866a8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -582,6 +582,7 @@ static int tpacket_rcv(struct sk_buff *s
 	unsigned long status = TP_STATUS_LOSING|TP_STATUS_USER;
 	unsigned short macoff, netoff;
 	struct sk_buff *copy_skb = NULL;
+	struct timeval tv;
 
 	if (skb->pkt_type == PACKET_LOOPBACK)
 		goto drop;
@@ -656,12 +657,13 @@ static int tpacket_rcv(struct sk_buff *s
 	h->tp_snaplen = snaplen;
 	h->tp_mac = macoff;
 	h->tp_net = netoff;
-	if (skb->tstamp.off_sec == 0) {
+	if (skb->tstamp.tv64 == 0) {
 		__net_timestamp(skb);
 		sock_enable_timestamp(sk);
 	}
-	h->tp_sec = skb->tstamp.off_sec;
-	h->tp_usec = skb->tstamp.off_usec;
+	tv = ktime_to_timeval(skb->tstamp);
+	h->tp_sec = tv.tv_sec;
+	h->tp_usec = tv.tv_usec;
 
 	sll = (struct sockaddr_ll*)((u8*)h + TPACKET_ALIGN(sizeof(*h)));
 	sll->sll_halen = 0;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 63ae947..a90e57a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -805,16 +805,12 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
-	if (skb->tstamp.off_sec == 0) {
-		struct timeval tv;
-
-		tv.tv_sec = xtime.tv_sec;
-		tv.tv_usec = xtime.tv_nsec / NSEC_PER_USEC;
-		skb_set_timestamp(skb, &tv);
+	if (skb->tstamp.tv64 == 0) {
+		skb->tstamp = ktime_get_real();
 		/* Don't enable netstamp, sunrpc doesn't
 		   need that much accuracy */
 	}
-	skb_get_timestamp(skb, &svsk->sk_sk->sk_stamp);
+	svsk->sk_sk->sk_stamp = skb->tstamp;
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
 	/*

--------------040707040200070202070100--
