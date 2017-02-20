From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH net-next v3 0/4] net: mvneta: improve rx/tx performance
Date: Mon, 20 Feb 2017 20:53:40 +0800
Message-ID: <20170220125344.3555-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
        <arnd@arndb.de>, <gregory.clement@free-electrons.com>,
        <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In hot code path such as mvneta_rx_swbm(), we access fields of rx_desc
and tx_desc. These DMA descs are allocated by dma_alloc_coherent, they
are uncacheable if the device isn't cache coherent, reading from
uncached memory is fairly slow.

patch1 reuses the read out status to getting status field of rx_desc
again.

patch2 avoids getting buf_phys_addr from rx_desc again in
mvneta_rx_hwbm by reusing the phys_addr variable.

patch3 avoids reading from tx_desc as much as possible by store what
we need in local variable.

We get the following performance data on Marvell BG4CT Platforms
(tested with iperf):

before the patch:
sending 1GB in mvneta_tx()(disabled TSO) costs 793553760ns

after the patch:
sending 1GB in mvneta_tx()(disabled TSO) costs 719953800ns

we saved 9.2% time.

patch4 uses cacheable memory to store the rx buffer DMA address.

We get the following performance data on Marvell BG4CT Platforms
(tested with iperf):

before the patch:
recving 1GB in mvneta_rx_swbm() costs 1492659600 ns

after the patch:
recving 1GB in mvneta_rx_swbm() costs 1421565640 ns

We saved 4.76% time.

Basically, patch1 and patch4 do what Arnd mentioned in [1].

Hi Arnd,

I added "Suggested-by you" tag, I hope you don't mind ;)

Thanks

[1] https://www.spinics.net/lists/netdev/msg405889.html

Since v2:
  - add Gregory's ack to patch1
  - only get rx buffer DMA address from cacheable memory for mvneta_rx_swbm()
  - add patch 2 to read rx_desc->buf_phys_addr once in mvneta_rx_hwbm()
  - add patch 3 to avoid reading from tx_desc as much as possible

Since v1:
  - correct the performance data typo


Jisheng Zhang (4):
  net: mvneta: avoid getting status from rx_desc as much as possible
  net: mvneta: avoid getting buf_phys_addr from rx_desc again
  net: mvneta: avoid reading from tx_desc as much as possible
  net: mvneta: Use cacheable memory to store the rx buffer DMA address

 drivers/net/ethernet/marvell/mvneta.c | 80 +++++++++++++++++++----------------
 1 file changed, 43 insertions(+), 37 deletions(-)

-- 
2.11.0
