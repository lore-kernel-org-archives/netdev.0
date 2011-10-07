From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [RFC] net: add wireless TX status socket option
Date: Fri, 07 Oct 2011 19:19:30 +0200
Message-ID: <1318007970.3988.27.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

The 802.1X EAPOL handshake hostapd does requires
knowing whether the frame was ack'ed by the peer.
Currently, we fudge this pretty badly by not even
transmitting the frame as a normal data frame but
injecting it with radiotap and getting the status
out of radiotap monitor as well. This is rather
complex, confuses users (mon.wlan0 presence) and
doesn't work with all hardware.

To get rid of that hack, introduce a real wifi TX
status option for data frame transmissions.

This works similar to the existing TX timestamping
in that it reflects the SKB back to the socket's
error queue with a SCM_WIFI_STATUS cmsg that has
an int indicating ACK status (0/1).

Since it is possible that at some point we will
want to have TX timestamping and wifi status in a
single errqueue SKB (there's little point in not
doing that), redefine SO_EE_ORIGIN_TIMESTAMPING
to SO_EE_ORIGIN_TXSTATUS which can collect more
than just the timestamp; keep the old constant
as an alias of course. Currently the internal APIs
don't make that possible, but it wouldn't be hard
to split them up in a way that makes it possible.

Thanks to Neil Horman for helping me figure out
the functions that add the control messages.

TODO:
 * sock_tx_timestamp() function should be renamed,
   maybe to sock_tx_status()?
 * sock_recv_timestamp() should also be renamed,
   I had a hard time figuring out the difference
   between that and sock_recv_ts_and_drops(). The
   former is generic, while the latter adds RX
   information only, maybe that should be reflected
   in new names?

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 arch/alpha/include/asm/socket.h   |    3 +++
 arch/arm/include/asm/socket.h     |    3 +++
 arch/avr32/include/asm/socket.h   |    3 +++
 arch/cris/include/asm/socket.h    |    3 +++
 arch/frv/include/asm/socket.h     |    3 +++
 arch/h8300/include/asm/socket.h   |    3 +++
 arch/ia64/include/asm/socket.h    |    3 +++
 arch/m32r/include/asm/socket.h    |    3 +++
 arch/m68k/include/asm/socket.h    |    3 +++
 arch/mips/include/asm/socket.h    |    3 +++
 arch/mn10300/include/asm/socket.h |    3 +++
 arch/parisc/include/asm/socket.h  |    3 +++
 arch/powerpc/include/asm/socket.h |    3 +++
 arch/s390/include/asm/socket.h    |    3 +++
 arch/sparc/include/asm/socket.h   |    3 +++
 arch/xtensa/include/asm/socket.h  |    3 +++
 include/asm-generic/socket.h      |    3 +++
 include/linux/errqueue.h          |    3 ++-
 include/linux/skbuff.h            |   18 ++++++++++++++++--
 include/net/sock.h                |    7 +++++++
 net/core/skbuff.c                 |   20 ++++++++++++++++++++
 net/core/sock.c                   |    9 +++++++++
 net/mac80211/status.c             |   35 +++++++++++++++++++++++++++--------
 net/mac80211/tx.c                 |    8 +++++++-
 net/socket.c                      |   19 +++++++++++++++++++
 25 files changed, 158 insertions(+), 12 deletions(-)

--- a/include/asm-generic/socket.h	2011-10-07 18:59:12.000000000 +0200
+++ b/include/asm-generic/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -64,4 +64,7 @@
 #define SO_DOMAIN		39
 
 #define SO_RXQ_OVFL             40
+
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS	SO_WIFI_STATUS
 #endif /* __ASM_GENERIC_SOCKET_H */
--- a/net/core/sock.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/core/sock.c	2011-10-07 18:59:12.000000000 +0200
@@ -740,6 +740,11 @@ set_rcvbuf:
 	case SO_RXQ_OVFL:
 		sock_valbool_flag(sk, SOCK_RXQ_OVFL, valbool);
 		break;
+
+	case SO_WIFI_STATUS:
+		sock_valbool_flag(sk, SOCK_WIFI_STATUS, valbool);
+		break;
+
 	default:
 		ret = -ENOPROTOOPT;
 		break;
@@ -961,6 +966,10 @@ int sock_getsockopt(struct socket *sock,
 		v.val = !!sock_flag(sk, SOCK_RXQ_OVFL);
 		break;
 
+	case SO_WIFI_STATUS:
+		v.val = !!sock_flag(sk, SOCK_WIFI_STATUS);
+		break;
+
 	default:
 		return -ENOPROTOOPT;
 	}
