From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] ethernet/sfc: report supported link speeds on SFP connections
Date: Thu,  2 Jun 2016 21:33:24 -0400
Message-ID: <1464917604-11596-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My solarflare cards connected to a 10GbE switch with an SFP+ module/cable
don't currently report any supported link speeds:

$ ethtool ens4f0
Settings for ens4f0:
	Supported ports: [ FIBRE ]
	Supported link modes:   Not reported
	Supported pause frame use: Symmetric Receive-only
	Supports auto-negotiation: Yes
	Advertised link modes:  Not reported
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10000baseKX4/Full
	Link partner advertised pause frame use: Symmetric
	Link partner advertised auto-negotiation: No
	Speed: 10000Mb/s
	Duplex: Full
	Port: FIBRE
	PHYAD: 255
	Transceiver: internal
	Auto-negotiation: on
Cannot get wake-on-lan settings: Operation not permitted
	Current message level: 0x000020f7 (8439)
			       drv probe link ifdown ifup rx_err tx_err hw
	Link detected: yes

I've navigated my way through the sfc code down to mcdi_to_ethtool_cap's
switch on media's MC_CMD_MEDIA_SFP_PLUS case, where no speeds are set.
If we just do some cap checks similar to the MC_CMD_MEDIA_KX4 case, I get
the expected output:

$ ethtool ens4f0
Settings for ens4f0:
	Supported ports: [ FIBRE ]
	Supported link modes:   1000baseKX/Full
	                        10000baseKX4/Full
	Supported pause frame use: Symmetric Receive-only
	Supports auto-negotiation: Yes
	Advertised link modes:  Not reported
	Advertised pause frame use: Symmetric
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10000baseKX4/Full
	Link partner advertised pause frame use: Symmetric
	Link partner advertised auto-negotiation: No
	Speed: 10000Mb/s
	Duplex: Full
	Port: FIBRE
	PHYAD: 255
	Transceiver: internal
	Auto-negotiation: on
Cannot get wake-on-lan settings: Operation not permitted
	Current message level: 0x000020f7 (8439)
			       drv probe link ifdown ifup rx_err tx_err hw
	Link detected: yes

This is from an sfc9120 interface here. It also applies to a 9140 with a
10GbE breakout cable.

Side note: wiring up Advertised by simply copying Supported seems to be a
thing many other drivers do. Worth doing here?...

CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
CC: Edward Cree <ecree@solarflare.com>
CC: Bert Kenward <bkenward@solarflare.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/sfc/mcdi_port.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 7f295c4..6516471 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -189,6 +189,10 @@ static u32 mcdi_to_ethtool_cap(u32 media, u32 cap)
 
 	case MC_CMD_MEDIA_XFP:
 	case MC_CMD_MEDIA_SFP_PLUS:
+		if (cap & (1 << MC_CMD_PHY_CAP_1000FDX_LBN))
+			result |= SUPPORTED_1000baseKX_Full;
+		if (cap & (1 << MC_CMD_PHY_CAP_10000FDX_LBN))
+			result |= SUPPORTED_10000baseKX4_Full;
 		result |= SUPPORTED_FIBRE;
 		break;
 
-- 
1.8.3.1
