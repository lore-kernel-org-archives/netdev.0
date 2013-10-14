From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Subject: [PATCH RFC 0/5] Ethernet support for Zynq
Date: Mon, 14 Oct 2013 16:58:55 -0700
Message-ID: <1381795140-10792-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michal Simek <michal.simek@xilinx.com>,
	Soren Brinkmann <soren.brinkmann@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am trying to make Ethernet work on Zynq, whose Ethernet core is a
cadence macb.

I came across two issues: The first is, that Ethernet does not work on
the Zedboard platform, but on zc702 and zc706. In both cases the probin=
g
looks good as far as I can tell:
zc706:
	[    1.754502] libphy: MACB_mii_bus: probed
	[    2.775957] macb e000b000.ethernet eth0: Cadence GEM at 0xe000b000 =
irq 54 (00:0a:35:00:01:22)
	[    2.784638] macb e000b000.ethernet eth0: attached PHY driver [Marve=
ll 88E1116R] (mii_bus:phy_addr=3De000b000.etherne:07, irq=3D-1)
zed:
	[    1.755202] libphy: MACB_mii_bus: probed
	[    1.771422] macb e000b000.ethernet eth0: Cadence GEM at 0xe000b000 =
irq 54 (00:0a:35:00:01:22)
	[    1.780141] macb e000b000.ethernet eth0: attached PHY driver [Marve=
ll 88E1510] (mii_bus:phy_addr=3De000b000.etherne:00, irq=3D-1)

But on the Zed no actual connection can be established:
zc706:
	# udhcpc
	udhcpc (v1.21.1) started
	grep: /etc/resolv.conf: No such file or directory
	Sending discover...
	Sending discover...
	[   50.769745] macb e000b000.ethernet eth0: link up (1000/Full)
	Sending discover...
	Sending select for 10.10.70.4...
	Lease of 10.10.70.4 obtained, lease time 600
	deleting routers
	route: SIOCDELRT: No such process
	adding dns 172.19.128.1
	adding dns 172.19.129.1
	# ping 10.10.70.101
	PING 10.10.70.101 (10.10.70.101): 56 data bytes
	64 bytes from 10.10.70.101: seq=3D0 ttl=3D64 time=3D0.848 ms
	64 bytes from 10.10.70.101: seq=3D1 ttl=3D64 time=3D0.350 ms

On Zed this just loops indefinitely printing "Sending discover...
The main difference is the different phy used on the Zed. Does
anybody have an idea what might go wrong here?


And my second issue is related to the macb clocks:
Currently the macb driver expects two input clocks - pclk and hclk. At
the same time the actual Ethernet clock - tx_clk - is not handled in th=
e
driver at all.
On Zynq's implementation of the macb, pclk and hclk are the same clock
and we provide a tx_clk separately and the driver needs to adjust it
according to the negotiated link speed (at least in some/most use-cases=
).
Handling this is sketched out in 5/5. But it does not really look nice.
 - How do other SOCs handle tx_clk adjustments?
 - the bindings do not really fit Zynq's implementation. How can we
   ensure that clocks are mandatory or optional as required by the SOC
   this core is implemented in?


The first four patches in this series are probably good to go.

   	Thanks,
	S=C3=B6ren


Soren Brinkmann (5):
  net: macb: Migrate to dev_pm_ops
  net: macb: Migrate to devm clock interface
  net: macb: Use devm_ioremap()
  net: macb: Use devm_request_irq()
  net: macb: Adjust tx_clk when link speed changes

 drivers/net/ethernet/cadence/macb.c | 128 ++++++++++++++++++++++++++++=
--------
 drivers/net/ethernet/cadence/macb.h |   1 +
 2 files changed, 100 insertions(+), 29 deletions(-)

--=20
1.8.4
