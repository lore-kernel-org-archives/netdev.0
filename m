From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v2 0/7] stmmac: dwmac-meson8b: configurable RGMII TX delay
Date: Fri, 25 Nov 2016 14:01:49 +0100
Message-ID: <20161125130156.17879-1-martin.blumenstingl@googlemail.com>
References: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
Cc: linux-arm-kernel@lists.infradead.org, alexandre.torgue@st.com,
        peppe.cavallaro@st.com, will.deacon@arm.com,
        catalin.marinas@arm.com, carlo@caione.org, f.fainelli@gmail.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net, khilman@baylibre.com,
        mark.rutland@arm.com, robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35159 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753255AbcKYNCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 08:02:25 -0500
In-Reply-To: <20161124143417.10178-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the dwmac-meson8b stmmac glue driver uses a hardcoded 1/4
cycle TX clock delay. This seems to work fine for many boards (for
example Odroid-C2 or Amlogic's reference boards) but there are some
others where TX traffic is simply broken.
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


NOTE: patches 3-7 should be taken though the Amlogic tree. patches 1
and 2 can be taken through the net-tree or through the Amlogic tree.
There shouldn't be a runtime dependency as long as phy-mode "rgmii"
(or the not-relevant-for-this-case "rmii") is used (which is currently
the case for all ARM64 meson-gx boards) due to the dwmac-meson8b's
default 2ns TX-delay.


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


Martin Blumenstingl (7):
  net: dt-bindings: add RGMII TX delay configuration to meson8b-dwmac
  net: stmmac: dwmac-meson8b: make the RGMII TX delay configurable
  ARM64: dts: meson-gx: move the MDIO node to meson-gx
  ARM64: dts: meson-gxbb-odroidc2: add reset for the ethernet PHY
  ARM64: dts: meson-gxbb-p20x: add reset for the ethernet PHY
  ARM64: dts: meson-gxbb-vega-s95: add reset for the ethernet PHY
  ARM64: dts: amlogic: add the ethernet TX delay configuration

 .../devicetree/bindings/net/meson-dwmac.txt        | 14 ++++++++++++
 arch/arm64/boot/dts/amlogic/meson-gx.dtsi          |  6 +++++
 .../arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 17 ++++++++++++++
 arch/arm64/boot/dts/amlogic/meson-gxbb-p20x.dtsi   | 17 ++++++++++++++
 .../boot/dts/amlogic/meson-gxbb-vega-s95.dtsi      | 17 ++++++++++++++
 .../boot/dts/amlogic/meson-gxl-s905d-p230.dts      |  2 ++
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi         |  6 -----
 .../arm64/boot/dts/amlogic/meson-gxm-nexbox-a1.dts |  2 ++
 .../arm64/boot/dts/amlogic/meson-gxm-s912-q200.dts |  2 ++
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 26 +++++++++++++++++-----
 10 files changed, 97 insertions(+), 12 deletions(-)

-- 
2.10.2
