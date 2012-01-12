From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: conntrack, suspicious RCU usage
Date: Thu, 12 Jan 2012 09:15:12 +0100
Message-ID: <201201120915.12668.hans.schillstrom@ericsson.com>
References: <201201111025.50994.hans.schillstrom@ericsson.com> <1326288835.2767.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1326293812.2767.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326293812.2767.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 January 2012 15:56:52 Eric Dumazet wrote:
> Le mercredi 11 janvier 2012 =C3=A0 14:33 +0100, Eric Dumazet a =C3=A9=
crit :
> > Le mercredi 11 janvier 2012 =C3=A0 14:24 +0100, Hans Schillstrom a =
=C3=A9crit :
> > > On Wednesday 11 January 2012 11:01:51 Eric Dumazet wrote:
> >=20
> > > > Hmm, we either need to take rcu_read_lock() while calling
> > > > __nf_ct_l3proto_find(), or define a variant using
> > > > rcu_dereference_protected() in places we hold nf_conntrack_lock
> > > >=20
> > > I made a qick test with locks /unlocks in
> > > __nf_ct_l3proto_find() and __nf_ct_l4proto_find()
> > >=20
> > > 	rcu_read_lock();
> > > ...
> > > 	rcu_read_unlock();
> > > 	return retp;
> > >=20
> > > It seems to help, I cant see the dump anymore and everything else=
 that I run works ...
> > >=20
> > >=20
> >=20
> > You cant do that, its just a brown paper bag :)
> >=20
> > If "retp" is returned, then the caller must handle the rcu_read_unl=
ock()
> > itself, after all possible "retp" dereferences.
> >=20
> > But really adding rcu_read_lock() should not be necessary on paths =
we
> > own the conntrack lock. We should use rcu_dereference_protected()
> > instead.
> >=20
>=20
> Well, __nf_ct_l4proto_find() being out of line and the way we already
> use rcu_read_lock() in this code, it seems following patch is
> the most natural way to cope with these lockdep warnings.
>=20
> Thanks
>=20
> [PATCH] netfilter: ctnetlink: fix lockep splats
>=20
> net/netfilter/nf_conntrack_proto.c:70 suspicious rcu_dereference_chec=
k() usage!
> =20
> other info that might help us debug this:
> =20
> =20
> rcu_scheduler_active =3D 1, debug_locks =3D 0
> 3 locks held by conntrack/3235:
>  #0:  (nfnl_mutex){+.+.+.}, at: [<ffffffff81603537>]
> nfnl_lock+0x17/0x20
>  #1:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff815fbd72>]
> netlink_dump+0x32/0x240
>  #2:  (nf_conntrack_lock){+.-...}, at: [<ffffffffa0115d2e>]
> ctnetlink_dump_table+0x3e/0x170 [nf_conntrack_netlink]
> =20
> stack backtrace:
> Pid: 3235, comm: conntrack Tainted: G        W    3.2.0+ #511
> Call Trace:
>  [<ffffffff8108ce45>] lockdep_rcu_suspicious+0xe5/0x100
>  [<ffffffffa00ec6e1>] __nf_ct_l4proto_find+0x81/0xb0 [nf_conntrack]
>  [<ffffffffa0115675>] ctnetlink_fill_info+0x215/0x5f0 [nf_conntrack_n=
etlink]
>  [<ffffffffa0115dc1>] ctnetlink_dump_table+0xd1/0x170 [nf_conntrack_n=
etlink]
>  [<ffffffff815fbdbf>] netlink_dump+0x7f/0x240
>  [<ffffffff81090f9d>] ? trace_hardirqs_on+0xd/0x10
>  [<ffffffff815fd34f>] netlink_dump_start+0xdf/0x190
>  [<ffffffffa0111490>] ? ctnetlink_change_nat_seq_adj+0x160/0x160 [nf_=
conntrack_netlink]
>  [<ffffffffa0115cf0>] ? ctnetlink_get_conntrack+0x2a0/0x2a0 [nf_connt=
rack_netlink]
>  [<ffffffffa0115ad9>] ctnetlink_get_conntrack+0x89/0x2a0 [nf_conntrac=
k_netlink]
>  [<ffffffff81603a47>] nfnetlink_rcv_msg+0x467/0x5f0
>  [<ffffffff81603a7c>] ? nfnetlink_rcv_msg+0x49c/0x5f0
>  [<ffffffff81603922>] ? nfnetlink_rcv_msg+0x342/0x5f0
>  [<ffffffff81071b21>] ? get_parent_ip+0x11/0x50
>  [<ffffffff816035e0>] ? nfnetlink_subsys_register+0x60/0x60
>  [<ffffffff815fed49>] netlink_rcv_skb+0xa9/0xd0
>  [<ffffffff81603475>] nfnetlink_rcv+0x15/0x20
>  [<ffffffff815fe70e>] netlink_unicast+0x1ae/0x1f0
>  [<ffffffff815fea16>] netlink_sendmsg+0x2c6/0x320
>  [<ffffffff815b2a87>] sock_sendmsg+0x117/0x130
>  [<ffffffff81125093>] ? might_fault+0x53/0xb0
>  [<ffffffff811250dc>] ? might_fault+0x9c/0xb0
>  [<ffffffff81125093>] ? might_fault+0x53/0xb0
>  [<ffffffff815b5991>] ? move_addr_to_kernel+0x71/0x80
>  [<ffffffff815b644e>] sys_sendto+0xfe/0x130
>  [<ffffffff815b5c94>] ? sys_bind+0xb4/0xd0
>  [<ffffffff817a8a0e>] ? retint_swapgs+0xe/0x13
>  [<ffffffff817afcd2>] system_call_fastpath+0x16/0x1b
>=20
>=20
> Reported-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

