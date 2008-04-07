From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling
	alignment holes in it.
Date: Mon, 7 Apr 2008 14:47:45 -0300
Message-ID: <20080407174745.GE15681@ghostprotocols.net>
References: <47FA4ADE.1020308@openvz.org> <47FA5426.10704@cosmosbay.com> <47FA5717.4070901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39818 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535AbYDGRsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 13:48:04 -0400
Content-Disposition: inline
In-Reply-To: <47FA5717.4070901@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Apr 07, 2008 at 07:17:11PM +0200, Eric Dumazet escreveu:
> Eric Dumazet a =E9crit :
>> Pavel Emelyanov a =E9crit :
>>> I've found a much easier way to shrink the net_device structure rat=
her=20
>>> that moving all the operations out of it. However, since
>>> the net_device may grow further, moving the operations into a
>>> separate place may look reasonable.
>>>
>>> The pahole tool showed, that there are a 124 and 80 bytes holes
>>> before the queue_lock and the _xmit_lock respectively. Moving most
>>> of the devices callbacks into the 2nd hole makes the sizeof of the
>>> structure be 1024 bytes.
>>>
>>>  =20
>> On 32 bits platform and CONFIG_X86_L1_CACHE_SHIFT=3D7
>> I presume :)
>>
>> Could you check if x86_64 machines with  X86_L1_CACHE_SHIFT =3D 7 or=
 8 dont=20
>> suffer from this patch ?
>>
>> At first glance I would say it seems OK, but this net_device is real=
ly=20
>> touchy for SMP performance :)
> I meant :
>
> X86_L1_CACHE_SHIFT =3D 6 (MK8 | MCORE2)  or 7 (others)

Info _before_ Pavel's patch, not that big holes.

[acme@doppio linux-2.6]$ getconf LEVEL1_DCACHE_LINESIZE
64

model name	: Intel(R) Core(TM)2 CPU         T7200  @ 2.00GHz

[acme@doppio linux-2.6]$ grep X86_L1_CACHE_SHIFT /boot/config-`uname -r=
`
CONFIG_X86_L1_CACHE_SHIFT=3D6

[acme@doppio linux-2.6]$ pahole -C net_device ../build/linux-2.6/doppio=
/net/core/dev.o=20
struct net_device {
	char                       name[16];             /*     0    16 */
	struct hlist_node          name_hlist;           /*    16    16 */
	long unsigned int          mem_end;              /*    32     8 */
	long unsigned int          mem_start;            /*    40     8 */
	long unsigned int          base_addr;            /*    48     8 */
	unsigned int               irq;                  /*    56     4 */
	unsigned char              if_port;              /*    60     1 */
	unsigned char              dma;                  /*    61     1 */

	/* XXX 2 bytes hole, try to pack */

	/* --- cacheline 1 boundary (64 bytes) --- */
	long unsigned int          state;                /*    64     8 */
	struct list_head           dev_list;             /*    72    16 */
	struct list_head           napi_list;            /*    88    16 */
	int                        (*init)(struct net_device *); /*   104     =
8 */
	long unsigned int          features;             /*   112     8 */
	struct net_device *        next_sched;           /*   120     8 */
	/* --- cacheline 2 boundary (128 bytes) --- */
	int                        ifindex;              /*   128     4 */
	int                        iflink;               /*   132     4 */
	struct net_device_stats *  (*get_stats)(struct net_device *); /*   136=
     8 */
	struct net_device_stats    stats;                /*   144   184 */
	/* --- cacheline 5 boundary (320 bytes) was 8 bytes ago --- */
	const struct iw_handler_def  * wireless_handlers; /*   328     8 */
	struct iw_public_data *    wireless_data;        /*   336     8 */
	const struct ethtool_ops  * ethtool_ops;         /*   344     8 */
	const struct header_ops  * header_ops;           /*   352     8 */
	unsigned int               flags;                /*   360     4 */
	short unsigned int         gflags;               /*   364     2 */
	short unsigned int         priv_flags;           /*   366     2 */
	short unsigned int         padded;               /*   368     2 */
	unsigned char              operstate;            /*   370     1 */
	unsigned char              link_mode;            /*   371     1 */
	unsigned int               mtu;                  /*   372     4 */
	short unsigned int         type;                 /*   376     2 */
	short unsigned int         hard_header_len;      /*   378     2 */

	/* XXX 4 bytes hole, try to pack */

	/* --- cacheline 6 boundary (384 bytes) --- */
	struct net_device *        master;               /*   384     8 */
	unsigned char              perm_addr[32];        /*   392    32 */
	unsigned char              addr_len;             /*   424     1 */

	/* XXX 1 byte hole, try to pack */

	short unsigned int         dev_id;               /*   426     2 */

	/* XXX 4 bytes hole, try to pack */

	struct dev_addr_list *     uc_list;              /*   432     8 */
	int                        uc_count;             /*   440     4 */
	int                        uc_promisc;           /*   444     4 */
	/* --- cacheline 7 boundary (448 bytes) --- */
	struct dev_addr_list *     mc_list;              /*   448     8 */
	int                        mc_count;             /*   456     4 */
	int                        promiscuity;          /*   460     4 */
	int                        allmulti;             /*   464     4 */

	/* XXX 4 bytes hole, try to pack */

