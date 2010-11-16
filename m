From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 V2] net: reorder struct sock fields
Date: Tue, 16 Nov 2010 16:56:04 +0100
Message-ID: <1289922964.5372.443.camel@edumazet-laptop>
References: <1289891544.3364.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43553 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875Ab0KPP4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 10:56:09 -0500
Received: by wyb28 with SMTP id 28so848715wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 07:56:08 -0800 (PST)
In-Reply-To: <1289891544.3364.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 08:12 +0100, Eric Dumazet a =C3=A9crit=
 :
> Right now, fields in struct sock are not optimally ordered, because e=
ach
> path (RX softirq, TX completion, RX user,  TX user) has to touch fiel=
ds
> that are contained in many different cache lines.
>=20

Performance testing pointed out I forgot :

- sk_drops, read for each queued packet, and incremented on packet drop=
s
- sk_flags tested in sock_def_readable()
- sk_policy[0]

Here is V2 of patch :

[PATCH net-next-2.6 V2] net: reorder struct sock fields

Right now, fields in struct sock are not optimally ordered, because eac=
h
path (RX softirq, TX completion, RX user,  TX user) has to touch fields
that are contained in many different cache lines.

The really critical thing is to shrink number of cache lines that are
used at RX softirq time : CPU handling softirqs for a device can receiv=
e
many frames per second for many sockets. If load is too big, we can dro=
p
frames at NIC level. RPS or multiqueue cards can help, but better reduc=
e
latency if possible.

This patch starts with UDP protocol, then additional patches will try t=
o
reduce latencies of other ones as well.

At RX softirq time, fields of interest for UDP protocol are :
(not counting ones in inet struct for the lookup)

Read/Written:
sk_refcnt   (atomic increment/decrement)
sk_rmem_alloc & sk_backlog.len (to check if there is room in queues)
sk_receive_queue
sk_backlog (if socket locked by user program)
sk_rxhash
sk_forward_alloc
sk_drops

Read only:
sk_rcvbuf (sk_rcvqueues_full())
sk_filter
sk_wq
sk_policy[0]
sk_flags

Additional notes :

- sk_backlog has one hole on 64bit arches. We can fill it to save 8
bytes.
- sk_backlog is used only if RX sofirq handler finds the socket while
locked by user.
- sk_rxhash is written only once per flow.
- sk_drops is written only if queues are full

=46inal layout :

[1] One section grouping all read/write fields, but placing rxhash and
sk_backlog at the end of this section.

[2] One section grouping all read fields in RX handler=20
   (sk_filter, sk_rcv_buf, sk_wq)

[3] Section used by other paths

I'll post a patch on its own to put sk_refcnt at the end of struct
sock_common so that it shares same cache line than section [1]

New offsets on 64bit arch :

sizeof(struct sock)=3D0x268
offsetof(struct sock, sk_refcnt)  =3D0x10
offsetof(struct sock, sk_lock)    =3D0x48
offsetof(struct sock, sk_receive_queue)=3D0x68
offsetof(struct sock, sk_backlog)=3D0x80
offsetof(struct sock, sk_rmem_alloc)=3D0x80
offsetof(struct sock, sk_forward_alloc)=3D0x98
offsetof(struct sock, sk_rxhash)=3D0x9c
offsetof(struct sock, sk_rcvbuf)=3D0xa4
offsetof(struct sock, sk_drops) =3D0xa0
offsetof(struct sock, sk_filter)=3D0xa8
offsetof(struct sock, sk_wq)=3D0xb0
offsetof(struct sock, sk_policy)=3D0xd0
offsetof(struct sock, sk_flags) =3D0xe0

Instead of :

sizeof(struct sock)=3D0x270
offsetof(struct sock, sk_refcnt)  =3D0x10
offsetof(struct sock, sk_lock)    =3D0x50
offsetof(struct sock, sk_receive_queue)=3D0xc0
offsetof(struct sock, sk_backlog)=3D0x70
offsetof(struct sock, sk_rmem_alloc)=3D0xac
offsetof(struct sock, sk_forward_alloc)=3D0x10c
offsetof(struct sock, sk_rxhash)=3D0x128
offsetof(struct sock, sk_rcvbuf)=3D0x4c
offsetof(struct sock, sk_drops) =3D0x16c
offsetof(struct sock, sk_filter)=3D0x198
offsetof(struct sock, sk_wq)=3D0x88
offsetof(struct sock, sk_policy)=3D0x98
offsetof(struct sock, sk_flags) =3D0x130

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |   55 ++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index a6338d0..a2825eb 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -241,59 +241,67 @@ struct sock {
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_prot			__sk_common.skc_prot
 #define sk_net			__sk_common.skc_net
-	kmemcheck_bitfield_begin(flags);
-	unsigned int		sk_shutdown  : 2,
-				sk_no_check  : 2,
-				sk_userlocks : 4,
-				sk_protocol  : 8,
-				sk_type      : 16;
-	kmemcheck_bitfield_end(flags);
-	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
+	struct sk_buff_head	sk_receive_queue;
 	/*
 	 * The backlog queue is special, it is always used with
 	 * the per-socket spinlock held and requires low latency
 	 * access. Therefore we special case it's implementation.
+	 * Note : rmem_alloc is in this structure to fill a hole
+	 * on 64bit arches, not because its logically part of
+	 * backlog.
 	 */
 	struct {
-		struct sk_buff *head;
-		struct sk_buff *tail;
-		int len;
+		atomic_t	rmem_alloc;
+		int		len;
+		struct sk_buff	*head;
+		struct sk_buff	*tail;
 	} sk_backlog;
+#define sk_rmem_alloc sk_backlog.rmem_alloc
+	int			sk_forward_alloc;
+#ifdef CONFIG_RPS
+	__u32			sk_rxhash;
+#endif
+	atomic_t		sk_drops;
+	int			sk_rcvbuf;
+
+	struct sk_filter __rcu	*sk_filter;
 	struct socket_wq	*sk_wq;
-	struct dst_entry	*sk_dst_cache;
+
+#ifdef CONFIG_NET_DMA
+	struct sk_buff_head	sk_async_wait_queue;
+#endif
+
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
+	unsigned long 		sk_flags;
+	struct dst_entry	*sk_dst_cache;
 	spinlock_t		sk_dst_lock;
-	atomic_t		sk_rmem_alloc;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
-	struct sk_buff_head	sk_receive_queue;
 	struct sk_buff_head	sk_write_queue;
-#ifdef CONFIG_NET_DMA
-	struct sk_buff_head	sk_async_wait_queue;
-#endif
+	kmemcheck_bitfield_begin(flags);
+	unsigned int		sk_shutdown  : 2,
+				sk_no_check  : 2,
+				sk_userlocks : 4,
+				sk_protocol  : 8,
+				sk_type      : 16;
+	kmemcheck_bitfield_end(flags);
 	int			sk_wmem_queued;
-	int			sk_forward_alloc;
 	gfp_t			sk_allocation;
 	int			sk_route_caps;
 	int			sk_route_nocaps;
 	int			sk_gso_type;
 	unsigned int		sk_gso_max_size;
 	int			sk_rcvlowat;
-#ifdef CONFIG_RPS
-	__u32			sk_rxhash;
-#endif
-	unsigned long 		sk_flags;
 	unsigned long	        sk_lingertime;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot_creator;
 	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
-	atomic_t		sk_drops;
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
@@ -301,7 +309,6 @@ struct sock {
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
 	long			sk_sndtimeo;
-	struct sk_filter __rcu	*sk_filter;
 	void			*sk_protinfo;
 	struct timer_list	sk_timer;
 	ktime_t			sk_stamp;


