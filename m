From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 net-next 00/22] net: mvpp2: add initial support for PPv2.2
Date: Tue,  7 Mar 2017 16:52:58 +0100
Message-ID: <1488902000-2658-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Yehuda Yitschak <yehuday@marvell.com>,
 Russell King <linux@arm.linux.org.uk>, Jason Cooper <jason@lakedaemon.net>,
 Hanna Hawa <hannah@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Stefan Chulski <stefanc@marvell.com>, Marcin Wojtas <mw@semihalf.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
 devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Pawel Moll <pawel.moll@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Kumar Gala <galak@codeaurora.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The goal of this patch series is to add basic support for PPv2.2 in
the existing mvpp2 driver. mvpp2 currently supported the PPv2.1
version of the IP, used in the 32 bits Marvell Armada 375 SoC. PPv2.2
is an evolution of this IP block, used in the 64 bits Marvell Armada
7K/8K SoCs.

In order to ease the review, the introduction of PPv2.2 support has
been made into multiple small commits, with the final commit adding
the compatible string that makes the PPv2.2 support actually
usable. The series remain fully bisectable.

People interested in testing the code will find the full series (plus
a few Device Tree patches) at:

  https://github.com/MISL-EBU-System-SW/mainline-public/tree/4.11/mvpp2.2-support-v3

I'd like to thank Stefan Chulski and Marcin Wojtas, who helped me a
lot in the development of this patch series, by reviewing the patches,
and giving lots of useful hints to debug the driver on PPv2.2. Thanks
as well to Russell King for reviewing previous iterations of this
series, and providing suggestions and fixes.

Changes between v2 and v3:

 - Rebased on v4.11-rc1.

 - Add patch "net: mvpp2: fix DMA address calculation in
   mvpp2_txq_inc_put()", to properly take into account the "packet
   offset" field of the TX descriptors. Without this, we were getting
   DMA_API_DEBUG warnings that we are unmapping DMA mappings with a
   non-mapped DMA address.

 - In patch "net: mvpp2: add and use accessors for TX/RX descriptors",
   add a function named mvpp2_txdesc_offset_get(), which is needed for
   the DMA address calculation fix.

 - In patch "net: mvpp2: add and use accessors for TX/RX descriptors",
   fix the calculation of tx_desc physical address and packet offset
   in mvpp2_tx_frag_process(). The offset was assigned into the buffer
   physical address, and the physical address to the packet offset,
   which meant the fragment process was completely broken.

 - In patch "net: mvpp2: adjust the allocation/free of BM pools for
   PPv2.2" fix how MVPP22_BM_ADDR_HIGH_VIRT_RLS_MASK is used. This
   mask is already shifted. So the value should be shifted before
   being masked and not the opposite.

 - Add a new patch "net: mvpp2: set dma mask and coherent dma mask on
   PPv2.2", to set the DMA mask and DMA coherent mask. By setting the
   DMA mask to 40 bits we avoid using bounce buffers when network
   packets are above the 4 GB limit. The coherent mask remains set to
   32 bits, because the BM pools must all have the same high 32 bits
   in their addresses.

 - Use "dma" instead of "phys" where appropriate, as suggested by
   Russell King.

 - Use the "cookie" field of the RX descriptor to store the physical
   address instead of the virtual address, and then use phys_to_virt()
   to get the virtual address. This allows to work around the limit
   that the "cookie" field only has 40 bits, which is not sufficient
   to store a virtual address on 64 bits platforms. This was suggested
   by Russell King.

   As part of this change, also got rid of all the compile time
   conditionals on CONFIG_ARCH_DMA_ADDR_T_64BIT, to get better
   compile-time coverage.

 - In patch "net: mvpp2: handle misc PPv2.1/PPv2.2 differences":

    * Instead of calling mvpp21_port_power_up(port) only on PPv2.1,
      remove this function, and call its relevant parts directly from
      ->probe(). Only mvpp2_port_fc_adv_enable() is PPv2.1
      specific. Reported by Russell King.

    * Add a mvpp22_port_mii_set() function that properly initializes
      SGMII support on PPv2.2. Code provided by Russell King.

 - In patch "net: mvpp2: handle register mapping and access for PPv2.2":

    * Adjust the code to match the change of the DT binding in terms
      of mapping the second register area on PPv2.2.

    * Rework the register accessors to remove the get_cpu()/put_cpu(),
      and instead use separate accessors for global registers
      vs. per-CPU registers.

 - Add a few new patches removing dead/unused/useless code:

   net: mvpp2: remove support for buffer header
   net: mvpp2: remove unused register definition MVPP2_TXQ_THRESH_REG
   net: mvpp2: remove mvpp2_txq_pend_desc_num_get() function

 - Fix a number of checkpatch warnings.

Changes between v1 and v2:

 - Made a separate series from the set of patches doing preparation
   changes/fixes to the mvpp2 driver.

 - Rebased on top of v4.10-rc1.

 - Update Kconfig text of the mvpp2 driver to mention the support for
   Armada 7K and 8K (PPv2.2).


Thomas Petazzoni (22):
  dt-bindings: net: update Marvell PPv2 binding for PPv2.2 support
  net: mvpp2: use "dma" instead of "phys" where appropriate
  net: mvpp2: remove support for buffer header
  net: mvpp2: remove unused register definition MVPP2_TXQ_THRESH_REG
  net: mvpp2: remove mvpp2_txq_pend_desc_num_get() function
  net: mvpp2: store physical address of buffer in rx_desc->buf_cookie
  net: mvpp2: add and use accessors for TX/RX descriptors
  net: mvpp2: add hw_version field in "struct mvpp2"
  net: mvpp2: introduce an intermediate union for the TX/RX descriptors
  net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors
  net: mvpp2: adjust the allocation/free of BM pools for PPv2.2
  net: mvpp2: adapt the mvpp2_rxq_*_pool_set functions to PPv2.2
  net: mvpp2: adapt mvpp2_defaults_set() to PPv2.2
  net: mvpp2: adjust mvpp2_{rxq,txq}_init for PPv2.2
  net: mvpp2: handle register mapping and access for PPv2.2
  net: mvpp2: handle misc PPv2.1/PPv2.2 differences
  net: mvpp2: add AXI bridge initialization for PPv2.2
  net: mvpp2: rework RXQ interrupt group initialization for PPv2.2
  net: mvpp2: adapt rxq distribution to PPv2.2
  net: mvpp2: add support for an additional clock needed for PPv2.2
  net: mvpp2: set dma mask and coherent dma mask on PPv2.2
  net: mvpp2: finally add the PPv2.2 compatible string

 .../devicetree/bindings/net/marvell-pp2.txt        |   62 +-
 drivers/net/ethernet/marvell/Kconfig               |    4 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 1186 ++++++++++++++------
 3 files changed, 908 insertions(+), 344 deletions(-)

-- 
2.7.4