	void *                     atalk_ptr;            /*   472     8 */
	void *                     ip_ptr;               /*   480     8 */
	void *                     dn_ptr;               /*   488     8 */
	void *                     ip6_ptr;              /*   496     8 */
	void *                     ec_ptr;               /*   504     8 */
	/* --- cacheline 8 boundary (512 bytes) --- */
	void *                     ax25_ptr;             /*   512     8 */
	struct wireless_dev *      ieee80211_ptr;        /*   520     8 */
	long unsigned int          last_rx;              /*   528     8 */
	unsigned char              dev_addr[32];         /*   536    32 */
	unsigned char              broadcast[32];        /*   568    32 */
	/* --- cacheline 9 boundary (576 bytes) was 24 bytes ago --- */
	spinlock_t                 ingress_lock;         /*   600     4 */

	/* XXX 4 bytes hole, try to pack */

	struct Qdisc *             qdisc_ingress;        /*   608     8 */

	/* XXX 24 bytes hole, try to pack */

	/* --- cacheline 10 boundary (640 bytes) --- */
	spinlock_t                 queue_lock;           /*   640     4 */

	/* XXX 4 bytes hole, try to pack */

	struct Qdisc *             qdisc;                /*   648     8 */
	struct Qdisc *             qdisc_sleeping;       /*   656     8 */
	struct list_head           qdisc_list;           /*   664    16 */
	long unsigned int          tx_queue_len;         /*   680     8 */
	struct sk_buff *           gso_skb;              /*   688     8 */

	/* XXX 8 bytes hole, try to pack */

	/* --- cacheline 11 boundary (704 bytes) --- */
	spinlock_t                 _xmit_lock;           /*   704     4 */
	int                        xmit_lock_owner;      /*   708     4 */
	void *                     priv;                 /*   712     8 */
	int                        (*hard_start_xmit)(struct sk_buff *, struct=
 net_device *); /*   720     8 */
	long unsigned int          trans_start;          /*   728     8 */
	int                        watchdog_timeo;       /*   736     4 */

	/* XXX 4 bytes hole, try to pack */

	struct timer_list          watchdog_timer;       /*   744    80 */

	/* XXX last struct has 4 bytes of padding */
	/* XXX 8 bytes hole, try to pack */

	/* --- cacheline 13 boundary (832 bytes) --- */
	atomic_t                   refcnt;               /*   832     4 */

	/* XXX 4 bytes hole, try to pack */

	struct list_head           todo_list;            /*   840    16 */
	struct hlist_node          index_hlist;          /*   856    16 */
	struct net_device *        link_watch_next;      /*   872     8 */
	enum {
		NETREG_UNINITIALIZED =3D 0,
		NETREG_REGISTERED =3D 1,
		NETREG_UNREGISTERING =3D 2,
		NETREG_UNREGISTERED =3D 3,
		NETREG_RELEASED =3D 4,
	} reg_state;                                     /*   880     4 */

	/* XXX 4 bytes hole, try to pack */

	void                       (*uninit)(struct net_device *); /*   888   =
  8 */
	/* --- cacheline 14 boundary (896 bytes) --- */
	void                       (*destructor)(struct net_device *); /*   89=
6     8 */
	int                        (*open)(struct net_device *); /*   904     =
8 */
	int                        (*stop)(struct net_device *); /*   912     =
8 */
	void                       (*change_rx_flags)(struct net_device *, int=
); /*   920     8 */
	void                       (*set_rx_mode)(struct net_device *); /*   9=
28     8 */
	void                       (*set_multicast_list)(struct net_device *);=
 /*   936     8 */
	int                        (*set_mac_address)(struct net_device *, voi=
d *); /*   944     8 */
	int                        (*validate_addr)(struct net_device *); /*  =
 952     8 */
	/* --- cacheline 15 boundary (960 bytes) --- */
	int                        (*do_ioctl)(struct net_device *, struct ifr=
eq *, int); /*   960     8 */
	int                        (*set_config)(struct net_device *, struct i=
fmap *); /*   968     8 */
	int                        (*change_mtu)(struct net_device *, int); /*=
   976     8 */
	void                       (*tx_timeout)(struct net_device *); /*   98=
4     8 */
	void                       (*vlan_rx_register)(struct net_device *, st=
ruct vlan_group *); /*   992     8 */
	void                       (*vlan_rx_add_vid)(struct net_device *, sho=
rt unsigned int); /*  1000     8 */
	void                       (*vlan_rx_kill_vid)(struct net_device *, sh=
ort unsigned int); /*  1008     8 */
	int                        (*neigh_setup)(struct net_device *, struct =
neigh_parms *); /*  1016     8 */
	/* --- cacheline 16 boundary (1024 bytes) --- */
	struct netpoll_info *      npinfo;               /*  1024     8 */
	void                       (*poll_controller)(struct net_device *); /*=
  1032     8 */
	struct net *               nd_net;               /*  1040     8 */
	struct net_bridge_port *   br_port;              /*  1048     8 */
	struct macvlan_port *      macvlan_port;         /*  1056     8 */
	struct device              dev;                  /*  1064   584 */
	/* --- cacheline 25 boundary (1600 bytes) was 48 bytes ago --- */
	struct attribute_group *   sysfs_groups[3];      /*  1648    24 */
	/* --- cacheline 26 boundary (1664 bytes) was 8 bytes ago --- */
	const struct rtnl_link_ops  * rtnl_link_ops;     /*  1672     8 */
	unsigned int               egress_subqueue_count; /*  1680     4 */

	/* XXX 4 bytes hole, try to pack */

	struct net_device_subqueue egress_subqueue[1];   /*  1688     8 */

	/* size: 1728, cachelines: 27 */
	/* sum members: 1617, holes: 14, sum holes: 79 */
	/* padding: 32 */
	/* paddings: 1, sum paddings: 4 */
};

Humm, I need to implement a way to inform pahole about fields that are
cacheline aligned, that together with --cacheline and --word_size would
allow us to try all these combinations, even --reorganize could use tha=
t
info...

- Arnaldo
