From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: kernel stack  trace using conntrack
Date: Tue, 16 Feb 2010 14:33:09 +0100
Message-ID: <4B7A9E95.103@netfilter.org>
References: <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D04@FRSPX100.fr01.awl.atosorigin.net>	 <1266313889.3045.1.camel@edumazet-laptop>	 <7EF5DBE4C76A7B4DA655334E9F2BFD26CED7BC8D54@FRSPX100.fr01.awl.atosorigin.net> <1266318928.3045.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ramblewski David <David.Ramblewski@atosorigin.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1266318928.3045.38.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> OK thanks David, I reproduced the problem on latest net-next-2.6 tree
> too. I wonder why nobody hit this before.

Hmm, my config had not NETFILTER_DEBUG enabled, that's why I didn't hit
that assertion.

> [352468.556484] ------------[ cut here ]------------
> [352468.556511] WARNING: at net/netfilter/nf_conntrack_extend.c:82
> __nf_ct_ext_add+0x1c2/0x1e0 [nf_conntrack]()
> [352468.556559] Hardware name: ProLiant BL460c G1
> [352468.556582] Modules linked in: nf_defrag_ipv4 nf_conntrack_netlink
> nf_conntrack sch_hfsc sch_sfq ipmi_devintf ipmi_si ipmi_msghandler hpilo
> bonding [last unloaded: nf_conntrack_ipv4]
> [352468.556675] Pid: 18852, comm: conntrack Tainted: G        W
> 2.6.33-rc5-02754-g0ea034c-dirty #545
> [352468.556721] Call Trace:
> [352468.556742]  [<c054d45f>] ? printk+0x1d/0x26
> [352468.556767]  [<c023bbc2>] warn_slowpath_common+0x72/0xa0
> [352468.556795]  [<fee75e42>] ? __nf_ct_ext_add+0x1c2/0x1e0
> [nf_conntrack]
> [352468.556825]  [<fee75e42>] ? __nf_ct_ext_add+0x1c2/0x1e0
> [nf_conntrack]
> [352468.556854]  [<c023bc0a>] warn_slowpath_null+0x1a/0x20
> [352468.556882]  [<fee75e42>] __nf_ct_ext_add+0x1c2/0x1e0 [nf_conntrack]
> [352468.556911]  [<fee70dcc>] ? nf_conntrack_alloc+0x10c/0x1a0
> [nf_conntrack]
> [352468.556940]  [<feecaf59>] ctnetlink_create_conntrack+0x339/0x360
> [nf_conntrack_netlink]
> [352468.556987]  [<feeca26b>] ? ctnetlink_parse_tuple+0x14b/0x1c0
> [nf_conntrack_netlink]
> [352468.557039]  [<fee6fd60>] ? __nf_conntrack_find+0x70/0x100
> [nf_conntrack]
> [352468.557068]  [<feecb090>] ctnetlink_new_conntrack+0x110/0x680
> [nf_conntrack_netlink]
> [352468.557113]  [<c04d93b5>] nfnetlink_rcv_msg+0x125/0x180
> [352468.557140]  [<c054ec57>] ? __mutex_lock_slowpath+0x197/0x230
> [352468.557167]  [<c04d9290>] ? nfnetlink_rcv_msg+0x0/0x180
> [352468.557194]  [<c04d5896>] netlink_rcv_skb+0x96/0xc0
> [352468.557219]  [<c04d927c>] nfnetlink_rcv+0x1c/0x30
> [352468.557245]  [<c04d5545>] netlink_unicast+0x255/0x2a0
> [352468.557274]  [<c04d5d3f>] netlink_sendmsg+0x1af/0x2b0
> [352468.557300]  [<c04a86ec>] sock_sendmsg+0xac/0xe0
> [352468.559358]  [<c029d042>] ? find_get_page+0x22/0xd0
> [352468.559385]  [<c029d9dc>] ? filemap_fault+0x8c/0x3c0
> [352468.559410]  [<c04a905a>] sys_sendto+0xaa/0xd0
> [352468.559436]  [<c02b3780>] ? __do_fault+0x370/0x470
> [352468.559462]  [<c02b54d9>] ? handle_mm_fault+0x1d9/0x7d0
> [352468.559488]  [<c04aa245>] sys_socketcall+0x195/0x280
> [352468.559514]  [<c0202c50>] sysenter_do_call+0x12/0x26
> [352468.559539] ---[ end trace 6ecb842e4e35a653 ]---
> 
> Could you try following patch ?
> 
> Thanks
> 
> diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
> index 0ffe689..d2657aa 100644
> --- a/net/netfilter/nf_conntrack_netlink.c
> +++ b/net/netfilter/nf_conntrack_netlink.c
> @@ -923,7 +923,7 @@ ctnetlink_change_status(struct nf_conn *ct, const struct nlattr * const cda[])
>  	unsigned int status = ntohl(nla_get_be32(cda[CTA_STATUS]));
>  	d = ct->status ^ status;
>  
> -	if (d & (IPS_EXPECTED|IPS_CONFIRMED|IPS_DYING))
> +	if (d & (IPS_EXPECTED|IPS_DYING))
>  		/* unchangeable */
>  		return -EBUSY;

I think that we should explicitly report if the user unsets
IPS_CONFIRMED. Please, don't change this.

Apart from that, the patch seems fine to me. Thanks!
