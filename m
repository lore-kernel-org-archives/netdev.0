From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Fri, 24 Jun 2011 11:49:00 +0800
Message-ID: <20110624034859.GB19188@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<20110618161934.GH8195@ponder.secretlab.ca>
	<20110619073000.GA23171@S2100-06.ap.freescale.net>
	<20110621135558.GB9228@S2101-09.ap.freescale.net>
	<BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
	<20110623183821.GA19188@S2100-06.ap.freescale.net>
	<BANLkTi=8Mks6T85WnEyihmB21U1j7reHrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BANLkTi=8Mks6T85WnEyihmB21U1j7reHrQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2011 at 05:11:54PM -0600, Grant Likely wrote:
[...]
> > diff --git a/drivers/of/base.c b/drivers/of/base.c
> > index 632ebae..90349a2 100644
> > --- a/drivers/of/base.c
> > +++ b/drivers/of/base.c
> > @@ -17,12 +17,27 @@
> > =A0* =A0 =A0 =A0as published by the Free Software Foundation; either ve=
rsion
> > =A0* =A0 =A0 =A02 of the License, or (at your option) any later version.
> > =A0*/
> > +#include <linux/ctype.h>
> > =A0#include <linux/module.h>
> > =A0#include <linux/of.h>
> > =A0#include <linux/spinlock.h>
> > =A0#include <linux/slab.h>
> > =A0#include <linux/proc_fs.h>
> >
> > +struct alias_devname {
> > + =A0 =A0 =A0 char devname[32];
> > + =A0 =A0 =A0 struct list_head link;
> > + =A0 =A0 =A0 struct list_head head;
> > +};
> > +
> > +struct alias_devid {
> > + =A0 =A0 =A0 int devid;
> > + =A0 =A0 =A0 struct device_node *node;
> > + =A0 =A0 =A0 struct list_head link;
> > +};
> =

> Some LinuxDoc documentation on the meaning of these structures would
> be helpful.  I'm not convinced that a two level lookup table is really
> necessary.  A flat table containing alias, device_node pointer, and
> possibly decoded devname and id is probably sufficient to get started.
>  Also, I think it will still be useful to store a pointer to the
> actual alias name in the alias_devid record.
> =

I thought two level lookup with driver probe function passing in
stem name will get the matching faster.  But I agree with you that
a flat table may be sufficient to get started, since practically
the alias number will not be that huge.

> > +
> > +static LIST_HEAD(aliases_lookup);
> > +
> > =A0struct device_node *allnodes;
> > =A0struct device_node *of_chosen;
> >
> > @@ -922,3 +937,170 @@ out_unlock:
> > =A0}
> > =A0#endif /* defined(CONFIG_OF_DYNAMIC) */
> >
> > +/*
> > + * get_alias_dev_name_id - Get device name and id from alias name
> > + *
> > + * an: The alias name passed in
> > + * dn: The pointer used to return device name
> =

> There is actually little point in decoding an alias to the device
> name.  It is more useful to decode alias to the device_node pointer
> which can be found with of_find_node_by_path().  I'd like to have a
> lookup table generated which contains {const char *alias_name,
> device_node *np} pairs.  It would also be useful for that table to
> decode the 'id' from the end of the alias name when available.  Then,
> given an alias stem and id (like imxuart and 2) the code could match
> it to alias imxuart0 and look up the device_node associated with (I
> could see this used by console setup code).  Alternately, driver probe

Yes, this is definitely one way to match.  But it's not as handy as
the alternate one below, in terms of migrating the current platform
drivers that use pdev->id everywhere to dt.  For the imx console
setup example, we can get the device_node by matching alias stem and
id, but we have to address the port we need with another two
contains_of(), device_node -> dev -> port.

> code could use its device_node pointer to lookup its alias, and if no
> alias exists, then use the table to find an unused id (and possibly
> even add an entry to the table when it allocates an id).
> =

And this is easier for the current platform drivers to migrate to
dt, so I would keep purchasing this one.

[...]
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int devid =3D get_alias_name_id(pp->name,=
 devname);
> > +
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We do not want to proceed this sentine=
l one */
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(pp->name, "name") && !strcmp(=
pp->value, "aliases"))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =

> Skipping the 'name' property is good, but I don't think you need to
> check the value.  You should also skip the "phandle" property.
> =

Ok. I have not seen "phandle" property in aliases node though.  Can
you give me an example, so that I can make one up for testing?

-- =

Regards,
Shawn
