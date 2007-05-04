From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH][SOCK]: shrink struct sock
Date: Fri, 4 May 2007 08:24:34 -0300
Message-ID: <39e6f6c70705040424w77462efemfd0a2857bbecf15c@mail.gmail.com>
References: <20070504041101.GA27519@ghostprotocols.net>
	 <463ACE47.6080807@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:62146 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbXEDLYg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 07:24:36 -0400
Received: by wx-out-0506.google.com with SMTP id h31so713552wxd
        for <netdev@vger.kernel.org>; Fri, 04 May 2007 04:24:35 -0700 (PDT)
In-Reply-To: <463ACE47.6080807@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/4/07, Eric Dumazet <dada1@cosmosbay.com> wrote:
> Arnaldo Carvalho de Melo a =E9crit :
> >
> > [acme@mica linux-2.6]$ pahole -C sk_buff_head net/core/sock.o
> > struct sk_buff_head {
> >       struct sk_buff *           next;                 /*     0    =
 8 */
> >       struct sk_buff *           prev;                 /*     8    =
 8 */
> >       __u32                      qlen;                 /*    16    =
 4 */
> >       spinlock_t                 lock;                 /*    20    =
 8 */
> > }; /* size: 32, cachelines: 1 */
> >    /* padding: 4 */
> >    /* last cacheline: 32 bytes */
>
>
> Hum, maybe not enough tea this morning, but I always thought spinlock=
_t size
> was 4 bytes....

Well, unfolding sk_buff_head to see the details:

[acme@mica linux-2.6]$ pahole --expand_types -C sk_buff_head net/core/s=
ock.o
/* <9a61> /home/acme/git/linux-2.6/include/linux/skbuff.h:111 */
struct sk_buff_head {
        struct sk_buff *           next;              /*     0     8 */
        struct sk_buff *           prev;              /*     8     8 */
        /* typedef __u32 */ unsigned int qlen;        /*    16     4 */
        /* typedef spinlock_t */ struct {
                /* typedef raw_spinlock_t */ struct {
                        unsigned int slock;           /*    20     4 */
                } raw_lock; /*    20     4 */
                unsigned int       break_lock;        /*    24     4 */
        } lock; /*    20     8 */
}; /* size: 32, cachelines: 1 */
   /* padding: 4 */
   /* last cacheline: 32 bytes */

#if defined(CONFIG_PREEMPT) && defined(CONFIG_SMP)
        unsigned int break_lock;
#endif

Disabling CONFIG_PREEMPT makes you regain your confidence in the
quality of your tea:

[acme@mica linux-2.6]$ pahole --expand_types -C sk_buff_head net/core/s=
ock.o
/* <9a40> /home/acme/git/linux-2.6/include/linux/skbuff.h:111 */
struct sk_buff_head {
        struct sk_buff *           next;              /*     0     8 */
        struct sk_buff *           prev;              /*     8     8 */
        /* typedef __u32 */ unsigned int qlen;        /*    16     4 */
        /* typedef spinlock_t */ struct {
                /* typedef raw_spinlock_t */ struct {
                        unsigned int slock;           /*    20     4 */
                } raw_lock; /*    20     4 */
        } lock; /*    20     4 */
}; /* size: 24, cachelines: 1 */
   /* last cacheline: 24 bytes */

And then struct sock gets leaner too:

