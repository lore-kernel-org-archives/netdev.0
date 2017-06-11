From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Sun, 11 Jun 2017 08:31:36 +0200
Message-ID: <CAG_g8w7aaryfdGgRtbazGMGm5svebgNPNcKyWBfxaObMHs3x-Q@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com> <20170610152741.GB26740@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f44.google.com ([209.85.214.44]:35493 "EHLO
        mail-it0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751683AbdFKGbi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 02:31:38 -0400
Received: by mail-it0-f44.google.com with SMTP id m62so13071668itc.0
        for <netdev@vger.kernel.org>; Sat, 10 Jun 2017 23:31:38 -0700 (PDT)
In-Reply-To: <20170610152741.GB26740@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Sat, Jun 10, 2017 at 5:27 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> Also what Martin Blumenstingl wrote is following which is also crucial
>> for fixing the issue:
>> Amlogic has given their ethernet PHY driver some updates [2], it now
>> includes wake-on-lan, and they now have an internal_phy_read_status
>> which uses reset_internal_phy if there's a link and some error counter
>> exceeds some magic value.
>
> Hi Crow
>
> You could probably just drop the Amlogic driver into mainline and see
> if it works better. If that solves your problem, we can look at
> merging the changes.
>
>         Andrew

Thank your for the suggestion, and thanks Martin to explaining me over
IRC what actually I should do.

I recompiled mainline kernel 4.12-rc4 with the Amlogic driver:
replaced drivers/net/phy/meson-gxl.c with
https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethernet/phy/amlogic.c

But this did not solve the issue. As soon as i start git clone i lose
network connection to device (no session timeout/disconnect this time,
but I am unable to reconnect over SSH or to get OK ping replay back).

Here are the tests:
Linux khadasvimpro 4.12.0-rc4-4-ARCH #1 SMP Sun Jun 11 03:39:21 CEST
2017 aarch64 GNU/Linux

# modinfo meson_gxl
filename:
/lib/modules/4.12.0-rc4-4-ARCH/kernel/drivers/net/phy/meson-gxl.ko.gz
license:        GPL
author:         Neil Armstrong <narmstrong@baylibre.com>
author:         Baoqi wang
description:    Amlogic Meson GXL Internal PHY driver
alias:          mdio:0000000110000001010001000000????
depends:
intree:         Y
vermagic:       4.12.0-rc4-4-ARCH SMP mod_unload aarch64
#
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000f 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 040a 1407 004a 0000 105a
  product info: vendor 00:60:51, model 0 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
$

over SSH startet following but it stall already at 0%:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
Cloning into 'linux-stable'...
remote: Counting objects: 5948690, done.
remote: Compressing objects: 100% (124799/124799), done.
Receiving objects:   0% (11668/5948690), 2.27 MiB | 4.52 MiB/s

shows timeout while trying to sync with NTP server:

# journalctl -f
systemd-timesyncd[299]: Timed out waiting for reply from
83.68.137.76:123 (2.at.pool.ntp.org).
systemd-timesyncd[299]: Timed out waiting for reply from
86.59.113.114:123 (2.at.pool.ntp.org).

while still not working dump the register:
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000d 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0002 40e8 5400 1c1c 0000 0000 aaaa
    fff0 ffff 0000 040a 1407 0000 0000 105a
  product info: vendor 00:60:51, model 0 rev 0
  basic mode:   autonegotiation enabled
  basic status: autonegotiation complete, link ok
  capabilities: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  advertising:  1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
  link partner: 1000baseT-HD 1000baseT-FD 100baseTx-FD 100baseTx-HD
10baseT-FD 10baseT-HD
#

# ifconfig eth0 down && ifconfig eth0 up
# dmesg -T | tail -n 10
[Sun Jun 11 07:40:34 2017] meson8b-dwmac c9410000.ethernet eth0:
device MAC address 00:15:18:01:81:31
[Sun Jun 11 07:40:34 2017] random: crng init done
[Sun Jun 11 07:40:34 2017] Meson GXL Internal PHY 0.e40908ff:08:
attached PHY driver [Meson GXL Internal PHY]
(mii_bus:phy_addr=0.e40908ff:08, irq=-1)
[Sun Jun 11 07:40:34 2017] meson8b-dwmac c9410000.ethernet eth0: PTP
not supported by HW
[Sun Jun 11 07:40:36 2017] brcmfmac: brcmf_c_preinit_dcmds: Firmware
version = wl0: Mar  1 2015 07:29:38 version 7.45.18 (r538002) FWID
01-6a2c8ad4
[Sun Jun 11 07:40:36 2017] meson8b-dwmac c9410000.ethernet eth0: Link
is Up - 100Mbps/Full - flow control off
[Sun Jun 11 07:41:23 2017] EXT4-fs (mmcblk1p1): mounted filesystem
with ordered data mode. Opts: (null)
[Sun Jun 11 07:54:28 2017] Meson GXL Internal PHY 0.e40908ff:08:
attached PHY driver [Meson GXL Internal PHY]
(mii_bus:phy_addr=0.e40908ff:08, irq=-1)
[Sun Jun 11 07:54:28 2017] meson8b-dwmac c9410000.ethernet eth0: PTP
not supported by HW
[Sun Jun 11 07:54:30 2017] meson8b-dwmac c9410000.ethernet eth0: Link
is Up - 100Mbps/Full - flow control off
#

then I took eth0 and wlan0 up (same ArchLinuxArm with same mainline
kernel same place where the files are stored eMMC) and this was
working so it should not be the ArchLinuxArm which makes problem, and
did same git clone as with custom Amlogic kernel (3.1.4 and 4.9.26
under Khadas Ubuntu image) and test was successfully:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
Cloning into 'linux-stable'...
remote: Counting objects: 5948690, done.
remote: Compressing objects: 100% (124799/124799), done.
remote: Total 5948690 (delta 427756), reused 549521 (delta 425675)
Receiving objects: 100% (5948690/5948690), 1.21 GiB | 4.94 MiB/s, done.
Resolving deltas: 100% (4961965/4961965), done.
Checking out files: 100% (59844/59844), done.
$

Regards,
