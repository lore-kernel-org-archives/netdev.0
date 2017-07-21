From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: Re: [PATCH v2 0/4] RGMII RX and TX clock delays using Atheros 8035
Date: Fri, 21 Jul 2017 14:47:53 +0200
Message-ID: <2711b987-a9db-e1d0-5346-a9d43309aaa2@sigmadesigns.com>
References: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>,
        Mason <slash.tmp@free.fr>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        "Zefir Kurtisi" <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:30734 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750762AbdGUMsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 08:48:01 -0400
In-Reply-To: <2617d673-ef81-5e7f-4730-ed3aa3f1c2c6@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/07/2017 13:22, Marc Gonzalez wrote:

> Changes from v1
> - Drop support for disabling RX and TX clock delays
> (it breaks some boards). Document the issues instead.
> - Split the MAC patch in two unrelated parts
> - Fix the vantage 1172 DTS
> 
> Marc Gonzalez (4):
>   net: phy: at803x: Document RGMII RX and TX clock delay issues
>   net: ethernet: nb8800: Set RGMII_MODE for all RGMII modes
>   net: ethernet: nb8800: Fix RGMII TX clock delay setup
>   ARM: dts: tango4: Add RGMII RX and TX clock delays
> 
>  arch/arm/boot/dts/tango4-vantage-1172.dts |  2 +-
>  drivers/net/ethernet/aurora/nb8800.c      |  8 +++++---
>  drivers/net/phy/at803x.c                  | 12 ++++++++++++
>  3 files changed, 18 insertions(+), 4 deletions(-)

Rudimentary test:

ip addr add 172.27.64.45/18 brd 172.27.127.255 dev eth0
ip link set eth0 up
sleep 10 ## autoneg should be complete
time fping -c 10000 -b 1450 -p 1 -i 1 -q 172.27.64.1
ethtool -S eth0
cat /proc/interrupts

# test_eth.sh 
[   13.276242] ENTER at803x_enable_rx_delay
[   13.280283] BEFORE=82ee
[   13.282735]  AFTER=82ee
[   13.285462] ENTER at803x_enable_tx_delay
[   13.289567] BEFORE=2d47
[   13.292018]  AFTER=2d47
[   16.663266] nb8800 26000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
172.27.64.1 : xmt/rcv/%loss = 10000/10000/0%, min/avg/max = 0.18/0.21/3.79

real    0m10.688s
user    0m0.106s
sys     0m0.472s

NIC statistics:
     rx_bytes_ok: 14960128
     rx_frames_ok: 10002
     rx_undersize_frames: 0
     rx_fragment_frames: 0
     rx_64_byte_frames: 2
     rx_127_byte_frames: 0
     rx_255_byte_frames: 0
     rx_511_byte_frames: 0
     rx_1023_byte_frames: 0
     rx_max_size_frames: 10000
     rx_oversize_frames: 0
     rx_bad_fcs_frames: 0
     rx_broadcast_frames: 0
     rx_multicast_frames: 0
     rx_control_frames: 0
     rx_pause_frames: 0
     rx_unsup_control_frames: 0
     rx_align_error_frames: 0
     rx_overrun_frames: 0
     rx_jabber_frames: 0
     rx_bytes: 14960128
     rx_frames: 10002
     tx_bytes_ok: 14960128
     tx_frames_ok: 10002
     tx_64_byte_frames: 2
     tx_127_byte_frames: 0
     tx_255_byte_frames: 0
     tx_511_byte_frames: 0
     tx_1023_byte_frames: 0
     tx_max_size_frames: 10000
     tx_oversize_frames: 0
     tx_broadcast_frames: 1
     tx_multicast_frames: 0
     tx_control_frames: 0
     tx_pause_frames: 0
     tx_underrun_frames: 0
     tx_single_collision_frames: 0
     tx_multi_collision_frames: 0
     tx_deferred_collision_frames: 0
     tx_late_collision_frames: 0
     tx_excessive_collision_frames: 0
     tx_bytes: 14960128
     tx_frames: 10002
     tx_collisions: 0

            CPU0       CPU1       
  19:      10825        983     GIC-0  29 Edge      twd
  20:         85          0      irq0   1 Level     ttyS0
  21:          0          0      irq0  60 Level     mmc0
  22:        228          0      irq0   8 Level     mmc1
  25:      20005          0      irq0  38 Level     eth0
  28:          1          0      irq0  37 Edge      26000.nb8800-mii:04
IPI0:          0          0  CPU wakeup interrupts
IPI1:          0          0  Timer broadcast interrupts
IPI2:       1183       1725  Rescheduling interrupts
IPI3:          0          1  Function call interrupts
IPI4:          0          0  CPU stop interrupts
IPI5:          1          0  IRQ work interrupts
IPI6:          0          0  completion interrupts
Err:           0


fping caps at 1000 packets per second, which limits
its usefulness as a benchmarking tool.

Regards.
