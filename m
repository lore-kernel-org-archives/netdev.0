From: Meelis Roos <mroos@linux.ee>
Subject: tg3 BUG: spinlock lockup suspected
Date: Wed, 5 Oct 2016 15:06:46 +0300 (EEST)
Message-ID: <alpine.LRH.2.20.1610051502240.23078@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org, sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am testing 4.8 on my sparcs and got this on Sun V210 (sparc64). This 
is reproducible. 4.8.0-rc3-00013 did not have this problem, will bisect 
when I get some time.

[   74.123859] tg3.c:v3.137 (May 11, 2014)
[   74.123880] PCI: Enabling device: (0000:00:02.0), cmd 2
[   74.315794] tg3 0000:00:02.0 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
[   74.656152] tg3 0000:00:02.0 eth0: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:85
[   74.656160] tg3 0000:00:02.0 eth0: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   74.656167] tg3 0000:00:02.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   74.656172] tg3 0000:00:02.0 eth0: dma_rwctrl[763f0000] dma_mask[32-bit]
[   74.656322] PCI: Enabling device: (0000:00:02.1), cmd 2
[   74.845325] tg3 0000:00:02.1 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
[   75.184539] tg3 0000:00:02.1 eth1: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:86
[   75.184546] tg3 0000:00:02.1 eth1: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   75.184551] tg3 0000:00:02.1 eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   75.184557] tg3 0000:00:02.1 eth1: dma_rwctrl[763f0000] dma_mask[32-bit]
[   75.184708] PCI: Enabling device: (0003:00:02.0), cmd 2
[   75.375322] tg3 0003:00:02.0 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
[   75.714681] tg3 0003:00:02.0 eth2: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:87
[   75.714688] tg3 0003:00:02.0 eth2: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   75.714694] tg3 0003:00:02.0 eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   75.714699] tg3 0003:00:02.0 eth2: dma_rwctrl[763f0000] dma_mask[32-bit]
[   75.714819] PCI: Enabling device: (0003:00:02.1), cmd 2
[   75.905278] tg3 0003:00:02.1 (unnamed net_device) (uninitialized): Cannot get nvram lock, tg3_nvram_init failed
[   76.244470] tg3 0003:00:02.1 eth3: Tigon3 [partno(none) rev 2003] (PCI:66MHz:64-bit) MAC address 00:03:ba:0a:f3:88
[   76.244477] tg3 0003:00:02.1 eth3: attached PHY is 5704 (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
[   76.244482] tg3 0003:00:02.1 eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
[   76.244488] tg3 0003:00:02.1 eth3: dma_rwctrl[763f0000] dma_mask[32-bit]
[   83.643317] tg3 0000:00:02.0 eth0: No firmware running
[...]
[   83.716570] BUG: spinlock lockup suspected on CPU#0, dhclient/1014
[   83.797819]  lock: 0xfff000123c8e4a08, .magic: dead4ead, .owner: ip/1001, .owner_cpu: 1
[   83.903130] CPU: 0 PID: 1014 Comm: dhclient Not tainted 4.8.0 #4
[   83.982129] Call Trace:
[   84.014160]  [00000000004b7220] spin_dump+0x60/0xa0
[   84.078203]  [00000000004b73a0] do_raw_spin_lock+0xa0/0x120
[   84.106344] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   84.107193] ip (1001) used greatest stack depth: 2168 bytes left
[   84.306955]  [000000000092c0d0] _raw_spin_lock_bh+0x30/0x40
[   84.380188]  [00000000100822cc] tg3_get_stats64+0xc/0x80 [tg3]
[   84.456885]  [00000000007fac8c] dev_get_stats+0x2c/0xc0
[   84.525506]  [000000000081a4e8] dev_seq_printf_stats+0x8/0xe0
[   84.600986]  [000000000081a5e4] dev_seq_show+0x24/0x40
[   84.668467]  [00000000005cb6c4] seq_read+0x2c4/0x440
[   84.733656]  [000000000060b97c] proc_reg_read+0x3c/0x80
[   84.802282]  [00000000005a219c] __vfs_read+0x1c/0x140
[   84.868613]  [00000000005a2310] vfs_read+0x50/0x100
[   84.932662]  [00000000005a265c] SyS_read+0x3c/0xa0
[   84.995573]  [00000000004061d4] linux_sparc_syscall32+0x34/0x60
[   85.073748] * CPU[  0]: TSTATE[00000044f0001a22] TPC[00000000f79a16b0] TNPC[00000000f79a16b4] TASK[dhclient:1014]
[   85.208732]              TPC[f79a16b0] O7[f79405c8] I7[0] RPC[0]
[   85.287633]   CPU[  1]: TSTATE[0000004480001605] TPC[00000000004b26f0] TNPC[00000000004d0b0c] TASK[swapper/1:0]
[   85.420338]              TPC[trace_hardirqs_off+0x10/0x20] O7[rcu_idle_enter+0x64/0xa0] I7[cpu_startup_entry+0x1b0/0x240] RPC[rest_init+0x178/0x1a0]
[   85.664600] tg3 0000:00:02.0 eth0: Link is up at 100 Mbps, full duplex
[   85.750515] tg3 0000:00:02.0 eth0: Flow control is off for TX and off for RX
[   85.843994] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

-- 
Meelis Roos (mroos@linux.ee)
