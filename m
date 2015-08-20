From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: RX packet loss on i.MX6Q running 4.2-rc7
Date: Fri, 21 Aug 2015 00:30:50 +0200
Message-ID: <20150820223049.GA20710@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King <rmk+kernel@arm.linux.org.uk>,
	Marek Vasut <marex@denx.de>,
	Duan Andy <fugang.duan@freescale.com>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Eric Nelson <eric.nelson@boundarydevices.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Uwe =?utf-8?Q?Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
	Lucas Stach <l.stach@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Lothar =?utf-8?Q?Wa=C3=9Fmann?= <LW@KARO-electronics.de>,
	Andrew Lunn <andrew@lunn.ch>,
	Clemens Gruber <clemens.gruber@pqgruber.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am experiencing massive RX packet loss on my i.MX6Q (Chip rev 1.3) on Linux
4.2-rc7 with a Marvell 88E1510 Gigabit Ethernet PHY connected over RGMII.
I noticed it when doing an UDP benchmark with iperf3. When sending UDP packets
from a Debian PC to the i.MX6 with a rate of 100 Mbit/s, 99% of the packets are
lost. With a rate of 10 Mbit/s, we are still losing 93% of all packets. TCP RX
does suffer from packet loss too, but still achieves about 211 Mbit/s.
TX is not affected.

Steps to reproduce:
On the i.MX6: iperf3 -s
On a desktop PC:  iperf3 -b 10M -u -c MX6IP

The iperf3 results:
[ ID] Interval           Transfer     Bandwidth       Jitter    Lost/Total
[  4]   0.00-10.00  sec  11.8 MBytes  9.90 Mbits/sec  0.687 ms  1397/1497 (93%)

During the 10 Mbit UDP test, the IEEE_rx_macerr counter increased to 5371.
ifconfig eth0 shows:
 RX packets:9216 errors:5248 dropped:170 overruns:5248 frame:5248
 TX packets:83 errors:0 dropped:0 overruns:0 carrier:0
 collisions:0

Here are the TCP results with iperf3 -c MX6IP:
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   252 MBytes   211 Mbits/sec  4343             sender
[  4]   0.00-10.00  sec   251 MBytes   211 Mbits/sec                  receiver

During the TCP test, IEEE_rx_macerr increased to 4059.
ifconfig eth0 shows:
RX packets:186368 errors:4206 dropped:50 overruns:4206 frame:4206
TX packets:41861 errors:0 dropped:0 overruns:0 carrier:0
collisions:0

Freescale errata entry ERR004512 did mention a RX FIFO overrun. Is this related?

Forcing pause frames via ethtool -A eth0 rx on tx on, does not improve it:
Same amount of UDP packet loss with reduced TCP throughput of 190 Mbit/s.
IEEE_rx_macerr increased up to 5232 during UDP 10Mbit and up to 4270 for TCP.

I am already using the MX6QDL_PAD_GPIO_6__ENET_IRQ workaround, which solved the
ping latency issues from ERR006687 but not the packet loss problem.

I read through the mailing list archives and found a discussion between Russell
King, Marek Vasut, Eric Nelson, Fugang Duan and others about a similar problem.
I therefore added you and contributors to fec_main.c to the CC.

One suggestion I found, was adding udelay(210); to fec_enet_rx():
https://lkml.org/lkml/2014/8/22/88
But this also did not reduce the packet loss. (I added it to the fec_enet_rx
function just before return pkt_received; but I still got 93% packet loss)

Does anyone have the equipment/setup to trace an i.MX6Q during UDP RX traffic
from iperf3 to find the root cause of this packet loss problem?

What else could we do to fix this?

Thanks,
Clemens