--- a/include/net/sock.h	2011-10-07 18:59:12.000000000 +0200
+++ b/include/net/sock.h	2011-10-07 18:59:12.000000000 +0200
@@ -564,6 +564,7 @@ enum sock_flags {
 	SOCK_FASYNC, /* fasync() active */
 	SOCK_RXQ_OVFL,
 	SOCK_ZEROCOPY, /* buffers from userspace */
+	SOCK_WIFI_STATUS, /* push wifi status to userspace */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
@@ -1705,7 +1706,10 @@ static inline int sock_intr_errno(long t
 
 extern void __sock_recv_timestamp(struct msghdr *msg, struct sock *sk,
 	struct sk_buff *skb);
+extern void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb);
 
+/* XXX: rename this function now? */
 static __inline__ void
 sock_recv_timestamp(struct msghdr *msg, struct sock *sk, struct sk_buff *skb)
 {
@@ -1732,6 +1736,9 @@ sock_recv_timestamp(struct msghdr *msg,
 		__sock_recv_timestamp(msg, sk, skb);
 	else
 		sk->sk_stamp = kt;
+
+	if (sock_flag(sk, SOCK_WIFI_STATUS) && skb->wifi_acked_valid)
+		__sock_recv_wifi_status(msg, sk, skb);
 }
 
 extern void __sock_recv_ts_and_drops(struct msghdr *msg, struct sock *sk,
--- a/arch/alpha/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/alpha/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -69,6 +69,9 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
--- a/arch/arm/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/arm/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/avr32/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/avr32/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* __ASM_AVR32_SOCKET_H */
--- a/arch/cris/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/cris/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -64,6 +64,9 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
 
 
--- a/arch/frv/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/frv/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,5 +62,8 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
 
--- a/arch/h8300/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/h8300/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/ia64/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/ia64/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -71,4 +71,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_IA64_SOCKET_H */
--- a/arch/m32r/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/m32r/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_M32R_SOCKET_H */
--- a/arch/m68k/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/m68k/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/mips/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/mips/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -82,6 +82,9 @@ To add: #define SO_REUSEPORT 0x0200	/* A
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #ifdef __KERNEL__
 
 /** sock_type - Socket types
--- a/arch/mn10300/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/mn10300/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -62,4 +62,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/parisc/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/parisc/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -61,6 +61,9 @@
 
 #define SO_RXQ_OVFL             0x4021
 
+#define SO_WIFI_STATUS		0x4022
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* O_NONBLOCK clashes with the bits used for socket types.  Therefore we
  * have to define SOCK_NONBLOCK to a different value here.
  */
--- a/arch/powerpc/include/asm/socket.h	2011-10-07 18:59:11.000000000 +0200
+++ b/arch/powerpc/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -69,4 +69,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif	/* _ASM_POWERPC_SOCKET_H */
--- a/arch/s390/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/s390/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -70,4 +70,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif /* _ASM_SOCKET_H */
--- a/arch/sparc/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/sparc/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -58,6 +58,9 @@
 
 #define SO_RXQ_OVFL             0x0024
 
+#define SO_WIFI_STATUS		0x0025
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 /* Security levels - as per NRL IPv6 - don't actually do anything */
 #define SO_SECURITY_AUTHENTICATION		0x5001
 #define SO_SECURITY_ENCRYPTION_TRANSPORT	0x5002
--- a/arch/xtensa/include/asm/socket.h	2011-10-07 18:59:10.000000000 +0200
+++ b/arch/xtensa/include/asm/socket.h	2011-10-07 18:59:12.000000000 +0200
@@ -73,4 +73,7 @@
 
 #define SO_RXQ_OVFL             40
 
+#define SO_WIFI_STATUS		41
+#define SCM_WIFI_STATUS		SO_WIFI_STATUS
+
 #endif	/* _XTENSA_SOCKET_H */
--- a/include/linux/errqueue.h	2011-10-07 18:59:11.000000000 +0200
+++ b/include/linux/errqueue.h	2011-10-07 18:59:12.000000000 +0200
@@ -17,7 +17,8 @@ struct sock_extended_err {
 #define SO_EE_ORIGIN_LOCAL	1
 #define SO_EE_ORIGIN_ICMP	2
 #define SO_EE_ORIGIN_ICMP6	3
-#define SO_EE_ORIGIN_TIMESTAMPING 4
+#define SO_EE_ORIGIN_TXSTATUS	4
+#define SO_EE_ORIGIN_TIMESTAMPING SO_EE_ORIGIN_TXSTATUS
 
 #define SO_EE_OFFENDER(ee)	((struct sockaddr*)((ee)+1))
 
--- a/include/linux/skbuff.h	2011-10-07 18:59:11.000000000 +0200
+++ b/include/linux/skbuff.h	2011-10-07 18:59:12.000000000 +0200
@@ -190,6 +190,9 @@ enum {
 
 	/* device driver supports TX zero-copy buffers */
 	SKBTX_DEV_ZEROCOPY = 1 << 4,
+
+	/* generate wifi status information (where possible) */
+	SKBTX_WIFI_STATUS = 1 << 5,
 };
 
 /*
@@ -322,6 +325,8 @@ typedef unsigned char *sk_buff_data_t;
  *	@queue_mapping: Queue mapping for multiqueue devices
  *	@ndisc_nodetype: router type (from link layer)
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
+ *	@wifi_acked_valid: wifi_acked was set
+ *	@wifi_acked: whether frame was acked on wifi or not
  *	@dma_cookie: a cookie to one of several possible DMA operations
  *		done by skb DMA functions
  *	@secmark: security marking
@@ -414,10 +419,10 @@ struct sk_buff {
 	__u8			ndisc_nodetype:2;
 #endif
 	__u8			ooo_okay:1;
+	__u8			wifi_acked_valid:1;
+	__u8			wifi_acked:1;
 	kmemcheck_bitfield_end(flags2);
 
-	/* 0/13 bit hole */
-
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
 #endif
@@ -2062,6 +2067,15 @@ static inline void skb_tx_timestamp(stru
 	sw_tx_timestamp(skb);
 }
 
+/**
+ * skb_complete_wifi_ack - deliver cloned skb with wifi status
+ *
+ * @skb: clone of the the original outgoing packet
+ * @acked: ack status
+ *
+ */
+void skb_complete_wifi_ack(struct sk_buff *skb, bool acked);
+
 extern __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len);
 extern __sum16 __skb_checksum_complete(struct sk_buff *skb);
 
--- a/net/core/skbuff.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/core/skbuff.c	2011-10-07 18:59:24.000000000 +0200
@@ -3150,6 +3150,26 @@ void skb_tstamp_tx(struct sk_buff *orig_
 }
 EXPORT_SYMBOL_GPL(skb_tstamp_tx);
 
+void skb_complete_wifi_ack(struct sk_buff *skb, bool acked)
+{
+	struct sock *sk = skb->sk;
+	struct sock_exterr_skb *serr;
+	int err;
+
+	skb->wifi_acked_valid = 1;
+	skb->wifi_acked = acked;
+
+	serr = SKB_EXT_ERR(skb);
+	memset(serr, 0, sizeof(*serr));
+	serr->ee.ee_errno = ENOMSG;
+	serr->ee.ee_origin = SO_EE_ORIGIN_TXSTATUS;
+
+	err = sock_queue_err_skb(sk, skb);
+	if (err)
+		kfree_skb(skb);
+}
+EXPORT_SYMBOL_GPL(skb_complete_wifi_ack);
+
 
 /**
  * skb_partial_csum_set - set up and verify partial csum values for packet
--- a/net/socket.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/socket.c	2011-10-07 18:59:12.000000000 +0200
@@ -531,6 +531,7 @@ void sock_release(struct socket *sock)
 }
 EXPORT_SYMBOL(sock_release);
 
+/* XXX: rename this function now */
 int sock_tx_timestamp(struct sock *sk, __u8 *tx_flags)
 {
 	*tx_flags = 0;
@@ -538,6 +539,8 @@ int sock_tx_timestamp(struct sock *sk, _
 		*tx_flags |= SKBTX_HW_TSTAMP;
 	if (sock_flag(sk, SOCK_TIMESTAMPING_TX_SOFTWARE))
 		*tx_flags |= SKBTX_SW_TSTAMP;
+	if (sock_flag(sk, SOCK_WIFI_STATUS))
+		*tx_flags |= SKBTX_WIFI_STATUS;
 	return 0;
 }
 EXPORT_SYMBOL(sock_tx_timestamp);
@@ -674,6 +677,22 @@ void __sock_recv_timestamp(struct msghdr
 }
 EXPORT_SYMBOL_GPL(__sock_recv_timestamp);
 
+void __sock_recv_wifi_status(struct msghdr *msg, struct sock *sk,
+	struct sk_buff *skb)
+{
+	int ack;
+
+	if (!sock_flag(sk, SOCK_WIFI_STATUS))
+		return;
+	if (!skb->wifi_acked_valid)
+		return;
+
+	ack = skb->wifi_acked;
+
+	put_cmsg(msg, SOL_SOCKET, SCM_WIFI_STATUS, sizeof(ack), &ack);
+}
+EXPORT_SYMBOL_GPL(__sock_recv_wifi_status);
+
 static inline void sock_recv_drops(struct msghdr *msg, struct sock *sk,
 				   struct sk_buff *skb)
 {
--- a/net/mac80211/status.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/mac80211/status.c	2011-10-07 19:05:24.000000000 +0200
@@ -252,8 +252,9 @@ void ieee80211_tx_status(struct ieee8021
 	struct sta_info *sta, *tmp;
 	int retry_count = -1, i;
 	int rates_idx = -1;
-	bool send_to_cooked;
+	bool send_to_cooked, need_for_monitors;
 	bool acked;
+	bool multicast;
 	struct ieee80211_bar *bar;
 	u16 tid;
 
@@ -278,6 +279,7 @@ void ieee80211_tx_status(struct ieee8021
 
 	sband = local->hw.wiphy->bands[info->band];
 	fc = hdr->frame_control;
+	multicast = is_multicast_ether_addr(hdr->addr1);
 
 	for_each_sta_info(local, hdr->addr1, sta, tmp) {
 		/* skip wrong virtual interface */
@@ -443,9 +445,6 @@ void ieee80211_tx_status(struct ieee8021
 			!!(info->flags & IEEE80211_TX_STAT_ACK), GFP_ATOMIC);
 	}
 
-	/* this was a transmitted frame, but now we want to reuse it */
-	skb_orphan(skb);
-
 	/* Need to make a copy before skb->cb gets cleared */
 	send_to_cooked = !!(info->flags & IEEE80211_TX_CTL_INJECTED) ||
 			(type != IEEE80211_FTYPE_DATA);
@@ -454,13 +453,33 @@ void ieee80211_tx_status(struct ieee8021
 	 * This is a bit racy but we can avoid a lot of work
 	 * with this test...
 	 */
-	if (!local->monitors && (!send_to_cooked || !local->cooked_mntrs)) {
-		dev_kfree_skb(skb);
-		return;
-	}
+	need_for_monitors = local->monitors ||
+	                    (send_to_cooked && local->cooked_mntrs);
 
 	/* send frame to monitor interfaces now */
 
+	if (!multicast && skb->sk &&
+	    skb_shinfo(skb)->tx_flags & SKBTX_WIFI_STATUS) {
+		struct sk_buff *mon_skb = NULL;
+
+                if (need_for_monitors)
+                        mon_skb = skb_clone(skb, GFP_ATOMIC);
+
+		/* consumes skb */
+		skb_complete_wifi_ack(skb, info->flags & IEEE80211_TX_STAT_ACK);
+
+		if (!mon_skb)
+			return;
+
+		skb = mon_skb;
+	} else if (!need_for_monitors) {
+	        dev_kfree_skb(skb);
+	        return;
+	} else {
+		/* this was a transmitted frame, but now we want to reuse it */
+		skb_orphan(skb);
+	}
+
 	if (skb_headroom(skb) < sizeof(*rthdr)) {
 		printk(KERN_ERR "ieee80211_tx_status: headroom too small\n");
 		dev_kfree_skb(skb);
--- a/net/mac80211/tx.c	2011-10-07 18:59:12.000000000 +0200
+++ b/net/mac80211/tx.c	2011-10-07 18:59:12.000000000 +0200
@@ -1686,6 +1686,7 @@ netdev_tx_t ieee80211_subif_start_xmit(s
 	bool wme_sta = false, authorized = false, tdls_auth = false;
 	struct sk_buff *tmp_skb;
 	bool tdls_direct = false;
+	bool multicast;
 
 	if (unlikely(skb->len < ETH_HLEN)) {
 		ret = NETDEV_TX_OK;
@@ -1872,7 +1873,8 @@ netdev_tx_t ieee80211_subif_start_xmit(s
 	 * if it is a multicast address (which can only happen
 	 * in AP mode)
 	 */
-	if (!is_multicast_ether_addr(hdr.addr1)) {
+	multicast = is_multicast_ether_addr(hdr.addr1);
+	if (!multicast) {
 		rcu_read_lock();
 		sta = sta_info_get(sdata, hdr.addr1);
 		if (sta) {
@@ -2019,6 +2021,10 @@ netdev_tx_t ieee80211_subif_start_xmit(s
 	memset(info, 0, sizeof(*info));
 
 	dev->trans_start = jiffies;
+
+	if (!multicast && skb_shinfo(skb)->tx_flags & SKBTX_WIFI_STATUS)
+		info->flags = IEEE80211_TX_CTL_REQ_TX_STATUS;
+
 	ieee80211_xmit(sdata, skb);
 
 	return NETDEV_TX_OK;


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
