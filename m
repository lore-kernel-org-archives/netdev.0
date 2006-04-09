From: Sergey Vlasov <vsu@altlinux.ru>
Subject: Re: net interface renaming issue (+fix?)
Date: Sun, 9 Apr 2006 21:56:59 +0400
Message-ID: <20060409215659.7f475745.vsu@altlinux.ru>
References: <20060409192140.73644723@eusebe>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Sun__9_Apr_2006_21_56_59_+0400_A.IQLFWmZxym9_e="
Cc: Linux-hotplug-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <linux-hotplug-devel-admin@lists.sourceforge.net>
To: Thomas de Grenier de Latour <degrenier@easyconnect.fr>
In-Reply-To: <20060409192140.73644723@eusebe>
Sender: linux-hotplug-devel-admin@lists.sourceforge.net
Errors-To: linux-hotplug-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-hotplug-devel>,
	<mailto:linux-hotplug-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:linux-hotplug-devel@lists.sourceforge.net>
List-Help: <mailto:linux-hotplug-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-hotplug-devel>,
	<mailto:linux-hotplug-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux-hotplug-devel>
List-Id: netdev.vger.kernel.org

--Signature=_Sun__9_Apr_2006_21_56_59_+0400_A.IQLFWmZxym9_e=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, 9 Apr 2006 19:21:40 +0200 Thomas de Grenier de Latour wrote:

> Hi,
>=20
> I'm running Gentoo Linux, a 2.6.16-ck kernel, and udev-0.89-r2, and=20
> have had hard time with network interfaces renaming through udev=20
> rules. The first thing i've tried were rules like this one:
>=20
> SUBSYSTEM=3D=3D"net", KERNEL=3D=3D"eth*", SYSFS{address}=3D=3D"00:0d:60:1=
2:75:0a", NAME=3D"lan"
>=20
> Plus this one from the standard early rules:
>=20
> ACTION=3D=3D"add", SUBSYSTEM=3D=3D"net", WAIT_FOR_SYSFS=3D"address"
>=20
> It doesn't work when i "modprobe e1000" (my ethernet driver):
> ...
> udevd[21612]: udev_event_run: seq 956 forked, pid [21816], 'add' 'net', 0=
 seconds old
> udevd-event[21816]: wait_for_sysfs: file '/sys/class/net/eth0/address' ap=
peared after 0 loops
> udevd-event[21816]: udev_rules_get_name: no node name set, will use kerne=
l name 'eth0'
> ...
> But if i later do a "echo add > /sys/class/net/eth0/uevent", then=20
> interface is properly renamed. It also works fine if i start with
> the module initialy not loaded, and then trigger the uevent on the
> corresponding pci device (will load the module, etc.)
>=20
>=20
> Then i've tried replacing the address match by DRIVER=3D=3D"e1000", with
> no more success.  But i've  noticed something interesting in debug=20
> output, when the rule matcher walks up in parent devices to check=20
> the driver:
> % grep -i driver /var/tmp/udev-net-debug.log
> ...
> udevd-event[18411]: match_key: key DRIVER value=3D'e1000'
> udevd-event[18411]: match_key: match DRIVER 'e1000' <-> ''
> udevd-event[18411]: match_key: DRIVER is false
> udevd-event[18411]: sysfs_device_get: add to cache 'devpath=3D/devices/pc=
i0000:00/0000:00:1e.0/0000:02:01.0', subsystem=3D'pci', driver=3D''
> udevd-event[18411]: match_key: key DRIVER value=3D'e1000'=20
> udevd-event[18411]: match_key: match DRIVER 'e1000' <-> ''=20
> udevd-event[18411]: match_key: DRIVER is false
> ...
> This is weird, because if i latter look in /sys, the "driver" links
> are here. Which made me think it was a race, so i've added this rule:
>=20
> ACTION=3D=3D"add", SUBSYSTEM=3D=3D"net", WAIT_FOR_SYSFS=3D"device/driver"
>=20
> And it fixed the problem:
> ...
> udevd[21612]: udev_event_run: seq 950 forked, pid [21790], 'add' 'net', 0=
 seconds old
