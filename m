From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Wed, 14 Sep 2016 17:30:29 +0200
Message-ID: <ce15ad26-2d07-655d-b813-947ad86696ac@st.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexandre Torgue <alexandre.torgue@st.com>,
        Johnson Leung <r58129@freescale.com>
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        <netdev@vger.kernel.org>, <linux-amlogic@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:10571 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1759988AbcINPbC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:31:02 -0400
In-Reply-To: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Martin

On 9/11/2016 10:39 PM, Martin Blumenstingl wrote:
> Hello,
>
> I have a device with a Meson GXBB SoC with an stmmac IP block.
> Gbit ethernet on my device is provided by a Realtek RTL8211F RGMII PHY.
> Similar issues were reported in #linux-amlogic by a user with an
> Odroid C2 board (= similar hardware).
>
> The symptoms are:
> Receiving data is plenty fast (I can max out my internet connection
> easily, and with iperf3 I get ~900Mbit/s).
> Transmitting data from the device is unfortunately very slow, traffic
> sometimes even stalls completely.
>
> I have attached the iperf results and the output of
> /sys/kernel/debug/stmmaceth/eth0/descriptors_status.
> Below you can find the ifconfig, netstat and stmmac dma_cap info
> (*after* I ran all tests).
>
> The "involved parties" are:
> - Meson GXBB specific network configuration registers (I have have
> double-checked them with the reference drivers: everything seems fine
> here)
> - stmmac: it seems that nobody else has reported these kind of issues
> so far, however I'd still like to hear where I should enable some
> debugging bits to rule out any stmmac bug

hmm I can also think that some configuration could impact!

For example, you could try disabling the scatter-gather or tx-cum
via ethtool and seeing if there is some benefit; so we could image
some problem on your HW or SYNP MAC integration for checksumming
on tx side.

Also you could check the AXI tuning and PBL value. To be honest
(thinking about your problem) I can actually suspect some related
problem on bus setup. So I suggest you to play with these value
(better if you ask for having values from HW validation on your side).
Otherwise the stmmac uses a default that cannot be good for your
platform. For example, sometime I have seen that PBL is better if
reduced to 8 instead of 32 and w/o 4xPBL...

> - RTL8211F PHY driver: unfortunately there are no public datasheets
> available so this is hard to debug. but I'm guessing that TX delay
> could cause similar issues, so this may be the cause as well.

as rule of thumb, I can only suggest you to see the RXDLY and TXDLY
and if you have (or need!) the resistor on PCB to have the 2ns of
extra delay. This can impact on RGMII case (1G).
Indeed, if this is true, I should expect some problem also when ping.

> Thanks for any input in advance!

welcome,

as Alex asked, pls provide us the output from ethtool -S eth0

Regards
Peppe

> Regards,
> Martin
>
>
> [root@alarm ~]# ifconfig eth0
> eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>         inet 192.168.1.235  netmask 255.255.255.0  broadcast 192.168.1.255
>         ether e2:aa:53:fc:f5:c5  txqueuelen 1000  (Ethernet)
>         RX packets 1967602  bytes 2968750265 (2.7 GiB)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 101875  bytes 8548285 (8.1 MiB)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
>         device interrupt 18
>
> [root@alarm ~]# netstat -i
> Kernel Interface table
> Iface      MTU    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
> eth0      1500  1967801      0      0 0        101934      0      0      0 BMRU
>
> [root@alarm ~]# cat /sys/kernel/debug/stmmaceth/eth0/dma_cap
> ==============================
>         DMA HW features
> ==============================
>         10/100 Mbps Y
>         1000 Mbps Y
>         Half duple Y
>         Hash Filter: Y
>         Multiple MAC address registers: Y
>         PCS (TBI/SGMII/RTBI PHY interfatces): N
>         SMA (MDIO) Interface: Y
>         PMT Remote wake up: Y
>         PMT Magic Frame: Y
>         RMON module: Y
>         IEEE 1588-2002 Time Stamp: N
>         IEEE 1588-2008 Advanced Time Stamp:N
>         802.3az - Energy-Efficient Ethernet (EEE) Y
>         AV features: N
>         Checksum Offload in TX: Y
>         IP Checksum Offload (type1) in RX: N
>         IP Checksum Offload (type2) in RX: Y
>         RXFIFO > 2048bytes: Y
>         Number of Additional RX channel: 0
>         Number of Additional TX channel: 0
>         Enhanced descriptors: N
>
