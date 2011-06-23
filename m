From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Thu, 23 Jun 2011 17:11:54 -0600
Message-ID: <BANLkTi=8Mks6T85WnEyihmB21U1j7reHrQ@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org> <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net> <20110621135558.GB9228@S2101-09.ap.freescale.net>
 <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com> <20110623183821.GA19188@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: patches@linaro.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org,
	David Gibson <david@gibson.dropbear.id.au>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110623183821.GA19188@S2100-06.ap.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2011 at 12:38 PM, Shawn Guo <shawn.guo@freescale.com> w=
rote:
> On Tue, Jun 21, 2011 at 01:13:50PM -0600, Grant Likely wrote:
> [...]
>> >
>> > =A0/**
>> > + * =A0 =A0 of_get_device_index - Get device index by looking up "=
aliases" node
>> > + * =A0 =A0 @np: =A0 =A0Pointer to device node that asks for devic=
e index
>> > + * =A0 =A0 @name: =A0The device alias without index number
>> > + *
>> > + * =A0 =A0 Returns the device index if find it, else returns -ENO=
DEV.
>> > + */
>> > +int of_get_device_index(struct device_node *np, const char *alias=
)
>> > +{
>> > + =A0 =A0 =A0 struct device_node *aliases =3D of_find_node_by_name=
(NULL, "aliases");
>> > + =A0 =A0 =A0 struct property *prop;
>> > + =A0 =A0 =A0 char name[32];
>> > + =A0 =A0 =A0 int index =3D 0;
>> > +
>> > + =A0 =A0 =A0 if (!aliases)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> > +
>> > + =A0 =A0 =A0 while (1) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, sizeof(name), "%s%d",=
 alias, index);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_find_property(aliases, n=
ame, NULL);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!prop)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np =3D=3D of_find_node_by_path(p=
rop->value))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index++;
>> > + =A0 =A0 =A0 }
>>
>> Rather than parsing the alias strings everytime, it would probably b=
e
>> better to preprocess all the properties in the aliases node and crea=
te
>> a lookup table of alias->node references that can be walked quickly
>> and trivially.
>>
>> Also, when obtaining an enumeration for a device, you'll need to be
>> careful about what number gets returned. =A0If the node doesn't matc=
h a
>> given alias, but aliases do exist for other devices of like type, th=
en
>> you need to be careful not to assign a number already assigned to
>> another device via an alias (this of course assumes the driver
>> supports dynamics enumeration, which many drivers will). =A0It would=
 be
>>
>
> Grant, please take a look at the second shot below. =A0Please let me
> know what you think.

Hey Shawn, good progress.  Comments below.

Also, once you've got this sorted out, you'll need to break the
drivers/of/ bits out into a separate patch so I can apply it
separately.

g.

>
> diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/=
imx51-babbage.dts
> index 7976932..f4a5c3c 100644
> --- a/arch/arm/boot/dts/imx51-babbage.dts
> +++ b/arch/arm/boot/dts/imx51-babbage.dts
> @@ -18,6 +18,12 @@
> =A0 =A0 =A0 =A0compatible =3D "fsl,imx51-babbage", "fsl,imx51";
> =A0 =A0 =A0 =A0interrupt-parent =3D <&tzic>;
>
> + =A0 =A0 =A0 aliases {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial0 =3D &uart0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial1 =3D &uart1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 serial2 =3D &uart2;
> + =A0 =A0 =A0 };
> +
> =A0 =A0 =A0 =A0chosen {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bootargs =3D "console=3Dttymxc0,115200=
 root=3D/dev/mmcblk0p3 rootwait";
> =A0 =A0 =A0 =A0};
> @@ -47,29 +53,29 @@
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x70000000 0x=
40000>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ranges;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@7000c000 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compati=
ble =3D "fsl,imx51-uart", "fsl,imx-uart";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart2: uart@7000c000 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compati=
ble =3D "fsl,imx51-uart", "fsl,imx21-uart";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D=
 <0x7000c000 0x4000>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interr=
