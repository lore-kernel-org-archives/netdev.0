From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Tue, 12 Apr 2011 18:55:55 -0500
Message-ID: <4DA4E68B.9010401@scotdoyle.com>
References: <4DA3F909.5020609@scotdoyle.com>	 <1302608951.3233.33.camel@edumazet-laptop>	 <1302613353.30934.22.camel@polaris.local>	 <1302614145.3233.47.camel@edumazet-laptop>	 <1302617968.30934.34.camel@polaris.local>	 <1302619749.3233.56.camel@edumazet-laptop>	 <1302621233.30934.44.camel@polaris.local>	 <1302624851.3233.63.camel@edumazet-laptop>	 <20110412092039.69f420f6@nehalam>	 <1302626152.3233.66.camel@edumazet-laptop>	 <20110412164557.GF2047@stratus.com>	 <1302627281.3233.70.camel@edumazet-laptop> <1302628720.3233.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?B?SmFuIEzDvGJiZQ==?= <jluebbe@debian.org>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, Bandan Das <bandan.das@stratus.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:56128 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095Ab1DLXz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:55:57 -0400
In-Reply-To: <1302628720.3233.84.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2011 12:18 PM, Eric Dumazet wrote:
> Commit 462fb2af9788a82 (bridge : Sanitize skb before it enters the IP
> stack), missed one IPCB init before calling ip_options_compile()
>
> Thanks to Scot Doyle for his tests and bug reports.
>
> Reported-by: Scot Doyle<lkml@scotdoyle.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Hiroaki SHIMODA<shimoda.hiroaki@gmail.com>
> Acked-by: Bandan Das<bandan.das@stratus.com>
> Acked-by: Stephen Hemminger<shemminger@vyatta.com>
> Cc: Jan L=C3=BCbbe<jluebbe@debian.org>
> ---
>   net/bridge/br_netfilter.c |    6 ++----
>   1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index 008ff6c..b353f7c 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *s=
kb)
>   		goto drop;
>   	}
>
> -	/* Zero out the CB buffer if no options present */
> -	if (iph->ihl =3D=3D 5) {
> -		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +	if (iph->ihl =3D=3D 5)
>   		return 0;
> -	}
>
>   	opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
>   	if (ip_options_compile(dev_net(dev), opt, skb))
>
>


Here's the output after pulling 2.6.39-rc3, applying the patches listed=
=20
below, doing a "make clean" and hitting the bridge's assigned ip addres=
s=20
with the IP Stack Checker tcpsic command. Maybe I should also be=20
applying the patch from yesterday too?  I'll try that next.

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 008ff6c..b9bdff9 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -249,11 +249,9 @@ static int br_parse_ip_options(struct sk_buff *skb=
)
                 goto drop;
         }

-       /* Zero out the CB buffer if no options present */
-       if (iph->ihl =3D=3D 5) {
-               memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-               return 0;
-       }
+       memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+       if (iph->ihl =3D=3D 5)
+               return 0;

         opt->optlen =3D iph->ihl*4 - sizeof(struct iphdr);
         if (ip_options_compile(dev_net(dev), opt, skb))

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index dd1b20e..9df4e63 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -354,7 +354,8 @@ static void inetpeer_free_rcu(struct rcu_head *head=
)
  }

  /* May be called with local BH enabled. */
-static void unlink_from_pool(struct inet_peer *p, struct inet_peer_bas=
e=20
*base)
+static void unlink_from_pool(struct inet_peer *p, struct inet_peer_bas=
e=20
*base,
+                            struct inet_peer __rcu **stack[PEER_MAXDEP=
TH])
  {
         int do_free;

@@ -368,7 +369,6 @@ static void unlink_from_pool(struct inet_peer *p,=20
struct inet_peer_base *base)
          * We use refcnt=3D-1 to alert lockless readers this entry is=20
deleted.
          */
         if (atomic_cmpxchg(&p->refcnt, 1, -1) =3D=3D 1) {
-               struct inet_peer __rcu **stack[PEER_MAXDEPTH];
                 struct inet_peer __rcu ***stackptr, ***delp;
                 if (lookup(&p->daddr, stack, base) !=3D p)
                         BUG();
@@ -422,7 +422,7 @@ static struct inet_peer_base *peer_to_base(struct=20
inet_peer *p)
  }

  /* May be called with local BH enabled. */
-static int cleanup_once(unsigned long ttl)
+static int cleanup_once(unsigned long ttl, struct inet_peer __rcu=20
**stack[PEER_MAXDEPTH])
  {
         struct inet_peer *p =3D NULL;

@@ -454,7 +454,7 @@ static int cleanup_once(unsigned long ttl)
                  * happen because of entry limits in route cache. */
                 return -1;

-       unlink_from_pool(p, peer_to_base(p));
+       unlink_from_pool(p, peer_to_base(p), stack);
         return 0;
  }

@@ -524,7 +524,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr=
=20
*daddr, int create)

         if (base->total >=3D inet_peer_threshold)
                 /* Remove one less-recently-used entry. */
