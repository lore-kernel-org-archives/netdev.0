From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in skb_flow_dissect()
Date: Mon, 23 Jun 2014 22:29:11 -0700
Message-ID: <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	<1402338773-5996-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38616 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbaFXF3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 01:29:12 -0400
Received: by mail-ig0-f171.google.com with SMTP id h18so4116826igc.10
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2014 22:29:12 -0700 (PDT)
In-Reply-To: <1402338773-5996-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 9, 2014 at 11:32 AM, Govindarajulu Varadarajan
<_govind@gmx.com> wrote:
> skb_flow_dissect() dissects only transport header type in ip_proto. It dose not
> give any information about IPv4 or IPv6.
>
> This patch adds new member, n_proto, to struct flow_keys. Which records the
> IP layer type. i.e IPv4 or IPv6.
>
> This can be used in netdev->ndo_rx_flow_steer driver function to dissect flow.
>
> Adding new member to flow_keys increases the struct size by around 4 bytes.
> This causes BUILD_BUG_ON(sizeof(qcb->data) < sz); to fail in
> qdisc_cb_private_validate()
>
> So increase data size by 4
>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  include/net/flow_keys.h   | 14 ++++++++++++++
>  include/net/sch_generic.h |  2 +-
>  net/core/flow_dissector.c |  1 +
>  3 files changed, 16 insertions(+), 1 deletion(-)
>
> diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
> index 7e64bd8..fbefdca 100644
> --- a/include/net/flow_keys.h
> +++ b/include/net/flow_keys.h
> @@ -1,6 +1,19 @@
>  #ifndef _NET_FLOW_KEYS_H
>  #define _NET_FLOW_KEYS_H
>
> +/* struct flow_keys:
> + *     @src: source ip address in case of IPv4
> + *           For IPv6 it contains 32bit hash of src address
> + *     @dst: destination ip address in case of IPv4
> + *           For IPv6 it contains 32bit hash of dst address
> + *     @ports: port numbers of Transport header
> + *             port16[0]: src port number
> + *             port16[1]: dst port number
> + *     @thoff: Transport header offset
> + *     @n_proto: Network header protocol (eg. IPv4/IPv6)
> + *     @ip_proto: Transport header protocol (eg. TCP/UDP)
> + * All the members, except thoff, are in network byte order.
> + */
>  struct flow_keys {
>         /* (src,dst) must be grouped, in the same way than in IP header */
>         __be32 src;
> @@ -10,6 +23,7 @@ struct flow_keys {
>                 __be16 port16[2];
>         };
>         u16 thoff;
> +       u16 n_proto;
>         u8 ip_proto;
>  };
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 624f985..a3cfb8e 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -231,7 +231,7 @@ struct qdisc_skb_cb {
>         unsigned int            pkt_len;
>         u16                     slave_dev_queue_mapping;
>         u16                     _pad;
> -       unsigned char           data[20];
> +       unsigned char           data[24];
>  };
>
>  static inline void qdisc_cb_private_validate(const struct sk_buff *skb, int sz)
> diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
> index 107ed12..c2b53c1 100644
> --- a/net/core/flow_dissector.c
> +++ b/net/core/flow_dissector.c
> @@ -175,6 +175,7 @@ ipv6:
>                 break;
>         }
>
> +       flow->n_proto = proto;
>         flow->ip_proto = ip_proto;
>         flow->ports = skb_flow_get_ports(skb, nhoff, ip_proto);
>         flow->thoff = (u16) nhoff;
> --
> 2.0.0
>
this patch in net-next cause kernel crash.

