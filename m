From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH v2 1/5] drivers: phy: add generic PHY framework
Date: Tue, 19 Feb 2013 10:01:10 +0200
Message-ID: <20130219080109.GD23197@arwen.pp.htv.fi>
References: <1361253198-7401-1-git-send-email-kishon@ti.com>
 <1361253198-7401-2-git-send-email-kishon@ti.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VMt1DrMGOVs3KQwf"
Cc: <rob@landley.net>, <tony@atomide.com>, <linux@arm.linux.org.uk>,
	<eballetbo@gmail.com>, <javier@dowhile0.org>, <balbi@ti.com>,
	<gregkh@linuxfoundation.org>, <akpm@linux-foundation.org>,
	<mchehab@redhat.com>, <cesarb@cesarb.net>, <davem@davemloft.net>,
	<arnd@arndb.de>, <santosh.shilimkar@ti.com>,
	<broonie@opensource.wolfsonmicro.com>, <swarren@nvidia.com>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Kishon Vijay Abraham I <kishon@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1361253198-7401-2-git-send-email-kishon@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--VMt1DrMGOVs3KQwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Feb 19, 2013 at 11:23:14AM +0530, Kishon Vijay Abraham I wrote:
> The PHY framework provides a set of APIs for the PHY drivers to
> create/destroy a PHY and APIs for the PHY users to obtain a reference to =
the
> PHY with or without using phandle. To obtain a reference to the PHY witho=
ut
> using phandle, the platform specfic intialization code (say from board fi=
le)
> should have already called phy_bind with the binding information. The bin=
ding
> information consists of phy's device name, phy user device name and an in=
dex.
> The index is used when the same phy user binds to mulitple phys.
>=20
> PHY drivers should create the PHY by passing phy_descriptor that has
> describes the PHY (label, type etc..) and ops like init, exit, suspend, r=
esume,

s/has describes/describes

> poweron, shutdown.
>=20
> The documentation for the generic PHY framework is added in
> Documentation/phy.txt and the documentation for the sysfs entry is added
> in Documentation/ABI/testing/sysfs-class-phy.

you forgot to mention here that one case of re-use is OMAP5 where the
same PHY IP (different instances of it) is used for SATA and USB3
functionality, which means that we would have to maintain 2 drivers for
the same thing.

> diff --git a/Documentation/ABI/testing/sysfs-class-phy b/Documentation/AB=
I/testing/sysfs-class-phy
> new file mode 100644
> index 0000000..ffd9930
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-class-phy
> @@ -0,0 +1,15 @@
> +What:		/sys/class/phy/<phy>/label
> +Date:		Feb 2013
> +KernelVersion:	3.10
> +Contact:	Kishon Vijay Abraham I <kishon@ti.com>
> +Description:
> +		This is a read-only file for getting the label of the phy.
> +
> +What:		/sys/class/phy/<phy>/bind

this will cause problems with the generic bind/unbind sysfs files which
are write-only. You should probably rename it to something else.

> +4. Getting a reference to the PHY
> +
> +Before the controller can make use of the PHY, it has to get a reference=
 to
> +the PHY. The PHY framework provides 4 APIs to get a reference to the PHY.

'it has to get a reference to it. This framework', decreases the
duplication of 'PHY'.

> +struct phy *phy_get(struct device *dev, u8 index);
> +struct phy *devm_phy_get(struct device *dev, u8 index);
> +struct phy *of_phy_get(struct device *dev, const char *phandle, u8 index=
);
> +struct phy *devm_of_phy_get(struct device *dev, const char *phandle, u8 =
index);
> +
> +phy_get and devm_phy_get can be used to get the PHY in non-dt boot. This=
 API
> +uses the binding information added using the phy_bind API to find and re=
turn
> +the appropriate PHY. The only difference between the two APIs is that
> +devm_phy_get associates the device with the PHY using devres on successf=
ul PHY
> +get. On driver detach, release function is invoked on the the devres dat=
a and

s/the the/the/

> +devres data is freed.

s/devres data/it/

> +7. Current Status
> +
> +Currently only USB in OMAP is made to use this framework. However using =
the
> +USB PHY library cannot be completely removed because it is intertwined w=
ith
> +OTG. Once we move OTG out of PHY completely, using the old PHY library c=
an be
> +completely removed. SATA in OMAP will also more likely use this new fram=
ework
> +and we should have a patch for it soon.

not sure if this should be in the documentation, but fair enough.

> +static DEFINE_MUTEX(phy_list_mutex);

not sure if a mutex is enough to protect list traversal...

> +struct phy_ops {
> +	int	(*init)(struct phy_descriptor *desc);
> +	int	(*exit)(struct phy_descriptor *desc);
> +	int	(*suspend)(struct phy_descriptor *desc);
> +	int	(*resume)(struct phy_descriptor *desc);

should you really have these two pointers ? I wonder if it wouldn't be
better to force runtime_pm down on the users and have phy_suspend() and
phy_resume() just be wrappers to pm_runtime_get() and pm_runtime_put().

Up to discussion, I guess.

> +#if defined(CONFIG_GENERIC_PHY) || defined(CONFIG_GENERIC_PHY_MODULE)

#if IS_ENABLED(CONFIG_GENERIC_PHY)

> +static inline struct phy *devm_phy_get(struct device *dev, u8 index)
> +{
> +	return ERR_PTR(-EINVAL);

would -EOPNOTSUPP fit better here (and all others)


--=20
balbi

--VMt1DrMGOVs3KQwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRIzFFAAoJEIaOsuA1yqREPaYP/irrHfuqqW4w/g0J72bLTLs+
cmGd1SCSpvbgdo9oD7vQSHWaPDVPfFqxXjMKUxomLmhCnEtNY6sjpnz8HAXANtjd
ajh/0sh+fCby/Lj+3x8J9cBgqsNmwfhmuPYskcBcsE/BmZ7YY+aS30hMLgpIvLRP
q5Z45sJLMm6w1rNDNvXnYzFFQ2fC26Z/T96YpAM7uSGncrITDkVxAzE0qEjvKC+R
W90+3iXalwbZmGK6Q8zBNrtqybLpmuIz6mj7gkKBskV2hXdlviwhA5Z53F70WyhE
TB6KkS32U4vu21iOZUHG7aGLcujjtnCnmthz8vOZ6YFr12Rl2OSl5DE/ormhSSDL
yO0FEnmzBrXtujAHgCxfR9IrkUf84Z+y1xmAry2FZada1HjlU8qBrKnCdpBl8A8r
D278mqZXgFstuD5QgMGibGTLCInMbIGNewXlMuhHCdhy29EPKgdX9+jXL1FaqJzo
UCthTndf46Rk56hAGbE6FEgZ8UrV0Rk9VU5imXsrF/kqxgourz2yyKLuNEyKyTHB
+Mwc/+Jtsi5NJi+WlZHQFAT4lPv/iM+OAC7ozG5M1JO8e6vSImeiYF28R36ILmMq
2mS4hz+rUl6LAE2rM/j4A3OrRndqENDueefCg3zDTBsNwep/bDegFK5WZmzLtdd7
XvCAsrVI3fM2Vr1uKSZt
=jXHf
-----END PGP SIGNATURE-----

--VMt1DrMGOVs3KQwf--
