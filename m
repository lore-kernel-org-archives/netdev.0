From: crow <crow@linux.org.ba>
Subject: Re: ARM GLX Khadas VIM Pro - Ethernet detected as only 10Mbps and
 stalled after some traffic
Date: Sun, 11 Jun 2017 15:43:02 +0200
Message-ID: <CAG_g8w71SWc_X2U9pNWLVheO9Jf4ydPznAVp1x-Y9kwU3qhf1A@mail.gmail.com>
References: <CAG_g8w7PND+6r17cLoTG0rG0CqVDA-Z9kr8Zi+TOq5Qbpd9Gtw@mail.gmail.com>
 <CAG_g8w40V_u7JnX+EuNvCLmB2dAzuk_TgMkkKT9pn-SLBRi1pA@mail.gmail.com> <20170610152741.GB26740@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, linux-amlogic@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33761 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751886AbdFKNnE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 09:43:04 -0400
Received: by mail-io0-f172.google.com with SMTP id t87so26828998ioe.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 06:43:04 -0700 (PDT)
In-Reply-To: <20170610152741.GB26740@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew

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


Please ignore my previus email as I used wrong kernel (not the patched
one, see the modinfo).

Thank your for the suggestion, and thanks Martin to explaining me over
IRC what actually I should do.

I recompiled mainline kernel 4.12-rc4 with the Amlogic driver:
replaced drivers/net/phy/meson-gxl.c with
https://github.com/khadas/linux/blob/ubuntu-4.9/drivers/amlogic/ethernet/phy/amlogic.c

But this did not solve the issue. As soon as i start git clone i lose
network connection to device (no session timeout/disconnect this time,
but I am unable to reconnect over SSH or to get OK ping replay back).

Linux khadasvimpro 4.12.0-rc4-4-ARCH #1 SMP Sun Jun 11 14:33:40 CEST
2017 aarch64 GNU/Linux

# modinfo meson_gxl
filename:
/lib/modules/4.12.0-rc4-4-ARCH/kernel/drivers/net/phy/meson-gxl.ko.gz
license:        GPL
author:         Yizhou Jiang
description:    amlogic internal ethernet phy driver
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
    0040 0082 40e8 5400 0d80 1000 0000 a900
    fff0 ffff 0000 130a 1407 00ca 0000 105a
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


over SSH startet following but it stall already at 1%:

$ git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
Cloning into 'linux-stable'...
remote: Counting objects: 5948690, done.
remote: Compressing objects: 100% (124799/124799), done.
Receiving objects:   1% (110361/5948690), 48.02 MiB | 6.54 MiB/s


journalctl shows timeout while trying to sync with NTP server:
systemd-timesyncd[292]: Timed out waiting for reply from
91.206.8.36:123 (2.at.pool.ntp.org).
systemd-timesyncd[292]: Timed out waiting for reply from
131.130.251.107:123 (2.at.pool.ntp.org).

ping to this device from other client: 100% packet loss

dumping register after stall state
# mii-tool -vvv eth0
Using SIOCGMIIPHY=0x8947
eth0: negotiated 1000baseT-HD flow-control, link ok
  registers for MII PHY 8:
    1000 782d 0181 4400 01e1 c1e1 000d 2001
    ffff ffff ffff ffff ffff ffff ffff ffff
    0040 0082 40e8 5400 0d80 1000 0000 a900
    fff0 ffff 0000 130a 1407 0000 0000 105a
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

after taking eth0 down and up, I am able to login to device over SSH
again, and ping from other devices in network to this device are all
OK.

# ifconfig eth0 down && ifconfig eth0 up
# dmesg -T | tail -n 10
[Sun Jun 11 15:03:02 2017] internal phy init
[Sun Jun 11 15:03:02 2017] internal phy init
[Sun Jun 11 15:03:02 2017] amlogic internal phy 0.e40908ff:08:
attached PHY driver [amlogic internal phy]
(mii_bus:phy_addr=0.e40908ff:08, irq=-1)
[Sun Jun 11 15:03:02 2017] meson8b-dwmac c9410000.ethernet eth0: PTP
not supported by HW
[Sun Jun 11 15:03:03 2017] wol_reg12[12]==0, error
[Sun Jun 11 15:03:04 2017] meson8b-dwmac c9410000.ethernet eth0: Link
is Up - 100Mbps/Full - flow control off

[Sun Jun 11 15:10:38 2017] internal phy init
[Sun Jun 11 15:10:38 2017] internal phy init
[Sun Jun 11 15:10:38 2017] amlogic internal phy 0.e40908ff:08:
attached PHY driver [amlogic internal phy]
(mii_bus:phy_addr=0.e40908ff:08, irq=-1)
[Sun Jun 11 15:10:38 2017] meson8b-dwmac c9410000.ethernet eth0: PTP
not supported by HW
[Sun Jun 11 15:10:39 2017] wol_reg12[12]==0, error
[Sun Jun 11 15:10:40 2017] meson8b-dwmac c9410000.ethernet eth0: Link
is Up - 100Mbps/Full - flow control off

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
Receiving objects: 100% (5948690/5948690), 1.21 GiB | 2.85 MiB/s, done.
Resolving deltas: 100% (4961965/4961965), done.
Checking out files: 100% (59844/59844), done.
$

Regards,
