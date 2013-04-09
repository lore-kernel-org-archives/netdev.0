From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Tue, 09 Apr 2013 09:19:30 -0400
Message-ID: <28452040.xEi3pLPik0@sifl>
References: <3505145.vfXt1x4t0P@sifl> <1365469759.3887.69.camel@edumazet-glaptop> <51636DEB.5000308@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28198 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760108Ab3DINTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:19:38 -0400
In-Reply-To: <51636DEB.5000308@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 06:24:59 PM Casey Schaufler wrote:
> On 4/8/2013 6:09 PM, Eric Dumazet wrote:
> > On Mon, 2013-04-08 at 17:59 -0700, Casey Schaufler wrote:
> >> I don't see that with adding 4 bytes. Again, I'm willing to be
> >> educated if I'm wrong.
> > 
> > Feel free to add 4 bytes without having the 'align to 8 bytes' problem
> > on 64 bit arches. Show us your patch.
> 
> Recall that it's replacing an existing 4 byte value with an 8 byte value.
> My compiler days were quite short and long ago, but it would seem that
> an 8 byte value ought not have an 'align to 8 bytes' problem.
> 
> Again, I'm willing to be educated.

Armed with a cup of coffee I took a look at the sk_buff structure this morning 
with the pahole tool and using the current sk_buff if we turn on all the 
#ifdefs here is what I see on x86_64:

struct sk_buff {
        struct sk_buff *           next;                 /*     0     8 */
        struct sk_buff *           prev;                 /*     8     8 */
        ktime_t                    tstamp;               /*    16     8 */
        struct sock *              sk;                   /*    24     8 */
        struct net_device *        dev;                  /*    32     8 */
        char                       cb[48];               /*    40    48 */
        /* --- cacheline 1 boundary (64 bytes) was 24 bytes ago --- */
        long unsigned int          _skb_refdst;          /*    88     8 */
        struct sec_path *          sp;                   /*    96     8 */
        unsigned int               len;                  /*   104     4 */
        unsigned int               data_len;             /*   108     4 */
        __u16                      mac_len;              /*   112     2 */
        __u16                      hdr_len;              /*   114     2 */
        union {
                __wsum             csum;                 /*           4 */
                struct {
                        __u16      csum_start;           /*   116     2 */
                        __u16      csum_offset;          /*   118     2 */
                };                                       /*           4 */
        };                                               /*   116     4 */
        __u32                      priority;             /*   120     4 */
        int                        flags1_begin[0];      /*   124     0 */
        __u8                       local_df:1;           /*   124: 7  1 */
        __u8                       cloned:1;             /*   124: 6  1 */
        __u8                       ip_summed:2;          /*   124: 4  1 */
        __u8                       nohdr:1;              /*   124: 3  1 */
        __u8                       nfctinfo:3;           /*   124: 0  1 */
        __u8                       pkt_type:3;           /*   125: 5  1 */
        __u8                       fclone:2;             /*   125: 3  1 */
        __u8                       ipvs_property:1;      /*   125: 2  1 */
        __u8                       peeked:1;             /*   125: 1  1 */
        __u8                       nf_trace:1;           /*   125: 0  1 */

        /* XXX 2 bytes hole, try to pack */

        /* --- cacheline 2 boundary (128 bytes) --- */
        int                        flags1_end[0];        /*   128     0 */
        __be16                     protocol;             /*   128     2 */

        /* XXX 6 bytes hole, try to pack */