upts =3D <33>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D=
 <3>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fsl,ha=
s-rts-cts;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fbc000 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,imx=
51-uart", "fsl,imx-uart";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart0: uart@73fbc000 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,imx=
51-uart", "fsl,imx21-uart";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x73fbc000 0x=
4000>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D <31>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D <1>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fsl,has-rts-cts;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart@73fc0000 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,imx=
51-uart", "fsl,imx-uart";
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 uart1: uart@73fc0000 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "fsl,imx=
51-uart", "fsl,imx21-uart";
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0reg =3D <0x73fc0000 0x=
4000>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0interrupts =3D <32>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0id =3D <2>;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fsl,has-rts-cts;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0};
>
> diff --git a/arch/arm/mach-mx5/imx51-dt.c b/arch/arm/mach-mx5/imx51-d=
t.c
> index 8bfdb91..e6c7298 100644
> --- a/arch/arm/mach-mx5/imx51-dt.c
> +++ b/arch/arm/mach-mx5/imx51-dt.c
> @@ -40,6 +40,8 @@ static const struct of_device_id tzic_of_match[] __=
initconst =3D {
>
> =A0static void __init imx51_dt_init(void)
> =A0{
> + =A0 =A0 =A0 of_scan_aliases();
> +

Instead of calling this from board code.  You can add the call
directly to the bottom of unflatten_device_tree() in drivers/of/fdt.c

> =A0 =A0 =A0 =A0irq_domain_generate_simple(tzic_of_match, MX51_TZIC_BA=
SE_ADDR, 0);
>
> =A0 =A0 =A0 =A0of_platform_populate(NULL, of_default_bus_match_table,
> diff --git a/drivers/of/base.c b/drivers/of/base.c
> index 632ebae..90349a2 100644
> --- a/drivers/of/base.c
> +++ b/drivers/of/base.c
> @@ -17,12 +17,27 @@
> =A0* =A0 =A0 =A0as published by the Free Software Foundation; either =
version
> =A0* =A0 =A0 =A02 of the License, or (at your option) any later versi=
on.
> =A0*/
> +#include <linux/ctype.h>
> =A0#include <linux/module.h>
> =A0#include <linux/of.h>
> =A0#include <linux/spinlock.h>
> =A0#include <linux/slab.h>
> =A0#include <linux/proc_fs.h>
>
> +struct alias_devname {
> + =A0 =A0 =A0 char devname[32];
> + =A0 =A0 =A0 struct list_head link;
> + =A0 =A0 =A0 struct list_head head;
> +};
> +
> +struct alias_devid {
> + =A0 =A0 =A0 int devid;
> + =A0 =A0 =A0 struct device_node *node;
> + =A0 =A0 =A0 struct list_head link;
> +};

Some LinuxDoc documentation on the meaning of these structures would
be helpful.  I'm not convinced that a two level lookup table is really
necessary.  A flat table containing alias, device_node pointer, and
possibly decoded devname and id is probably sufficient to get started.
 Also, I think it will still be useful to store a pointer to the
actual alias name in the alias_devid record.

> +
> +static LIST_HEAD(aliases_lookup);
> +
> =A0struct device_node *allnodes;
> =A0struct device_node *of_chosen;
>
> @@ -922,3 +937,170 @@ out_unlock:
> =A0}
> =A0#endif /* defined(CONFIG_OF_DYNAMIC) */
>
> +/*
> + * get_alias_dev_name_id - Get device name and id from alias name
> + *
> + * an: The alias name passed in
> + * dn: The pointer used to return device name

There is actually little point in decoding an alias to the device
name.  It is more useful to decode alias to the device_node pointer
which can be found with of_find_node_by_path().  I'd like to have a
lookup table generated which contains {const char *alias_name,
device_node *np} pairs.  It would also be useful for that table to
decode the 'id' from the end of the alias name when available.  Then,
given an alias stem and id (like imxuart and 2) the code could match
it to alias imxuart0 and look up the device_node associated with (I
could see this used by console setup code).  Alternately, driver probe
code could use its device_node pointer to lookup its alias, and if no
alias exists, then use the table to find an unused id (and possibly
even add an entry to the table when it allocates an id).

> + *
> + * Returns device id which should be the number at the end of alias
> + * name, otherwise returns -1.
> + */
> +static int get_alias_name_id(char *an, char *dn)

Even private static functions should have a prefix consistent with the
file.  In this case, all the functions should probably be something in
the form "of_alias_*()"

> +{
> + =A0 =A0 =A0 int len =3D strlen(an);
> + =A0 =A0 =A0 char *end =3D an + len;
> +
> + =A0 =A0 =A0 while (isdigit(*--end))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len--;

Clever!  :-)

> +
> + =A0 =A0 =A0 end++;
> + =A0 =A0 =A0 strncpy(dn, an, len);
> + =A0 =A0 =A0 dn[len] =3D '\0';
> +
> + =A0 =A0 =A0 return strlen(end) ? simple_strtol(end, NULL, 10) : -1;

Just to be pendantic: simple_strtoul()  :-)

> +}
> +
> +/*
> + * get_an_available_devid - Get an available devid for the given dev=
name
> + *
> + * adn: =A0 =A0 =A0 =A0The pointer to the given alias_devname
> + *
> + * Returns the available devid
> + */
> +static int get_an_available_devid(struct alias_devname *adn)
> +{
> + =A0 =A0 =A0 int devid =3D 0;
> + =A0 =A0 =A0 struct alias_devid *adi;
> +
> + =A0 =A0 =A0 while (1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool used =3D false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry(adi, &adn->head, li=
nk) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (adi->devid =3D=3D d=
evid) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 used =3D=
 true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!used)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 devid++;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return devid;
> +}
> +
> +/*
> + * of_scan_aliases - Scan all properties of aliases node and populat=
e the
> + * =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global lookup table with the d=
evice name and id info
> + *
> + * Returns the number of aliases properties found, or error code in =
error case.
> + */

