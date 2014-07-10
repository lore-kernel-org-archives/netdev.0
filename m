From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: sh_eth DMA API violations
Date: Thu, 10 Jul 2014 12:12:13 +0200
Message-ID: <CAMuHMdVgBe89P6a5Zmk4Z3VTBOgA=YE7Nvy9twpHOEAX+mk6TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After enabling CONFIG_DMA_API_DEBUG=y, several violations of the DMA API
are reported:

1)  WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:1140 check_unmap+0x6a4/0x7e0()
    net eth0: DMA-API: device driver failed to check map error[device
address=0x000000006e583002] [size=590 bytes] [mapped as single]

    ....

    [<c026bfe8>] (sh_eth_txfree) from [<c026c414>]
(sh_eth_interrupt+0x148/0x59c)
     r10:c04e12e7 r9:c04affa8 r8:00200000 r7:c04da10c r6:ee580d00 r5:00200000
     r4:ee580800
    [<c026c2cc>] (sh_eth_interrupt) from [<c006205c>]
(handle_irq_event_percpu+0x38/0x130)
     r8:eec0f400 r7:00000000 r6:00000000 r5:000000c2 r4:ee59f200

    The return value of dma_map_single() is never checked using
    dma_mapping_error(). In several cases, its return value isn't used at
    all; virt_to_phys() is used instead.


2)  WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:501 add_dma_entry+0xe0/0x134()
    DMA-API: exceeded 7 overlapping mappings of cacheline 0x0000000001b97201

    ...

    [<c01c5d54>] (debug_dma_map_page) from [<c026ba08>]
(sh_eth_poll+0x3c0/0x534)
     r10:0000003f r9:00000040 r8:005cb900 r7:00000024 r6:0000003f r5:ee5a8040
     r4:ee580800
    [<c026b648>] (sh_eth_poll) from [<c02c7dc8>] (net_rx_action+0xb4/0x16c)

    Receive buffers are never unmapped using dma_unmap_single(). This will
    lead to resource shortages when using an IOMMU.


3)  WARNING: CPU: 0 PID: 0 at lib/dma-debug.c:1189 check_sync+0x148/0x4f8()
    net eth0: DMA-API: device driver tries to sync DMA memory it has
not allocated [device address=0x000000006e5e8060] [size=1546 bytes]

    ...

    [<c01c4e44>] (debug_dma_sync_single_for_cpu) from [<c026b944>]
(sh_eth_poll+0x240/0x578)
     r5:0000003f r4:ee54a000
    [<c026b704>] (sh_eth_poll) from [<c02c7f38>] (net_rx_action+0xb4/0x16c)
     r10:c04e1406 r9:ef1e2cc8 r8:ffff8ead r7:0000012c r6:00000040 r5:ef1e2cc0
     r4:ee54a51c
    [<c02c7e84>] (net_rx_action) from [<c0029af8>] (__do_softirq+0xe8/0x21c)
     r10:c04be08c r9:0000000a r8:c04bc000 r7:00000100 r6:00000008 r5:c04bc010
     r4:40000003
    [<c0029a10>] (__do_softirq) from [<c0029e8c>] (irq_exit+0x8c/0xe8)
     r10:00000000 r9:c04affa8 r8:c04c4380 r7:c04bdf6c r6:00000000 r5:000000c2
     r4:c04bc020
    [<c0029e00>] (irq_exit) from [<c000f5f0>] (handle_IRQ+0x74/0x98)
     r4:c04b9bd8 r3:000001af

    This one is less likely to happen.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
