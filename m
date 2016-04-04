From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net: memory leak due to CLONE_NEWNET
Date: Mon, 4 Apr 2016 10:13:24 +0200
Message-ID: <CACT4Y+bGs=wVUL8VGmOHBtQPtGWBAXmXiW69Af9YuH9-J_sszw@mail.gmail.com>
References: <CACT4Y+bNxEoM9iEydzsKqO50Pfe3JLJszS=Kyiom47vE=J7cvQ@mail.gmail.com>
 <CAM_iQpU2_7dFR22xqHm3R3Vh7jbbe1=j3CBBnjhQj3G3AnYvYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpU2_7dFR22xqHm3R3Vh7jbbe1=j3CBBnjhQj3G3AnYvYg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 3, 2016 at 12:31 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Apr 2, 2016 at 6:55 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> Hello,
>>
>> The following program leads to memory leaks in:
>>
>> unreferenced object 0xffff88005c10d208 (size 96):
>>   comm "a.out", pid 10753, jiffies 4296778619 (age 43.118s)
>>   hex dump (first 32 bytes):
>>     e8 31 85 2d 00 88 ff ff 0f 00 00 00 00 00 00 00  .1.-............
>>     00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
>>   backtrace:
>>     [<ffffffff8679bb23>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:915
>>     [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
>>     [<     inline     >] slab_post_alloc_hook mm/slab.h:406
>>     [<     inline     >] slab_alloc_node mm/slub.c:2602
>>     [<     inline     >] slab_alloc mm/slub.c:2610
>>     [<ffffffff8179b4c0>] kmem_cache_alloc_trace+0x160/0x3d0 mm/slub.c:2627
>>     [<     inline     >] kmalloc include/linux/slab.h:478
>>     [<     inline     >] tc_action_net_init include/net/act_api.h:122
>>     [<ffffffff8574e62e>] csum_init_net+0x15e/0x450 net/sched/act_csum.c:593
>>     [<ffffffff8564ffc9>] ops_init+0xa9/0x3a0 net/core/net_namespace.c:109
>>     [<ffffffff85650474>] setup_net+0x1b4/0x3e0 net/core/net_namespace.c:287
>>     [<ffffffff85651a56>] copy_net_ns+0xd6/0x1a0 net/core/net_namespace.c:367
>>     [<ffffffff813d01bf>] create_new_namespaces+0x37f/0x740 kernel/nsproxy.c:106
>>     [<ffffffff813d0b69>] unshare_nsproxy_namespaces+0xa9/0x1d0
>
> The following patch should fix it.
>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 2a19fe1..03e322b 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -135,6 +135,7 @@ void tcf_hashinfo_destroy(const struct tc_action_ops *ops,
>  static inline void tc_action_net_exit(struct tc_action_net *tn)
>  {
>         tcf_hashinfo_destroy(tn->ops, tn->hinfo);
> +       kfree(tn->hinfo);
>  }
>
>  int tcf_generic_walker(struct tc_action_net *tn, struct sk_buff *skb,


Fixes the leak for me.

Tested-by: Dmitry Vyukov <dvyukov@google.com>

Thanks