Use LinuxDoc format for documentation blocks.
Documentation/kernel-doc-nano-HOWTO.txt

> +int of_scan_aliases(void)
> +{
> + =A0 =A0 =A0 struct device_node *aliases =3D of_find_node_by_name(NU=
LL, "aliases");

Like the chosen node, it is useful to keep around a reference to the
aliases node.  There is other code that will use it that I hope to
merge soon.  You can add a global of_aliases pointer and initialized
it in unflatten_device_tree()

> + =A0 =A0 =A0 struct property *pp;
> + =A0 =A0 =A0 struct alias_devname *adn;
> + =A0 =A0 =A0 struct alias_devid *adi;
> + =A0 =A0 =A0 int ret =3D 0;
> +
> + =A0 =A0 =A0 if (!aliases) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;

The function hasn't done anything that needs unwinding yet. Just
return immediately.

> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 for (pp =3D aliases->properties; pp !=3D NULL; pp =3D p=
p->next) {

A "for_each_property()" macro would be useful to have and use here.
Can you add one to include/linux/of.h?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bool found =3D false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 char devname[32];

Rather than a static sized string, I'd like this to be the actual size
of the string.  You can do this by making the name the last element of
the list and giving it a [0] length.  Then when memory is kzalloced
for it, the size of the devname can be added to the end:

struct alias_devname {
 =A0 =A0 =A0 struct list_head link;
       const char *alias;
 =A0 =A0 =A0 struct device_node *node;
 =A0 =A0 =A0 int alias_id;
 =A0 =A0 =A0 char alias_stem[0];
};

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int devid =3D get_alias_name_id(pp->nam=
e, devname);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* We do not want to proceed this senti=
nel one */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(pp->name, "name") && !strcm=
p(pp->value, "aliases"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;

Skipping the 'name' property is good, but I don't think you need to
check the value.  You should also skip the "phandle" property.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* See if the devname already exists */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry(adn, &aliases_looku=
p, link) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(adn->devnam=
e, devname)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 found =3D=
 true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Create the entry for this devname =
if not found,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and add it into aliases_lookup
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!found) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 adn =3D kzalloc(sizeof(=
*adn), GFP_KERNEL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!adn) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D=
 -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ou=
t;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strcpy(adn->devname, de=
vname);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&adn->he=
ad);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&adn->lin=
k, &aliases_lookup);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Save the devid as one entry of the=
 list for this
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* specified devname
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adi =3D kzalloc(sizeof(*adi), GFP_KERNE=
L);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!adi) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adi->devid =3D (devid =3D=3D -1) ? get_=
an_available_devid(adn) :
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0devid;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 adi->node =3D of_find_node_by_path(pp->=
value);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add_tail(&adi->link, &adn->head);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret++;

