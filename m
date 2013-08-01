From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the driver-core tree with the net-next
 tree
Date: Thu, 1 Aug 2013 15:21:48 +1000
Message-ID: <20130801152148.c98a281ec6e076646edeb7cb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__1_Aug_2013_15_21_48_+1000_K1aA6E80bP5x_tIB"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__1_Aug_2013_15_21_48_+1000_K1aA6E80bP5x_tIB
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the driver-core tree got a conflict in
net/core/net-sysfs.c between commit ff80e519ab1b ("net: export physical
port id via sysfs") from the net-next tree and commit 6be8aeef348a ("net:
core: convert class code to use dev_groups") from the driver-core tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/core/net-sysfs.c
index 8826b0d,707c313..0000000
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@@ -237,9 -250,9 +250,31 @@@ static ssize_t operstate_show(struct de
 =20
  	return sprintf(buf, "%s\n", operstates[operstate]);
  }
+ static DEVICE_ATTR_RO(operstate);
+=20
++static ssize_t phys_port_id_show(struct device *dev,
++				 struct device_attribute *attr, char *buf)
++{
++	struct net_device *netdev =3D to_net_dev(dev);
++	ssize_t ret =3D -EINVAL;
++
++	if (!rtnl_trylock())
++		return restart_syscall();
++
++	if (dev_isalive(netdev)) {
++		struct netdev_phys_port_id ppid;
++
++		ret =3D dev_get_phys_port_id(netdev, &ppid);
++		if (!ret)
++			ret =3D sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
++	}
++	rtnl_unlock();
++
++	return ret;
++}
++static DEVICE_ATTR_RO(phys_port_id);
 +
  /* read-write attributes */
- NETDEVICE_SHOW(mtu, fmt_dec);
 =20
  static int change_mtu(struct net_device *net, unsigned long new_mtu)
  {
@@@ -333,52 -344,32 +366,33 @@@ static ssize_t group_store(struct devic
  {
  	return netdev_store(dev, attr, buf, len, change_group);
  }
-=20
- static ssize_t show_phys_port_id(struct device *dev,
- 				 struct device_attribute *attr, char *buf)
- {
- 	struct net_device *netdev =3D to_net_dev(dev);
- 	ssize_t ret =3D -EINVAL;
-=20
- 	if (!rtnl_trylock())
- 		return restart_syscall();
-=20
- 	if (dev_isalive(netdev)) {
- 		struct netdev_phys_port_id ppid;
-=20
- 		ret =3D dev_get_phys_port_id(netdev, &ppid);
- 		if (!ret)
- 			ret =3D sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
- 	}
- 	rtnl_unlock();
-=20
- 	return ret;
- }
-=20
- static struct device_attribute net_class_attributes[] =3D {
- 	__ATTR(addr_assign_type, S_IRUGO, show_addr_assign_type, NULL),
- 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
- 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
- 	__ATTR(ifalias, S_IRUGO | S_IWUSR, show_ifalias, store_ifalias),
- 	__ATTR(iflink, S_IRUGO, show_iflink, NULL),
- 	__ATTR(ifindex, S_IRUGO, show_ifindex, NULL),
- 	__ATTR(type, S_IRUGO, show_type, NULL),
- 	__ATTR(link_mode, S_IRUGO, show_link_mode, NULL),
- 	__ATTR(address, S_IRUGO, show_address, NULL),
- 	__ATTR(broadcast, S_IRUGO, show_broadcast, NULL),
- 	__ATTR(carrier, S_IRUGO | S_IWUSR, show_carrier, store_carrier),
- 	__ATTR(speed, S_IRUGO, show_speed, NULL),
- 	__ATTR(duplex, S_IRUGO, show_duplex, NULL),
- 	__ATTR(dormant, S_IRUGO, show_dormant, NULL),
- 	__ATTR(operstate, S_IRUGO, show_operstate, NULL),
- 	__ATTR(mtu, S_IRUGO | S_IWUSR, show_mtu, store_mtu),
- 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
- 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
- 	       store_tx_queue_len),
- 	__ATTR(netdev_group, S_IRUGO | S_IWUSR, show_group, store_group),
- 	__ATTR(phys_port_id, S_IRUGO, show_phys_port_id, NULL),
- 	{}
+ NETDEVICE_SHOW(group, fmt_dec);
+ static DEVICE_ATTR(netdev_group, S_IRUGO | S_IWUSR, group_show, group_sto=
re);
+=20
+ static struct attribute *net_class_attrs[] =3D {
+ 	&dev_attr_netdev_group.attr,
+ 	&dev_attr_type.attr,
+ 	&dev_attr_dev_id.attr,
+ 	&dev_attr_iflink.attr,
+ 	&dev_attr_ifindex.attr,
+ 	&dev_attr_addr_assign_type.attr,
+ 	&dev_attr_addr_len.attr,
+ 	&dev_attr_link_mode.attr,
+ 	&dev_attr_address.attr,
+ 	&dev_attr_broadcast.attr,
+ 	&dev_attr_speed.attr,
+ 	&dev_attr_duplex.attr,
+ 	&dev_attr_dormant.attr,
+ 	&dev_attr_operstate.attr,
++	&dev_attr_phys_port_id.attr,
+ 	&dev_attr_ifalias.attr,
+ 	&dev_attr_carrier.attr,
+ 	&dev_attr_mtu.attr,
+ 	&dev_attr_flags.attr,
+ 	&dev_attr_tx_queue_len.attr,
+ 	NULL,
  };
+ ATTRIBUTE_GROUPS(net_class);
 =20
  /* Show a given an attribute in the statistics group */
  static ssize_t netstat_show(const struct device *d,

--Signature=_Thu__1_Aug_2013_15_21_48_+1000_K1aA6E80bP5x_tIB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR+fB0AAoJEECxmPOUX5FEX6AP+QEfxyxtAlYZTL2HmtaidYZx
UsuBLK8huEZ3tEjJix9MAIsTZWNWO40gYfhrDeVI3B3iK5+I407NH8Xw7bxh6FVv
s8EuDvdv3hbR5gTTUk4/ytNDHhUVvg0KeFa3FxZGfEmHrsr570UjXD1YqtNinsEJ
NHtuTGLO5q0oRpV95uNydeJ7M6//KzZRaPKAZKWxNkHqwFMDe+Cp5O1CG8mtmkEd
JZMGDiDCspXi+Q+dHUa1hFD2w22oNXEpH0O8p2XmVZOcocRHCj/jr9yNMrCIMSQR
3dgZhVeLbBCQKv83GeTkfpcxWAqxqEKidZNUxU4gOlj9mOfHCdT/SLU1mD3GA6ar
PFPk1ZcAN2kSFXPnMShEQphcNt5VCLGT9q6hZE0Qk1V7q22PgcDpcXHylVPpvM4f
m3nwGbBNlgHXa0jqrSBZUtJIqkuDLR081kWfo/kFfPfhbZMW9f9QMTK1Y7Ac6jna
j7iKhKoWU42Lp1drbwcHK28h+lykEDYwa1tPoKUq3Qp9lcsgQEAp89k2gM3G5n6h
qbueOXC1eWmZYvLSR74LiR5CFRoJbeyZ3n6Ukislt3AlchLb8DxC7PlJe+b9v7H9
5xxLXVJeEaILxN0zLDclQXJiwR9xCgrI5j8YrzY+sYBjYlKOotO8e5pvpPpls57p
ZCGtYhVnAEJf727vVPmi
=3PaK
-----END PGP SIGNATURE-----

--Signature=_Thu__1_Aug_2013_15_21_48_+1000_K1aA6E80bP5x_tIB--
