From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Mon, 4 Apr 2011 21:04:29 -0600
Message-ID: <20110405030428.GB29522@ponder.secretlab.ca>
References: <20110202195417.228e2656@queued.net>
 <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca>
 <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo>
 <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
 <20110401235239.GE29397@sortiz-mobl>
 <BANLkTi=bq=OGzXFp7qiBr7x_BnGOWf=DRQ@mail.gmail.com>
 <20110404100314.GC2751@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andres Salomon <dilinger@queued.net>, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110404100314.GC2751@sortiz-mobl>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2011 at 12:03:15PM +0200, Samuel Ortiz wrote:
> On Fri, Apr 01, 2011 at 05:58:44PM -0600, Grant Likely wrote:
> > On Fri, Apr 1, 2011 at 5:52 PM, Samuel Ortiz <sameo@linux.intel.com=
> wrote:
> > > On Fri, Apr 01, 2011 at 11:56:35AM -0600, Grant Likely wrote:
> > >> On Fri, Apr 1, 2011 at 11:47 AM, Andres Salomon <dilinger@queued=
=2Enet> wrote:
> > >> > On Fri, 1 Apr 2011 13:20:31 +0200
> > >> > Samuel Ortiz <sameo@linux.intel.com> wrote:
> > >> >
> > >> >> Hi Grant,
> > >> >>
> > >> >> On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
> > >> > [...]
> > >> >> > Gah. =A0Not all devices instantiated via mfd will be an mfd=
 device,
> > >> >> > which means that the driver may very well expect an *entire=
ly
> > >> >> > different* platform_device pointer; which further means a v=
ery high
> > >> >> > potential of incorrectly dereferenced structures (as eviden=
ced by a
> > >> >> > patch series that is not bisectable). =A0For instance, the =
xilinx ip
> > >> >> > cores are used by more than just mfd.
> > >> >> I agree. Since the vast majority of the MFD subdevices are MF=
D
> > >> >> specific IPs, I overlooked that part. The impacted drivers ar=
e the
> > >> >> timberdale and the DaVinci voice codec ones.
> > >>
> > >> Another option is you could do this for MFD devices:
> > >>
> > >> struct mfd_device {
> > >> =A0 =A0 =A0 =A0 struct platform_devce pdev;
> > >> =A0 =A0 =A0 =A0 struct mfd_cell *cell;
> > >> };
> > >>
> > >> However, that requires that drivers using the mfd_cell will *nev=
er*
> > >> get instantiated outside of the mfd infrastructure, and there is=
 no
> > >> way to protect against this so it is probably a bad idea.
> > >>
> > >> Or, mfd_cell could be added to platform_device directly which wo=
uld
> > >> *by far* be the safest option at the cost of every platform_devi=
ce
> > >> having a mostly unused mfd_cell pointer. =A0Not a significant co=
st in my
> > >> opinion.
> > > I thought about this one, but I had the impression people would w=
ant to kill
> > > me for adding an MFD specific pointer to platform_device. I guess=
 it's worth
> > > giving it a try since it would be a simple and safe solution.
> > > I'll look at it later this weekend.
> > >
> > > Thanks for the input.
> >=20
> > [cc'ing gregkh because we're talking about modifying struct platfor=
m_device]
> >=20
> > I'll back you up on this one.  It is a far better solution than the
> > alternatives.  At least with mfd, it covers a large set of devices.=
  I
> > think there is a strong argument for doing this.  Or alternatively,
> > the particular interesting fields from mfd_cell could be added to
> > platform_device.  What information do child devices need access to?
> In some cases, they need the whole cell to clone it. So I'm up for ad=
ding an
> mfd_cell pointer to the platform_device structure.
> Below is a tentative patch. This is a first step and would fix all
> regressions. I tried to keep the MFD dependencies as small as possibl=
e, which
> is why I placed the pdev->mfd_cell building code in mfd-core.c

Okay.

> The second step would be to get rid of mfd_get_data() and have all su=
bdrivers
> going back to the regular platform_data way. They would no longer be =
dependant
> on the MFD code except for those who really need it. In that case the=
y could
> just call mfd_get_cell() and get full access to their MFD cell.

