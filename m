From: Piotr Gabriel Kosinski <pg.kosinski@gmail.com>
Subject: Realtek RTL8101E PCI-E ethernet controller does not work with the
 r8169 driver
Date: Thu, 27 Apr 2017 17:31:56 +0200
Message-ID: <CAFMLSdOBwO4zWZo48EymSGw=4i5DSDfc4VjrxBjWaM5h5DBknw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35230 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938953AbdD0PcD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 11:32:03 -0400
Received: by mail-ua0-f171.google.com with SMTP id f10so21718519uaa.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 08:31:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Realtek RTL8101E PCI Express ethernet controller does not work
with the r8169 driver, on kernel 4.10 (it also did not work on earlier
kernels). These are the messages from the kernel log:

[   11.359593] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[   11.359611] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have
ASPM control
[   11.359803] r8169 0000:03:00.0 (unnamed net_device)
(uninitialized): unknown MAC, using family default
[   11.369802] r8169 0000:03:00.0 (unnamed net_device)
(uninitialized): rtl_chipcmd_cond == 1 (loop: 100, delay: 100).
[   11.406668] r8169 0000:03:00.0 eth0: rtl_counters_cond == 1 (loop:
1000, delay: 10).
[   11.406815] r8169 0000:03:00.0 eth0: RTL8101e at
0xffffb3140068d000, ff:ff:ff:ff:ff:ff, XID 9cf0f8ff IRQ 89
[   11.482740] r8169 0000:03:00.0 enp3s0: renamed from eth0
[   11.501187] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   33.348246] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   34.273602] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.195420] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   35.678908] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).
[   36.401291] IPv6: ADDRCONF(NETDEV_UP): enp3s0: link is not ready
[   36.411989] r8169 0000:03:00.0 enp3s0: rtl_counters_cond == 1
(loop: 1000, delay: 10).

the rtl_counters_cond message is then regularly repeated.

ifconfig's ether address shows ff:ff:ff:ff:ff:ff


If that is of any help - the controller works on FreeBSD's re driver,
but only when the following two loader options are set:
hw.re.msix_disable=1
hw.re.prefer_iomap=1

Both of these options must be set to 1. If prefer_iomap is not set,
there are messages like:
re0: reset never completed!
re0: PHY write failed
re0: attaching PHYs failed
device_attach: re0 attach returned 6

If msix_disable is not set (msix is enabled), there are no error
messages and mac address is read correctly, but the controller does
not work (no connection can be established, e.g. DHCP).

If both of the above options are set to 1, the controller works fine,
with the following messages:
re0: <RealTek 810xE PCIe 10/100baseTX> port 0xe000-0xe0ff mem
0xe0004000-0xe0004fff,0xe0000000-0xe0003fff at device 0.0 on pci2
re0: Using 1 MSI message
re0: Chip rev. 0x44800000
re0: MAC rev. 0x00100000
miibus0: <MII bus> on re0
rlphy0: <RTL8201E 10/100 media interface> PHY 1 on miibus0
rlphy0: 10baseT, 100baseT-FDX, 100baseTX, 100baseTX-FDX, auto, auto-flow
re0: Using defaults for TSO: 65518/35/2048
re0: netmap queues/slots: TX 1/256, RX 1/256
re0: link state changed to DOWN
re0: link state changed to UP

The problem occurs e.g. on Intel Atom-based Toshiba NB10-A-104 Netbook.
In the next mail I will attach lspci -vvv output.

Thank you,
Piotr.
