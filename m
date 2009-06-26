From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/4] of/mdio: Add fixed link support
Date: Fri, 26 Jun 2009 17:33:26 -0600
Message-ID: <fa686aa40906261633y502f0ed2jebc58f9160c683ce@mail.gmail.com>
References: <20090626222900.GA14594@oksana.dev.rtsoft.ru>
	<20090626222945.GA32487@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090626222945.GA32487@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 26, 2009 at 4:29 PM, Anton
Vorontsov<avorontsov@ru.mvista.com> wrote:
> Currently the fixed link support is broken for all OF ethernet drivers,
> an "OF MDIO rework" removed most of the support. Instead of re-adding
> fixed-link stuff to the drivers, add the support to a framework, so we
> won't duplicate any code.
>
> With this patch, if a node pointer is NULL, then of_phy_connect() will
> try to find ethernet device's node, then will look for fixed-link
> property, and if specified, it connects PHY as usual, via bus_id (fixed
> link PHYs do not have any device tree nodes associated with them).
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Ugh.  I do not like this approach.  I did not intend to break fixed
links, but I do not think that this approach is the right fix.  There
are several problems.

I don't like the fixed.c approach of creating a dummy phy to begin
with.  I think it is an abuse of the device model to register a dummy
mii_bus and have dummy devices registered on it.  It is a lot of code
for what should be a very simple thing.  In particular, if a PHY is
not specified, then the driver should use a static link configuration.
 This is trivial to implement in an Ethernet driver and I do not think
the dummy phy adds anything.

It hooks into the initialization path of *all* OF enabled net drivers,
whether it wants it or not.  ie. The MPC5200 FEC driver does not want
it because the fixed-link property is not part of the mpc5200-fec
binding; it uses a current-speed property instead.  'fixed-link' has
not been agreed upon to be applicable to all Ethernet bindings, and
I'm not convinced that the format of it won't need to be changed for
future Ethernet bindings.  A function for parsing fixed-link should be
a library function that a driver can choose to call out to.  It should
not be welded into the init path.

I also think parsing the device tree at device open time (when
of_phy_connect is usually called) is best to be avoided.  fixed-link
parsing should really happen at probe time and the values cached IMHO.
 It's probably not significant, but I'd like to keep device tree reads
constrained in the cold path (driver probe time) as opposed to the hot
(or slightly less cool) device open path.

Instead, I think that each driver should be more graceful about
missing phy pointers and the init path should call out to a fixed-link
parser function that sets the initial link settings.  Probably less
than 5 lines of code per driver.

I'm sorry about breaking it.  It was my fault, and I'd be happy to fix
it if you'd like me to, but I don't think that this patch is the right
approach.

g.

> ---
> =A0drivers/of/of_mdio.c | =A0 45 ++++++++++++++++++++++++++++++++++++++++=
+----
> =A01 files changed, 41 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index aee967d..cfd876a 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -9,6 +9,10 @@
> =A0* out of the OpenFirmware device tree and using it to populate an mii_=
bus.
> =A0*/
>
> +#include <linux/kernel.h>
> +#include <linux/device.h>
> +#include <linux/netdevice.h>
> +#include <linux/err.h>
> =A0#include <linux/phy.h>
> =A0#include <linux/of.h>
> =A0#include <linux/of_mdio.h>
> @@ -129,11 +133,44 @@ struct phy_device *of_phy_connect(struct net_device=
 *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (=
*hndlr)(struct net_device *), u32 flags,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0phy_in=
terface_t iface)
> =A0{
> - =A0 =A0 =A0 struct phy_device *phy =3D of_phy_find_device(phy_np);
> + =A0 =A0 =A0 struct phy_device *phy =3D NULL;
> +
> + =A0 =A0 =A0 if (phy_np) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy =3D of_phy_find_device(phy_np);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!phy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D phy_connect_direct(dev, phy, hndlr,=
 flags, iface);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 } else if (dev->dev.parent) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_node *net_np;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 const u32 *phy_id;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 char *bus_id;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int sz;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 net_np =3D dev_archdata_get_node(&dev->dev.=
parent->archdata);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!net_np)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy_id =3D of_get_property(net_np, "fixed-l=
ink", &sz);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!phy_id || sz < sizeof(*phy_id))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bus_id =3D kasprintf(GFP_KERNEL, PHY_ID_FMT=
, "0", phy_id[0]);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!bus_id) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&dev->dev, "could n=
ot allocate memory\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 if (!phy)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 phy =3D phy_connect(dev, bus_id, hndlr, 0, =
iface);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(bus_id);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (IS_ERR(phy))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 return phy_connect_direct(dev, phy, hndlr, flags, iface) ? =
NULL : phy;
> + =A0 =A0 =A0 return phy;
> =A0}
> =A0EXPORT_SYMBOL(of_phy_connect);
> --
> 1.6.3.1
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
