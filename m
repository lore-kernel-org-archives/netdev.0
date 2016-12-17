From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: [PATCH net-next v4 0/2] stmmac: dwmac-meson8b: configurable RGMII TX delay
Date: Sat, 17 Dec 2016 19:21:17 +0100
Message-ID: <20161217182119.4037-1-martin.blumenstingl@googlemail.com>
References: <20161202233238.17561-1-martin.blumenstingl@googlemail.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org,
        khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161202233238.17561-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently the dwmac-meson8b stmmac glue driver uses a hardcoded 1/4
cycle (= 2ns) TX clock delay. This seems to work fine for many boards
(for example Odroid-C2 or Amlogic's reference boards) but there are
some others where TX traffic is simply broken.
There are probably multiple reasons why it's working on some boards
while it's broken on others:
- some of Amlogic's reference boards are using a Micrel PHY
- hardware circuit design
- maybe more...

iperf3 results on my Mecool BB2 board (Meson GXM, RTL8211F PHY) with
TX clock delay disabled on the MAC (as it's enabled in the PHY driver).
TX throughput was virtually zero before:
$ iperf3 -c 192.168.1.100 -R
Connecting to host 192.168.1.100, port 5201
Reverse mode, remote host 192.168.1.100 is sending
[  4] local 192.168.1.206 port 52828 connected to 192.168.1.100 port 5201
[ ID] Interval           Transfer     Bandwidth
[  4]   0.00-1.00   sec   108 MBytes   901 Mbits/sec
[  4]   1.00-2.00   sec  94.2 MBytes   791 Mbits/sec
[  4]   2.00-3.00   sec  96.5 MBytes   810 Mbits/sec
[  4]   3.00-4.00   sec  96.2 MBytes   808 Mbits/sec
[  4]   4.00-5.00   sec  96.6 MBytes   810 Mbits/sec
[  4]   5.00-6.00   sec  96.5 MBytes   810 Mbits/sec
[  4]   6.00-7.00   sec  96.6 MBytes   810 Mbits/sec
[  4]   7.00-8.00   sec  96.5 MBytes   809 Mbits/sec
[  4]   8.00-9.00   sec   105 MBytes   884 Mbits/sec
[  4]   9.00-10.00  sec   111 MBytes   934 Mbits/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  1000 MBytes   839 Mbits/sec    0             sender
[  4]   0.00-10.00  sec   998 MBytes   837 Mbits/sec                  receiver

iperf Done.
$ iperf3 -c 192.168.1.100
Connecting to host 192.168.1.100, port 5201
[  4] local 192.168.1.206 port 52832 connected to 192.168.1.100 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.01   sec  99.5 MBytes   829 Mbits/sec  117    139 KBytes
[  4]   1.01-2.00   sec   105 MBytes   884 Mbits/sec  129   70.7 KBytes
[  4]   2.00-3.01   sec   107 MBytes   889 Mbits/sec  106    187 KBytes
[  4]   3.01-4.01   sec   105 MBytes   878 Mbits/sec   92    143 KBytes
[  4]   4.01-5.00   sec   105 MBytes   882 Mbits/sec  140    129 KBytes
[  4]   5.00-6.01   sec   106 MBytes   883 Mbits/sec  115    195 KBytes
[  4]   6.01-7.00   sec   102 MBytes   863 Mbits/sec  133   70.7 KBytes
[  4]   7.00-8.01   sec   106 MBytes   884 Mbits/sec  143   97.6 KBytes
[  4]   8.01-9.01   sec   104 MBytes   875 Mbits/sec  124    107 KBytes
[  4]   9.01-10.01  sec   105 MBytes   876 Mbits/sec   90    139 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.01  sec  1.02 GBytes   874 Mbits/sec  1189             sender
[  4]   0.00-10.01  sec  1.02 GBytes   873 Mbits/sec                  receiver

iperf Done.

I get similar TX throughput on my Meson GXBB "MXQ Pro+" board when I
disable the PHY's TX-delay and configure a 4ms TX-delay on the MAC.
So changes to at least the RTL8211F PHY driver are needed to get it
working properly in all situations.

Changes since v3:
- rebased to apply against current net-next branch (fixes a conflict
  with d2ed0a7755fe14c7 "net: ethernet: stmmac: fix of-node and
  fixed-link-phydev leaks")
- 

Changes since v2:
- moved all .dts patches (3-7) to a separate series
- removed the default 2ns TX delay when phy-mode RGMII is specified
- (rebased against current net-next)

Changes since v1:
- renamed the devicetree property "amlogic,tx-delay" to
  "amlogic,tx-delay-ns", which makes the .dts easier to read as we can
  simply specify human-readable values instead of having "preprocessor
  defines and calculation in human brain". Thanks to Andrew Lunn for
  the suggestion!
- improved documentation to indicate when the MAC TX-delay should be
  configured and how to use the PHY's TX-delay
- changed the default TX-delay in the dwmac-meson8b driver from 2ns
  to 0ms when any of the rgmii-*id modes are used (the 2ns default
  value still applies for phy-mode "rgmii")
- added patches to properly reset the PHY on Meson GXBB devices and to
  use a similar configuration than the one we use on Meson GXL devices
  (by passing a phy-handle to stmmac and defining the PHY in the mdio0
  bus - patch 3-6)
- add the "amlogic,tx-delay-ns" property to all boards which are using
  the RGMII PHY (patch 7)

Martin Blumenstingl (2):
  net: dt-bindings: add RGMII TX delay configuration to meson8b-dwmac
  net: stmmac: dwmac-meson8b: make the RGMII TX delay configurable

 .../devicetree/bindings/net/meson-dwmac.txt         | 14 ++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson8b.c | 21 +++++++++++++++------
 2 files changed, 29 insertions(+), 6 deletions(-)

-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
