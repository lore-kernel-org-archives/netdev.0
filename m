From: Helmut Grohne <h.grohne@cygnusnetworks.de>
Subject: Re: TUN/TAP: tap driver reports bogus interface speed in ethtool operations
Date: Tue, 23 Jul 2013 15:32:40 +0200
Message-ID: <E4A37B97-95FE-42C3-AD78-119BA406A44A@cygnusnetworks.de>
References: <2F174B03-5074-4BA0-B91A-8F2F62C2B082@cygnusnetworks.de> <5192BDD6.6060703@qti.qualcomm.com> <3E916AF0-C587-443D-B653-C968A96C8751@cygnusnetworks.de> <48A2F278-A32C-47C6-AD2D-1FC15EC73B88@cygnusnetworks.de> <51E5BE27.3060207@qti.qualcomm.com>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Content-Type: multipart/mixed; boundary="Apple-Mail=_64A2BE9F-0C56-4875-BD8C-4563DE14143F"
Cc: David Miller <davem@davemloft.net>,
	Max Krasnyansky <maxk@qti.qualcomm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.w359.de ([46.189.116.21]:33933 "EHLO mail2.w359.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756615Ab3GWNmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jul 2013 09:42:04 -0400
In-Reply-To: <51E5BE27.3060207@qti.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_64A2BE9F-0C56-4875-BD8C-4563DE14143F
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1


On 16.07.2013, at 23:41, Max Krasnyansky <maxk@qti.qualcomm.com> wrote:
> The patch looks fine to me (must admit that I only glanced at it). =
Please send it to the netdev
> mailing list netdev@vger.kernel.org, if you have't already done so.
> CC David Miller <davem@davemloft.net> and me.

Doing that. Now summarizing the issue for the new recipients:

Problem:

When querying a tap device for its speed using ethtool the tun driver =
reports a speed
of SPEED_10. This number is hard coded into the driver. Nowadays virtual =
network devices
can go way faster than that. When doing automatic bandwidth monitoring =
based on the
speed reported by ethtool, tap devices tend to come up as false =
positives. Arguably the
hard coded speed is wrong.

Proposed solution:

To that end I propose supporting the ETHTOOL_SSET command in addition to =
the already
supported ETHTOOL_GSET. It would deny setting any setting except for the =
bandwidth
where it would allow arbitrary values. You can find this patch attached.

With this patch an administrator can increase the reported speed for tap =
devices and
keep using automatic detection of interface speeds.

Workarounds:

Using ethtool a detection utility can determine the driver for an =
interface. If the
driver matches the string "tun", the reported speed should not be used.

Helmut


--Apple-Mail=_64A2BE9F-0C56-4875-BD8C-4563DE14143F
Content-Disposition: attachment;
	filename=0001-tuntap-allow-changing-ethtool-speed.patch
Content-Type: application/octet-stream;
	name="0001-tuntap-allow-changing-ethtool-speed.patch"
Content-Transfer-Encoding: quoted-printable

=46rom=209e0d2928ebed1d74ec92d131dcdc7511dde867ac=20Mon=20Sep=2017=20=
00:00:00=202001=0AFrom:=20Helmut=20Grohne=20<h.grohne@cygnusnetworks.de>=0A=
Date:=20Fri,=2017=20May=202013=2014:03:47=20+0200=0ASubject:=20[PATCH]=20=
tuntap:=20allow=20changing=20ethtool=20speed=0A=0AThe=20data=20reported=20=
by=20the=20ethtool=20interface=20for=20tun/tap=20devices=20is=0A=
artificial.=20The=20default=20speed=20is=2010Mbit.=20Virtual=20=
interfaces=20are=20often=0Afaster=20than=20this=20nowadays,=20so=20the=20=
observed=20bandwidth=20may=20exceed=20the=0Aavailable=20bandwidth.=20=
This=20patch=20allows=20an=20administrator=20to=20change=20the=0A=
available=20bandwidth=20as=20reported=20by=20ethtool.=0A=0A=
Signed-off-by:=20Helmut=20Grohne=20<h.grohne@cygnusnetworks.de>=0A---=0A=20=
drivers/net/tun.c=20|=20=20=2025=20++++++++++++++++++++++++-=0A=201=20=
file=20changed,=2024=20insertions(+),=201=20deletion(-)=0A=0Adiff=20=
--git=20a/drivers/net/tun.c=20b/drivers/net/tun.c=0Aindex=20=
f042b03..2555a11=20100644=0A---=20a/drivers/net/tun.c=0A+++=20=
b/drivers/net/tun.c=0A@@=20-187,6=20+187,7=20@@=20struct=20tun_struct=20=
{=0A=20=09struct=20list_head=20disabled;=0A=20=09void=20*security;=0A=20=09=
u32=20flow_count;=0A+=09u32=20advertised_speed;=0A=20};=0A=20=0A=20=
static=20inline=20u32=20tun_hashfn(u32=20rxhash)=0A@@=20-1404,6=20=
+1405,7=20@@=20static=20void=20tun_setup(struct=20net_device=20*dev)=0A=20=
=0A=20=09tun->owner=20=3D=20INVALID_UID;=0A=20=09tun->group=20=3D=20=
INVALID_GID;=0A+=09tun->advertised_speed=20=3D=20SPEED_10;=0A=20=0A=20=09=
dev->ethtool_ops=20=3D=20&tun_ethtool_ops;=0A=20=09dev->destructor=20=3D=20=
tun_free_netdev;=0A@@=20-2197,9=20+2199,11=20@@=20static=20struct=20=
miscdevice=20tun_miscdev=20=3D=20{=0A=20=0A=20static=20int=20=
tun_get_settings(struct=20net_device=20*dev,=20struct=20ethtool_cmd=20=
*cmd)=0A=20{=0A+=09struct=20tun_struct=20*tun=20=3D=20netdev_priv(dev);=0A=
+=0A=20=09cmd->supported=09=09=3D=200;=0A=20=09cmd->advertising=09=3D=20=
0;=0A-=09ethtool_cmd_speed_set(cmd,=20SPEED_10);=0A+=09=
ethtool_cmd_speed_set(cmd,=20tun->advertised_speed);=0A=20=09cmd->duplex=09=
=09=3D=20DUPLEX_FULL;=0A=20=09cmd->port=09=09=3D=20PORT_TP;=0A=20=09=
cmd->phy_address=09=3D=200;=0A@@=20-2210,6=20+2214,24=20@@=20static=20=
int=20tun_get_settings(struct=20net_device=20*dev,=20struct=20=
ethtool_cmd=20*cmd)=0A=20=09return=200;=0A=20}=0A=20=0A+static=20int=20=
tun_set_settings(struct=20net_device=20*dev,=20struct=20ethtool_cmd=20=
*cmd)=0A+{=0A+=09struct=20tun_struct=20*tun=20=3D=20netdev_priv(dev);=0A=
+=0A+=09if(cmd->supported=20!=3D=200=20||=0A+=09=09=09cmd->advertising=20=
!=3D=200=20||=0A+=09=09=09cmd->duplex=20!=3D=20DUPLEX_FULL=20||=0A+=09=09=
=09cmd->port=20!=3D=20PORT_TP=20||=0A+=09=09=09cmd->phy_address=20!=3D=20=
0=20||=0A+=09=09=09cmd->transceiver=20!=3D=20XCVR_INTERNAL=20||=0A+=09=09=
=09cmd->autoneg=20!=3D=20AUTONEG_DISABLE=20||=0A+=09=09=09cmd->maxtxpkt=20=
!=3D=200=20||=0A+=09=09=09cmd->maxrxpkt=20!=3D=200)=0A+=09=09return=20=
-EOPNOTSUPP;=0A+=09tun->advertised_speed=20=3D=20ethtool_cmd_speed(cmd);=0A=
+=09return=200;=0A+}=0A+=0A=20static=20void=20tun_get_drvinfo(struct=20=
net_device=20*dev,=20struct=20ethtool_drvinfo=20*info)=0A=20{=0A=20=09=
struct=20tun_struct=20*tun=20=3D=20netdev_priv(dev);=0A@@=20-2247,6=20=
+2269,7=20@@=20static=20void=20tun_set_msglevel(struct=20net_device=20=
*dev,=20u32=20value)=0A=20=0A=20static=20const=20struct=20ethtool_ops=20=
tun_ethtool_ops=20=3D=20{=0A=20=09.get_settings=09=3D=20=
tun_get_settings,=0A+=09.set_settings=09=3D=20tun_set_settings,=0A=20=09=
.get_drvinfo=09=3D=20tun_get_drvinfo,=0A=20=09.get_msglevel=09=3D=20=
tun_get_msglevel,=0A=20=09.set_msglevel=09=3D=20tun_set_msglevel,=0A--=20=
=0A1.7.10.4=0A=0A=

--Apple-Mail=_64A2BE9F-0C56-4875-BD8C-4563DE14143F--
