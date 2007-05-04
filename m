From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: [PATCH][SOCK]: shrink struct sock
Date: Fri, 4 May 2007 01:11:01 -0300
Message-ID: <20070504041101.GA27519@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.226]:34609 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767563AbXEDELI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 00:11:08 -0400
Received: by wx-out-0506.google.com with SMTP id h31so639523wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 21:11:07 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

	This saves 8 bytes out of struct sock in 64bit arches, tested on x86_64.

[acme@mica linux-2.6]$ codiff sock.o.before net/core/sock.o
/home/acme/git/linux-2.6/net/core/sock.c:
  struct sock |   -8
 1 struct changed
[acme@mica linux-2.6]$

Now struct sock has this layout, where we waste more 20 bytes, in four 4 byte
paddings in struct skb_buff_head members (layout at the bottom) + one 4 bytes
hole:

[acme@mica linux-2.6]$ pahole -C sock net/core/sock.o
struct sock {
	struct sock_common         __sk_common;          /*     0    56 */
	unsigned char              sk_shutdown:2;        /*    56     1 */
	unsigned char              sk_no_check:2;        /*    56     1 */
	unsigned char              sk_userlocks:4;       /*    56     1 */
	unsigned char              sk_protocol;          /*    57     1 */
	short unsigned int         sk_type;              /*    58     2 */
	int                        sk_rcvbuf;            /*    60     4 */
	/* --- cacheline 1 boundary (64 bytes) --- */
	socket_lock_t              sk_lock;              /*    64    40 */
	struct {
		struct sk_buff *   head;                 /*   104     8 */
		struct sk_buff *   tail;                 /*   112     8 */
	} sk_backlog;                                    /*   104    16 */
	wait_queue_head_t *        sk_sleep;             /*   120     8 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	struct dst_entry *         sk_dst_cache;         /*   128     8 */
	struct xfrm_policy *       sk_policy[2];         /*   136    16 */
	rwlock_t                   sk_dst_lock;          /*   152     8 */
	atomic_t                   sk_rmem_alloc;        /*   160     4 */
	atomic_t                   sk_wmem_alloc;        /*   164     4 */
	atomic_t                   sk_omem_alloc;        /*   168     4 */
	int                        sk_sndbuf;            /*   172     4 */
	struct sk_buff_head        sk_receive_queue;     /*   176    32 */

	/* XXX last struct has 4 bytes of padding */

	/* --- cacheline 3 boundary (192 bytes) was 16 bytes ago --- */
	struct sk_buff_head        sk_write_queue;       /*   208    32 */

	/* XXX last struct has 4 bytes of padding */

	struct sk_buff_head        sk_async_wait_queue;  /*   240    32 */

	/* XXX last struct has 4 bytes of padding */

	/* --- cacheline 4 boundary (256 bytes) was 16 bytes ago --- */
	int                        sk_wmem_queued;       /*   272     4 */
	int                        sk_forward_alloc;     /*   276     4 */
	gfp_t                      sk_allocation;        /*   280     4 */
	int                        sk_route_caps;        /*   284     4 */
	int                        sk_gso_type;          /*   288     4 */
	int                        sk_rcvlowat;          /*   292     4 */
	long unsigned int          sk_flags;             /*   296     8 */
	long unsigned int          sk_lingertime;        /*   304     8 */
	struct sk_buff_head        sk_error_queue;       /*   312    32 */

	/* XXX last struct has 4 bytes of padding */

	/* --- cacheline 5 boundary (320 bytes) was 24 bytes ago --- */
	struct proto *             sk_prot_creator;      /*   344     8 */
	rwlock_t                   sk_callback_lock;     /*   352     8 */
	int                        sk_err;               /*   360     4 */
	int                        sk_err_soft;          /*   364     4 */
	short unsigned int         sk_ack_backlog;       /*   368     2 */
	short unsigned int         sk_max_ack_backlog;   /*   370     2 */
	__u32                      sk_priority;          /*   372     4 */
	struct ucred               sk_peercred;          /*   376    12 */

	/* XXX 4 bytes hole, try to pack */

	/* --- cacheline 6 boundary (384 bytes) was 8 bytes ago --- */
	long int                   sk_rcvtimeo;          /*   392     8 */
	long int                   sk_sndtimeo;          /*   400     8 */
	struct sk_filter *         sk_filter;            /*   408     8 */
	void *                     sk_protinfo;          /*   416     8 */
	struct timer_list          sk_timer;             /*   424    48 */
	/* --- cacheline 7 boundary (448 bytes) was 24 bytes ago --- */
	ktime_t                    sk_stamp;             /*   472     8 */
	struct socket *            sk_socket;            /*   480     8 */
	void *                     sk_user_data;         /*   488     8 */
	struct page *              sk_sndmsg_page;       /*   496     8 */
	struct sk_buff *           sk_send_head;         /*   504     8 */
	/* --- cacheline 8 boundary (512 bytes) --- */
	__u32                      sk_sndmsg_off;        /*   512     4 */
	int                        sk_write_pending;     /*   516     4 */
	void *                     sk_security;          /*   520     8 */
	void                       (*sk_state_change)(struct sock *); /*   528     8 */
	void                       (*sk_data_ready)(struct sock *, int); /*   536     8 */
	void                       (*sk_write_space)(struct sock *); /*   544     8 */
	void                       (*sk_error_report)(struct sock *); /*   552     8 */
	int                        (*sk_backlog_rcv)(struct sock *, struct sk_buff *); /*   560     8 */
	void                       (*sk_destruct)(struct sock *); /*   568     8 */
	/* --- cacheline 9 boundary (576 bytes) --- */
}; /* size: 576, cachelines: 9 */
   /* sum members: 572, holes: 1, sum holes: 4 */
   /* paddings: 4, sum paddings: 16 */


[acme@mica linux-2.6]$ pahole -C sk_buff_head net/core/sock.o
struct sk_buff_head {
	struct sk_buff *           next;                 /*     0     8 */
	struct sk_buff *           prev;                 /*     8     8 */
	__u32                      qlen;                 /*    16     4 */
	spinlock_t                 lock;                 /*    20     8 */
}; /* size: 32, cachelines: 1 */
   /* padding: 4 */
   /* last cacheline: 32 bytes */

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index 25c37e3..64a5429 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -218,13 +218,13 @@ struct sock {
 	atomic_t		sk_rmem_alloc;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
+	int			sk_sndbuf;
 	struct sk_buff_head	sk_receive_queue;
 	struct sk_buff_head	sk_write_queue;
 	struct sk_buff_head	sk_async_wait_queue;
 	int			sk_wmem_queued;
 	int			sk_forward_alloc;
 	gfp_t			sk_allocation;
-	int			sk_sndbuf;
 	int			sk_route_caps;
 	int			sk_gso_type;
 	int			sk_rcvlowat;
