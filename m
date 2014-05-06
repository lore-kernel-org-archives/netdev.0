From: Brian Lilly <brian@crystalfontz.com>
Subject: Re: i.MX28 based system losing eth0 on boot
Date: Tue, 6 May 2014 12:12:22 -0700
Message-ID: <CAOk88BJ+sCtM_cRLuBktUKWYHcPo6KtQ+GAgTJL0zBgQqcQYog@mail.gmail.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <20140506181151.GU28564@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506181151.GU28564@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is happening during boot up:

<snip, kernel 3.12 >

Configuring network interfaces... [   35.117114] fec 800f0000.ethernet
eth0: Freescale FEC PHY driver [SMSC LAN8710/LAN8720]
(mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
[   35.129967] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
udhcpc (v1.21.1) started

Sending discover...

[   37.113901] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   37.120134] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
Sending discover...

Sending select for 10.10.10.217...
Lease of 10.10.10.217 obtained, lease time 86400
/etc/udhcpc.d/50default: Adding DNS 10.10.10.13
[   39.319957] IPv6: ADDRCONF(NETDEV_UP): usb0: link is not ready
done.
Starting rpcbind daemon...done.
net.ipv4.conf.default.rp_filter =3D 1
net.ipv4.conf.all.rp_filter =3D 1
Mon Apr 14 22:40:00 UTC 2014
INIT: Entering runlevel: 5
Starting Xserver
Starting system message bus: dbus.
Starting Connection Manager
Starting wpa_supplicant
Successfully initialized wpa_supplicant
Starting Dropbear SSH server
[   44.754915] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-=
1)
[   45.781364] fec 800f0000.ethernet eth0: MDIO read timeout
[   46.826170] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   47.811385] fec 800f0000.ethernet eth0: MDIO read timeout

With a different kernel (3.14):

[   28.989897] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
[   30.991210] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   37.369372] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
[   38.398346] fec 800f0000.ethernet eth0: MDIO read timeout
[   39.438412] fec 800f0000.ethernet eth0: MDIO read timeout
[   39.468419] fec 800f0000.ethernet eth0: MDIO write timeout
[   40.498848] fec 800f0000.ethernet eth0: MDIO read timeout

Afterward I have to ifdown eth0, ifup eth0 and then it functions
normally, without reverting the commit.

root@cfa100xx:~# ifdown eth0
[ 1154.679658] fec 800f0000.ethernet eth0: Freescale FEC PHY driver
[Generic PHY] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D-1)
root@cfa100xx:~# ifup eth0
udhcpc (v1.21.1) started
Sending discover...
[ 1156.679547] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
Sending discover...
Sending select for 10.10.10.217...
Lease of 10.10.10.217 obtained, lease time 86400
ip: RTNETLINK answers: File exists

--
Brian


On Tue, May 6, 2014 at 11:11 AM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
> Hello Brian,
>
> On Tue, May 06, 2014 at 09:44:34AM -0700, Brian Lilly wrote:
>> With commit a264b981f2c76e281ef27e7232774bf6c54ec865 we're having et=
h0
>> come up, then brought right back down with an MDIO rx timeout moment=
s
>> after.  Adding back in the removed code keeps the interface alive an=
d
>> it's working afterward without trouble.  I've tested the re-inserted
>> code in 3.12, 3.14 without issue on our boards.
> So you can reliably trigger that problem? You're just doing
>
>         ifconfig eth0 1.2.3.4 up
>
> (or equivalent) and the interface goes down without further
> interference with the above mentioned commit? The exact error you're
> seeing is
>
>         MDIO read timeout
>
> (with some prefix saying something about fec and eth0 I think)?
>
> This error is also present with a264b981f2 reverted, just doesn't aff=
ect
> eth0 being functional? Does the timeout always happen, or only on
> specific addresses?
>
> This is not a proper fix, but does it help to increment FEC_MII_TIMEO=
UT?
>
>> Is there something else that can be done to prevent the MDIO timeout=
s?
>> We are using basically the same schematic for networking as the
>> imx28evk.
> Hard to say, but assuming it works just fine on the imx28evk for you,
> too, there seems to be some hardware difference that makes your machi=
ne
> fail. (That doesn't mean it's not fixable in software.)
>
> I don't know if a mdio read error is intended to make the device go
> down, maybe one the the netdev guys can answer that.
> Assuming that it's not intended, instrument the code, find out how th=
at
> timeout makes your device go down and find the wrong branch. I'd star=
t
> with adding stackdumps when the mdio timeout happens and when
> fec_enet_start_xmit is called with fep->link =3D=3D 0.
>
> Best regards
> Uwe
>
> --
> Pengutronix e.K.                           | Uwe Kleine-K=C3=B6nig   =
         |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
