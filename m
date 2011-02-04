From: Keith Packard <keithp@keithp.com>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 03 Feb 2011 17:05:54 -0800
Message-ID: <yund3n88v7x.fsf@aiko.keithp.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera>
	<AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
	<s5haaid3xos.wl%tiwai@suse.de> <201102032009.17100.rjw@sisk.pl>
	<AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
	<AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com>
	<AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
	<AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0090281889=="
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Takashi Iwai <tiwai@suse.de>, Carlos Mafra <crmafra2@gmail.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	Florian Mickler <florian@mickler.org>,
	Network Development <netdev@vger.kernel.org>,
	Dave Airlie <airlied@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Dave Airlie <airlied@gmail.com>
Return-path: <dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
Errors-To: dri-devel-bounces+sf-dri-devel=m.gmane.org@lists.freedesktop.org
List-Id: netdev.vger.kernel.org

--===============0090281889==
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--=-=-=
Content-Transfer-Encoding: quoted-printable

On Thu, 3 Feb 2011 16:30:56 -0800, Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
> On Thu, Feb 3, 2011 at 4:06 PM, Dave Airlie <airlied@gmail.com> wrote:
> >
> > If we are setting a mode on a connector it automatically will end up
> > in a DPMS on state,
> > so this seemed correct from what I can see.
>=20
> The more I look at that function, the more I disagree with you and
> with that patch.
>=20
> The code is just crazy.
>=20
> First off, it isn't even necessarily setting a mode to begin with,
> because as far as I can tell. If the mode doesn't change, neither
> mode_changed nor fb_changed will be true, afaik. There seems to be a
> fair amount of code there explicitly to avoid changing modes if not
> necessary.
>=20
> But even _if_ we are setting a mode, if I read the code correctly, the
> mode may be set to NULL - which seems to mean "turn it off". In which
> case it looks to me that drm_helper_disable_unused_functions() will
> actually do a
>=20
>    (*crtc_funcs->dpms)(crtc, DRM_MODE_DPMS_OFF);
>=20
> call on the crtc in question. So then blindly just saying "it's mode
> DRM_MODE_DPMS_ON" afterwards looks rather bogus to me.
>=20
> _Maybe_ it would work if it was done before that whole
> "disable_unused" logic. Or maybe it should just be done in
> drm_crtc_helper_set_mode(), which is what actually sets the mode (but
> there's the 'fb_changed' case too)
>=20
> > A future mode set shouldn't ever not turn the connector on, since
> > modesetting is an implicit
> > DPMS,
> >
> > It sounds like something more subtle than that, though I'm happy to
> > revert this for now, and let Keith
> > think about it a bit more.
>=20
> So I haven't heard anything from Keith. Keith? Just revert it? Or do
> you have a patch for people to try?

The goal is to make it so that when you *do* set a mode, DPMS gets set
to ON (as the monitor will actually be "on" at that point). Here's a
patch which does the DPMS_ON precisely when setting a mode.

Dave thinks we should instead force dpms to match crtc->enabled, I'd
rather have dpms get set when we know the hardware has been changed.

(note, this patch compiles, but is otherwise only lightly tested).

From=2038507bb3a67441425e11085d17d727f3b230f927 Mon Sep 17 00:00:00 2001
From: Keith Packard <keithp@keithp.com>
Date: Thu, 3 Feb 2011 16:57:28 -0800
Subject: [PATCH] drm: Only set DPMS ON when actually configuring a mode

In drm_crtc_helper_set_config, instead of always forcing all outputs
to DRM_MODE_DPMS_ON, only set them if the CRTC is actually getting a
mode set, as any mode set will turn all outputs on.

Signed-off-by: Keith Packard <keithp@keithp.com>
=2D--
 drivers/gpu/drm/drm_crtc_helper.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/gpu/drm/drm_crtc_helper.c b/drivers/gpu/drm/drm_crtc_h=
elper.c
index 952b3d4..17459ee 100644
=2D-- a/drivers/gpu/drm/drm_crtc_helper.c
+++ b/drivers/gpu/drm/drm_crtc_helper.c
@@ -665,6 +665,12 @@ int drm_crtc_helper_set_config(struct drm_mode_set *se=
t)
 				ret =3D -EINVAL;
 				goto fail;
 			}
+			DRM_DEBUG_KMS("Setting connector DPMS state to on\n");
+			for (i =3D 0; i < set->num_connectors; i++) {
+				DRM_DEBUG_KMS("\t[CONNECTOR:%d:%s] set DPMS on\n", set->connectors[i]-=
>base.id,
+					      drm_get_connector_name(set->connectors[i]));
+				set->connectors[i]->dpms =3D DRM_MODE_DPMS_ON;
+			}
 		}
 		drm_helper_disable_unused_functions(dev);
 	} else if (fb_changed) {
@@ -681,12 +687,6 @@ int drm_crtc_helper_set_config(struct drm_mode_set *se=
t)
 			goto fail;
 		}
 	}
=2D	DRM_DEBUG_KMS("Setting connector DPMS state to on\n");
=2D	for (i =3D 0; i < set->num_connectors; i++) {
=2D		DRM_DEBUG_KMS("\t[CONNECTOR:%d:%s] set DPMS on\n", set->connectors[i]-=
>base.id,
=2D			      drm_get_connector_name(set->connectors[i]));
=2D		set->connectors[i]->dpms =3D DRM_MODE_DPMS_ON;
=2D	}
=20
 	kfree(save_connectors);
 	kfree(save_encoders);
=2D-=20
1.7.2.3

=2D-=20
keith.packard@intel.com

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFNS1DyQp8BWwlsTdMRAvOJAKDPOT2MtyMRveY5kOoJJ4EKjm9qMQCbBiwj
dsr57celRU5NJXl467pe5dU=
=nXhj
-----END PGP SIGNATURE-----
--=-=-=--

--===============0090281889==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
dri-devel mailing list
dri-devel@lists.freedesktop.org
http://lists.freedesktop.org/mailman/listinfo/dri-devel

--===============0090281889==--
