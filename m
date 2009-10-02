From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH v2] net: export device speed and duplex via sysfs
Date: Fri, 2 Oct 2009 15:26:12 -0400
Message-ID: <20091002192612.GA1639@gospo.rdu.redhat.com>
References: <20091002180742.GH4436@gospo.rdu.redhat.com> <4AC6432C.1020202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728AbZJBT0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 15:26:10 -0400
Content-Disposition: inline
In-Reply-To: <4AC6432C.1020202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 02, 2009 at 08:15:08PM +0200, Eric Dumazet wrote:
> Andy Gospodarek a =E9crit :
> > +static ssize_t show_speed(struct device *dev,
> > +			  struct device_attribute *attr, char *buf)
> > +{
> > +	struct net_device *netdev =3D to_net_dev(dev);
> > +	int ret =3D -EINVAL;
> > +
> > +	if (!rtnl_trylock())
> > +		return restart_syscall();
> > +
> > +	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> > +		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
> > +
> > +		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)
>=20
> 		rtnl lock leak ?
>=20
>=20
> > +			return -EINVAL;
> > +		ret =3D sprintf(buf, fmt_dec, cmd.speed);
> > +	}
> > +	rtnl_unlock();
> > +	return ret;
> > +}
> > +
> > +static ssize_t show_duplex(struct device *dev,
> > +			   struct device_attribute *attr, char *buf)
> > +{
> > +	struct net_device *netdev =3D to_net_dev(dev);
> > +	int ret =3D -EINVAL;
> > +
> > +	if (!rtnl_trylock())
> > +		return restart_syscall();
> > +
> > +	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
> > +		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
> > +
> > +		if (netdev->ethtool_ops->get_settings(netdev, &cmd) < 0)
>=20
> 		rtnl lock leak ?
>=20
> > +			return -EINVAL;
> > +		ret =3D sprintf(buf, "%s\n", cmd.duplex ? "full" : "half");
> > +	}
> > +	rtnl_unlock();
> > +	return ret;
> > +}
> > +
>=20

Thanks for spotting that, Eric.  Here's an updated (and tested patch).
I also switched to using ethtool_cmd_speed to get link speed to get the
'entire' speed.

[PATCH] net: export device speed and duplex via sysfs

This patch exports the link-speed (in Mbps) and duplex of an interface
via sysfs.  This eliminates the need to use ethtool just to check the
link-speed.  Not requiring 'ethtool' and not relying on the SIOCETHTOOL
ioctl should be helpful in an embedded environment where space is at a
premium as well.

NOTE: This patch also intentionally allows non-root users to check the =
link
speed and duplex -- something not possible with ethtool.

Here's some sample output:

# cat /sys/class/net/eth0/speed=20
100
# cat /sys/class/net/eth0/duplex
half
# ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full=20
                                100baseT/Half 100baseT/Full=20
                                1000baseT/Half 1000baseT/Full=20
        Supports auto-negotiation: Yes
        Advertised link modes:  Not reported
        Advertised auto-negotiation: No
        Speed: 100Mb/s
        Duplex: Half
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: off
        Supports Wake-on: g
        Wake-on: g
        Current message level: 0x000000ff (255)
        Link detected: yes


---
 net/core/net-sysfs.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 3994680..133dbc4 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -130,6 +130,44 @@ static ssize_t show_carrier(struct device *dev,
 	return -EINVAL;
 }
=20
+static ssize_t show_speed(struct device *dev,
+			  struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	int ret =3D -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
+		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
+
+		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))
+			ret =3D sprintf(buf, fmt_dec, ethtool_cmd_speed(&cmd));
+	}
+	rtnl_unlock();
+	return ret;
+}
+
+static ssize_t show_duplex(struct device *dev,
+			   struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	int ret =3D -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (netif_running(netdev) && netdev->ethtool_ops->get_settings) {
+		struct ethtool_cmd cmd =3D { ETHTOOL_GSET };
+
+		if (!netdev->ethtool_ops->get_settings(netdev, &cmd))
+			ret =3D sprintf(buf, "%s\n", cmd.duplex ? "full" : "half");
+	}
+	rtnl_unlock();
+	return ret;
+}
+
 static ssize_t show_dormant(struct device *dev,
 			    struct device_attribute *attr, char *buf)
 {
@@ -259,6 +297,8 @@ static struct device_attribute net_class_attributes=
[] =3D {
 	__ATTR(address, S_IRUGO, show_address, NULL),
 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
 	__ATTR(carrier, S_IRUGO, show_carrier, NULL),
+	__ATTR(speed, S_IRUGO, show_speed, NULL),
+	__ATTR(duplex, S_IRUGO, show_duplex, NULL),
 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
 	__ATTR(operstate, S_IRUGO, show_operstate, NULL),
 	__ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu),
