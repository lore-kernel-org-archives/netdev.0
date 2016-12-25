From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Sun, 25 Dec 2016 21:46:44 +0100
Message-ID: <201612252146.44496@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com> <1482598381-16513-3-git-send-email-pali.rohar@gmail.com> <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart41192482.HPLGM5dO2y";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart41192482.HPLGM5dO2y
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Sunday 25 December 2016 21:15:40 Arend Van Spriel wrote:
> On 24-12-2016 17:52, Pali Roh=C3=A1r wrote:
> > NVS calibration data for wl1251 are model specific. Every one
> > device with wl1251 chip has different and calibrated in factory.
> >=20
> > Not all wl1251 chips have own EEPROM where are calibration data
> > stored. And in that case there is no "standard" place. Every
> > device has stored them on different place (some in rootfs file,
> > some in dedicated nand partition, some in another proprietary
> > structure).
> >=20
> > Kernel wl1251 driver cannot support every one different storage
> > decided by device manufacture so it will use
> > request_firmware_prefer_user() call for loading NVS calibration
> > data and userspace helper will be responsible to prepare correct
> > data.
>=20
> Responding to this patch as it provides a lot of context to discuss.
> As you might have gathered from earlier discussions I am not a fan
> of using user-space helper. I can agree that the kernel driver,
> wl1251 in this case, should be agnostic to platform specific details
> regarding storage solutions and the firmware api should hide that.
> However, it seems your only solution is adding user-space to the mix
> and changing the api towards that. Can we solve it without
> user-space help?

Without userspace helper it means that userspace helper code must be=20
integrated into kernel.

So what is userspace helper doing?

1) Read MAC address from CAL
2) Read NVS data from CAL
3) Modify MAC address in memory NVS data (new for this patch series)
4) Modify in memory NVS data if we in FCC country

Checking for country is done via dbus call to either Maemo cellular=20
daemon or alternatively via REGDOMAIN in /etc/default/crda. I have plan=20
to use ofono (instead Maemo cellular daemon) too...

Currently we are using closed Nokia proprietary CAL library.

Steps 1) and 2) needs closed library, step 4) needs dbus call.

In current state I do not see way to integrate it into kernel. And=20
because wl1251 currently uses request_firmware() to load those nvs data=20
I think it is still the best way how to handle it...

And IIRC there was already discussion about Nokia CAL parser in kernel=20
and it was declined.

> The firmware_class already supports a number of path prefixes it
> traverses looking for the requested firmware. So I was thinking about
> adding a hashtable in which a platform driver can add firmware which
> are stored in the hashtable using the hashed firmware name. Upon a
> firmware request from the driver we could check the hashtable before
> traversing the path prefixes on VFS. The obvious problem is that the
> request may come before the firmware is added to the hashtable. Just
> wanted to pitch the idea first and hear what others think about it
> and maybe someone has a nice solution for this problem. Fingers
> crossed :-p
>=20
> > In case userspace helper fails request_firmware_prefer_user() still
> > try to load data file directly from VFS as fallback mechanism.
> >=20
> > On Nokia N900 device which has wl1251 chip, NVS calibration data
> > are stored in CAL nand partition. CAL is proprietary Nokia
> > key/value format for nand devices.
>=20
> With the firmware hashtable api on N900 a platform driver could
> interpret the CAL data in the nand partition and provide it through
> the firmware_class.
>=20
> > With this patch it is finally possible to load correct model
> > specific NVS calibration data for Nokia N900.
>=20
> But on other devices that use wl1251, but for instance have no
> userspace helper the request to userspace will fail (after 60 sec?)
> and try VFS after that. Maybe not so nice.

Currently support for those devices is broken (like for N900) as without=20
proper NVS data they do not work correctly...

> You should consider other device configurations. Not just N900.

I do not have any other wl1251 devices. I know that pandora has wl1251=20
too, but it has wl1251 with eeprom where is stored NVS. And in this case=20
request_firmware() is not used there.

> Regards,
> Arend
>=20
> > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
> > ---
> >=20
> >  drivers/net/wireless/ti/wl1251/Kconfig |    1 +
> >  drivers/net/wireless/ti/wl1251/main.c  |    2 +-
> >  2 files changed, 2 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/net/wireless/ti/wl1251/Kconfig
> > b/drivers/net/wireless/ti/wl1251/Kconfig index 7142ccf..affe154
> > 100644
> > --- a/drivers/net/wireless/ti/wl1251/Kconfig
> > +++ b/drivers/net/wireless/ti/wl1251/Kconfig
> > @@ -2,6 +2,7 @@ config WL1251
> >=20
> >  	tristate "TI wl1251 driver support"
> >  	depends on MAC80211
> >  	select FW_LOADER
> >=20
> > +	select FW_LOADER_USER_HELPER
> >=20
> >  	select CRC7
> >  	---help---
> >  =09
> >  	  This will enable TI wl1251 driver support. The drivers make
> >=20
> > diff --git a/drivers/net/wireless/ti/wl1251/main.c
> > b/drivers/net/wireless/ti/wl1251/main.c index 208f062..24f8866
> > 100644
> > --- a/drivers/net/wireless/ti/wl1251/main.c
> > +++ b/drivers/net/wireless/ti/wl1251/main.c
> > @@ -110,7 +110,7 @@ static int wl1251_fetch_nvs(struct wl1251 *wl)
> >=20
> >  	struct device *dev =3D wiphy_dev(wl->hw->wiphy);
> >  	int ret;
> >=20
> > -	ret =3D request_firmware(&fw, WL1251_NVS_NAME, dev);
> > +	ret =3D request_firmware_prefer_user(&fw, WL1251_NVS_NAME, dev);
> >=20
> >  	if (ret < 0) {
> >  =09
> >  		wl1251_error("could not get nvs file: %d", ret);

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com

--nextPart41192482.HPLGM5dO2y
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlhgMDQACgkQi/DJPQPkQ1LnSQCfZy/Ao8PFnbEcFYRiqCO0Q2sf
TfIAn0gtHSBt4iOIqlSpnZeZFI1mDvuL
=U0uD
-----END PGP SIGNATURE-----

--nextPart41192482.HPLGM5dO2y--
