From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH 2/3] ipvlan: grab rcu_read_lock on xmit path
Date: Tue, 19 May 2015 16:33:21 -0700
Message-ID: <CAF2d9jgKfEmAhO8_FMARirQ8DRqdhTtZ0xxOXUorry3oqNK_hA@mail.gmail.com>
References: <20150514134657.14062.87579.stgit@buzz> <20150514135619.14062.97774.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36126 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbbESXdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 19:33:43 -0400
Received: by obbkp3 with SMTP id kp3so24447531obb.3
        for <netdev@vger.kernel.org>; Tue, 19 May 2015 16:33:42 -0700 (PDT)
In-Reply-To: <20150514135619.14062.97774.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 14, 2015 at 6:56 AM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
> ipvlan_start_xmit() is called with rcu_read_lock_bh() while its internal
> structures requre normal rcu_read_lock().
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> ---
>
> [  802.945151] ===============================
> [  802.945160] [ INFO: suspicious RCU usage. ]
> [  802.945164] 4.1.0-rc3+ #71 Not tainted
> [  802.945165] -------------------------------
> [  802.945167] drivers/net/ipvlan/ipvlan.h:103 suspicious rcu_dereference_check() usage!
> [  802.945168]
> [  802.945168] other info that might help us debug this:
> [  802.945168]
> [  802.945170]
> [  802.945170] rcu_scheduler_active = 1, debug_locks = 1
> [  802.945173] 3 locks held by ping6/3813:
> [  802.945174]  #0:  (sk_lock-AF_INET6){+.+.+.}, at: [<ffffffff81880f72>] rawv6_sendmsg+0x512/0xbb0
> [  802.945197]  #1:  (rcu_read_lock_bh){......}, at: [<ffffffff8185e577>] ip6_finish_output2+0x57/0x790
> [  802.945205]  #2:  (rcu_read_lock_bh){......}, at: [<ffffffff8177a68b>] __dev_queue_xmit+0x4b/0x930
> [  802.945218]
> [  802.945218] stack backtrace:
> [  802.945221] CPU: 2 PID: 3813 Comm: ping6 Not tainted 4.1.0-rc3+ #71
> [  802.945222] Hardware name: OpenStack Foundation OpenStack Nova, BIOS Bochs 01/01/2011
> [  802.945224]  0000000000000001 ffff8800db7b7888 ffffffff819de6f8 0000000000000007
> [  802.945226]  ffff8800db738000 ffff8800db7b78b8 ffffffff810a7f92 ffff880214fc8c00
> [  802.945229]  ffff88021595b000 ffff88021595a000 ffff880214adf800 ffff8800db7b7968
> [  802.945232] Call Trace:
> [  802.945248]  [<ffffffff819de6f8>] dump_stack+0x4c/0x65
> [  802.945253]  [<ffffffff810a7f92>] lockdep_rcu_suspicious+0xe2/0x130
> [  802.945265]  [<ffffffff815e24ac>] ipvlan_queue_xmit+0x17c/0x5a0
> [  802.945268]  [<ffffffff810aa5a4>] ? __lock_is_held+0x54/0x70
> [  802.945271]  [<ffffffff815e300c>] ipvlan_start_xmit+0x1c/0x50
> [  802.945272]  [<ffffffff8177a117>] dev_hard_start_xmit+0x2f7/0x820
> [  802.945274]  [<ffffffff817797b6>] ? netif_skb_features+0xf6/0x1d0
> [  802.945276]  [<ffffffff81779b84>] ? validate_xmit_skb.isra.99.part.100+0x24/0x2c0
> [  802.945278]  [<ffffffff8177ad04>] __dev_queue_xmit+0x6c4/0x930
> [  802.945280]  [<ffffffff8177a68b>] ? __dev_queue_xmit+0x4b/0x930
> [  802.945281]  [<ffffffff810a963a>] ? mark_held_locks+0x6a/0x90
> [  802.945283]  [<ffffffff8177af8e>] dev_queue_xmit_sk+0xe/0x10
> [  802.945285]  [<ffffffff8185e824>] ip6_finish_output2+0x304/0x790
> [  802.945287]  [<ffffffff81860dde>] ? ip6_finish_output+0x9e/0x1e0
> [  802.945288]  [<ffffffff81860dde>] ip6_finish_output+0x9e/0x1e0
> [  802.945290]  [<ffffffff81860fdb>] ip6_output+0xbb/0x180
> [  802.945302]  [<ffffffff818a7d0a>] ? ip6_find_1stfragopt+0x9a/0xa0
> [  802.945304]  [<ffffffff81860d40>] ? ip6_fragment+0xe80/0xe80
> [  802.945306]  [<ffffffff818a805c>] ip6_local_out_sk+0x2c/0x70
> [  802.945308]  [<ffffffff818a80b0>] ip6_local_out+0x10/0x20
> [  802.945309]  [<ffffffff81861571>] ip6_send_skb+0x31/0xd0
> [  802.945311]  [<ffffffff81861644>] ip6_push_pending_frames+0x34/0x40
> [  802.945313]  [<ffffffff81881368>] rawv6_sendmsg+0x908/0xbb0
> [  802.945328]  [<ffffffff810aa5a4>] ? __lock_is_held+0x54/0x70
> [  802.945340]  [<ffffffff81817e9e>] inet_sendmsg+0x10e/0x1f0
> [  802.945343]  [<ffffffff81817d90>] ? inet_recvmsg+0x200/0x200
> [  802.945351]  [<ffffffff81758275>] sock_sendmsg+0x45/0x50
> [  802.945354]  [<ffffffff8175a719>] SYSC_sendto+0xd9/0x110
> [  802.945357]  [<ffffffff8175ac99>] SyS_sendto+0x9/0x10
> [  802.945362]  [<ffffffff819ebfae>] system_call_fastpath+0x12/0x76
> ---
>  drivers/net/ipvlan/ipvlan_main.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
> index 77b92a0fe557..0cafd3e6f02d 100644
> --- a/drivers/net/ipvlan/ipvlan_main.c
> +++ b/drivers/net/ipvlan/ipvlan_main.c
> @@ -173,6 +173,7 @@ static int ipvlan_stop(struct net_device *dev)
>         return 0;
>  }
>
> +/* called with rcu_read_lock_bh. */
>  static netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb,
>                                      struct net_device *dev)
>  {
> @@ -180,6 +181,7 @@ static netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb,
>         int skblen = skb->len;
>         int ret;
>
> +       rcu_read_lock();

I don't believe this is correct. The correct way would be the way  it
is fixed in the following patch -
https://patchwork.ozlabs.org/patch/471481/

>         ret = ipvlan_queue_xmit(skb, dev);
>         if (likely(ret == NET_XMIT_SUCCESS || ret == NET_XMIT_CN)) {
>                 struct ipvl_pcpu_stats *pcptr;
> @@ -193,6 +195,8 @@ static netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb,
>         } else {
>                 this_cpu_inc(ipvlan->pcpu_stats->tx_drps);
>         }
> +       rcu_read_unlock();
> +
>         return ret;
>  }
>
>
