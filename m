From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 net] packet: avoid panic in packet_getsockopt()
Date: Sat, 21 Oct 2017 03:11:53 +0800
Message-ID: <201710210201.6l3IUwxu%fengguang.wu@intel.com>
References: <1508368492.31614.153.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        John Sperbeck <jsperbeck@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46799 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752457AbdJTTMz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Oct 2017 15:12:55 -0400
Content-Disposition: inline
In-Reply-To: <1508368492.31614.153.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

[auto build test WARNING on net/master]

url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/packet-avoid-panic-in-packet_getsockopt/20171021-003615
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)


vim +3936 net/packet/af_packet.c

  3845	
  3846	static int packet_getsockopt(struct socket *sock, int level, int optname,
  3847				     char __user *optval, int __user *optlen)
  3848	{
  3849		int len;
  3850		int val, lv = sizeof(val);
  3851		struct sock *sk = sock->sk;
  3852		struct packet_sock *po = pkt_sk(sk);
  3853		void *data = &val;
  3854		union tpacket_stats_u st;
  3855		struct tpacket_rollover_stats rstats;
  3856		struct packet_rollover *rollover;
  3857	
  3858		if (level != SOL_PACKET)
  3859			return -ENOPROTOOPT;
  3860	
  3861		if (get_user(len, optlen))
  3862			return -EFAULT;
  3863	
  3864		if (len < 0)
  3865			return -EINVAL;
  3866	
  3867		switch (optname) {
  3868		case PACKET_STATISTICS:
  3869			spin_lock_bh(&sk->sk_receive_queue.lock);
  3870			memcpy(&st, &po->stats, sizeof(st));
  3871			memset(&po->stats, 0, sizeof(po->stats));
  3872			spin_unlock_bh(&sk->sk_receive_queue.lock);
  3873	
  3874			if (po->tp_version == TPACKET_V3) {
  3875				lv = sizeof(struct tpacket_stats_v3);
  3876				st.stats3.tp_packets += st.stats3.tp_drops;
  3877				data = &st.stats3;
  3878			} else {
  3879				lv = sizeof(struct tpacket_stats);
  3880				st.stats1.tp_packets += st.stats1.tp_drops;
  3881				data = &st.stats1;
  3882			}
  3883	
  3884			break;
  3885		case PACKET_AUXDATA:
  3886			val = po->auxdata;
  3887			break;
  3888		case PACKET_ORIGDEV:
  3889			val = po->origdev;
  3890			break;
  3891		case PACKET_VNET_HDR:
  3892			val = po->has_vnet_hdr;
  3893			break;
  3894		case PACKET_VERSION:
  3895			val = po->tp_version;
  3896			break;
  3897		case PACKET_HDRLEN:
  3898			if (len > sizeof(int))
  3899				len = sizeof(int);
  3900			if (len < sizeof(int))
  3901				return -EINVAL;
  3902			if (copy_from_user(&val, optval, len))
  3903				return -EFAULT;
  3904			switch (val) {
  3905			case TPACKET_V1:
  3906				val = sizeof(struct tpacket_hdr);
  3907				break;
  3908			case TPACKET_V2:
  3909				val = sizeof(struct tpacket2_hdr);
  3910				break;
  3911			case TPACKET_V3:
  3912				val = sizeof(struct tpacket3_hdr);
  3913				break;
  3914			default:
  3915				return -EINVAL;
  3916			}
  3917			break;
  3918		case PACKET_RESERVE:
  3919			val = po->tp_reserve;
  3920			break;
  3921		case PACKET_LOSS:
  3922			val = po->tp_loss;
  3923			break;
  3924		case PACKET_TIMESTAMP:
  3925			val = po->tp_tstamp;
  3926			break;
  3927		case PACKET_FANOUT:
  3928			val = (po->fanout ?
  3929			       ((u32)po->fanout->id |
  3930				((u32)po->fanout->type << 16) |
  3931				((u32)po->fanout->flags << 24)) :
  3932			       0);
  3933			break;
  3934		case PACKET_ROLLOVER_STATS:
  3935			rcu_read_lock();
> 3936			rollover = rcu_dereference(po->rollover);
  3937			if (rollover) {
  3938				rstats.tp_all = atomic_long_read(&rollover->num);
  3939				rstats.tp_huge = atomic_long_read(&rollover->num_huge);
  3940				rstats.tp_failed = atomic_long_read(&rollover->num_failed);
  3941				data = &rstats;
  3942				lv = sizeof(rstats);
  3943			}
  3944			rcu_read_unlock();
  3945			if (!rollover)
  3946				return -EINVAL;
  3947			break;
  3948		case PACKET_TX_HAS_OFF:
  3949			val = po->tp_tx_has_off;
  3950			break;
  3951		case PACKET_QDISC_BYPASS:
  3952			val = packet_use_direct_xmit(po);
  3953			break;
  3954		default:
  3955			return -ENOPROTOOPT;
  3956		}
  3957	
  3958		if (len > lv)
  3959			len = lv;
  3960		if (put_user(len, optlen))
  3961			return -EFAULT;
  3962		if (copy_to_user(optval, data, len))
  3963			return -EFAULT;
  3964		return 0;
  3965	}
  3966	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