-               cleanup_once(0);
+               cleanup_once(0, stack);

         return p;
  }
@@ -540,6 +540,7 @@ static void peer_check_expire(unsigned long dummy)
  {
         unsigned long now =3D jiffies;
         int ttl, total;
+       struct inet_peer __rcu **stack[PEER_MAXDEPTH];

         total =3D compute_total();
         if (total >=3D inet_peer_threshold)
@@ -548,7 +549,7 @@ static void peer_check_expire(unsigned long dummy)
                 ttl =3D inet_peer_maxttl
                                 - (inet_peer_maxttl - inet_peer_minttl=
)=20
/ HZ *
                                         total / inet_peer_threshold * =
HZ;
-       while (!cleanup_once(ttl)) {
+       while (!cleanup_once(ttl, stack)) {
                 if (jiffies !=3D now)
                         break;
         }

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 28a736f..dea9947 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -200,6 +200,11 @@ int ip_options_echo(struct ip_options * dopt,=20
struct sk_buff * skb)
                 *dptr++ =3D IPOPT_END;
                 dopt->optlen++;
         }
+       if (unlikely(dopt->optlen > 40)) {
+               pr_err("ip_options_echo() fatal error optlen=3D%u > 40\=
n",=20
dopt->optlen);
+               print_hex_dump(KERN_ERR, "ip options: ", DUMP_PREFIX_OF=
=46SET,
+                       16, 1, dopt->__data, dopt->optlen, false);
+       }
         return 0;
}


------------


