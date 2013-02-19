From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 09:16:10 -0300
Message-ID: <20130219091610.2b746a30@redhat.com>
References: <20130218164638.7cb53baa@redhat.com>
	<20130218200542.GB20137@arwen.pp.htv.fi>
	<20130218184742.5a4c3c06@redhat.com>
	<20130218215434.GB16794@kroah.com>
	<20130218221306.GA21493@pd.tnic>
	<20130218222618.GA21818@kroah.com>
	<20130218224405.GB21493@pd.tnic>
	<20130219070310.2cadad7a@redhat.com>
	<20130219101121.GJ23197@arwen.pp.htv.fi>
	<20130219081149.46972f56@redhat.com>
	<20130219114345.GA26623@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: balbi@ti.com, Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
To: Borislav Petkov <bp@alien8.de>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130219114345.GA26623@pd.tnic>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Tue, 19 Feb 2013 12:43:46 +0100
Borislav Petkov <bp@alien8.de> escreveu:

> On Tue, Feb 19, 2013 at 08:11:49AM -0300, Mauro Carvalho Chehab wrote=
:
> > > > I remember I saw some discussions about it in the past at blues=
moke ML,
> > > > saying that -ENODEV is the expected behavior when this is not s=
upported.
> > > >=20
> > > > Changing from -ENODEV to "N/A" will break anything that would b=
e relying
> > > > on the previous behavior. So, I think that such change will for=
 sure break
> > > > userspace.
> > > >=20
> > > > If we're willing to change it, not creating the "sdram_scrub_ra=
te" sysfs=20
> > > > node is less likely to affect userspace.
>=20
> This will break scripts which assume this file's presence implicitly.

If are there any script like that, then yes.

> [ =E2=80=A6 ]
>=20
> > @@ -1017,6 +1010,14 @@ int edac_create_sysfs_mci_device(struct mem_=
ctl_info *mci)
> >  		return err;
> >  	}
> > =20
> > +	if (mci->set_sdram_scrub_rate && mci->get_sdram_scrub_rate) {
>=20
> This will break cpc925_edac.c because it defines a
> ->get_sdram_scrub_rate but not a ->set_sdram_scrub_rate.

True. Patch below fixes it.

> I think a maybe better fix would be to figure out the sysfs file
> permissions based on the presence of the two functions and *then* add
> the attribute.
>=20
> This way, the only visible change to userspace is the corrected sysfs
> file permissions.

I'm not sure if is there a way to pass fs permissions to something simi=
lar
to device_create_file().

On both cases, an error will happen at open:
	- if file doesn't exist (this approach), it will return -ENOENT;
	- if file is opened with wrong permissions, open will return -EPERM.

However, if the file is not created, readdir() won't show the file.
So, if userspace first seeks for the sdram_scrub_rate, it won't fail.
That makes the logic below a little safer, IMO.


[PATCH EDAC] edac: only create sdram_scrub_rate where supported

Currently, sdram_scrub_rate sysfs node is created even if the device
doesn't support get/set the scub rate. Change the logic to only
create this device node when the operation is supported.

If only read or only write is supported, it will keep returning -ENODEV
just like before.

Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>

diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysfs.=
c
index 9c58da6..29b66a2 100644
--- a/drivers/edac/edac_mc_sysfs.c
+++ b/drivers/edac/edac_mc_sysfs.c
@@ -7,7 +7,7 @@
  *
  * Written Doug Thompson <norsk5@xmission.com> www.softwarebitmaker.co=
m
  *
- * (c) 2012 - Mauro Carvalho Chehab <mchehab@redhat.com>
+ * (c) 2012-2013 - Mauro Carvalho Chehab <mchehab@redhat.com>
  *	The entire API were re-written, and ported to use struct device
  *
  */
@@ -882,7 +882,6 @@ static struct attribute *mci_attrs[] =3D {
 	&dev_attr_ce_noinfo_count.attr,
 	&dev_attr_ue_count.attr,
 	&dev_attr_ce_count.attr,
-	&dev_attr_sdram_scrub_rate.attr,
 	&dev_attr_max_location.attr,
 	NULL
 };
@@ -1017,6 +1016,14 @@ int edac_create_sysfs_mci_device(struct mem_ctl_=
info *mci)
 		return err;
 	}
=20
+	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate) {
+		err =3D device_create_file(&mci->dev,
+					 &dev_attr_sdram_scrub_rate);
+		if (err) {
+			edac_dbg(1, "failure: create sdram_scrub_rate\n");
+			goto fail2;
+		}
+	}
 	/*
 	 * Create the dimm/rank devices
 	 */
@@ -1061,6 +1068,7 @@ fail:
 			continue;
 		device_unregister(&dimm->dev);
 	}
+fail2:
 	device_unregister(&mci->dev);
 	bus_unregister(&mci->bus);
 	kfree(mci->bus.name);