[acme@mica linux-2.6]$ pahole --expand_types -C sock net/core/sock.o
/* <7a57> /home/acme/git/linux-2.6/include/linux/net.h:114 */
struct sock {
	struct sock_common {
		short unsigned int skc_family;           /*    0     2 */
		volatile unsigned char  skc_state;       /*    2     1 */
		unsigned char      skc_reuse;            /*    3     1 */
		int                skc_bound_dev_if;     /*    4     4 */
		struct hlist_node {
			struct hlist_node * next;        /*    8     8 */
			struct hlist_node * * pprev;     /*   16     8 */
		} skc_node; /*    8    16 */
		struct hlist_node {
			struct hlist_node * next;        /*   24     8 */
			struct hlist_node * * pprev;     /*   32     8 */
		} skc_bind_node; /*   24    16 */
		/* typedef atomic_t */ struct {
			int        counter;              /*   40     4 */
		} skc_refcnt; /*   40     4 */
		unsigned int       skc_hash;             /*   44     4 */
		struct proto *     skc_prot;             /*   48     8 */
	} __sk_common; /*    0    56 */
	unsigned char              sk_shutdown:2;        /*   56     1 */
	unsigned char              sk_no_check:2;        /*   56     1 */
	unsigned char              sk_userlocks:4;       /*   56     1 */
	unsigned char              sk_protocol;          /*   57     1 */
	short unsigned int         sk_type;              /*   58     2 */
	int                        sk_rcvbuf;            /*   60     4 */
	/* --- cacheline 1 boundary (64 bytes) --- */
	/* typedef socket_lock_t */ struct {
		/* typedef spinlock_t */ struct {
			/* typedef raw_spinlock_t */ struct {
				unsigned int slock;      /*   64     4 */
			} raw_lock; /*   64     4 */
		} slock; /*   64     4 */
		struct sock_iocb * owner;                /*   72     8 */
		/* typedef wait_queue_head_t */ struct __wait_queue_head {
			/* typedef spinlock_t */ struct {
				/* typedef raw_spinlock_t */ struct {
					unsigned int slock; /*   80     4 */
				} raw_lock; /*   80     4 */
			} lock; /*   80     4 */

			/* XXX 4 bytes hole, try to pack */

			struct list_head {
				struct list_head * next; /*   88     8 */
				struct list_head * prev; /*   96     8 */
			} task_list; /*   88    16 */
		} wq; /*   80    24 */
	} sk_lock; /*   64    40 */
	struct {
		struct sk_buff *   head;                 /*  104     8 */
		struct sk_buff *   tail;                 /*  112     8 */
	} sk_backlog;                                    /*  104    16 */
	wait_queue_head_t *        sk_sleep;             /*  120     8 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	struct dst_entry *         sk_dst_cache;         /*  128     8 */
	struct xfrm_policy *       sk_policy[2];         /*  136    16 */
	/* typedef rwlock_t */ struct {
		/* typedef raw_rwlock_t */ struct {
			unsigned int lock;               /*  152     4 */
		} raw_lock; /*  152     4 */
	} sk_dst_lock; /*  152     4 */
	/* typedef atomic_t */ struct {
		int                counter;              /*  156     4 */
	} sk_rmem_alloc; /*  156     4 */
	/* typedef atomic_t */ struct {
		int                counter;              /*  160     4 */
	} sk_wmem_alloc; /*  160     4 */
	/* typedef atomic_t */ struct {
		int                counter;              /*  164     4 */
	} sk_omem_alloc; /*  164     4 */
	int                        sk_sndbuf;            /*  168     4 */

	/* XXX 4 bytes hole, try to pack */