[  761.720393] BUG: unable to handle kernel NULL pointer dereference at=
=20
00000000000000d0
[  761.728206] IP: [<ffffffff8129fbe9>] ip_options_compile+0x1c1/0x435
[  761.734452] PGD 0
[  761.736459] Oops: 0000 [#1] SMP
[  761.739683] last sysfs file: /sys/devices/virtual/misc/kvm/uevent
[  761.745744] CPU 0
[  761.747570] Modules linked in: kvm_intel kvm bridge stp loop snd_pcm=
=20
snd_timer snd tpm_tis tpm tpm_bios soundcore psmouse snd_page_alloc=20
processor ghes thermal_sys
i7core_edac evdev pcspkr serio_raw edac_core dcdbas power_meter button=20
hed ext2 mbcache dm_mod raid1 md_mod sd_mod crc_t10dif usb_storage uas=20
uhci_hcd ehci_hcd mpt2sas
  scsi_transport_sas raid_class igb scsi_mod usbcore bnx2 dca [last=20
unloaded: scsi_wait_scan]
[  761.785171]
[  761.786651] Pid: 0, comm: swapper Not tainted 2.6.39-rc3+ #14 Dell=20
Inc. PowerEdge R510/0DPRKF
[  761.795157] RIP: 0010:[<ffffffff8129fbe9>]  [<ffffffff8129fbe9>]=20
ip_options_compile+0x1c1/0x435
[  761.803823] RSP: 0018:ffff88042f203af0  EFLAGS: 00010286
[  761.809106] RAX: 0000000000000017 RBX: ffff8804027b3600 RCX:=20
ffff88040466a864
[  761.816205] RDX: 000000000000001a RSI: 0000000000000000 RDI:=20
ffffffff817e6100
[  761.823304] RBP: ffff88040466a862 R08: ffffffffa01d6e89 R09:=20
ffff88042f203c58
[  761.830402] R10: 0000000000000000 R11: 0000000000000000 R12:=20
ffff8804027b3628
[  761.837501] R13: 000000000000001d R14: ffff88040466a84e R15:=20
0000000000000024
[  761.844601] FS:  0000000000000000(0000) GS:ffff88042f200000(0000)=20
knlGS:0000000000000000
[  761.852650] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  761.858365] CR2: 00000000000000d0 CR3: 0000000001603000 CR4:=20
00000000000006f0
[  761.865463] DR0: 0000000000000000 DR1: 0000000000000000 DR2:=20
0000000000000000
[  761.872562] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:=20
0000000000000400
[  761.879661] Process swapper (pid: 0, threadinfo ffffffff81600000,=20
task ffffffff8160b020)
[  761.887710] Stack:
[  761.889708]  0000000000000000 ffffffff81276928 0000000000000000=20
ffffffff817e6100
[  761.897102]  000000000000004e ffff88040500e600 ffff88040500e600=20
ffff8804027b3600
[  761.904496]  ffff880404fc0000 ffff8804027b3628 0000000000000000=20
ffff880404fc0000
[  761.911889] Call Trace:
[  761.914319] <IRQ>
[  761.916413]  [<ffffffff81276928>] ? netif_receive_skb+0x52/0x58
[  761.922306]  [<ffffffffa01dae3b>] ? br_parse_ip_options+0x134/0x1a8=20
[bridge]
[  761.929319]  [<ffffffffa01dbbe0>] ? br_nf_pre_routing+0x348/0x3cb=20
[bridge]
[  761.936160]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  761.941444]  [<ffffffff8104afaa>] ? irq_exit+0x58/0x8f
[  761.946556]  [<ffffffffa01d6e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridg=
e]
[  761.953052]  [<ffffffffa01d6e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridg=
e]
[  761.959546]  [<ffffffff812985d7>] ? nf_hook_slow+0x73/0x114
[  761.965089]  [<ffffffffa01d6e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridg=
e]
[  761.971583]  [<ffffffff8126d097>] ? __netdev_alloc_skb+0x15/0x2f
[  761.977561]  [<ffffffffa01d6e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridg=
e]
[  761.984055]  [<ffffffffa01d6e6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridg=
e]
[  761.990551]  [<ffffffff812a7dde>] ? tcp_gro_receive+0xa1/0x204
[  761.996355]  [<ffffffffa01d71e5>] ? br_handle_frame+0x195/0x1ac [bri=
dge]
[  762.003022]  [<ffffffffa01d7050>] ?=20
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[  762.010294]  [<ffffffff812764ef>] ? __netif_receive_skb+0x2a7/0x450
[  762.016530]  [<ffffffff81276928>] ? netif_receive_skb+0x52/0x58
[  762.022420]  [<ffffffff81276e2a>] ? napi_gro_receive+0x1f/0x2f
[  762.028222]  [<ffffffff812769ff>] ? napi_skb_finish+0x1c/0x31
[  762.033941]  [<ffffffffa024afcd>] ? igb_poll+0x6d9/0x9ee [igb]
[  762.039744]  [<ffffffff8109034f>] ? handle_irq_event+0x40/0x55
[  762.045547]  [<ffffffff8106fc3c>] ? arch_local_irq_save+0x14/0x1d
[  762.051609]  [<ffffffff81276f55>] ? net_rx_action+0xa4/0x1b1
[  762.057239]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[  762.062783]  [<ffffffff81333cdc>] ? call_softirq+0x1c/0x30
[  762.068241]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[  762.073524]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[  762.078635]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[  762.083575]  [<ffffffff8132cc53>] ? common_interrupt+0x13/0x13
[  762.089375] <EOI>
[  762.091469]  [<ffffffff81061348>] ? enqueue_hrtimer+0x3f/0x53
[  762.097188]  [<ffffffffa0430417>] ? arch_local_irq_enable+0x7/0x8=20
[processor]
[  762.104288]  [<ffffffffa0430dab>] ? acpi_idle_enter_c1+0x86/0xa2=20
[processor]
[  762.111303]  [<ffffffff8125d05d>] ? cpuidle_idle_call+0xf4/0x17e
[  762.117277]  [<ffffffff81008298>] ? cpu_idle+0xa2/0xc4
[  762.122388]  [<ffffffff8169db60>] ? start_kernel+0x3b9/0x3c4
[  762.128018]  [<ffffffff8169d3c6>] ? x86_64_start_kernel+0x102/0x10f
[  762.134253] Code: 4d 02 3c 03 0f 86 59 02 00 00 0f b6 d0 44 39 ea 7f=
=20
32 83 c2 03 44 39 ea 0f 8f 45 02 00 00 48 85 db 74 18 48 8b 74 24 10 0f=
=20
b6 c0 <8b> 96 d0 00 00 00 89 54 05 ff 41 80 4c 24 08 04 80 01 04 41 80
[  762.153593] RIP  [<ffffffff8129fbe9>] ip_options_compile+0x1c1/0x435
[  762.159923]  RSP <ffff88042f203af0>
[  762.163391] CR2: 00000000000000d0
[  762.167017] ---[ end trace e15d7b082f680b62 ]---