        void                       (*destructor)(struct sk_buff *); /*   136     
8 */
        struct nf_conntrack *      nfct;                 /*   144     8 */
        struct sk_buff *           nfct_reasm;           /*   152     8 */
        struct nf_bridge_info *    nf_bridge;            /*   160     8 */
        int                        skb_iif;              /*   168     4 */
        __u32                      rxhash;               /*   172     4 */
        __u16                      vlan_tci;             /*   176     2 */
        __u16                      tc_index;             /*   178     2 */
        __u16                      tc_verd;              /*   180     2 */
        __u16                      queue_mapping;        /*   182     2 */
        int                        flags2_begin[0];      /*   184     0 */
        __u8                       ndisc_nodetype:2;     /*   184: 6  1 */
        __u8                       pfmemalloc:1;         /*   184: 5  1 */
        __u8                       ooo_okay:1;           /*   184: 4  1 */
        __u8                       l4_rxhash:1;          /*   184: 3  1 */
        __u8                       wifi_acked_valid:1;   /*   184: 2  1 */
        __u8                       wifi_acked:1;         /*   184: 1  1 */
        __u8                       no_fcs:1;             /*   184: 0  1 */
        __u8                       head_frag:1;          /*   185: 7  1 */
        __u8                       encapsulation:1;      /*   185: 6  1 */

        /* XXX 6 bits hole, try to pack */
        /* XXX 2 bytes hole, try to pack */

        int                        flags2_end[0];        /*   188     0 */
        dma_cookie_t               dma_cookie;           /*   188     4 */
        /* --- cacheline 3 boundary (192 bytes) --- */
        __u32                      secmark;              /*   192     4 */
        union {
                __u32              mark;                 /*           4 */
                __u32              dropcount;            /*           4 */
                __u32              reserved_tailroom;    /*           4 */
        };                                               /*   196     4 */
        sk_buff_data_t             inner_transport_header; /*   200     8 */
        sk_buff_data_t             inner_network_header; /*   208     8 */
        sk_buff_data_t             transport_header;     /*   216     8 */
        sk_buff_data_t             network_header;       /*   224     8 */
        sk_buff_data_t             mac_header;           /*   232     8 */
        sk_buff_data_t             tail;                 /*   240     8 */
        sk_buff_data_t             end;                  /*   248     8 */
        /* --- cacheline 4 boundary (256 bytes) --- */
        unsigned char *            head;                 /*   256     8 */
        unsigned char *            data;                 /*   264     8 */
        unsigned int               truesize;             /*   272     4 */
        atomic_t                   users;                /*   276     4 */

        /* size: 280, cachelines: 5, members: 62 */
        /* sum members: 270, holes: 3, sum holes: 10 */
        /* bit holes: 1, sum bit holes: 6 bits */
        /* last cacheline: 24 bytes */
};

It looks like there some holes we might be able to capitalize on.  If we 
remove "secmark" (we can handle it inside a security blob) and move "protocol" 
to after the flags2 bit field we can make an aligned 8 byte hold for a 
security blob before "destructor".  According to pahole the structure size 
stays the same and the only field which moves to a different cacheline is 
"dma_cookie" which moves from cacheline 2 to 3.  Here is the pahole output:

struct sk_buff_test {
        struct sk_buff *           next;                 /*     0     8 */
        struct sk_buff *           prev;                 /*     8     8 */
        ktime_t                    tstamp;               /*    16     8 */
        struct sock *              sk;                   /*    24     8 */
        struct net_device *        dev;                  /*    32     8 */
        char                       cb[48];               /*    40    48 */
        /* --- cacheline 1 boundary (64 bytes) was 24 bytes ago --- */
        long unsigned int          _skb_refdst;          /*    88     8 */
        struct sec_path *          sp;                   /*    96     8 */
        unsigned int               len;                  /*   104     4 */
        unsigned int               data_len;             /*   108     4 */
        __u16                      mac_len;              /*   112     2 */
        __u16                      hdr_len;              /*   114     2 */
        union {
                __wsum             csum;                 /*           4 */
                struct {
                        __u16      csum_start;           /*   116     2 */
                        __u16      csum_offset;          /*   118     2 */
                };                                       /*           4 */
        };                                               /*   116     4 */
        __u32                      priority;             /*   120     4 */
        int                        flags1_begin[0];      /*   124     0 */
        __u8                       local_df:1;           /*   124: 7  1 */
        __u8                       cloned:1;             /*   124: 6  1 */
        __u8                       ip_summed:2;          /*   124: 4  1 */
        __u8                       nohdr:1;              /*   124: 3  1 */
        __u8                       nfctinfo:3;           /*   124: 0  1 */
        __u8                       pkt_type:3;           /*   125: 5  1 */
        __u8                       fclone:2;             /*   125: 3  1 */
        __u8                       ipvs_property:1;      /*   125: 2  1 */
        __u8                       peeked:1;             /*   125: 1  1 */
        __u8                       nf_trace:1;           /*   125: 0  1 */

