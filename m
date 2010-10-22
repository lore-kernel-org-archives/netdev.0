From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: cxgb3: possible double-IRQ free if EEH errors occur?
Date: Fri, 22 Oct 2010 10:28:36 -0700
Message-ID: <20101022172836.GA7663@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Wen Xiong <wenxiong@us.ibm.com>, Julia Lawall <julia@diku.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sonnyrao@us.ibm.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm testing some new firmware for pSeries and the firmware is leading to
EEH errors for a Chelsio card. These failures are PCI bus errors and
failed resets. This happens at a point, though, which results in a ton
of the following:

Trying to free already-free IRQ 62
------------[ cut here ]------------
WARNING: at kernel/irq/manage.c:899
Modules linked in: autofs4 ipt_REJECT xt_tcpudp nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack iptable_filter ip_tables x_tables binfmt_misc dm_mirror dm_region_hash dm_log cxgb3 mdio ib_ehca ib_core [last unloaded: scsi_wait_scan]
NIP: c0000000000ee198 LR: c0000000000ee194 CTR: c000000000520b7c
REGS: c000000f2918ef70 TRAP: 0700   Not tainted  (2.6.36-rc7-00159-g3f287d7)
MSR: 8000000000029032 <EE,ME,CE,IR,DR>  CR: 28000022  XER: 00000004
TASK = c000000f38f58000[8615] 'eehd' THREAD: c000000f2918c000 CPU: 56
GPR00: c0000000000ee194 c000000f2918f1f0 c000000000ad89b8 0000000000000026 
GPR04: 0000000000000000 ffffffffffffffff 0000000000004000 000000000000008b 
GPR08: 0000000000000000 c0000000009c74a8 c000000000ab6558 0000000000000001 
GPR12: 0000000028000022 c00000000eed4c00 0000000002adfa78 0000000000979800 
GPR16: 0000000003280000 c000000000876260 c000000000871de8 0000000003c0b5b8 
GPR20: c00000000098b5b8 0000000000000000 c000000001085e55 0000000000000000 
GPR24: c0000007aa4fc000 0000000000000001 c000000000aee264 000000000000003e 
GPR28: 0000000000000000 c000000000aee200 c000000000a38658 c000000f2918f1f0 
NIP [c0000000000ee198] .__free_irq+0xb8/0x240
LR [c0000000000ee194] .__free_irq+0xb4/0x240
Call Trace:
[c000000f2918f1f0] [c0000000000ee194] .__free_irq+0xb4/0x240 (unreliable)
[c000000f2918f2a0] [c0000000000ee3a0] .free_irq+0x80/0xd8
[c000000f2918f340] [d000000009209a88] .free_irq_resources+0x58/0x108 [cxgb3]
[c000000f2918f3e0] [d00000000920cbdc] .cxgb_down+0xb4/0x17c [cxgb3]
[c000000f2918f490] [d00000000920cf6c] .cxgb_close+0x1dc/0x218 [cxgb3]
[c000000f2918f530] [c0000000005cfff4] .__dev_close+0xbc/0xf0
[c000000f2918f5c0] [c0000000005d0060] .dev_close+0x38/0x74
[c000000f2918f650] [c0000000005d017c] .rollback_registered_many+0xe0/0x2fc
[c000000f2918f700] [c0000000005d04ec] .unregister_netdevice_queue+0xac/0xec
[c000000f2918f7a0] [c0000000005d0564] .unregister_netdev+0x38/0x58
[c000000f2918f830] [d00000000922bd6c] .remove_one+0xd0/0x218 [cxgb3]
[c000000f2918f8e0] [c0000000003926a4] .pci_device_remove+0x5c/0xa0
[c000000f2918f970] [c000000000415fcc] .__device_release_driver+0xc8/0x138
[c000000f2918fa10] [c0000000004161d0] .device_release_driver+0x40/0x68
[c000000f2918faa0] [c000000000414ef0] .bus_remove_device+0x110/0x154
[c000000f2918fb40] [c000000000411dc8] .device_del+0x184/0x248
[c000000f2918fbe0] [c000000000411ee4] .device_unregister+0x58/0x7c
[c000000f2918fc70] [c00000000038d180] .pci_stop_bus_device+0x8c/0xc0
[c000000f2918fd10] [c00000000038d2dc] .pci_remove_bus_device+0x40/0x120
[c000000f2918fdb0] [c00000000005b4d0] .pcibios_remove_pci_devices+0xc4/0xf8
[c000000f2918fe50] [c000000000059e90] .handle_eeh_events+0x3a0/0x3e8
[c000000f2918ff00] [c00000000005a484] .eeh_event_handler+0xfc/0x194
[c000000f2918ff90] [c00000000002f960] .kernel_thread+0x54/0x70
Instruction dump:
7f43d378 485aa379 60000000 eb9d0040 397d0040 7c791b78 2fbc0000 409e002c 
e87e80a0 7f64db78 485b3935 60000000 <0fe00000> 7f43d378 7f24cb78 485a9b09 
---[ end trace 28239ce5a229a8c2 ]---

I think I know why, but I'd like some confirmation. I also am not sure
if adding an appropriate netif_running() check is sufficient?

from cxgb3_main.c:

        if (!(adap->flags & QUEUES_BOUND)) {
                err = bind_qsets(adap);
                if (err) {
                        CH_ERR(adap, "failed to bind qsets, err %d\n", err);
                        t3_intr_disable(adap);
                        free_irq_resources(adap);
                        goto out;
                }
                adap->flags |= QUEUES_BOUND;
        }

and in my dmesg:

        cxgb3 0009:01:00.0: failed to bind qsets, err 2

So this path is encountered and the IRQ has been freed. However, when
the EEH errors start occurring which leads to free_irq_resources being
called again. So, does that simply mean some check needs to be added in
the close or down path to avoid freeing already freed IRQs?

I'm also wondering about the following similar situation?

eeh_report_failure -> driver->err_handler->error_detected
                   -> t3_io_error_detected
                   -> t3_adapter_error
                   -> cxgb_close
                   -> same trace as above

If there was already a failure earlier in the bringup.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center
