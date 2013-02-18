From: Felipe Balbi <balbi@ti.com>
Subject: Re: SYSFS "errors"
Date: Mon, 18 Feb 2013 20:46:33 +0200
Message-ID: <20130218184633.GC10755@arwen.pp.htv.fi>
References: <20130218153316.GA2663@arwen.pp.htv.fi>
 <20130218155012.GA30974@kroah.com>
 <20130218155215.GB2663@arwen.pp.htv.fi>
 <20130218171334.GA31329@kroah.com>
 <20130218172700.GH2663@arwen.pp.htv.fi>
 <20130218174916.GA2070@kroah.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="0IvGJv3f9h+YhkrH"
Cc: Felipe Balbi <balbi@ti.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130218174916.GA2070@kroah.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--0IvGJv3f9h+YhkrH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, On Mon, Feb 18, 2013 at 09:49:16AM -0800, Greg KH wrote:
> > Input/output error - /sys/devices/cpu/power/autosuspend_delay_ms
>=20
> The issue with this file is, if the power.use_autosuspend flag is not
> set for the device, then it can't be read or written to.  This flag
> changes dynamically with the system state
> (__pm_runtime_use_autosuspend() can change it), so we can't just not
> show the file if the flag is not set properly, sorry.
>=20
> So the "error" is correct here, as is the 0644 file value.

hmm... we could create the file at pm_runtime_enable() time and remove
it on pm_runtime_disable() time, no ? Addin Rafael to Cc

> > No such device or address - /sys/devices/pci0000:00/0000:00:1d.7/usb2/2=
-5/2-5.1/2-5.1.1/2-5.1.1:1.0/host100/target100:0:0/100:0:0:0/block/sdc/trac=
e/pid
> > No such device or address - /sys/devices/pci0000:00/0000:00:1d.7/usb2/2=
-5/2-5.1/2-5.1.1/2-5.1.1:1.0/host100/target100:0:0/100:0:0:0/block/sdc/trac=
e/end_lba
> > No such device or address - /sys/devices/pci0000:00/0000:00:1d.7/usb2/2=
-5/2-5.1/2-5.1.1/2-5.1.1:1.0/host100/target100:0:0/100:0:0:0/block/sdc/trac=
e/enable
> > No such device or address - /sys/devices/pci0000:00/0000:00:1d.7/usb2/2=
-5/2-5.1/2-5.1.1/2-5.1.1:1.0/host100/target100:0:0/100:0:0:0/block/sdc/trac=
e/act_mask
> > No such device or address - /sys/devices/pci0000:00/0000:00:1d.7/usb2/2=
-5/2-5.1/2-5.1.1/2-5.1.1:1.0/host100/target100:0:0/100:0:0:0/block/sdc/trac=
e/start_lba
> > Invalid argument - /sys/devices/pci0000:00/0000:00:1f.2/ata2/host1/scsi=
_host/host1/em_buffer
> > Invalid argument - /sys/devices/pci0000:00/0000:00:1f.2/ata2/host1/targ=
et1:0:0/1:0:0:0/sw_activity
> > Operation not supported - /sys/devices/pci0000:00/0000:00:1f.2/ata2/hos=
t1/target1:0:0/1:0:0:0/unload_heads
>=20
> SCSI fun, go poke the SCSI developers about these files, I know nothing
> about them, nor do I really want to :)
>=20
> > No such device - /sys/devices/system/edac/mc/mc0/sdram_scrub_rate
>=20
> Odd, go ask the edac developers

will do ;-)

> > Input/output error - /sys/devices/system/memory/soft_offline_page
> > Input/output error - /sys/devices/system/memory/hard_offline_page
>=20
> These both should be mode 0400, not 0644, they have no 'show' attribute,
> that's a bug, care to make up a patch that I can take?  Or I can, let me
> know.

sure, will send in a bit.

> > Invalid argument - /sys/devices/virtual/net/lo/speed
> > Invalid argument - /sys/devices/virtual/net/lo/duplex
>=20
> Ask the network developers, odds are, the loopback device doesn't really
> have a speed :)

right ;-)

> > No such device or address - /sys/devices/virtual/block/loop0/trace/pid
> > No such device or address - /sys/devices/virtual/block/loop0/trace/end_=
lba
> > No such device or address - /sys/devices/virtual/block/loop0/trace/enab=
le
> > No such device or address - /sys/devices/virtual/block/loop0/trace/act_=
mask
> > No such device or address - /sys/devices/virtual/block/loop0/trace/star=
t_lba
>=20
> Hm, these show up for virtual block devices as well, maybe they aren't
> scsi specific, but rather block specific, go poke the block developers
> then.

yeah, I was looking into these a while ago. They're created by
blk_trace_init_sysfs() which is called by blk_register_queue() but I
wonder if we couldn't defer the creation of those so that:

sysfs_blk_trace_attr_show():

1639         bdev =3D bdget(part_devt(p));
1640         if (bdev =3D=3D NULL)
1641                 goto out;
1642=20
1643         q =3D blk_trace_get_queue(bdev);
1644         if (q =3D=3D NULL)
1645                 goto out_bdput;

never fail (meaning they could be removed), adding some block folks to
the loop.

--=20
balbi

--0IvGJv3f9h+YhkrH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRIncJAAoJEIaOsuA1yqREDr0P/jIuEk5NZM1ZXoLJ7VHyYa14
ryQ6bQdJI8GJ0GgGTpy9VYHPmtKOpoidQ8xB8fMtuBdEvFYrwHu+5QmtNSSMAjbV
lYs/J6q0jIlxvLQecDEER6xZFvm4YiNRiDgwgARB8xc74HukbtLbM5XSIiyOR5cc
u7ue0ZACpDznT9j0/CvR6F/k1wSsCwsf6qJS1KH69ro7t/0XbpykbDVeBZAAczCk
bnIoSP1b9auWOiFxObVBXNWie2Uf8NAE0Y9RaF91FpChgklsQc2kMXZCMTfPd2Lc
Q4kSi1Hu+epdSzS3y20mAMOnH1EdWnAsCUikZYXfduQVXY60bdiwie4ejy5eNkTJ
w5SLGuTc3Jd3sY65kxApOfCLi8396pEi6/Ru6gSr/3o77cgtQPkv6/SGiufzLjGh
xlOau8TEbAEkA38vmyIZoTTTNVPeRo0q3jCXVmzD6Wn3p/iQLUAHx7FqQ7FLhd5a
+ipFbKN5wvU0tEKxNrnm3QXEzVYEB0IQMMZsrXMykKdVDADccIDNtgZ9NAmAdUeV
FdN6hjZMunh1akvKVnwcETy6aOQhWzFFKTL2oVgMrDvW52gjd6Hh1QS5bAs3RoWH
0/57uC8buGLWCMVcNtJdbeshPbdMN8Po7QyOpQK32w7iXXuQFOE1ScbcFWSgdRYw
hkNmCY0YtkQ5iHC+LVPP
=Z36/
-----END PGP SIGNATURE-----

--0IvGJv3f9h+YhkrH--
