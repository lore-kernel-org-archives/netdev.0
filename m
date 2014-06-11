From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 10 Jun 2014 21:16:13 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1406102114520.28698@dinf>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>  <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1406101726390.11647@dtop>  <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com> <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rydia.net ([69.46.88.68]:58170 "EHLO mail.rydia.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaFKEQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 00:16:18 -0400
In-Reply-To: <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014, Eric Dumazet wrote:

> On Tue, 2014-06-10 at 18:12 -0700, Eric Dumazet wrote:
>
> >
> > For the curious, another problem is in ipv4_sk_update_pmtu()
> >
> > This can be called on UDP sockets, but from softirq context.
> >
> > We cannot use sk_dst_lock because this lock is not softirq safe.
> >
> > I guess we should use xchg() for sk_dst_set() and sk_dst_reset()
>
> This would be something like this untested patch :
>
>  include/net/sock.h |   12 ++++++------
>  net/ipv4/route.c   |   15 ++++++++-------
>  2 files changed, 14 insertions(+), 13 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 21569cf456ed..04400978ceb5 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1766,9 +1766,11 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
>  static inline void
>  sk_dst_set(struct sock *sk, struct dst_entry *dst)
>  {
> -	spin_lock(&sk->sk_dst_lock);
> -	__sk_dst_set(sk, dst);
> -	spin_unlock(&sk->sk_dst_lock);
> +	struct dst_entry *old_dst;
> +
> +	sk_tx_queue_clear(sk);
> +	old_dst = xchg(&sk->sk_dst_cache, dst);
> +	dst_release(old_dst);
>  }
>
>  static inline void
> @@ -1780,9 +1782,7 @@ __sk_dst_reset(struct sock *sk)
>  static inline void
>  sk_dst_reset(struct sock *sk)
>  {
> -	spin_lock(&sk->sk_dst_lock);
> -	__sk_dst_reset(sk);
> -	spin_unlock(&sk->sk_dst_lock);
> +	sk_dst_set(sk, NULL);
>  }
>
>  struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 5e676be3daeb..be9f2b1ac3ab 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1022,7 +1022,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  	const struct iphdr *iph = (const struct iphdr *) skb->data;
>  	struct flowi4 fl4;
>  	struct rtable *rt;
> -	struct dst_entry *dst;
> +	struct dst_entry *odst = NULL;
>  	bool new = false;
>
>  	bh_lock_sock(sk);
> @@ -1030,16 +1030,17 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  	if (!ip_sk_accept_pmtu(sk))
>  		goto out;
>
> -	rt = (struct rtable *) __sk_dst_get(sk);
> +	odst = sk_dst_get(sk);
>
> -	if (sock_owned_by_user(sk) || !rt) {
> +	if (sock_owned_by_user(sk) || !odst) {
>  		__ipv4_sk_update_pmtu(skb, sk, mtu);
>  		goto out;
>  	}
>
>  	__build_flow_key(&fl4, sk, iph, 0, 0, 0, 0, 0);
>
> -	if (!__sk_dst_check(sk, 0)) {
> +	rt = (struct rtable *)odst;
> +	if (odst->obsolete && odst->ops->check(odst, 0) == NULL) {
>  		rt = ip_route_output_flow(sock_net(sk), &fl4, sk);
>  		if (IS_ERR(rt))
>  			goto out;
> @@ -1049,8 +1050,7 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>
>  	__ip_rt_update_pmtu((struct rtable *) rt->dst.path, &fl4, mtu);
>
> -	dst = dst_check(&rt->dst, 0);
> -	if (!dst) {
> +	if (!dst_check(&rt->dst, 0)) {
>  		if (new)
>  			dst_release(&rt->dst);
>
> @@ -1062,10 +1062,11 @@ void ipv4_sk_update_pmtu(struct sk_buff *skb, struct sock *sk, u32 mtu)
>  	}
>
>  	if (new)
> -		__sk_dst_set(sk, &rt->dst);
> +		sk_dst_set(sk, &rt->dst);
>
>  out:
>  	bh_unlock_sock(sk);
> +	dst_release(odst);
>  }
>  EXPORT_SYMBOL_GPL(ipv4_sk_update_pmtu);
>
>
>
>

Ran our udpkill util against 3.10.42 with both of your patches applied...
seems like it ran a bit longer than normally would with this test (15-20
minutes), then died:

<4>[ 2572.249626] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge
coretemp crc32_pclmul ghash_clmulni_intel gpio_ich ipmi_watchdog
ipmi_devintf microcode sb_edac edac_core lpc_ich mfd_core ipmi_si
ipmi_msghandler igb i2c_algo_bit ixgbe ptp pps_core mdio
<4>[ 2572.249733] CPU: 15 PID: 65425 Comm: udpkill Not tainted
3.10.42 #1
<4>[ 2572.249748] Hardware name: Supermicro
X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
<4>[ 2572.249768] task: ffff885e71fe5c00 ti: ffff885e80bc4000 task.ti:
ffff885e80bc4000
<4>[ 2572.249783] RIP: 0010:[<ffffffff81602c95>]  [<ffffffff81602c95>]
ipv4_dst_destroy+0x45/0x80
<4>[ 2572.249809] RSP: 0018:ffff885e80bc5b58  EFLAGS: 00010292
<4>[ 2572.249820] RAX: dead000000200200 RBX: ffff882f2a5f26c0 RCX:
dead000000100100
<4>[ 2572.249835] RDX: dead000000100100 RSI: ffffffffffffffff RDI:
ffffffff81e95302
<4>[ 2572.249849] RBP: ffff885e80bc5b68 R08: 0000000000000000 R09:
ffff885e80bc5c78
<4>[ 2572.249863] R10: 0000000000000001 R11: 0000000000000293 R12:
0000000000000000
<4>[ 2572.249878] R13: ffffffff81c8c840 R14: ffff885e80bc5da0 R15:
ffffffff8160c9f0
<4>[ 2572.249893] FS:  00007f6a2d2af700(0000) GS:ffff88607fce0000(0000)
knlGS:0000000000000000
<4>[ 2572.249909] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[ 2572.249921] CR2: 000079686b6e0000 CR3: 0000005f65094000 CR4:
00000000000407e0
<4>[ 2572.249952] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
<4>[ 2572.249982] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
<4>[ 2572.250011] Stack:
<4>[ 2572.250032]  ffff882f2a5f26c0 ffff882f2a5f26c0 ffff885e80bc5b98
ffffffff815c12b2
<4>[ 2572.250083]  0000000000000000 ffff882f2a5f26c0 0000000000000000
0000000000000140
<4>[ 2572.250135]  ffff885e80bc5bb8 ffffffff815c15a6 0000000000000000
ffff885f6ec29f80
<4>[ 2572.250187] Call Trace:
<4>[ 2572.250216]  [<ffffffff815c12b2>] dst_destroy+0x32/0xd0
<4>[ 2572.250246]  [<ffffffff815c15a6>] dst_release+0x56/0x80
<4>[ 2572.250282]  [<ffffffff815a7272>] sk_dst_check+0x82/0x90
<4>[ 2572.250311]  [<ffffffff81634f72>] udp_sendmsg+0x622/0x8d0
<4>[ 2572.250343]  [<ffffffff8163ec95>] inet_sendmsg+0x45/0xb0
<4>[ 2572.250374]  [<ffffffff815a0dae>] sock_aio_write+0x11e/0x130
<4>[ 2572.250408]  [<ffffffff811563af>] do_sync_write+0x7f/0xb0
<4>[ 2572.250437]  [<ffffffff81156254>] ? fsnotify_modify+0x64/0x80
<4>[ 2572.250465]  [<ffffffff81156806>] vfs_write+0x166/0x1a0
<4>[ 2572.250493]  [<ffffffff81156cef>] SyS_write+0x5f/0xa0
<4>[ 2572.250526]  [<ffffffff816d2bc2>] system_call_fastpath+0x16/0x1b
<4>[ 2572.250553] Code: 87 b0 00 00 00 74 4f 48 c7 c7 02 53 e9 81 e8 a3 79
0c 00 48 8b 93 b0 00 00 00 48 8b 83 b8 00 00 00 48 b9 00 01 10 00 00 00 ad
de <48> 89 42 08 48 c7 c7 02 53 e9 81 48 89 10 48 ba 00 02 20 00 00
<1>[ 2572.250783] RIP  [<ffffffff81602c95>] ipv4_dst_destroy+0x45/0x80
<4>[ 2572.250813]  RSP <ffff885e80bc5b58>
<4>[ 2572.251127] ---[ end trace 62611fc9c3ed8cf0 ]---
<0>[ 2573.377286] Kernel panic - not syncing: Fatal exception in interrupt
