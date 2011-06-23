From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Fri, 24 Jun 2011 02:38:23 +0800
Message-ID: <20110623183821.GA19188@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
 <20110618161934.GH8195@ponder.secretlab.ca>
 <20110619073000.GA23171@S2100-06.ap.freescale.net>
 <20110621135558.GB9228@S2101-09.ap.freescale.net>
 <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <patches@linaro.org>, <netdev@vger.kernel.org>,
	<devicetree-discuss@lists.ozlabs.org>,
	Jason Liu <jason.hui@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	<linux-arm-kernel@lists.infradead.org>,
	David Gibson <david@gibson.dropbear.id.au>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTim4vunTm1176MRw3pqRZnunu4=9jg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 21, 2011 at 01:13:50PM -0600, Grant Likely wrote:
[...]
> >
> > =A0/**
> > + * =A0 =A0 of_get_device_index - Get device index by looking up "a=
liases" node
> > + * =A0 =A0 @np: =A0 =A0Pointer to device node that asks for device=
 index
> > + * =A0 =A0 @name: =A0The device alias without index number
> > + *
> > + * =A0 =A0 Returns the device index if find it, else returns -ENOD=
EV.
> > + */
> > +int of_get_device_index(struct device_node *np, const char *alias)
> > +{
> > + =A0 =A0 =A0 struct device_node *aliases =3D of_find_node_by_name(=
NULL, "aliases");
> > + =A0 =A0 =A0 struct property *prop;
> > + =A0 =A0 =A0 char name[32];
> > + =A0 =A0 =A0 int index =3D 0;
> > +
> > + =A0 =A0 =A0 if (!aliases)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> > +
> > + =A0 =A0 =A0 while (1) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 snprintf(name, sizeof(name), "%s%d", =
alias, index);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 prop =3D of_find_property(aliases, na=
me, NULL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!prop)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENODEV;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np =3D=3D of_find_node_by_path(pr=
op->value))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 index++;
> > + =A0 =A0 =A0 }
>=20
> Rather than parsing the alias strings everytime, it would probably be
> better to preprocess all the properties in the aliases node and creat=
e
> a lookup table of alias->node references that can be walked quickly
> and trivially.
>=20
> Also, when obtaining an enumeration for a device, you'll need to be
> careful about what number gets returned.  If the node doesn't match a
> given alias, but aliases do exist for other devices of like type, the=
n
> you need to be careful not to assign a number already assigned to
> another device via an alias (this of course assumes the driver
> supports dynamics enumeration, which many drivers will).  It would be
>=20

Grant, please take a look at the second shot below.  Please let me
know what you think.

diff --git a/arch/arm/boot/dts/imx51-babbage.dts b/arch/arm/boot/dts/im=
x51-babbage.dts
index 7976932..f4a5c3c 100644
--- a/arch/arm/boot/dts/imx51-babbage.dts
+++ b/arch/arm/boot/dts/imx51-babbage.dts
@@ -18,6 +18,12 @@
 	compatible =3D "fsl,imx51-babbage", "fsl,imx51";
 	interrupt-parent =3D <&tzic>;
=20
+	aliases {
+		serial0 =3D &uart0;
+		serial1 =3D &uart1;
+		serial2 =3D &uart2;
+	};
+
 	chosen {
 		bootargs =3D "console=3Dttymxc0,115200 root=3D/dev/mmcblk0p3 rootwai=
t";
 	};
@@ -47,29 +53,29 @@
 			reg =3D <0x70000000 0x40000>;
 			ranges;
=20
-			uart@7000c000 {
-				compatible =3D "fsl,imx51-uart", "fsl,imx-uart";
+			uart2: uart@7000c000 {
+				compatible =3D "fsl,imx51-uart", "fsl,imx21-uart";
 				reg =3D <0x7000c000 0x4000>;
 				interrupts =3D <33>;
 				id =3D <3>;
				fsl,has-rts-cts;
 			};
 		};
