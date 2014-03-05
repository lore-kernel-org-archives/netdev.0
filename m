From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Tue, 04 Mar 2014 16:03:43 -0800
Message-ID: <87d2i17bq8.fsf@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46185 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbaCEAD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 19:03:57 -0500
In-Reply-To: <20140304.160825.893718566461536483.davem@davemloft.net> (David
	Miller's message of "Tue, 04 Mar 2014 16:08:25 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 03 Mar 2014 12:40:05 -0800
>
>> <IRQ>  [<ffffffff8104934c>] warn_slowpath_common+0x85/0x9d
>> [<ffffffff8104937e>] warn_slowpath_null+0x1a/0x1c
>> [<ffffffff81429aa7>] skb_release_head_state+0x7b/0xe1
>> [<ffffffff814297e1>] __kfree_skb+0x16/0x81
>> [<ffffffff814298a0>] consume_skb+0x54/0x69
>> [<ffffffffa015925b>] bnx2_tx_int.clone.6+0x1b0/0x33e [bnx2]
>
> Other drivers, such as bnx2x, uses dev_kfree_skb_any(), probably
> exactly to deal with this situation.
>
> If in_irq() is true or interrupts are disabled, __dev_kfree_skb_any
> will use __dev_kfree_skb_irq, which will queue up the SKB and schedule
> a software interrupt to do the actual work.
>
> For example, see this commit, which we probably just need to duplicate
> into other poll supporting drivers:

When the patch to make that change was submitted to you to do that you
rejected it:

> From:	David Miller <davem@davemloft.net>
> Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
> To:	tdmackey@booleanhaiku.com
> Cc:	mchan@broadcom.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
> Date: Tue, 29 Oct 2013 22:42:27 -0400 (EDT) (17 weeks, 6 days, 20 hours ago)
> 
> From: David Mackey <tdmackey@booleanhaiku.com>
> Date: Tue, 29 Oct 2013 15:16:38 -0700
> 
> > Using dev_kfree_skb_any() will resolve the below issue when a
> > netconsole message is transmitted in an irq.
>  ...
> > Signed-off-by: David Mackey <tdmackey@booleanhaiku.com>
> 
> This is absolutely not the correct fix.
> 
> The netpoll facility must invoke ->poll() in an environment which
> is compatible, locking and interrupt/soft-interrupt wise, as that
> in which it is normally called.
> 
> Therefore, bnx2_tx_int(), which is invoked from the driver's ->poll()
> method, should not need to use dev_kfree_skb_any().  The real problem
> is somewhere else.

In that discussion you were also strongly objecting to making the poll
methods safe in hard irq context.  Although there may be something
subtle I am missing.

So when I looked at this problem this weekend I realized it was not at
all hard to just queue packets in hard irq context, so we would not call
driver methods in a context they were not prepared for.

If dev_kfree_skb to dev_kfree_skb_any were the only issue (which is
seems to be in many cases I wouldn't much care).

However it appears we can run huge portions of the networking stack from
napi context and there are other issues beyond dev_kfree_skb.

The worst issues I have seen are with the mlx4 driver.  In part mlx4
looks crazy calling napi_synchronize which calls msleep with interrupts
disabled.  But I have some warnings that I can should be triggerable
with other drivers using netpoll as well.

So I would like some clear guidance.  Will you accept patches to make
it safe to call the napi poll routines from hard irq context, or should
we simply defer messages prented with netconsole in hard irq context
into another context where we can run the napi code?

If there is not a clear way to fix the problems that crop up we should
just delete all of the netpoll code altogether, as it seems deadly in
it's current form.



This first mlx4 trace looks a little questionable but I can find
an equivalent trace through the tg3 driver so this looks like
another legitmate netpoll issue.
tg3_rx
  napi_gro_receive
    napi_skb_finish
      netif_receive_skb_internal
         __netif_receive_skb
            ip_rcv
              NF_HOOK()
                 nf_iterate
                    ip_tables_mange_hook
                       ipt_do_table
            
------------[ cut here ]------------
WARNING: at kernel/softirq.c:159 _local_bh_enable_ip+0x41/0x8b()
Hardware name: PowerEdge C6220
Modules linked in: xt_DSCP iptable_mangle netconsole configfs ipv6 ppdev parport_pc lp parport tcp_diag inet_diag ipmi_si ipmi_devintf ipmi_msghandler hed dcdbas coretemp crc32c_intel ghash_clmulni_intel microcode i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support shpchp ioatdma dca mlx4_en mlx4_core wmi [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper/9 Not tainted 3.4 #1
Call Trace:
 <NMI>  [<ffffffff8103c20c>] warn_slowpath_common+0x85/0x9d
 [<ffffffff8103c23e>] warn_slowpath_null+0x1a/0x1c
 [<ffffffff810429ef>] _local_bh_enable_ip+0x41/0x8b
 [<ffffffff81042a5b>] local_bh_enable+0x12/0x14
 [<ffffffff8147df9a>] ipt_do_table+0x652/0x68b
 [<ffffffffa005e177>] iptable_mangle_hook+0xff/0x11c [iptable_mangle]
 [<ffffffff81435d44>] nf_iterate+0x48/0x7d
 [<ffffffff8143e7a4>] ? inet_del_protocol+0x3a/0x3a
 [<ffffffff81435eaf>] nf_hook_slow+0x6c/0xff
 [<ffffffff8143e7a4>] ? inet_del_protocol+0x3a/0x3a
 [<ffffffff8143e7a4>] ? inet_del_protocol+0x3a/0x3a
 [<ffffffff8143edd4>] NF_HOOK.clone.1+0x41/0x53
 [<ffffffff8143f074>] ip_rcv+0x23c/0x268
 [<ffffffff8140fe4f>] __netif_receive_skb+0x3a5/0x3fe
 [<ffffffff81411874>] netif_receive_skb+0x4b/0x7b
 [<ffffffff81411e24>] ? __napi_gro_receive+0xf8/0x107
 [<ffffffff814118f4>] napi_frags_finish+0x50/0xc4
 [<ffffffff81411e6c>] napi_gro_frags+0x39/0x3e
 [<ffffffffa003b6bf>] mlx4_en_process_rx_cq+0x30c/0x567 [mlx4_en]
 [<ffffffffa003d4a6>] mlx4_en_netpoll+0x8d/0xb1 [mlx4_en]
 [<ffffffff8142541b>] netpoll_poll_dev+0x4a/0x1b7
 [<ffffffff814255bf>] ? find_skb+0x37/0x82
 [<ffffffff8111cf3a>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff81424fd5>] netpoll_send_skb_on_dev+0x117/0x200
 [<ffffffff8142583a>] netpoll_send_udp+0x230/0x242
 [<ffffffffa0067296>] write_msg+0xa7/0xfb [netconsole]
 [<ffffffff8103c46d>] __call_console_drivers+0x7d/0x8f
 [<ffffffff8103c534>] _call_console_drivers+0xb5/0xd0
 [<ffffffff8103d02f>] console_unlock+0x16c/0x219
 [<ffffffff8103d6b9>] vprintk+0x3bc/0x405
 [<ffffffff814ba4b7>] printk+0x68/0x71
 [<ffffffff810891dc>] print_modules+0x6a/0xf3
 [<ffffffff81004164>] show_registers+0x48/0x214
 [<ffffffff814ba4b7>] ? printk+0x68/0x71
 [<ffffffff81009a18>] show_regs+0x16/0x2d
 [<ffffffff814bdcf1>] arch_trigger_all_cpu_backtrace_handler+0x60/0x79
 [<ffffffff814bd663>] default_do_nmi+0x66/0x1d4
 [<ffffffff814bd841>] do_nmi+0x70/0xbb
 [<ffffffff814bcd0c>] end_repeat_nmi+0x1a/0x1e
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 <<EOE>>  [<ffffffff813e23d8>] ? menu_select+0x1ac/0x303
 [<ffffffff813e0d6c>] cpuidle_enter+0x12/0x14
 [<ffffffff813e1432>] cpuidle_idle_call+0xd1/0x19b
 [<ffffffff81009545>] cpu_idle+0xb6/0xff
 [<ffffffff814b3975>] start_secondary+0xc8/0xca
---[ end trace b7bd3fb31d1fc0d7 ]---
------------[ cut here ]------------

I see a lot of this one, but this one is clearly bogus. Calling
napi_synchronize with irqs disabled!

BUG: scheduling while atomic: swapper/9/0/0x04010000
Modules linked in: xt_DSCP iptable_mangle netconsole configfs ipv6 ppdev parport_pc lp parport tcp_diag inet_diag ipmi_si ipmi_devintf ipmi_msghandler hed dcdbas coretemp crc32c_intel ghash_clmulni_intel microcode i2c_i801 i2c_core iTCO_wdt iTCO_vendor_support shpchp ioatdma dca mlx4_en mlx4_core wmi [last unloaded: scsi_wait_scan]
Pid: 0, comm: swapper/9 Tainted: G        W    3.4 #1
Call Trace:
 <NMI>  [<ffffffff8106493e>] __schedule_bug+0x4d/0x4f
 [<ffffffff814bb21a>] __schedule+0xa3/0x4ec
 [<ffffffff814bb925>] schedule+0x64/0x66
 [<ffffffff814ba584>] schedule_timeout+0xab/0xe3
 [<ffffffff81048fd1>] ? del_timer+0x82/0x82
 [<ffffffff814ba5da>] schedule_timeout_uninterruptible+0x1e/0x20
 [<ffffffff810494c0>] msleep+0x1b/0x22
                      napi_synchronize()
 [<ffffffffa003d47e>] mlx4_en_netpoll+0x65/0xb1 [mlx4_en]
 [<ffffffff8142541b>] netpoll_poll_dev+0x4a/0x1b7
 [<ffffffff814255bf>] ? find_skb+0x37/0x82
 [<ffffffff8111cf3a>] ? virt_to_head_page+0x9/0x2c
 [<ffffffff81424fd5>] netpoll_send_skb_on_dev+0x117/0x200
 [<ffffffff8142583a>] netpoll_send_udp+0x230/0x242
 [<ffffffffa0067296>] write_msg+0xa7/0xfb [netconsole]
 [<ffffffff8103c46d>] __call_console_drivers+0x7d/0x8f
 [<ffffffff8103c534>] _call_console_drivers+0xb5/0xd0
 [<ffffffff8103d02f>] console_unlock+0x16c/0x219
 [<ffffffff8103d6b9>] vprintk+0x3bc/0x405
 [<ffffffff814ba4b7>] printk+0x68/0x71
 [<ffffffff810891dc>] print_modules+0x6a/0xf3
 [<ffffffff81004164>] show_registers+0x48/0x214
 [<ffffffff814ba4b7>] ? printk+0x68/0x71
 [<ffffffff81009a18>] show_regs+0x16/0x2d
 [<ffffffff814bdcf1>] arch_trigger_all_cpu_backtrace_handler+0x60/0x79
 [<ffffffff814bd663>] default_do_nmi+0x66/0x1d4
 [<ffffffff814bd841>] do_nmi+0x70/0xbb
 [<ffffffff814bcd0c>] end_repeat_nmi+0x1a/0x1e
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 [<ffffffff812a24bd>] ? intel_idle+0xae/0x112
 <<EOE>>  [<ffffffff813e23d8>] ? menu_select+0x1ac/0x303
 [<ffffffff813e0d6c>] cpuidle_enter+0x12/0x14
 [<ffffffff813e1432>] cpuidle_idle_call+0xd1/0x19b
 [<ffffffff81009545>] cpu_idle+0xb6/0xff
 [<ffffffff814b3975>] start_secondary+0xc8/0xca
------------[ cut here ]------------