Tested-by: Hans Schillstrom <hans.schillstrom@ericsson.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/netfilter/nf_conntrack_netlink.c |   31 ++++++++++++++----------=
-
>  1 file changed, 18 insertions(+), 13 deletions(-)
>=20
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_=
conntrack_netlink.c
> index e07dc3a..14840d9 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -110,15 +110,15 @@ ctnetlink_dump_tuples(struct sk_buff *skb,
>  	struct nf_conntrack_l3proto *l3proto;
>  	struct nf_conntrack_l4proto *l4proto;
> =20
> +	rcu_read_lock();
>  	l3proto =3D __nf_ct_l3proto_find(tuple->src.l3num);
>  	ret =3D ctnetlink_dump_tuples_ip(skb, tuple, l3proto);
> =20
> -	if (unlikely(ret < 0))
> -		return ret;
> -
> -	l4proto =3D __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.proto=
num);
> -	ret =3D ctnetlink_dump_tuples_proto(skb, tuple, l4proto);
> -
> +	if (ret >=3D 0) {
> +		l4proto =3D __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.prot=
onum);
> +		ret =3D ctnetlink_dump_tuples_proto(skb, tuple, l4proto);
> +	}
> +	rcu_read_unlock();
>  	return ret;
>  }
> =20
> @@ -703,6 +703,7 @@ ctnetlink_dump_table(struct sk_buff *skb, struct =
netlink_callback *cb)
>  	struct hlist_nulls_node *n;
>  	struct nfgenmsg *nfmsg =3D nlmsg_data(cb->nlh);
>  	u_int8_t l3proto =3D nfmsg->nfgen_family;
> +	int res;
> =20
>  	spin_lock_bh(&nf_conntrack_lock);
>  	last =3D (struct nf_conn *)cb->args[1];
> @@ -723,11 +724,14 @@ restart:
>  					continue;
>  				cb->args[1] =3D 0;
>  			}
> -			if (ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
> +			rcu_read_lock();
> +			res =3D ctnetlink_fill_info(skb, NETLINK_CB(cb->skb).pid,
>  						cb->nlh->nlmsg_seq,
>  						NFNL_MSG_TYPE(
>  							cb->nlh->nlmsg_type),
> -						ct) < 0) {
> +						ct);
> +			rcu_read_unlock();
> +			if (res < 0) {
>  				nf_conntrack_get(&ct->ct_general);
>  				cb->args[1] =3D (unsigned long)ct;
>  				goto out;
> @@ -1626,17 +1630,18 @@ ctnetlink_exp_dump_mask(struct sk_buff *skb,
>  	if (!nest_parms)
>  		goto nla_put_failure;
> =20
> +	rcu_read_lock();
>  	l3proto =3D __nf_ct_l3proto_find(tuple->src.l3num);
>  	ret =3D ctnetlink_dump_tuples_ip(skb, &m, l3proto);
> +	if (ret >=3D 0) {
> +		l4proto =3D __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.prot=
onum);
> +		ret =3D ctnetlink_dump_tuples_proto(skb, &m, l4proto);
> +	}
> +	rcu_read_unlock();
> =20
>  	if (unlikely(ret < 0))
>  		goto nla_put_failure;
> =20
> -	l4proto =3D __nf_ct_l4proto_find(tuple->src.l3num, tuple->dst.proto=
num);
> -	ret =3D ctnetlink_dump_tuples_proto(skb, &m, l4proto);
> -	if (unlikely(ret < 0))
> -		goto nla_put_failure;
> -
>  	nla_nest_end(skb, nest_parms);
> =20
>  	return 0;
>=20
>=20
> --
Thank's Eric
It works I cant get the fault any more.

Tested-by: Hans Schillstrom <hans.schillstrom@ericsson.com>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
