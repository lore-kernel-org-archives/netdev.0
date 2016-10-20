From: Tariq Toukan <tariqt@mellanox.com>
Subject: Re: mlx4: panic during shutdown
Date: Thu, 20 Oct 2016 12:07:01 +0300
Message-ID: <e81d1dfe-bcbf-64e4-6270-4309fa6b2e78@mellanox.com>
References: <alpine.LFD.2.20.1610191617400.1730@schleppi>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Yishai Hadas <yishaih@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0083.outbound.protection.outlook.com ([104.47.2.83]:6512
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751873AbcJTMic (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 08:38:32 -0400
In-Reply-To: <alpine.LFD.2.20.1610191617400.1730@schleppi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sebastian,

Thanks for the report.
We've encountered this as well, and trying to find the correct way of 
solving it.

On 19/10/2016 5:35 PM, Sebastian Ott wrote:
> Hi,
>
> After a userspace update (fedora 23->24) I reproducibly run into the
> following oops during shutdown (on s390):
>
> [   71.054832] Unable to handle kernel pointer dereference in virtual kernel address space
> [   71.054835] Failing address: 6b6b6b6b6b6b6000 TEID: 6b6b6b6b6b6b6803
> [   71.054838] Fault in home space mode while using kernel ASCE.
> [   71.054847] AS:0000000000f70007 R3:0000000000000024
> [   71.054883] Oops: 0038 ilc:3 [#1] PREEMPT SMP
> [   71.054887] Modules linked in: mlx4_ib ib_core mlx4_en ptp pps_core mlx4_core [...]
> [   71.054912] CPU: 8 PID: 809 Comm: kworker/8:6 Not tainted 4.8.0-02896-g7137af2-dirty #6
> [   71.054913] Hardware name: IBM              2964 N96              704              (LPAR)
> [   71.054919] Workqueue: events linkwatch_event
> [   71.054921] task: 00000000dbea0008 task.stack: 00000000dbea4000
> [   71.054923] Krnl PSW : 0704e00180000000 000003ff8007a496 (mlx4_en_get_phys_port_id+0x66/0xb0 [mlx4_en])
> [   71.054933]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 RI:0 EA:3
>                 Krnl GPRS: 0000000000000080 0000000000000268 000000000000004e 00000000001c33e0
> [   71.054937]            000003ff8007a486 0000000000882790 6b6b6b6b6b6b6b6b 0000000000000010
> [   71.054939]            00000000dbea7b18 6b6b6b6b6b6b6b6b 00000000dbea7b18 00000000e72e0000
> [   71.054941]            00000000f15ec900 0000000000000000 000003ff8007a486 00000000dbea79c8
> [   71.054950] Krnl Code: 000003ff8007a486: e310b81c0d14	lgf	%r1,55324(%r11)
>                            000003ff8007a48c: a71b004b		aghi	%r1,75
>                           #000003ff8007a490: eb110003000d	sllg	%r1,%r1,3
>                           >000003ff8007a496: e31190000002	ltg	%r1,0(%r1,%r9)
>                            000003ff8007a49c: a7840015		brc	8,3ff8007a4c6
>                            000003ff8007a4a0: 9208a020		mvi	32(%r10),8
>                            000003ff8007a4a4: 4130a007		la	%r3,7(%r10)
>                            000003ff8007a4a8: a7290008		lghi	%r2,8
> [   71.054965] Call Trace:
> [   71.054969] ([<000003ff8007a486>] mlx4_en_get_phys_port_id+0x56/0xb0 [mlx4_en])
> [   71.054971] ([<0000000000760b94>] rtnl_fill_ifinfo+0x4ec/0xc90)
> [   71.054974] ([<0000000000764fae>] rtmsg_ifinfo_build_skb+0x96/0xe8)
> [   71.054976] ([<0000000000765038>] rtmsg_ifinfo+0x38/0x78)
> [   71.054978] ([<000000000074150e>] netdev_state_change+0x5e/0x70)
> [   71.054981] ([<0000000000765ca6>] linkwatch_do_dev+0x66/0xc8)
> [   71.054983] ([<0000000000765fd6>] __linkwatch_run_queue+0x13e/0x190)
> [   71.054985] ([<0000000000766070>] linkwatch_event+0x48/0x58)
> [   71.054988] ([<0000000000162a2e>] process_one_work+0x3fe/0x820)
> [   71.054990] ([<00000000001630e6>] worker_thread+0x296/0x460)
> [   71.054992] ([<000000000016b41a>] kthread+0x112/0x120)
> [   71.054996] ([<00000000008762b2>] kernel_thread_starter+0x6/0xc)
> [   71.054998] ([<00000000008762ac>] kernel_thread_starter+0x0/0xc)
> [   71.055000] INFO: lockdep is turned off.
> [   71.055001] Last Breaking-Event-Address:
> [   71.055004]  [<0000000000294480>] printk+0xc8/0xd0
> [   71.055006]
> [   71.055008] Kernel panic - not syncing: Fatal exception: panic_on_oops
>
>
> This was observed with 4.8 but it's also reproducible on 4.9-rc1.
> In mlx4_en_get_phys_port_id (which looks like it's called from userspace
> via sysfs) the data behind mlx4_en_priv->mdev is already freed.
>
> The problem probably is that the lifetime of mlx4_en_priv->mdev seems to
> be shorter than that of struct net_device (and mlx4_en_get_phys_port_id
> can be called as long as struct net_device exists).
Right. This happens because we've already freed some resources.
One possible solution is to add a check of netif_device_present in 
dev_get_phys_port_id.

Something like this:

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6601,6 +6601,8 @@ int dev_get_phys_port_id(struct net_device *dev,

         if (!ops->ndo_get_phys_port_id)
                 return -EOPNOTSUPP;
+       if (!netif_device_present(dev))
+               return -ENODEV;
         return ops->ndo_get_phys_port_id(dev, ppid);
  }
  EXPORT_SYMBOL(dev_get_phys_port_id);


However, this causes other issues when combining with MTU change.
In MTU change, netif_device_present returns false for a while, causing 
an unexpected failure of dev_get_phys_port_id.
>
> Regards,
> Sebastian
>
Regards,
Tariq Toukan