        /* XXX 2 bytes hole, try to pack */

        /* --- cacheline 2 boundary (128 bytes) --- */
        int                        flags1_end[0];        /*   128     0 */
        void *                     security;             /*   128     8 */
        void                       (*destructor)(struct sk_buff *); /*   136     
8 */
        struct nf_conntrack *      nfct;                 /*   144     8 */
        struct sk_buff *           nfct_reasm;           /*   152     8 */
        struct nf_bridge_info *    nf_bridge;            /*   160     8 */
        int                        skb_iif;              /*   168     4 */
        __u32                      rxhash;               /*   172     4 */
        __u16                      vlan_tci;             /*   176     2 */
        __u16                      tc_index;             /*   178     2 */
        __u16                      tc_verd;              /*   180     2 */
        __u16                      queue_mapping;        /*   182     2 */
        int                        flags2_begin[0];      /*   184     0 */
        __u8                       ndisc_nodetype:2;     /*   184: 6  1 */
        __u8                       pfmemalloc:1;         /*   184: 5  1 */
        __u8                       ooo_okay:1;           /*   184: 4  1 */
        __u8                       l4_rxhash:1;          /*   184: 3  1 */
        __u8                       wifi_acked_valid:1;   /*   184: 2  1 */
        __u8                       wifi_acked:1;         /*   184: 1  1 */
        __u8                       no_fcs:1;             /*   184: 0  1 */
        __u8                       head_frag:1;          /*   185: 7  1 */
        __u8                       encapsulation:1;      /*   185: 6  1 */

        /* XXX 6 bits hole, try to pack */
        /* XXX 2 bytes hole, try to pack */

        int                        flags2_end[0];        /*   188     0 */
        __be16                     protocol;             /*   188     2 */

        /* XXX 2 bytes hole, try to pack */

        /* --- cacheline 3 boundary (192 bytes) --- */
        dma_cookie_t               dma_cookie;           /*   192     4 */
        union {
                __u32              mark;                 /*           4 */
                __u32              dropcount;            /*           4 */
                __u32              reserved_tailroom;    /*           4 */
        };                                               /*   196     4 */
        sk_buff_data_t             inner_transport_header; /*   200     8 */
        sk_buff_data_t             inner_network_header; /*   208     8 */
        sk_buff_data_t             transport_header;     /*   216     8 */
        sk_buff_data_t             network_header;       /*   224     8 */
        sk_buff_data_t             mac_header;           /*   232     8 */
        sk_buff_data_t             tail;                 /*   240     8 */
        sk_buff_data_t             end;                  /*   248     8 */
        /* --- cacheline 4 boundary (256 bytes) --- */
        unsigned char *            head;                 /*   256     8 */
        unsigned char *            data;                 /*   264     8 */
        unsigned int               truesize;             /*   272     4 */
        atomic_t                   users;                /*   276     4 */

        /* size: 280, cachelines: 5, members: 62 */
        /* sum members: 274, holes: 3, sum holes: 6 */
        /* bit holes: 1, sum bit holes: 6 bits */
        /* last cacheline: 24 bytes */
};

As Casey already mentioned, if this isn't acceptable please help me understand 
why.

-- 
paul moore
security and virtualization @ redhat
