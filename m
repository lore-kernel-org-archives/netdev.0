From: Mauro Carvalho Chehab <mchehab@redhat.com>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 08:11:49 -0300
Message-ID: <20130219081149.46972f56@redhat.com>
References: <20130218174916.GA2070@kroah.com>
	<20130218184633.GC10755@arwen.pp.htv.fi>
	<20130218164638.7cb53baa@redhat.com>
	<20130218200542.GB20137@arwen.pp.htv.fi>
	<20130218184742.5a4c3c06@redhat.com>
	<20130218215434.GB16794@kroah.com>
	<20130218221306.GA21493@pd.tnic>
	<20130218222618.GA21818@kroah.com>
	<20130218224405.GB21493@pd.tnic>
	<20130219070310.2cadad7a@redhat.com>
	<20130219101121.GJ23197@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/kE7axfAqYO72=xudnJiWZpI"; protocol="application/pgp-signature"
Cc: Borislav Petkov <bp@alien8.de>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, <JBottomley@parallels.com>,
	<linux-scsi@vger.kernel.org>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	Doug Thompson <dougthompson@xmission.com>,
	<linux-edac@vger.kernel.org>, <rjw@sisk.pl>,
	<linux-pm@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130219101121.GJ23197@arwen.pp.htv.fi>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/kE7axfAqYO72=xudnJiWZpI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Em Tue, 19 Feb 2013 12:11:21 +0200
Felipe Balbi <balbi@ti.com> escreveu:

> Hi,
>=20
> On Tue, Feb 19, 2013 at 07:03:10AM -0300, Mauro Carvalho Chehab wrote:
> > > But my gut feeling says to stay concervative and not touch this code -
> > > we don't know what uses it and how much we would break by "fixing" it.
> > > The current situation is not that big of a deal IMVHO and I'd be will=
ing
> > > to accept the small inconcistency versus possibly breaking userspace.
> >=20
> > I remember I saw some discussions about it in the past at bluesmoke ML,
> > saying that -ENODEV is the expected behavior when this is not supported.
> >=20
> > Changing from -ENODEV to "N/A" will break anything that would be relying
> > on the previous behavior. So, I think that such change will for sure br=
eak
> > userspace.
> >=20
> > If we're willing to change it, not creating the "sdram_scrub_rate" sysf=
s=20
> > node is less likely to affect userspace.
>=20
> yeah, I agree with this. Guess we shouldn't be creating files which
> aren't supported by the underlying HW and having a read() return -ENODEV
> is quite weird IMO since that's actually 'breaking' read() interface
> although that's up to interpretations.

The enclosed (untested) patch will likely do the trick. It needs to be
tested with one of the drivers that support scrub setting (amd64_edac.c,
cpc925_edac.c, e752x_edac.c, i5100_edac.c or i7core_edac.c).

Regards,
Mauro

-

[PATCH] edac: only create sdram_scrub_rate where supported

Currently, sdram_scrub_rate sysfs node is created even if the device
doesn't support get/set the scub rate. Change the logic to only
create this device node when the operation is supported.

Reported-by: Felipe Balbi <balbi@ti.com>
Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>

diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysfs.c
index 9c58da6..937975b 100644
--- a/drivers/edac/edac_mc_sysfs.c
+++ b/drivers/edac/edac_mc_sysfs.c
@@ -7,7 +7,7 @@
  *
  * Written Doug Thompson <norsk5@xmission.com> www.softwarebitmaker.com
  *
- * (c) 2012 - Mauro Carvalho Chehab <mchehab@redhat.com>
+ * (c) 2012-2013 - Mauro Carvalho Chehab <mchehab@redhat.com>
  *	The entire API were re-written, and ported to use struct device
  *
  */
@@ -681,9 +681,6 @@ static ssize_t mci_sdram_scrub_rate_store(struct device=
 *dev,
 	unsigned long bandwidth =3D 0;
 	int new_bw =3D 0;
=20
-	if (!mci->set_sdram_scrub_rate)
-		return -ENODEV;
-
 	if (strict_strtoul(data, 10, &bandwidth) < 0)
 		return -EINVAL;
=20
@@ -707,9 +704,6 @@ static ssize_t mci_sdram_scrub_rate_show(struct device =
*dev,
 	struct mem_ctl_info *mci =3D to_mci(dev);
 	int bandwidth =3D 0;
=20
-	if (!mci->get_sdram_scrub_rate)
-		return -ENODEV;
-
 	bandwidth =3D mci->get_sdram_scrub_rate(mci);
 	if (bandwidth < 0) {
 		edac_printk(KERN_DEBUG, EDAC_MC, "Error reading scrub rate\n");
@@ -882,7 +876,6 @@ static struct attribute *mci_attrs[] =3D {
 	&dev_attr_ce_noinfo_count.attr,
 	&dev_attr_ue_count.attr,
 	&dev_attr_ce_count.attr,
-	&dev_attr_sdram_scrub_rate.attr,
 	&dev_attr_max_location.attr,
 	NULL
 };
@@ -1017,6 +1010,14 @@ int edac_create_sysfs_mci_device(struct mem_ctl_info=
 *mci)
 		return err;
 	}
=20
+	if (mci->set_sdram_scrub_rate && mci->get_sdram_scrub_rate) {
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
@@ -1061,6 +1062,7 @@ fail:
 			continue;
 		device_unregister(&dimm->dev);
 	}
+fail2:
 	device_unregister(&mci->dev);
 	bus_unregister(&mci->bus);
 	kfree(mci->bus.name);


--Sig_/kE7axfAqYO72=xudnJiWZpI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRI14HAAoJEGO08Bl/PELnvNgP/j/qBNdLQgOv7gSArNQiB3Za
TzfbFPTpsSAPSM8RIjqAdct6tP+0zBYVMCeqG28xHpV0z735UAFxztoUmtU/wvPc
kn5tRRaI6ktnLQknCCI9Xi5zPESPH4HSvWH/+ilKe0tGVCBBlA70Q9u+99ooLhxP
bEAaw2/saAfMN6tzi+OidZc5RjizXRGW6hqXXw2Rxf3QikAP0Tuo8kQUpU6kj7LZ
ue4QPqRmp6Ij0Gwn+eH7ChPv+rrqj17x+CKs4tvmdOil0HLTfUZjPuSINa1wW6xk
Dm6W8ERDXMmtsglIh06bwAZ8Of6tRIks2IvNhfqLLFtib4dXB4O5A7FfD/74DAY7
E5XI3rMIkSiMI1SDpQYIEO3JhksrjhCy5G3HeK//Ky7nNOTiy9hCTwRmZjrAy2EX
TrAMDXPDlpyej9Qig3hVVkifZO6/wVKw0U0jWW72KprUtmyALO8SItAbjqPc5le2
jlTmwb50vD7scGHsolGiDe5tSkz7fQBb9m0bgfAdFqdGmhArK0ElRijRIFlcR+gP
yMC1n3GDv5XOW5YHA3W/w40/FuvkDhPdGWo/RHMnxBdDMpK1Uedc3/xUGmuYqoSj
axHEUFO2Nbzw6JRp1ATQQD39e4FnPau8+bBCfvwx3I9GaqlGelQVSlbfOJA/9dLV
SLajhH+KoAF/aChzml0j
=CXMw
-----END PGP SIGNATURE-----

--Sig_/kE7axfAqYO72=xudnJiWZpI--