> udevd-event[21790]: wait_for_sysfs: file '/sys/class/net/eth0/address' ap=
peared after 0 loops
> udevd-event[21790]: wait_for_sysfs: wait for '/sys/class/net/eth0/device/=
driver' for 20 mseconds
> udevd-event[21790]: wait_for_sysfs: file '/sys/class/net/eth0/device/driv=
er' appeared after 1 loops
> udevd-event[21790]: udev_rules_get_name: rule applied, 'eth0' becomes 'la=
n'
> udevd-event[21790]: rename_net_if: changing net interface name from 'eth0=
' to 'lan'
> udevd-event[21790]: udev_add_device: renamed netif to 'lan'
> ...
>=20
> It also fixes the problem with using a SYSFS{address} match btw.
> With no such wait, i can see in debug that "address" is found in sysfs,
> but with no value:
> ...
> udevd-event[21977]: sysfs_attr_get_value: open '/class/net/eth0'/'address'
> udevd-event[21977]: sysfs_attr_get_value: new uncached attribute '/sys/cl=
ass/net/eth0/address'
> udevd-event[21977]: sysfs_attr_get_value: add to cache '/sys/class/net/et=
h0/address'
> udevd-event[21977]: sysfs_attr_get_value: open '/class/net/eth0'/'address'
> ...
> Whereas with the wait-for-driver trick, i can see it read with a=20
> useful value:
> ...
> udevd-event[21954]: sysfs_attr_get_value: open '/class/net/eth0'/'address'
> udevd-event[21954]: sysfs_attr_get_value: new uncached attribute '/sys/cl=
ass/net/eth0/address'
> udevd-event[21954]: sysfs_attr_get_value: add to cache '/sys/class/net/et=
h0/address'
> udevd-event[21954]: sysfs_attr_get_value: cache '/sys/class/net/eth0/addr=
ess' with value '00:0d:60:12:75:0a'
> ...
>=20
> So i wonder, maybe such a rule should be added to the standard early
> ones? It should maybe use more checks though, to be sure there is
> actually a driver to wait. Something like ENV{PHYSDEVPATH}=3D=3D"?*"=20
> and/or ENV{PHYSDEVDRIVER}=3D=3D"?*".
>=20
> Btw, using ENV{PHYSDEVDRIVER}=3D=3D"e1000" in my renaming rule was working
> fine, with no trick (this variables are correctly set, like 'udevmonitor=
=20
> --env' shows).
>=20
>=20
> So, what do you think, does such a rule makes sense?
> Or is "address" being added to sysfs with no useful value yet the real
> issue, and my rule only an ugly workround?

(quoting the whole message for netdev)

Apparently there is a race there.  The "add" uevent for /class/net/eth0
is emitted by class_device_register(), which is called by
netdev_register_sysfs().  Class device attributes (like "address") are
also added by class_device_register() (really class_device_add(), which
is invoked from there), but this is done before generating the uevent,
so at the first glance there is no race here (and waiting for "address"
is unnecessary).  However, show_address() does not output anything
unless dev->reg_state =3D=3D NETREG_REGISTERED - and this state is set by
netdev_run_todo() only after netdev_register_sysfs() returns, so in the
meantime (while netdev_register_sysfs() is busy adding the "statistics"
attribute group) some process may see an empty "address" attribute.

Waiting for "device/driver" ensures that udevd continues to process the
uevent only after the probe function completes, which ensures completion
of the registration (netdev_run_todo() is invoked by rtnl_unlock() at
the end of register_netdev() and processes all pending requests).

--Signature=_Sun__9_Apr_2006_21_56_59_+0400_A.IQLFWmZxym9_e=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.9.17 (GNU/Linux)

iD8DBQFEOUruW82GfkQfsqIRAgO/AJ0YcvPeY1XVv1cthcbzfcud8wZhdACdEOpm
guCqAJRjYXPapp/bZXJzmog=
=kflz
-----END PGP SIGNATURE-----

--Signature=_Sun__9_Apr_2006_21_56_59_+0400_A.IQLFWmZxym9_e=--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
