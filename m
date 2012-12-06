From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: Random MAC address from smsc75xx: How to permanently set?
Date: Thu, 06 Dec 2012 20:44:16 +0100
Message-ID: <87ip8f9d9r.fsf@nemi.mork.no>
References: <8D5812289502B448AD36E6780A069B8D436C23@ashexcmb01.corp.solutionpoint-intl.com>
	<1354819495.8021.32.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Cunningham\, Robert" <RCunningham-Vgq8tmJ6w6ci4B+fuzNac0EOCMrvLtNR@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1354819495.8021.32.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org> (Dan Williams's
	message of "Thu, 06 Dec 2012 12:44:55 -0600")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> On Thu, 2012-12-06 at 18:35 +0000, Cunningham, Robert wrote:
>
>> I'm trying to bring up an OMAP4 system based on Variscite's OM44
>> module running Linaro's Ubuntu Precise in a headless configuration.
>> The system contains two SMSC LAN7500 USB-GigE chips (not dongles),
>> both of which are fully functional.
>>=20
>> The GigE chips don't have EEPROMS, so no permanent MAC addresses can
>> be assigned in hardware.  As expected, the smsc75xx driver assigns a
>> random MAC address when the interface is discovered and initialized.
>> However, we need to provide consistent MAC addresses on these
>> interfaces.  (Yes, we could respin the board to add EEPROMS, but
>> that's a last, and expensive, resort.)
>>=20
>> After the system boots, I'd like to change the MAC addresses to
>> specific values.  While there are multiple ways to do this (using
>> commands such as ifconfig, ip, macchanger, and others), it seems the
>> updated MAC address is always overridden when I do "ifconfig ethX
>> up", which causes yet another different random MAC address to be
>> created and assigned.  Simply repeating ifconfig up/down causes an
>> endless list of random MAC addresses to be generated.
>>=20
>> I created a udev rule that I hoped would handle the situation, but it is=
 also overridden:
>> /etc/udev/rules.d/99-mac-address.rules:
>>     SUBSYSTEM=3D=3D"net", KERNEL=3D=3D"eth0", RUN+=3D"/sbin/ip link set =
dev %k address XX:XX:XX:XX:XX:00"
>>     SUBSYSTEM=3D=3D"net", KERNEL=3D=3D"eth1", RUN+=3D"/sbin/ip link set =
dev %k address XX:XX:XX:XX:XX:01"
>>=20
>> For a single interface, I can use u-boot variables or kernel boot
>> arguments, but they seem to work only for the first interface, and I
>> have two.
>
> Just matching on interface name won't guarantee that you get the same
> MAC assigned to the same physical interface each time you boot.  You
> can't rely on bus probing order.  What you really want to do is enhance
> the udev rule to match the network interfaces based on stuff like PCI
> bus address, SDIO details, or whatever bus type the interfaces are
> hanging off.

Creating a rule matching on the USB device should do, provided the
driver is fixed to prevent changing the address on every open.


>> I've searched extensively for other solutions, but have found none that =
will survive "ifconfig ethX up".
>>=20
>> Is there a way to "permanently" tell the smsc75xx device driver to
>> use my desired MAC addresses instead of generating random ones every
>> time?  And to have the MAC addresses remain unchanged when I bring
>> the interfaces up and down?

Well, that is clearly a driver bug.  It should reuse the same address.
What do you think about something like the completely untested attached
patch, Steve?

You may want to go over the other parts of .reset as well.  It does a
lot, and I suspect most of it should be a onetime initialization thing
and not done on every device open.


Bj=C3=B8rn


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: inline;
 filename=0001-smsc75xx-dont-reset-macaddress-in-open.patch
Content-Transfer-Encoding: quoted-printable

>From a51089b8ad13957ba72be2f411c06684225ab3e5 Mon Sep 17 00:00:00 2001
From: =3D?UTF-8?q?Bj=3DC3=3DB8rn=3D20Mork?=3D <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Thu, 6 Dec 2012 20:33:25 +0100
Subject: [PATCH] smsc75xx: dont reset macaddress in open
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

usbnet_open calls the minidriver .reset function. Moving the
macadress initialization to .bind to prevent the macaddress
from changing every time the device is brought up in case a
persistent macaddress is missing.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/smsc75xx.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 1cbd936..971c679 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -1054,17 +1054,6 @@ static int smsc75xx_reset(struct usbnet *dev)
=20
 	netif_dbg(dev, ifup, dev->net, "PHY reset complete\n");
=20
-	smsc75xx_init_mac_address(dev);
-
-	ret =3D smsc75xx_set_mac_address(dev);
-	if (ret < 0) {
-		netdev_warn(dev->net, "Failed to set mac address\n");
-		return ret;
-	}
-
-	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM\n",
-		  dev->net->dev_addr);
--=-=-=--
