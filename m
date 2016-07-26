From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 26 Jul 2016 23:32:18 +0800
Message-ID: <20160726153218.GA17690@wfg-t540p.sh.intel.com>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com>
 <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

It works!

On Tue, Jul 26, 2016 at 11:14:52AM +0200, Eric Dumazet wrote:
>On Tue, 2016-07-26 at 11:50 +0800, Fengguang Wu wrote:
>> Greetings,
>>
>> This BUG message can be found in recent kernels as well as v4.4 and
>> linux-stable. It happens when running
>>
>>         modprobe netconsole netconsole=@/,$port@$server/
>>
>> [   39.937534] 22 Jul 13:30:40 ntpdate[440]: step time server 192.168.1.1 offset -673.833841 sec
>> [   39.943285] netpoll: netconsole: local port 6665
>> [   39.943436] netpoll: netconsole: local IPv4 address 0.0.0.0
>> [   39.943609] netpoll: netconsole: interface 'eth0'
>> [   39.943756] netpoll: netconsole: remote port 6672
>> [   39.943913] netpoll: netconsole: remote IPv4 address 192.168.1.1
>> [   39.944099] netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
>> [   39.944311] netpoll: netconsole: local IP 192.168.1.193
>> [   39.944514] BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
>> [   39.944515] in_atomic(): 1, irqs_disabled(): 1, pid: 448, name: modprobe
>> [   39.944517] CPU: 6 PID: 448 Comm: modprobe Not tainted 4.7.0-rc7-wt-ath-10122-gf9b5ec2 #102
>> [   39.944518] Hardware name:                  /DZ77BH-55K, BIOS BHZ7710H.86A.0097.2012.1228.1346 12/28/2012
>> [   39.944522]  0000000000000000 ffffc90001f2f9e8 ffffffff813417d9 ffff88007faba5c0
>> [   39.944524]  000000000000006e ffffc90001f2fa00 ffffffff810aec03 ffffffff81a25948
>> [   39.944525]  ffffc90001f2fa28 ffffffff810aec9a ffff8803e5bd9400 ffff8803e50fbd68
>> [   39.944526] Call Trace:
>> [   39.944533]  [<ffffffff813417d9>] dump_stack+0x63/0x8a
>> [   39.944536]  [<ffffffff810aec03>] ___might_sleep+0xd3/0x120
>> [   39.944537]  [<ffffffff810aec9a>] __might_sleep+0x4a/0x80
>> [   39.944541]  [<ffffffff810e4638>] synchronize_irq+0x38/0xa0
>> [   39.944543]  [<ffffffff810e3c8e>] ? __irq_put_desc_unlock+0x1e/0x40
>> [   39.944545]  [<ffffffff810e48e3>] ? __disable_irq_nosync+0x43/0x60
>> [   39.944547]  [<ffffffff810e492c>] disable_irq+0x1c/0x20
>> [   39.944559]  [<ffffffffa0220932>] e1000_netpoll+0xf2/0x120 [e1000e]
>> [   39.944563]  [<ffffffff815f2bdc>] netpoll_poll_dev+0x5c/0x1a0
>> [   39.944567]  [<ffffffff815bb361>] ? __kmalloc_reserve+0x31/0x90
>> [   39.944569]  [<ffffffff815f2e8b>] netpoll_send_skb_on_dev+0x16b/0x250
>> [   39.944572]  [<ffffffff815f325c>] netpoll_send_udp+0x2ec/0x450
>> [   39.944576]  [<ffffffffa003cb62>] write_msg+0xb2/0xf0 [netconsole]
>> [   39.944578]  [<ffffffff810e04e5>] call_console_drivers+0x115/0x120
>> [   39.944580]  [<ffffffff810e1f13>] console_unlock+0x333/0x5c0
>> [   39.944583]  [<ffffffff810e2c74>] register_console+0x1c4/0x380
>> [   39.944586]  [<ffffffffa004f1c5>] init_netconsole+0x1c5/0x1000 [netconsole]
>> [   39.944588]  [<ffffffffa004f000>] ? 0xffffffffa004f000
>> [   39.944591]  [<ffffffff8100216d>] do_one_initcall+0x3d/0x150
>> [   39.944592]  [<ffffffff810aec9a>] ? __might_sleep+0x4a/0x80
>> [   39.944596]  [<ffffffff811f5098>] ? kmem_cache_alloc_trace+0x188/0x1e0
>> [   39.944598]  [<ffffffff8118f871>] do_init_module+0x5f/0x1d8
>> [   39.944602]  [<ffffffff81114009>] load_module+0x1429/0x1b40
>> [   39.944604]  [<ffffffff81110cd0>] ? __symbol_put+0x40/0x40
>> [   39.944607]  [<ffffffff8121f348>] ? kernel_read_file+0x178/0x1a0
>> [   39.944608]  [<ffffffff8121f429>] ? kernel_read_file_from_fd+0x49/0x80
>> [   39.944611]  [<ffffffff81114973>] SYSC_finit_module+0xc3/0xf0
>> [   39.944614]  [<ffffffff811149be>] SyS_finit_module+0xe/0x10
>> [   39.944617]  [<ffffffff816e5877>] entry_SYSCALL_64_fastpath+0x1a/0xa9
>> [   39.946384] console [netcon0] enabled
>> [   39.946514] netconsole: network logging started
>>
>> Can this be possibly fixed?
>
>Could you try this ?
>
>diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
>index f42129d09e2c23ba9fdb5cde890d50ecb7166a42..a53c41c4c4f7d1fe52f95a2cab8784a938b3820b 100644
>--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
>+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
>@@ -5257,9 +5257,13 @@ static void e1000_netpoll(struct net_device *netdev)
> {
> 	struct e1000_adapter *adapter = netdev_priv(netdev);
>
>-	disable_irq(adapter->pdev->irq);
>-	e1000_intr(adapter->pdev->irq, netdev);
>-	enable_irq(adapter->pdev->irq);
>+	if (napi_schedule_prep(&adapter->napi)) {
>+		adapter->total_tx_bytes = 0;
>+		adapter->total_tx_packets = 0;
>+		adapter->total_rx_bytes = 0;
>+		adapter->total_rx_packets = 0;
>+		__napi_schedule(&adapter->napi);
>+	}

The machines are actually running e1000e driver, so I copied your
approach to e1000e and it works:

kern  :info  : [   16.109647] netpoll: netconsole: local port 6665
kern  :info  : [   16.109961] netpoll: netconsole: local IPv4 address 0.0.0.0
kern  :info  : [   16.110346] netpoll: netconsole: interface 'eth0'
kern  :info  : [   16.110672] netpoll: netconsole: remote port 6676
kern  :info  : [   16.110991] netpoll: netconsole: remote IPv4 address 192.168.2.1
kern  :info  : [   16.111398] netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:ff
kern  :info  : [   16.111845] netpoll: netconsole: local IP 192.168.2.3
kern  :info  : [   16.114284] console [netcon0] enabled
kern  :info  : [   16.114550] netconsole: network logging started

However I'm not sure if it'll have side effects, because this
effectively disables the various checks in e1000_intr() and
e1000_intr_msi().

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9b4ec13..4f89873 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6711,15 +6711,14 @@ static void e1000_netpoll(struct net_device *netdev)
 	case E1000E_INT_MODE_MSIX:
 		e1000_intr_msix(adapter->pdev->irq, netdev);
 		break;
-	case E1000E_INT_MODE_MSI:
-		disable_irq(adapter->pdev->irq);
-		e1000_intr_msi(adapter->pdev->irq, netdev);
-		enable_irq(adapter->pdev->irq);
-		break;
 	default:		/* E1000E_INT_MODE_LEGACY */
-		disable_irq(adapter->pdev->irq);
-		e1000_intr(adapter->pdev->irq, netdev);
-		enable_irq(adapter->pdev->irq);
+		if (napi_schedule_prep(&adapter->napi)) {
+			adapter->total_tx_bytes = 0;
+			adapter->total_tx_packets = 0;
+			adapter->total_rx_bytes = 0;
+			adapter->total_rx_packets = 0;
+			__napi_schedule(&adapter->napi);
+		}
 		break;
 	}
 }

Thanks,
Fengguang
