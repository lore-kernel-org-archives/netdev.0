From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 7 Jan 2011 10:46:48 -0800
Message-ID: <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com>
References: <20110106.122003.233698077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <benh@debian.org>,
	David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110106.122003.233698077.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 6, 2011 at 12:20 PM, David Miller <davem@davemloft.net> wro=
te:
>
> Plus the usual spattering of wireless, bluetooth, and wired driver
> updates.

Grr.

This breaks booting for me.

[torvalds@i5 linux]$ git bisect good
bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0 is the first bad commit
commit bca03d5f32c8ee9b5cfa1d32640a63fded6cb3c0
Author: fran=E7ois romieu <romieu@fr.zoreil.com>
Date:   Mon Jan 3 15:07:31 2011 +0000

    r8169: remove the firmware of RTL8111D.

    The binary file of the firmware is moved to linux-firmware reposito=
ry.
    The firmwares are rtl_nic/rtl8168d-1.fw and rtl_nic/rtl8168d-2.fw.
    The driver goes along if the firmware couldn't be found. However, i=
t
    is suggested to be done with the suitable firmware.

    Some wrong PHY parameters are directly corrected in the driver.

    Simple firmware checking added per Ben Hutchings suggestion.

    Signed-off-by: Hayes Wang <hayeswang@realtek.com>
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Ben Hutchings <benh@debian.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

and the behavior is very broken: it just hangs at boot-time. No
messages from the driver (certainly not any messages about missing
firmware), no nothing. The thing is just hung.

On a working setup, I have


  [    1.595071] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
  [    1.595114] r8169 0000:01:00.0: PCI INT A -> GSI 19 (level, low) -=
> IRQ 19
  [    1.595174] r8169 0000:01:00.0: setting latency timer to 64
  [    1.595227] r8169 0000:01:00.0: irq 42 for MSI/MSI-X
  [    1.595770] r8169 0000:01:00.0: eth0: RTL8168d/8111d at
0xffffc90000068000, e0:cb:4e:95:1a:d7, XID 083000c0 IRQ 42
  ...
  [    7.985917] r8169 0000:01:00.0: eth0: link up
  [    7.987525] r8169 0000:01:00.0: eth0: link up

while on a non-working setup, I get that XID line, and after that a
few other init routines continue to show up (probably just
multi-threaded initcalls), but the box is dead.

Quite frankly, that commit looks broken anyway. It doesn't just switch
to the firmware loader, it also seems to change other things (ie
removed some mdio writes, added others).

What's going on? This is NOT how things are supposed to happen. Yes,
the firmware file is in the external linux-firmware repo, but that
doesn't help if the kernel build won't even notice and pick it up (or
warn about it not being found). Also, the external linux-firmware repo
isn't even support any sane installation scripts, nor does it work
with the "build automatically into the kernel" mode.

We also have those CONFIG_FIRMWARE_IN_KERNEL and CONFIG_STANDALONE
flags, and the build apparently failed both of those.

Not acceptable. I'm ok with an external firmware repository, but only
if it _works_. Right now it doesn't. It just seems to cause silent
failures: there were no warnings about missing firmware at ANY time.
Not build-time, not run-time.

I bet I can make it work by making it a module, and installing the
firmware manually. But it's supposed to work even without that.

                             Linus