[  148.466045] qlge 0000:4a:00.1 eth27: Passed Get Port Configuration.
[  162.385445] BUG: unable to handle kernel paging request at 000000010000007e
[  162.385839] IP: [<ffffffff81f18899>] __dev_queue_xmit+0x399/0x630
[  162.398541] PGD 0
[  162.398659] Oops: 0002 [#1] SMP
[  162.398845] Modules linked in:
[  162.399022] CPU: 5 PID: 1 Comm: swapper/0 Tainted: G        W
3.16.0-rc2-yh-00302-g3d5dc41-dirty #22
[  162.418490] Hardware name: Oracle Corporation  unknown       /
, BIOS 11016600    05/17/2011
[  162.438851] task: ffff884027a80000 ti: ffff881027d20000 task.ti:
ffff881027d20000
[  162.468329] RIP: 0010:[<ffffffff81f18899>]  [<ffffffff81f18899>]
__dev_queue_xmit+0x399/0x630
[  162.488085] RSP: 0000:ffff881027d23d28  EFLAGS: 00010202
[  162.488345] RAX: 00000000fffffffe RBX: ffff887026041000 RCX: 0000000000000001
[  162.508245] RDX: 0000000000000000 RSI: ffffffff82dfee78 RDI: ffff884027a80000
[  162.508590] RBP: ffff881027d23d70 R08: 0000000000000001 R09: 0000000000000000
[  162.528255] R10: 0000000000000000 R11: ffff885026020800 R12: ffffffff82dfedc0
[  162.547963] R13: ffff881022b7c000 R14: 0000000000000dac R15: ffff88702434c400
[  162.548310] FS:  0000000000000000(0000) GS:ffff88103f000000(0000)
knlGS:0000000000000000
[  162.568186] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  162.568489] CR2: 000000010000007e CR3: 0000000002c19000 CR4: 00000000000007e0
[  162.588263] Stack:
[  162.588354]  ffffffff81f18505 0000000000000000 00ff881027d23d80
ffffffff82dfee60
[  162.608269]  ffff885023dd1e40 ffff881022b7c000 ffff885026020929
0000000000000dac
[  162.628043]  ffff887026041000 ffff881027d23d80 ffffffff81f18b40
ffff881027d23e18
[  162.628422] Call Trace:
[  162.647963]  [<ffffffff81f18505>] ? __dev_queue_xmit+0x5/0x630
[  162.648284]  [<ffffffff81f18b40>] dev_queue_xmit+0x10/0x20
[  162.667987]  [<ffffffff83087b64>] ip_auto_config+0x8e6/0xf13
[  162.668282]  [<ffffffff8100031d>] ? do_one_initcall+0xdd/0x1e0
[  162.688018]  [<ffffffff810e36ad>] ? trace_hardirqs_on+0xd/0x10
[  162.688298]  [<ffffffff8110c40f>] ? ktime_get+0xbf/0x140
[  162.708029]  [<ffffffff8308727e>] ? root_nfs_parse_addr+0xbd/0xbd
[  162.708292]  [<ffffffff81000323>] do_one_initcall+0xe3/0x1e0
[  162.728075]  [<ffffffff810ba8bd>] ? parse_args+0x1ed/0x330
[  162.728340]  [<ffffffff8203501a>] ? printk+0x54/0x56
[  162.748027]  [<ffffffff8301f4c5>] kernel_init_freeable+0x237/0x2ce
[  162.748344]  [<ffffffff8301eaf7>] ? do_early_param+0x8a/0x8a
[  162.768070]  [<ffffffff8202abb0>] ? rest_init+0xc0/0xc0
[  162.768318]  [<ffffffff8202abbe>] kernel_init+0xe/0x100
[  162.788057]  [<ffffffff8204c4ac>] ret_from_fork+0x7c/0xb0
[  162.788314]  [<ffffffff8202abb0>] ? rest_init+0xc0/0xc0
[  162.808008] Code: e8 5d 48 18 ff eb 13 48 c7 c7 60 d9 c5 82 e8 cf
bc 1c ff 85 c0 74 dd 0f 1f 00 48 8b 43 58 48 83 e0 fe 48 85 c0 48 89
43 58 74 07 <f0> ff 80 80 00 00 00 4c 89 e6 48 89 df 41 ff 14 24 41 89
c6 41
[  162.828797] RIP  [<ffffffff81f18899>] __dev_queue_xmit+0x399/0x630
[  162.848186]  RSP <ffff881027d23d28>
[  162.848341] CR2: 000000010000007e
[  162.848490] ---[ end trace 26b7736a09036e46 ]---
[  162.868194] Kernel panic - not syncing: Fatal exception in interrupt
[  162.872673] Kernel Offset: 0x0 from 0xffffffff81000000 (relocation
range: 0xffffffff80000000-0xffffffff9fffffff)
[  162.888531] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
[  162.908306] ------------[ cut here ]------------

After the commit is reverted, the system work again.
