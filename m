From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Tue, 09 Apr 2013 10:19:22 -0400
Message-ID: <2238729.HES6agzVX2@sifl>
References: <3505145.vfXt1x4t0P@sifl> <28452040.xEi3pLPik0@sifl> <1365516022.3887.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365516022.3887.131.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, April 09, 2013 07:00:22 AM Eric Dumazet wrote:
> On Tue, 2013-04-09 at 09:19 -0400, Paul Moore wrote:
> > As Casey already mentioned, if this isn't acceptable please help me
> > understand why.
> 
> You see something which is not the reality. If you do such analysis,
> better do it properly, because any change you are going to submit will
> be doubly checked by people who really care.

I am attempting to do it properly, I simply made a mistake.  Ben also pointed 
it out.  As you wrote yesterday, "Lets go forward".

After fixing the BITS_PER_LONG problem I looked at it again and it appears 
that by simply replacing the "secmark" field with a blob we retain the size of 
the sk_buff as well as the cacheline positions of all the fields, e.g. 
dma_cookie no longer moves cachelines.  Thoughts?

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
        void *                     security;             /*   192     8 */
        union {
                __u32              mark;                 /*           4 */
                __u32              dropcount;            /*           4 */
                __u32              reserved_tailroom;    /*           4 */
        };                                               /*   200     4 */
        sk_buff_data_t             inner_transport_header; /*   204     4 */
        sk_buff_data_t             inner_network_header; /*   208     4 */
        sk_buff_data_t             transport_header;     /*   212     4 */
        sk_buff_data_t             network_header;       /*   216     4 */
        sk_buff_data_t             mac_header;           /*   220     4 */
        sk_buff_data_t             tail;                 /*   224     4 */
        sk_buff_data_t             end;                  /*   228     4 */
        unsigned char *            head;                 /*   232     8 */
        unsigned char *            data;                 /*   240     8 */
        unsigned int               truesize;             /*   248     4 */
        atomic_t                   users;                /*   252     4 */
        /* --- cacheline 4 boundary (256 bytes) --- */

        /* size: 256, cachelines: 4, members: 62 */
        /* sum members: 246, holes: 3, sum holes: 10 */
        /* bit holes: 1, sum bit holes: 6 bits */
};

-- 
paul moore
security and virtualization @ redhat