Going to a single level lookup table will certainly simplify this funct=
ion.

> + =A0 =A0 =A0 }
> +
> +out:
> + =A0 =A0 =A0 return ret;
> +}
> +
> +/**
> + * =A0 =A0 of_get_device_id - Get device id by looking up "aliases" =
node
> + * =A0 =A0 @np: =A0 =A0Pointer to device node that asks for device i=
d
> + * =A0 =A0 @name: =A0The device alias name
> + *
> + * =A0 =A0 Returns the device id if find it, else returns -ENODEV.
> + */
> +int of_get_device_id(struct device_node *np, const char *name)
> +{
> + =A0 =A0 =A0 struct alias_devname *adn;
> + =A0 =A0 =A0 struct alias_devid *adi;
> + =A0 =A0 =A0 bool found =3D false;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 list_for_each_entry(adn, &aliases_lookup, link) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(adn->devname, name)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 found =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!found) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D -ENODEV;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 found =3D false;
> + =A0 =A0 =A0 list_for_each_entry(adi, &adn->head, link) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np =3D=3D adi->node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 found =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 ret =3D found ? adi->devid : -ENODEV;
> +out:
> + =A0 =A0 =A0 return ret;
> +}
> +EXPORT_SYMBOL(of_get_device_id);
> diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
> index 2769353..062639e 100644
> --- a/drivers/tty/serial/imx.c
> +++ b/drivers/tty/serial/imx.c
> @@ -1225,43 +1265,33 @@ static int serial_imx_resume(struct platform_=
device *dev)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> =A0static int serial_imx_probe_dt(struct imx_port *sport,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct platform_device *pdev)
> =A0{
> =A0 =A0 =A0 =A0struct device_node *node =3D pdev->dev.of_node;
> - =A0 =A0 =A0 const __be32 *line;
> + =A0 =A0 =A0 int line;
>
> =A0 =A0 =A0 =A0if (!node)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>
> - =A0 =A0 =A0 line =3D of_get_property(node, "id", NULL);
> - =A0 =A0 =A0 if (!line)
> + =A0 =A0 =A0 line =3D of_get_device_id(node, "serial");
> + =A0 =A0 =A0 if (IS_ERR_VALUE(line))

if (line < 0) is a sufficient test.  I don't much like the IS_ERR_VALUE=
() macro.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -ENODEV;
>
> - =A0 =A0 =A0 sport->port.line =3D be32_to_cpup(line) - 1;
> + =A0 =A0 =A0 sport->port.line =3D line;
>
> diff --git a/include/linux/of.h b/include/linux/of.h
> index bfc0ed1..270c671 100644
> --- a/include/linux/of.h
> +++ b/include/linux/of.h
> @@ -213,6 +213,9 @@ extern int of_parse_phandles_with_args(struct dev=
ice_node *np,
> =A0 =A0 =A0 =A0const char *list_name, const char *cells_name, int ind=
ex,
> =A0 =A0 =A0 =A0struct device_node **out_node, const void **out_args);
>
> +extern int of_scan_aliases(void);
> +extern int of_get_device_id(struct device_node *np, const char *name=
);
> +
> =A0extern int of_machine_is_compatible(const char *compat);
>
> =A0extern int prom_add_property(struct device_node* np, struct proper=
ty* prop);
>
> --
> Regards,
> Shawn
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
