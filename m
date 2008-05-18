From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 18 May 2008 14:57:15 +0200
Message-ID: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:33226 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbYERM5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 08:57:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch series fixes hibernate/wake-on-lan for my
System (Asus M2N-SLI Deluxe, Dual MCP55 Gigabit Ethernet).

See also http://bugzilla.kernel.org/show_bug.cgi?id=3D8381
"(net forcedeth) doesn't wol on suspend".

Note that so far this is only tested on my system with hibernate
using the 'shutdown' method.

The local setup combines the two onboard nforce gigabit interfaces
eth0 and eth1 into a bridge br0, so it doesn't matter which port I
plug the cable into.  The bridging means eth0 and eth1 normally
operate in promiscous mode.

The initial situation (unpatched driver) was as follows:
After a normal boot, turning on wol and sending the system into
hibernate, waking it up with etherwake works as expected.
However, after waking up (be it via wol or via manual poweron)
from hibernate network connectivity is down.

This is because 1) the mac address is now swapped and 2) promiscous
mode is not restored.

The first patch addresses 2)

After this patch wake-on-lan stops working, since in 'shutdown' mode
the suspend callback of the device does not get called again before
poweroff and promiscous mode is apparently incompatible with wol.

So the second patch introduces a shutdown handler, which prepares
the device for wake-on-lan before the system is powered off.

Now waking the system up works again, but the 'swapped mac' problem
is still there.

The reason for this is that in my case the MCP55 is not flagged as
'DEV_HAS_CORRECT_MACADDR' and 'NVREG_TRANSMITPOLL_MAC_ADDR_REV' is
not set by the bios, so in nv_probe during the initial loading of
the driver the MAC address is read in reversed order and
NVREG_TRANSMITPOLL_MAC_ADDR_REV is set.
However during hibernate the device configuration space is lost
(reset do BIOS defaults) and so we get the reversed MAC again, but
resume unconditionally sets NVREG_TRANSMITPOLL_MAC_ADDR_REV, which
means we now have effectively swapped the MAC.

The third patch fixes this by saving and restoring the
configuration space between suspend and resume.

The fourth (optional) patch reorders the code in suspend/resume to
match the order in e100/e1000e more closely, since I think the
latter order is more correct.
=46or example the configuration space should be saved on suspend even
for devices that are not up.

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
