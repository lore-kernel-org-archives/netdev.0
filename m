From: Elad Kanfi <eladkan@mellanox.com>
Subject: [PATCH v3 0/2] Net driver bugs fix
Date: Mon, 9 May 2016 20:13:18 +0300
Message-ID: <1462814000-16331-1-git-send-email-eladkan@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <noamca@mellanox.com>, <linux-kernel@vger.kernel.org>,
	<abrodkin@synopsys.com>, <eladkan@mellanox.com>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Elad Kanfi <eladkan@mellanox.com>

v3:
tx_packet_sent flag is not necessary, use socket buffer pointer
instead.
Use wmb() instead of smp_wmb().

v2:
Remove code style commit for now.
Code style commit will be added after the bugs fix will be approved.

Summary:
 1. Bug description: TX done interrupts that arrives while interrupts
    are masked, during NAPI poll, will not trigger an interrupt handling.
    Since TX interrupt is of level edge we will lose the TX done interrupt.
    As a result all pending tx frames will get no service.

    Solution: Check if there is a pending tx request after unmasking the
    interrupt and if answer is yes then re-add ourselves to
    the NAPI poll list.

 2. Bug description: CPU-A before sending a frame will set a variable
    to true. CPU-B that executes the tx done interrupt service routine
    might read a non valid value of that variable.

    Solution: Use the socket buffer pointer instead of the variable,
    and add a write memory barrier at the tx sending function after
    the pointer is set.

Elad Kanfi (2):
  net: nps_enet: Tx handler synchronization
  net: nps_enet: bug fix - handle lost tx interrupts

 drivers/net/ethernet/ezchip/nps_enet.c |   30 ++++++++++++++++++++++++------
 drivers/net/ethernet/ezchip/nps_enet.h |    2 --
 2 files changed, 24 insertions(+), 8 deletions(-)
