From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [RFC] Wild and crazy ideas involving struct sk_buff
Date: Wed, 22 Aug 2007 19:06:10 -0300
Message-ID: <20070822220610.GD23220@ghostprotocols.net>
References: <200708221631.34234.paul.moore@hp.com> <20070822212005.GR32236@postel.suug.ch> <200708221726.36783.paul.moore@hp.com> <20070822.143627.62367286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.moore@hp.com, tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:48262 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763807AbXHVWGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 18:06:19 -0400
Received: by wr-out-0506.google.com with SMTP id 36so244513wra
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 15:06:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070822.143627.62367286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Aug 22, 2007 at 02:36:27PM -0700, David Miller escreveu:
> From: Paul Moore <paul.moore@hp.com>
> Date: Wed, 22 Aug 2007 17:26:36 -0400
> 
> > Was it just a thought, or was there some actual design/code/patchset
> > to go along with it that described the idea?
> 
> It was a thought mentioned at the first two netconfs, but it
> went nowhere because the more we discussed the implementation
> the more horrific it began to sound :-)

Which makes it more interesting to make it work :-)

Anyway, there is space there to be used, in 32 and 64 bits we have two
bytes after queue_mapping (this kernel doesn't have CONFIG_NET_SCHED nor
CONFIG_NET_CLS_ACT enabled, if the first was we wouldn't have the hole,
but if both, as its common in distro kernels, were we would have the 2
bytes hole, as we can see on the pahole output for the 64bits kernel,
that uses the kernel config used in the Red Hat kernels.

Bonus points would go to continue the skb offset fight and reduce the
size of mac_header to two bytes, and then moving it to just after
queue_mapping. Do that and you'll get some credits :-P

- Arnaldo

[acme@mica net-2.6.24]$ pahole -C sk_buff ../32bits/net/core/skbuff.o
struct sk_buff {
	struct sk_buff *           next;                 /*     0     4 */
	struct sk_buff *           prev;                 /*     4     4 */
	struct sock *              sk;                   /*     8     4 */
	ktime_t                    tstamp;               /*    12     8 */
	struct net_device *        dev;                  /*    20     4 */
	struct dst_entry *         dst;                  /*    24     4 */
	struct sec_path *          sp;                   /*    28     4 */
	char                       cb[48];               /*    32    48 */
	/* --- cacheline 1 boundary (64 bytes) was 16 bytes ago --- */
	unsigned int               len;                  /*    80     4 */
	unsigned int               data_len;             /*    84     4 */
	__u16                      mac_len;              /*    88     2 */
	__u16                      hdr_len;              /*    90     2 */
	union {
		__wsum             csum;                 /*           4 */
		struct {
			__u16      csum_start;           /*    92     2 */
			__u16      csum_offset;          /*    94     2 */
		}                                        /*           4 */
	};                                               /*    92     4 */
	__u32                      priority;             /*    96     4 */
	__u8                       local_df:1;           /*   100     1 */
	__u8                       cloned:1;             /*   100     1 */
	__u8                       ip_summed:2;          /*   100     1 */
	__u8                       nohdr:1;              /*   100     1 */
	__u8                       nfctinfo:3;           /*   100     1 */
	__u8                       pkt_type:3;           /*   101     1 */
	__u8                       fclone:2;             /*   101     1 */
	__u8                       ipvs_property:1;      /*   101     1 */
	__u8                       nf_trace:1;           /*   101     1 */

	/* XXX 1 bit hole, try to pack */

	__be16                     protocol;             /*   102     2 */
	void            (*destructor)(struct sk_buff *); /*   104     4 */
	int                        iif;                  /*   108     4 */
	__u16                      queue_mapping;        /*   112     2 */

	/* XXX 2 bytes hole, try to pack */

	__u32                      mark;                 /*   116     4 */
	sk_buff_data_t             transport_header;     /*   120     4 */
	sk_buff_data_t             network_header;       /*   124     4 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	sk_buff_data_t             mac_header;           /*   128     4 */
	sk_buff_data_t             tail;                 /*   132     4 */
	sk_buff_data_t             end;                  /*   136     4 */
	unsigned char *            head;                 /*   140     4 */
	unsigned char *            data;                 /*   144     4 */
	unsigned int               truesize;             /*   148     4 */
	atomic_t                   users;                /*   152     4 */

	/* size: 156, cachelines: 3 */
	/* sum members: 154, holes: 1, sum holes: 2 */
	/* bit holes: 1, sum bit holes: 1 bits */
	/* last cacheline: 28 bytes */
};

[acme@mica net-2.6.24]$ pahole -C sk_buff ../64bits/net/core/skbuff.o
struct sk_buff {
	struct sk_buff *           next;                 /*     0     8 */
	struct sk_buff *           prev;                 /*     8     8 */
	struct sock *              sk;                   /*    16     8 */
	ktime_t                    tstamp;               /*    24     8 */
	struct net_device *        dev;                  /*    32     8 */
	struct dst_entry *         dst;                  /*    40     8 */
	struct sec_path *          sp;                   /*    48     8 */
	char                       cb[48];               /*    56    48 */
	/* --- cacheline 1 boundary (64 bytes) was 40 bytes ago --- */
	unsigned int               len;                  /*   104     4 */
	unsigned int               data_len;             /*   108     4 */
	__u16                      mac_len;              /*   112     2 */
	__u16                      hdr_len;              /*   114     2 */
	union {
		__wsum             csum;                 /*           4 */
		struct {
			__u16      csum_start;           /*   116     2 */
			__u16      csum_offset;          /*   118     2 */
		}                                        /*           4 */
	};                                               /*   116     4 */
	__u32                      priority;             /*   120     4 */
	__u8                       local_df:1;           /*   124     1 */
	__u8                       cloned:1;             /*   124     1 */
	__u8                       ip_summed:2;          /*   124     1 */
	__u8                       nohdr:1;              /*   124     1 */
	__u8                       nfctinfo:3;           /*   124     1 */
	__u8                       pkt_type:3;           /*   125     1 */
	__u8                       fclone:2;             /*   125     1 */
	__u8                       ipvs_property:1;      /*   125     1 */
	__u8                       nf_trace:1;           /*   125     1 */

	/* XXX 1 bit hole, try to pack */

	__be16                     protocol;             /*   126     2 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	void            (*destructor)(struct sk_buff *); /*   128     8 */
	struct nf_conntrack *      nfct;                 /*   136     8 */
	struct sk_buff *           nfct_reasm;           /*   144     8 */
	struct nf_bridge_info *    nf_bridge;            /*   152     8 */
	int                        iif;                  /*   160     4 */
	__u16                      queue_mapping;        /*   164     2 */
	__u16                      tc_index;             /*   166     2 */
	__u16                      tc_verd;              /*   168     2 */

	/* XXX 2 bytes hole, try to pack */

	dma_cookie_t               dma_cookie;           /*   172     4 */
	__u32                      secmark;              /*   176     4 */
	__u32                      mark;                 /*   180     4 */
	sk_buff_data_t             transport_header;     /*   184     4 */
	sk_buff_data_t             network_header;       /*   188     4 */
	/* --- cacheline 3 boundary (192 bytes) --- */
	sk_buff_data_t             mac_header;           /*   192     4 */
	sk_buff_data_t             tail;                 /*   196     4 */
	sk_buff_data_t             end;                  /*   200     4 */

	/* XXX 4 bytes hole, try to pack */

	unsigned char *            head;                 /*   208     8 */
	unsigned char *            data;                 /*   216     8 */
	unsigned int               truesize;             /*   224     4 */
	atomic_t                   users;                /*   228     4 */

	/* size: 232, cachelines: 4 */
	/* sum members: 226, holes: 2, sum holes: 6 */
	/* bit holes: 1, sum bit holes: 1 bits */
	/* last cacheline: 40 bytes */
};