The revert to platform_data needs to happen ASAP though.  If this
second step isn't ready really quickly, then the current patches
should be reverted to give some breathing room for creating the
replacement patches.  However, it's not such a rush if the below
patch really does eliminate all of the nastiness of the original
series. (I haven't looked and a rolled up diff of the first series and
this change, so I don't know for sure).

In principle I agree with this patch.  Some comments below.

g.

>=20
> ---=20
>  drivers/mfd/mfd-core.c          |   27 ++++++++++++++++++++++-----
>  include/linux/mfd/core.h        |    7 +++++--
>  include/linux/platform_device.h |    5 +++++
>  3 files changed, 32 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
> index d01574d..c0fc1c0 100644
> --- a/drivers/mfd/mfd-core.c
> +++ b/drivers/mfd/mfd-core.c
> @@ -18,6 +18,21 @@
>  #include <linux/pm_runtime.h>
>  #include <linux/slab.h>
> =20
> +static int mfd_platform_add_cell(struct platform_device *pdev, const=
 struct mfd_cell *cell)
> +{
> +	struct mfd_cell *c;
> +
> +	if (cell =3D=3D NULL)
> +		return 0;
> +
> +	c =3D kmemdup(cell, sizeof(struct mfd_cell), GFP_KERNEL);
> +	if (c =3D=3D NULL)
> +		return -ENOMEM;
> +
> +	pdev->mfd_cell =3D c;
> +	return 0;
> +}

'sizeof(*cell) is a teensy bit safer.  Also, this can be more concise:

static int mfd_platform_add_cell(struct platform_device *pdev,
				 const struct mfd_cell *cell)
{
	if (!cell)
		return 0;

	pdev->mfd_cell =3D kmemdup(cell, sizeof(*cell), GFP_KERNEL);
	return pdev->mfd_cell ? 0 : -ENOMEM;
}

> +
>  int mfd_cell_enable(struct platform_device *pdev)
>  {
>  	const struct mfd_cell *cell =3D mfd_get_cell(pdev);
> @@ -75,7 +90,7 @@ static int mfd_add_device(struct device *parent, in=
t id,
> =20
>  	pdev->dev.parent =3D parent;
> =20
> -	ret =3D platform_device_add_data(pdev, cell, sizeof(*cell));
> +	ret =3D mfd_platform_add_cell(pdev, cell);
>  	if (ret)
>  		goto fail_res;
> =20
> @@ -104,17 +119,17 @@ static int mfd_add_device(struct device *parent=
, int id,
>  		if (!cell->ignore_resource_conflicts) {
>  			ret =3D acpi_check_resource_conflict(res);
>  			if (ret)
> -				goto fail_res;
> +				goto fail_cell;
>  		}
>  	}
> =20
>  	ret =3D platform_device_add_resources(pdev, res, cell->num_resource=
s);
>  	if (ret)
> -		goto fail_res;
> +		goto fail_cell;
> =20
>  	ret =3D platform_device_add(pdev);
>  	if (ret)
> -		goto fail_res;
> +		goto fail_cell;
> =20
>  	if (cell->pm_runtime_no_callbacks)
>  		pm_runtime_no_callbacks(&pdev->dev);
> @@ -123,7 +138,8 @@ static int mfd_add_device(struct device *parent, =
int id,
> =20
>  	return 0;
> =20
> -/*	platform_device_del(pdev); */
> +fail_cell:
> +	kfree(pdev->mfd_cell);

Looks like kfreeing the cell should become part of the
platform_device_release() function.  Which would remove it from here,
and also ...

>  fail_res:
>  	kfree(res);
>  fail_device:
> @@ -171,6 +187,7 @@ static int mfd_remove_devices_fn(struct device *d=
ev, void *c)
>  	if (!*usage_count || (cell->usage_count < *usage_count))
>  		*usage_count =3D cell->usage_count;
> =20
> +	kfree(pdev->mfd_cell);

=2E.. from here.

>  	platform_device_unregister(pdev);
>  	return 0;
>  }
> diff --git a/include/linux/mfd/core.h b/include/linux/mfd/core.h
> index ad1b19a..0e4d3a6 100644
> --- a/include/linux/mfd/core.h
> +++ b/include/linux/mfd/core.h
> @@ -86,7 +86,7 @@ extern int mfd_clone_cell(const char *cell, const c=
har **clones,
>   */
>  static inline const struct mfd_cell *mfd_get_cell(struct platform_de=
vice *pdev)
>  {
> -	return pdev->dev.platform_data;
> +	return pdev->mfd_cell;
>  }
> =20
>  /*
> @@ -95,7 +95,10 @@ static inline const struct mfd_cell *mfd_get_cell(=
struct platform_device *pdev)
>   */
>  static inline void *mfd_get_data(struct platform_device *pdev)
>  {
> -	return mfd_get_cell(pdev)->mfd_data;
> +	if (pdev->mfd_cell !=3D NULL)
> +		return mfd_get_cell(pdev)->mfd_data;
> +	else
> +		return pdev->dev.platform_data;

Blech!  Yeah, this should become consistent that platform data
*always* comes from pdev->dev.platform_data.

>  }
> =20
>  extern int mfd_add_devices(struct device *parent, int id,
> diff --git a/include/linux/platform_device.h b/include/linux/platform=
_device.h
> index d96db98..734d254 100644
> --- a/include/linux/platform_device.h
> +++ b/include/linux/platform_device.h
> @@ -14,6 +14,8 @@
>  #include <linux/device.h>
>  #include <linux/mod_devicetable.h>
> =20
> +struct mfd_cell;
> +
>  struct platform_device {
>  	const char	* name;
>  	int		id;
> @@ -23,6 +25,9 @@ struct platform_device {
> =20
>  	const struct platform_device_id	*id_entry;
> =20
> +	/* MFD cell pointer */
> +	struct mfd_cell	*mfd_cell;
> +

Move this down to by the of_node pointer.  May as well collect all the
supplemental data about the device in the same place.

>  	/* arch specific additions */
>  	struct pdev_archdata	archdata;
>  };
>=20
> --=20
> Intel Open Source Technology Centre
> http://oss.intel.com/
