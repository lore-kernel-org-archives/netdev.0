From: <sean.wang@mediatek.com>
Subject: [PATCH net 0/2] Fix crash caused by reporting inconsistent skb->len to BQL
Date: Tue, 11 Apr 2017 15:12:32 +0800
Message-ID: <1491894754-16384-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

The series fixes kernel BUG caused by inconsistent SKB length reported
into BQL. The reason for inconsistent length comes from hardware BUG which
results in different port number carried on the TXD within the lifecycle of
SKB. So patch 2) is proposed for use a software way to track which port
the SKB involving instead of hardware way. And patch 1) is given for another
issue I found which causes TXD and SKB inconsistency that is not expected
in the initial logic, so it is also being corrected it in the series.

The log for the kernel BUG caused by the issue is shown as below.

[  120.825955] kernel BUG at ... lib/dynamic_queue_limits.c:26!
[  120.837684] Internal error: Oops - BUG: 0 [#1] SMP ARM
[  120.842778] Modules linked in:
[  120.845811] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.11.0-rc1-191576-gdbcef47 #35
[  120.853488] Hardware name: Mediatek Cortex-A7 (Device Tree)
[  120.859012] task: c1007480 task.stack: c1000000
[  120.863510] PC is at dql_completed+0x108/0x17c
[  120.867915] LR is at 0x46
[  120.870512] pc : [<c03c19c8>]    lr : [<00000046>]    psr: 80000113
[  120.870512] sp : c1001d58  ip : c1001d80  fp : c1001d7c
[  120.881895] r10: 0000003e  r9 : df6b3400  r8 : 0ed86506
[  120.887075] r7 : 00000001  r6 : 00000001  r5 : 0ed8654c  r4 : df0135d8
[  120.893546] r3 : 00000001  r2 : df016800  r1 : 0000fece  r0 : df6b3480
[  120.900018] Flags: Nzcv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[  120.907093] Control: 10c5387d  Table: 9e27806a  DAC: 00000051
[  120.912789] Process swapper/0 (pid: 0, stack limit = 0xc1000218)
[  120.918744] Stack: (0xc1001d58 to 0xc1002000)

....

121.085331] 1fc0: 00000000 c0a52a28 00000000 c10855d4 c1003c58 c0a52a24 c100885c 8000406a
[  121.093444] 1fe0: 410fc073 00000000 00000000 c1001ff8 8000807c c0a009cc 00000000 00000000
[  121.101575] [<c03c19c8>] (dql_completed) from [<c04cb010>] (mtk_napi_tx+0x1d0/0x37c)
[  121.109263] [<c04cb010>] (mtk_napi_tx) from [<c05e28cc>] (net_rx_action+0x24c/0x3b8)
[  121.116951] [<c05e28cc>] (net_rx_action) from [<c010152c>] (__do_softirq+0xe4/0x35c)
[  121.124638] [<c010152c>] (__do_softirq) from [<c012a624>] (irq_exit+0xe8/0x150)
[  121.131895] [<c012a624>] (irq_exit) from [<c017750c>] (__handle_domain_irq+0x70/0xc4)
[  121.139666] [<c017750c>] (__handle_domain_irq) from [<c0101404>] (gic_handle_irq+0x58/0x9c)
[  121.147953] [<c0101404>] (gic_handle_irq) from [<c010e18c>] (__irq_svc+0x6c/0x90)
[  121.155373] Exception stack(0xc1001ef8 to 0xc1001f40)

Sean Wang (2):
  net: ethernet: mediatek: fix inconsistency between TXD and the used
    buffer
  net: ethernet: mediatek: fix inconsistency of port number carried in
    TXD

 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 31 ++++++++++++++++-------------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h | 12 ++++++++---
 2 files changed, 26 insertions(+), 17 deletions(-)

-- 
1.9.1
