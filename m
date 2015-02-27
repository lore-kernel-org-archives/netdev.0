From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH] sh_eth: Fix lost MAC address on kexec
Date: Fri, 27 Feb 2015 17:16:26 +0100
Message-ID: <1425053786-24223-1-git-send-email-geert+renesas@glider.be>
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Kevin Hilman <khilman@kernel.org>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 740c7f31c094703c ("sh_eth: Ensure DMA engines are stopped before
freeing buffers") added a call to sh_eth_reset() to the
sh_eth_set_ringparam() and sh_eth_close() paths.

However, setting the software reset bit(s) in the EDMR register resets
the MAC Address Registers to zero. Hence after kexec, the new kernel
doesn't detect a valid MAC address and assigns a random MAC address,
breaking DHCP.

Set the MAC address again after the reset in sh_eth_dev_exit() to fix
this.

Tested on r8a7740/armadillo (GETHER) and r8a7791/koelsch (FAST_RCAR).

Fixes: 740c7f31c094703c ("sh_eth: Ensure DMA engines are stopped before freeing buffers")
Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
---
 drivers/net/ethernet/renesas/sh_eth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 4da8bd263997a17b..654b48d1e61a3124 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1392,6 +1392,9 @@ static void sh_eth_dev_exit(struct net_device *ndev)
 	msleep(2); /* max frame time at 10 Mbps < 1250 us */
 	sh_eth_get_stats(ndev);
 	sh_eth_reset(ndev);
+
+	/* Set MAC address again */
+	update_mac_address(ndev);
 }
 
 /* free Tx skb function */
-- 
1.9.1
