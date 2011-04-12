From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 02:02:33 -0500
Message-ID: <4DA3F909.5020609@scotdoyle.com>
References: <4D9E62D9.5010400@scotdoyle.com>	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com> <1302587490.3603.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:58579 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755696Ab1DLHCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 03:02:36 -0400
In-Reply-To: <1302587490.3603.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2011 12:51 AM, Eric Dumazet wrote:
>
> Oh well, sorry (not enough time these days to even test patches)
>
> 	if (!skb_dst(skb)) {

--- br_netfilter.c.a    2011-04-01 02:37:53.000000000 -0500
+++ br_netfilter.c.b    2011-04-12 00:29:00.000000000 -0500
@@ -221,6 +221,7 @@ static int br_parse_ip_options(struct sk
      struct ip_options *opt;
      struct iphdr *iph;
      struct net_device *dev = skb->dev;
+    struct rtable *rt;
      u32 len;

      iph = ip_hdr(skb);
@@ -255,6 +256,16 @@ static int br_parse_ip_options(struct sk
          return 0;
      }

+    /* Associate bogus bridge route table */
+    if (!skb_dst(skb)) {
+        rt = bridge_parent_rtable(dev);
+        if (!rt) {
+            kfree_skb(skb);
+            return 0;
+        }
+        skb_dst_set_noref(skb,&rt->dst);
+    }
+
      opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
      if (ip_options_compile(dev_net(dev), opt, skb))
          goto inhdr_error;


Now we are making progress! With the patch above from Stephen and Eric, 
I cannot make the kernel panic when sending packets to the IP address of 
the bridge.

However, if a guest virtual machine is sharing the bridge with the host 
via a tap device, I can cause a host panic by targeting the IP address 
of the guest. Is this an unrelated problem?

Here are two kernel panics. The guest virtual machine was pingable 
before being attacked with IP Stack Checker's tcpsic command. Spanning 
Tree Protocol was off during the first panic and on during the second.

------------

[  606.921739] br0: port 2(tap0) entering forwarding state
[  636.058941] Kernel panic - not syncing: stack-protector: Kernel stack 
is corrupted in: ffffffff812c2781
[  636.058942]
[  636.069789] Pid: 2261, comm: kvm Tainted: G        W   2.6.39-rc2+ #11
[  636.076292] Call Trace:
[  636.078725] <IRQ>  [<ffffffff8132ad78>] ? panic+0x92/0x1a1
[  636.084287]  [<ffffffff8104abe8>] ? _local_bh_enable_ip.clone.8+0x20/0x8c
[  636.091044]  [<ffffffff812c2781>] ? icmp_send+0x337/0x349
[  636.096418]  [<ffffffff810454e5>] ? __stack_chk_fail+0x17/0x17
[  636.102221]  [<ffffffff812c2781>] ? icmp_send+0x337/0x349
[  636.107595]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  636.112883]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  636.118172]  [<ffffffffa017b0d4>] ? br_flood+0xc8/0xc8 [bridge]
[  636.124065]  [<ffffffffa017b250>] ? __br_deliver+0xb0/0xb0 [bridge]
[  636.130302]  [<ffffffff812985d7>] ? nf_hook_slow+0x73/0x114
[  636.135850]  [<ffffffffa017b250>] ? __br_deliver+0xb0/0xb0 [bridge]
[  636.142089]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.148586]  [<ffffffffa017b250>] ? __br_deliver+0xb0/0xb0 [bridge]
[  636.154826]  [<ffffffffa017b186>] ? NF_HOOK.clone.5+0x3c/0x56 [bridge]
[  636.161323]  [<ffffffffa017bfe1>] ? 
br_handle_frame_finish+0x158/0x1c7 [bridge]
[  636.168601]  [<ffffffffa0180689>] ? 
br_nf_pre_routing_finish+0x1d4/0x1e1 [bridge]
[  636.176052]  [<ffffffffa017fc76>] ? NF_HOOK_THRESH+0x3b/0x55 [bridge]
[  636.182463]  [<ffffffffa0180c84>] ? br_nf_pre_routing+0x3be/0x3cb 
[bridge]
[  636.189307]  [<ffffffff812985d7>] ? nf_hook_slow+0x73/0x114
[  636.194852]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  636.200139]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.206637]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.213133]  [<ffffffff812985d7>] ? nf_hook_slow+0x73/0x114
[  636.218679]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.225177]  [<ffffffffa017bfe1>] ? 
br_handle_frame_finish+0x158/0x1c7 [bridge]
[  636.232455]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.238954]  [<ffffffffa017be6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[  636.245452]  [<ffffffff812a7d8e>] ? tcp_gro_receive+0xa1/0x204
[  636.251258]  [<ffffffffa017c1e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[  636.257928]  [<ffffffffa017c050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[  636.265204]  [<ffffffff812764ef>] ? __netif_receive_skb+0x2a7/0x450
[  636.271443]  [<ffffffff81276928>] ? netif_receive_skb+0x52/0x58
[  636.277335]  [<ffffffff81276e2a>] ? napi_gro_receive+0x1f/0x2f
[  636.283139]  [<ffffffff812769ff>] ? napi_skb_finish+0x1c/0x31
[  636.288865]  [<ffffffffa0241fcd>] ? igb_poll+0x6d9/0x9ee [igb]
[  636.294673]  [<ffffffffa003bde2>] ? scsi_run_queue+0x2ce/0x30a [scsi_mod]
[  636.301431]  [<ffffffffa017be89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  636.307930]  [<ffffffff812764ef>] ? __netif_receive_skb+0x2a7/0x450
[  636.314168]  [<ffffffff81276f55>] ? net_rx_action+0xa4/0x1b1
[  636.319800]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[  636.325346]  [<ffffffff81333c5c>] ? call_softirq+0x1c/0x30
[  636.330807]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[  636.336092]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[  636.341204]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[  636.346146]  [<ffffffff8132cbd3>] ? common_interrupt+0x13/0x13
[  636.351949] <EOI>  [<ffffffff81271f58>] ? arch_local_irq_save+0x12/0x1b
[  636.358629]  [<ffffffff8100a9f2>] ? arch_local_irq_restore+0x2/0x8
[  636.364781]  [<ffffffff8127680d>] ? netif_rx_ni+0x1e/0x27
[  636.370154]  [<ffffffffa01557d2>] ? tun_get_user+0x3a3/0x3cb [tun]
[  636.376305]  [<ffffffffa0155bd8>] ? tun_get_socket+0x3b/0x3b [tun]
[  636.382457]  [<ffffffffa0155c36>] ? tun_chr_aio_write+0x5e/0x79 [tun]
[  636.388869]  [<ffffffff810f6b07>] ? do_sync_readv_writev+0x9a/0xd5
[  636.395021]  [<ffffffff810371f3>] ? need_resched+0x1a/0x23
[  636.400481]  [<ffffffff8132b725>] ? _cond_resched+0x9/0x20
[  636.405941]  [<ffffffff810f5f77>] ? copy_from_user+0x18/0x30
[  636.411573]  [<ffffffff8115fbf6>] ? security_file_permission+0x18/0x33
[  636.418068]  [<ffffffff810f6d55>] ? do_readv_writev+0xa4/0x11a
[  636.423873]  [<ffffffff810f7913>] ? fput+0x1a/0x1a2
[  636.428726]  [<ffffffff810f6f39>] ? sys_writev+0x45/0x90
[  636.434012]  [<ffffffff81332a52>] ? system_call_fastpath+0x16/0x1b

------------

[  110.442839] br0: port 2(tap0) entering forwarding state
[  136.948700] Kernel panic - not syncing: stack-protector: Kernel stack 
is corrupted in: ffffffff812c2781
[  136.948702]
[  136.959561] Pid: 1093, comm: md123_resync Not tainted 2.6.39-rc2+ #11
[  136.965977] Call Trace:
[  136.968408] <IRQ>  [<ffffffff8132ad78>] ? panic+0x92/0x1a1
[  136.973970]  [<ffffffff8104abe8>] ? _local_bh_enable_ip.clone.8+0x20/0x8c
[  136.980727]  [<ffffffff812c2781>] ? icmp_send+0x337/0x349
[  136.986102]  [<ffffffff810454e5>] ? __stack_chk_fail+0x17/0x17
[  136.991906]  [<ffffffff812c2781>] ? icmp_send+0x337/0x349
[  136.997281]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  137.002570]  [<ffffffffa0198fe1>] ? 
br_handle_frame_finish+0x158/0x1c7 [bridge]
[  137.009847]  [<ffffffffa019d689>] ? 
br_nf_pre_routing_finish+0x1d4/0x1e1 [bridge]
[  137.017297]  [<ffffffffa019cc76>] ? NF_HOOK_THRESH+0x3b/0x55 [bridge]
[  137.023707]  [<ffffffffa019dc84>] ? br_nf_pre_routing+0x3be/0x3cb 
[bridge]
[  137.030551]  [<ffffffff81298527>] ? nf_iterate+0x41/0x7e
[  137.035837]  [<ffffffff8103704d>] ? test_tsk_need_resched+0xe/0x17
[  137.041991]  [<ffffffffa0198e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  137.048488]  [<ffffffffa0198e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  137.054984]  [<ffffffff812985d7>] ? nf_hook_slow+0x73/0x114
[  137.060531]  [<ffffffffa0198e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  137.067028]  [<ffffffffa0198e89>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[  137.073526]  [<ffffffffa0198e6f>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[  137.080023]  [<ffffffff812a7d8e>] ? tcp_gro_receive+0xa1/0x204
[  137.085830]  [<ffffffffa01991e5>] ? br_handle_frame+0x195/0x1ac [bridge]
[  137.092500]  [<ffffffffa0199050>] ? 
br_handle_frame_finish+0x1c7/0x1c7 [bridge]
[  137.099776]  [<ffffffff812764ef>] ? __netif_receive_skb+0x2a7/0x450
[  137.106013]  [<ffffffff81276928>] ? netif_receive_skb+0x52/0x58
[  137.111906]  [<ffffffff81276e2a>] ? napi_gro_receive+0x1f/0x2f
[  137.117713]  [<ffffffff812769ff>] ? napi_skb_finish+0x1c/0x31
[  137.123438]  [<ffffffffa0226fcd>] ? igb_poll+0x6d9/0x9ee [igb]
[  137.129243]  [<ffffffff8109034f>] ? handle_irq_event+0x40/0x55
[  137.135049]  [<ffffffff8132cbd3>] ? common_interrupt+0x13/0x13
[  137.140854]  [<ffffffff81276f55>] ? net_rx_action+0xa4/0x1b1
[  137.146487]  [<ffffffff8104ad26>] ? __do_softirq+0xb8/0x176
[  137.152034]  [<ffffffff81333c5c>] ? call_softirq+0x1c/0x30
[  137.157494]  [<ffffffff8100aa57>] ? do_softirq+0x3f/0x84
[  137.162779]  [<ffffffff8104af91>] ? irq_exit+0x3f/0x8f
[  137.167893]  [<ffffffff8100a793>] ? do_IRQ+0x85/0x9e
[  137.172833]  [<ffffffff8132cbd3>] ? common_interrupt+0x13/0x13
[  137.178636] <EOI>  [<ffffffff8106fc1a>] ? arch_local_irq_restore+0x2/0x8
[  137.185408]  [<ffffffffa0050fca>] ? _scsih_qcmd+0x54f/0x561 [mpt2sas]
[  137.191823]  [<ffffffffa01e452f>] ? scsi_dispatch_cmd+0x180/0x219 
[scsi_mod]
[  137.198841]  [<ffffffffa01ea385>] ? scsi_request_fn+0x3e6/0x413 
[scsi_mod]
[  137.205683]  [<ffffffff81187470>] ? elv_rqhash_add.clone.15+0x26/0x4c
[  137.212095]  [<ffffffff8118bde2>] ? __blk_run_queue+0x5e/0x84
[  137.217814]  [<ffffffff8118d63c>] ? __make_request+0x273/0x28f
[  137.223619]  [<ffffffff8118b569>] ? generic_make_request+0x267/0x2e1
[  137.229943]  [<ffffffff8105eb49>] ? remove_wait_queue+0x11/0x4d
[  137.235837]  [<ffffffffa0002417>] ? raise_barrier+0x162/0x16f [raid1]
[  137.242246]  [<ffffffff8103eba4>] ? try_to_wake_up+0x17c/0x17c
[  137.248052]  [<ffffffffa0002f2f>] ? sync_request+0x567/0x583 [raid1]
[  137.254379]  [<ffffffffa00bd834>] ? md_do_sync+0x776/0xb8e [md_mod]
[  137.260617]  [<ffffffff8100e537>] ? sched_clock+0x5/0x8
[  137.265819]  [<ffffffffa00bde83>] ? md_thread+0xfa/0x118 [md_mod]
[  137.271886]  [<ffffffffa00bdd89>] ? md_rdev_init+0x8f/0x8f [md_mod]
[  137.278124]  [<ffffffffa00bdd89>] ? md_rdev_init+0x8f/0x8f [md_mod]
[  137.284362]  [<ffffffff8105e497>] ? kthread+0x7a/0x82
[  137.289390]  [<ffffffff81333b64>] ? kernel_thread_helper+0x4/0x10
[  137.295454]  [<ffffffff8105e41d>] ? kthread_worker_fn+0x149/0x149
[  137.301519]  [<ffffffff81333b60>] ? gs_change+0x13/0x13