	struct sk_buff_head {
		struct sk_buff *   next;                 /*  176     8 */
		struct sk_buff *   prev;                 /*  184     8 */
		/* typedef __u32 */ unsigned int qlen;   /*  192     4 */
		/* typedef spinlock_t */ struct {
			/* typedef raw_spinlock_t */ struct {
				unsigned int slock;      /*  196     4 */
			} raw_lock; /*  196     4 */
		} lock; /*  196     4 */
	} sk_receive_queue; /*  176    24 */
	/* --- cacheline 3 boundary (192 bytes) was 8 bytes ago --- */
	struct sk_buff_head {
		struct sk_buff *   next;                 /*  200     8 */
		struct sk_buff *   prev;                 /*  208     8 */
		/* typedef __u32 */ unsigned int qlen;   /*  216     4 */
		/* typedef spinlock_t */ struct {
			/* typedef raw_spinlock_t */ struct {
				unsigned int slock;      /*  220     4 */
			} raw_lock; /*  220     4 */
		} lock; /*  220     4 */
	} sk_write_queue; /*  200    24 */
	struct sk_buff_head {
		struct sk_buff *   next;                 /*  224     8 */
		struct sk_buff *   prev;                 /*  232     8 */
		/* typedef __u32 */ unsigned int qlen;   /*  240     4 */
		/* typedef spinlock_t */ struct {
			/* typedef raw_spinlock_t */ struct {
				unsigned int slock;      /*  244     4 */
			} raw_lock; /*  244     4 */
		} lock; /*  244     4 */
	} sk_async_wait_queue; /*  224    24 */
	int                        sk_wmem_queued;       /*  248     4 */
	int                        sk_forward_alloc;     /*  252     4 */
	/* --- cacheline 4 boundary (256 bytes) --- */
	/* typedef gfp_t */ unsigned int sk_allocation;  /*  256     4 */
	int                        sk_route_caps;        /*  260     4 */
	int                        sk_gso_type;          /*  264     4 */
	int                        sk_rcvlowat;          /*  268     4 */
	long unsigned int          sk_flags;             /*  272     8 */
	long unsigned int          sk_lingertime;        /*  280     8 */
	struct sk_buff_head {
		struct sk_buff *   next;                 /*  288     8 */
		struct sk_buff *   prev;                 /*  296     8 */
		/* typedef __u32 */ unsigned int qlen;   /*  304     4 */
		/* typedef spinlock_t */ struct {
			/* typedef raw_spinlock_t */ struct {
				unsigned int slock;      /*  308     4 */
			} raw_lock; /*  308     4 */
		} lock; /*  308     4 */
	} sk_error_queue; /*  288    24 */
	struct proto *             sk_prot_creator;      /*  312     8 */
	/* --- cacheline 5 boundary (320 bytes) --- */
	/* typedef rwlock_t */ struct {
		/* typedef raw_rwlock_t */ struct {
			unsigned int lock;               /*  320     4 */
		} raw_lock; /*  320     4 */
	} sk_callback_lock; /*  320     4 */
	int                        sk_err;               /*  324     4 */
	int                        sk_err_soft;          /*  328     4 */
	short unsigned int         sk_ack_backlog;       /*  332     2 */
	short unsigned int         sk_max_ack_backlog;   /*  334     2 */
	/* typedef __u32 */ unsigned int sk_priority;    /*  336     4 */
	struct ucred {
		/* typedef __u32 */ unsigned int pid;    /*  340     4 */
		/* typedef __u32 */ unsigned int uid;    /*  344     4 */
		/* typedef __u32 */ unsigned int gid;    /*  348     4 */
	} sk_peercred; /*  340    12 */
	long int                   sk_rcvtimeo;          /*  352     8 */
	long int                   sk_sndtimeo;          /*  360     8 */
	struct sk_filter *         sk_filter;            /*  368     8 */
	void *                     sk_protinfo;          /*  376     8 */
	/* --- cacheline 6 boundary (384 bytes) --- */
	struct timer_list {
		struct list_head {
			struct list_head * next;         /*  384     8 */
			struct list_head * prev;         /*  392     8 */
		} entry; /*  384    16 */
		long unsigned int  expires;              /*  400     8 */
		void (*function)(long unsigned int);     /*  408     8 */
		long unsigned int  data;                 /*  416     8 */
		struct tvec_t_base_s * base;             /*  424     8 */
	} sk_timer; /*  384    48 */
	/* typedef ktime_t */ union {
		/* typedef s64 */ long long int tv64;    /*          8 */
	} sk_stamp; /*  432     8 */
	struct socket *            sk_socket;            /*  440     8 */
	/* --- cacheline 7 boundary (448 bytes) --- */
	void *                     sk_user_data;         /*  448     8 */
	struct page *              sk_sndmsg_page;       /*  456     8 */
	struct sk_buff *           sk_send_head;         /*  464     8 */
	/* typedef __u32 */ unsigned int sk_sndmsg_off;  /*  472     4 */
	int                        sk_write_pending;     /*  476     4 */
	void *                     sk_security;          /*  480     8 */
	void (*sk_state_change)(struct sock *);          /*  488     8 */
	void (*sk_data_ready)(struct sock *, int);       /*  496     8 */
	void (*sk_write_space)(struct sock *);           /*  504     8 */
	/* --- cacheline 8 boundary (512 bytes) --- */
	void (*sk_error_report)(struct sock *);          /*  512     8 */
	int  (*sk_backlog_rcv)(struct sock *,
                               struct sk_buff *);        /*  520     8 =
*/
	void (*sk_destruct)(struct sock *);              /*  528     8 */
}; /* size: 536, cachelines: 9 */
   /* sum members: 532, holes: 1, sum holes: 4 */
   /* last cacheline: 24 bytes */

- Arnaldo
