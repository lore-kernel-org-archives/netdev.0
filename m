From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Fri, 29 Jan 2016 22:31:41 +0100
Message-ID: <56ABDA3D.8040100@cumulusnetworks.com>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Bj=c3=b8rnar_Ness?= <bjornar.ness@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35286 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcA2Vbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 16:31:43 -0500
Received: by mail-wm0-f54.google.com with SMTP id r129so85634107wmr.0
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 13:31:43 -0800 (PST)
In-Reply-To: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2016 05:24 PM, Bj=C3=B8rnar Ness wrote:
> As subject says, 802.3ad bonding is not working with virtio network m=
odel.
>=20
> The only errors I see is:
>=20
> No 802.3ad response from the link partner for any adapters in the bon=
d.
>=20
> Dumping the network traffic shows that no LACP packets are sent from =
the
> host running with virtio driver, changing to for example e1000 solves
> this problem
> with no configuration changes.
>=20
> Is this a known problem?
>=20
[Including bonding maintainers for comments]

Hi,
Here's a workaround patch for virtio_net devices that "cheats" the
duplex test (which is the actual problem). I've tested this locally
and it works for me.
I'd let the others comment on the implementation, there're other signs
that can be used to distinguish a virtio_net device so I'm open to sugg=
estions.
Also feedback if this is at all acceptable would be appreciated.

Could you give it a try ?

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_=
3ad.c
index 4cbb8b27a891..0578a95e3ade 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -334,6 +334,7 @@ static u16 __get_link_speed(struct port *port)
 static u8 __get_duplex(struct port *port)
 {
 	struct slave *slave =3D port->slave;
+	const struct net_device *slave_dev =3D slave->dev;
 	u8 retval =3D 0x0;
=20
 	/* handling a special case: when the configuration starts with
@@ -354,6 +355,15 @@ static u8 __get_duplex(struct port *port)
 			break;
 		}
 	}
+	if (!retval && slave_dev->dev.parent &&
+	    !strcmp(dev_driver_string(slave_dev->dev.parent),
+		    "virtio_net") &&
+	    netif_carrier_ok(slave_dev)) {
+		netdev_dbg(slave->bond->dev, "port %d: activating virtio_net workaro=
und\n",
+			   port->actor_port_number);
+		retval =3D 1;
+	}
+
 	return retval;
 }
=20