=20
-		uart@73fbc000 {
-			compatible =3D "fsl,imx51-uart", "fsl,imx-uart";
+		uart0: uart@73fbc000 {
+			compatible =3D "fsl,imx51-uart", "fsl,imx21-uart";
 			reg =3D <0x73fbc000 0x4000>;
 			interrupts =3D <31>;
 			id =3D <1>;
			fsl,has-rts-cts;
 		};
=20
-		uart@73fc0000 {
-			compatible =3D "fsl,imx51-uart", "fsl,imx-uart";
+		uart1: uart@73fc0000 {
+			compatible =3D "fsl,imx51-uart", "fsl,imx21-uart";
 			reg =3D <0x73fc0000 0x4000>;
 			interrupts =3D <32>;
 			id =3D <2>;
			fsl,has-rts-cts;
 		};
 	};
=20
diff --git a/arch/arm/mach-mx5/imx51-dt.c b/arch/arm/mach-mx5/imx51-dt.=
c
index 8bfdb91..e6c7298 100644
--- a/arch/arm/mach-mx5/imx51-dt.c
+++ b/arch/arm/mach-mx5/imx51-dt.c
@@ -40,6 +40,8 @@ static const struct of_device_id tzic_of_match[] __in=
itconst =3D {
=20
 static void __init imx51_dt_init(void)
 {
+	of_scan_aliases();
+
 	irq_domain_generate_simple(tzic_of_match, MX51_TZIC_BASE_ADDR, 0);
=20
 	of_platform_populate(NULL, of_default_bus_match_table,
diff --git a/drivers/of/base.c b/drivers/of/base.c
index 632ebae..90349a2 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -17,12 +17,27 @@
  *      as published by the Free Software Foundation; either version
  *      2 of the License, or (at your option) any later version.
  */
+#include <linux/ctype.h>
 #include <linux/module.h>
 #include <linux/of.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
 #include <linux/proc_fs.h>
=20
+struct alias_devname {
+	char devname[32];
+	struct list_head link;
+	struct list_head head;
+};
+
+struct alias_devid {
+	int devid;
+	struct device_node *node;
+	struct list_head link;
+};
+
+static LIST_HEAD(aliases_lookup);
+
 struct device_node *allnodes;
 struct device_node *of_chosen;
=20
@@ -922,3 +937,170 @@ out_unlock:
 }
 #endif /* defined(CONFIG_OF_DYNAMIC) */
=20
+/*
+ * get_alias_dev_name_id - Get device name and id from alias name
+ *
+ * an:	The alias name passed in
+ * dn:	The pointer used to return device name
+ *
+ * Returns device id which should be the number at the end of alias
+ * name, otherwise returns -1.
+ */
+static int get_alias_name_id(char *an, char *dn)
+{
+	int len =3D strlen(an);
+	char *end =3D an + len;
+
+	while (isdigit(*--end))
+		len--;
+
+	end++;
+	strncpy(dn, an, len);
+	dn[len] =3D '\0';
+
+	return strlen(end) ? simple_strtol(end, NULL, 10) : -1;
+}
+
+/*
+ * get_an_available_devid - Get an available devid for the given devna=
me
+ *
+ * adn:	The pointer to the given alias_devname
+ *
+ * Returns the available devid
+ */
+static int get_an_available_devid(struct alias_devname *adn)
+{
+	int devid =3D 0;
+	struct alias_devid *adi;
+
+	while (1) {
+		bool used =3D false;
+		list_for_each_entry(adi, &adn->head, link) {
+			if (adi->devid =3D=3D devid) {
+				used =3D true;
+				break;
+			}
+		}
+
+		if (!used)
+			break;
+
+		devid++;
+	}
+
+	return devid;
+}
+
+/*
+ * of_scan_aliases - Scan all properties of aliases node and populate =
the
+ * 		     global lookup table with the device name and id info
+ *
+ * Returns the number of aliases properties found, or error code in er=
ror case.
+ */
+int of_scan_aliases(void)
+{
+	struct device_node *aliases =3D of_find_node_by_name(NULL, "aliases")=
;
+	struct property *pp;
+	struct alias_devname *adn;
+	struct alias_devid *adi;
+	int ret =3D 0;
+
+	if (!aliases) {
+		ret =3D -ENODEV;
+		goto out;
+	}
+
+	for (pp =3D aliases->properties; pp !=3D NULL; pp =3D pp->next) {
+		bool found =3D false;
+		char devname[32];
+		int devid =3D get_alias_name_id(pp->name, devname);
+
+		/* We do not want to proceed this sentinel one */
+		if (!strcmp(pp->name, "name") && !strcmp(pp->value, "aliases"))
+			break;
+
+		/* See if the devname already exists */
+		list_for_each_entry(adn, &aliases_lookup, link) {
+			if (!strcmp(adn->devname, devname)) {
+				found =3D true;
+				break;
+			}
+		}
+
+		/*
+		 * Create the entry for this devname if not found,
+		 * and add it into aliases_lookup
+		 */
+		if (!found) {
+			adn =3D kzalloc(sizeof(*adn), GFP_KERNEL);
+			if (!adn) {
+				ret =3D -ENOMEM;
+				goto out;
+			}
+
+			strcpy(adn->devname, devname);
+			INIT_LIST_HEAD(&adn->head);
+			list_add_tail(&adn->link, &aliases_lookup);
+		}
+
+		/*
+		 * Save the devid as one entry of the list for this
+		 * specified devname
+		 */
+		adi =3D kzalloc(sizeof(*adi), GFP_KERNEL);
+		if (!adi) {
+			ret =3D -ENOMEM;
+			goto out;
+		}
+
+		adi->devid =3D (devid =3D=3D -1) ? get_an_available_devid(adn) :
+					     devid;
+		adi->node =3D of_find_node_by_path(pp->value);
+
+		list_add_tail(&adi->link, &adn->head);
+		ret++;
+	}
+
+out:
+	return ret;
+}
+
+/**
+ *	of_get_device_id - Get device id by looking up "aliases" node
+ *	@np:	Pointer to device node that asks for device id
+ *	@name:	The device alias name
+ *
+ *	Returns the device id if find it, else returns -ENODEV.
+ */
+int of_get_device_id(struct device_node *np, const char *name)
+{
+	struct alias_devname *adn;
+	struct alias_devid *adi;
+	bool found =3D false;
+	int ret;
+
+	list_for_each_entry(adn, &aliases_lookup, link) {
+		if (!strcmp(adn->devname, name)) {
+			found =3D true;
+			break;
+		}
+	}
+
+	if (!found) {
+		ret =3D -ENODEV;
+		goto out;
+	}
+
+	found =3D false;
+	list_for_each_entry(adi, &adn->head, link) {
+		if (np =3D=3D adi->node) {
+			found =3D true;
+			break;
+		}
+	}
+
+	ret =3D found ? adi->devid : -ENODEV;
+out:
+	return ret;
+}
+EXPORT_SYMBOL(of_get_device_id);
diff --git a/drivers/tty/serial/imx.c b/drivers/tty/serial/imx.c
index 2769353..062639e 100644
--- a/drivers/tty/serial/imx.c
+++ b/drivers/tty/serial/imx.c
@@ -1225,43 +1265,33 @@ static int serial_imx_resume(struct platform_de=
vice *dev)
 	return 0;
 }
=20
 static int serial_imx_probe_dt(struct imx_port *sport,
 		struct platform_device *pdev)
 {
 	struct device_node *node =3D pdev->dev.of_node;
-	const __be32 *line;
+	int line;
=20
 	if (!node)
 		return -ENODEV;
=20
-	line =3D of_get_property(node, "id", NULL);
-	if (!line)
+	line =3D of_get_device_id(node, "serial");
+	if (IS_ERR_VALUE(line))
 		return -ENODEV;
=20
-	sport->port.line =3D be32_to_cpup(line) - 1;
+	sport->port.line =3D line;
=20
diff --git a/include/linux/of.h b/include/linux/of.h
index bfc0ed1..270c671 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -213,6 +213,9 @@ extern int of_parse_phandles_with_args(struct devic=
e_node *np,
 	const char *list_name, const char *cells_name, int index,
 	struct device_node **out_node, const void **out_args);
=20
+extern int of_scan_aliases(void);
+extern int of_get_device_id(struct device_node *np, const char *name);
+
 extern int of_machine_is_compatible(const char *compat);
=20
 extern int prom_add_property(struct device_node* np, struct property* =
prop);

--=20
Regards,
Shawn
