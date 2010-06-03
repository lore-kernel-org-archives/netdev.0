From: Narendra K <Narendra_K@dell.com>
Subject: Re: [PATCH V2 1/2] Export firmware assigned labels of network devices to sysfs
Date: Thu, 3 Jun 2010 16:07:15 -0500
Message-ID: <20100603210715.GA18025@auslistsprd01.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE6128E1@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com
To: greg@kroah.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE6128E1@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:greg@kroah.com]=20
> Sent: Friday, May 28, 2010 9:11 PM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; linux-hotplug@vger.kernel.org;
> linux-pci@vger.kernel.org; Domsch, Matt; Hargrave, Jordan; Rose,
> Charles; Nijhawan, Vijay
> Subject: Re: [PATCH 1/2] Export firmware assigned labels of network
> devices to sysfs
>=20
Thanks for the comments.

> On Fri, May 28, 2010 at 06:55:21AM -0500, K, Narendra wrote:
> > Please refer to the PCI-SIG Draft ECN
> > "PCIe Device Labeling under Operating Systems Draft ECN" at this li=
nk
> -
> > http://www.pcisig.com/specifications/pciexpress/review_zone/.
> >=20
> > It would be great to know your views on this ECN. Please let us kno=
w
> if you have
> > have any suggestions or changes.
>=20
> Note that only members of the PCI-SIG can do this, which pretty much
> rules out any "normal" Linux kernel developer :(
>=20
> Care to post a public version of this for us to review?
> > --- /dev/null
> > +++ b/drivers/pci/pci-label.c
> > @@ -0,0 +1,242 @@
> > +/*
> > + * File:       drivers/pci/pci-label.c
>=20
> This line is not needed, we know the file name :)
>=20
> > + * Purpose:    Export the firmware label associated with a pci
> network interface
> > + * device to sysfs
> > + * Copyright (C) 2010 Dell Inc.
> > + * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave
> <Jordan_Hargrave@dell.com>
> > + *
> > + * This code checks if the pci network device has a related ACPI
> _DSM. If
> > + * available, the code calls the _DSM to retrieve the index and
> string and
> > + * exports them to sysfs. If the ACPI _DSM is not available, it fa=
lls
> back on
> > + * SMBIOS. SMBIOS defines type 41 for onboard pci devices. This co=
de
> retrieves
> > + * strings associated with the type 41 and exports it to sysfs.
> > + *
> > + * Please see http://linux.dell.com/wiki/index.php/Oss/libnetdevna=
me
> for more
> > + * information.
> > + */
> > +
> > +#include <linux/pci-label.h>
>=20
> Why is this file in include/linux/ ?  Who needs it there?  Can't it j=
ust
> be in in the drivers/pci/ directory?  Actually all you need is 2
> functions in there, so it could go into the internal pci.h file in th=
at
> directory without a problem, right?
>=20

This file is removed and functions are moved to the internal pci.h

> > +
> > +static ssize_t
> > +smbiosname_string_exists(struct device *dev, char *buf)
> > +{
> > +       struct pci_dev *pdev =3D to_pci_dev(dev);
> > +       const struct dmi_device *dmi;
> > +       struct dmi_devslot *dslot;
> > +       int bus;
> > +       int devfn;
> > +
> > +       bus =3D pdev->bus->number;
> > +       devfn =3D pdev->devfn;
> > +
> > +       dmi =3D NULL;
> > +       while ((dmi =3D dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL,
> dmi)) !=3D NULL) {
> > +               dslot =3D dmi->device_data;
> > +               if (dslot && dslot->bus =3D=3D bus && dslot->devfn =
=3D=3D
> devfn) {
> > +                       if (buf)
> > +                               return scnprintf(buf, PAGE_SIZE,
> "%s\n", dmi->name);
> > +                       return strlen(dmi->name);
> > +               }
> > +       }
> > +
> > +       return 0;
> > +}
> > +
> > +static ssize_t
> > +smbiosname_show(struct device *dev, struct device_attribute *attr,
> char *buf)
> > +{
> > +       return smbiosname_string_exists(dev, buf);
> > +}
> > +
> > +struct smbios_attribute smbios_attr_label =3D {
> > +       .attr =3D {.name =3D __stringify(label), .mode =3D 0444, .o=
wner =3D
> THIS_MODULE},
>=20
> Can't you just put "label" as the name?
>=20

This is fixed.

> > +       .show =3D smbiosname_show,
> > +       .test =3D smbiosname_string_exists,
> > +};
> > +
> > +static int
> > +pci_create_smbiosname_file(struct pci_dev *pdev)
> > +{
> > +       if (smbios_attr_label.test &&
> smbios_attr_label.test(&pdev->dev, NULL)) {
> > +               sysfs_create_file(&pdev->dev.kobj,
> &smbios_attr_label.attr);
> > +               return 0;
> > +       }
> > +       return -1;
> > +}
> > +
> > +static int
> > +pci_remove_smbiosname_file(struct pci_dev *pdev)
> > +{
> > +       if (smbios_attr_label.test &&
> smbios_attr_label.test(&pdev->dev, NULL)) {
> > +               sysfs_remove_file(&pdev->dev.kobj,
> &smbios_attr_label.attr);
> > +               return 0;
> > +       }
> > +       return -1;
> > +}
> > +
> > +static const char dell_dsm_uuid[] =3D {
>=20
> Um, a dell specific uuid in a generic file?  What happens when we nee=
d
> to support another manufacturer?
>=20

My understanding of uuid was incorrect. I have renamed it to a more gen=
eric
device_label_dsm_uuid and ACPI_DSM_FUNCTION to DEVICE_LABEL_DSM

> > +       0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
> > +       0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
> > +};
> > +
> > +
> > +static int
> > +dsm_get_label(acpi_handle handle, int func,
> > +              struct acpi_buffer *output,
> > +              char *buf, char *attribute)
> > +{
> > +       struct acpi_object_list input;
> > +       union acpi_object params[4];
> > +       union acpi_object *obj;
> > +       int len =3D 0;
> > +
> > +       int err;
> > +
> > +       input.count =3D 4;
> > +       input.pointer =3D params;
> > +       params[0].type =3D ACPI_TYPE_BUFFER;
> > +       params[0].buffer.length =3D sizeof(dell_dsm_uuid);
> > +       params[0].buffer.pointer =3D (char *)dell_dsm_uuid;
> > +       params[1].type =3D ACPI_TYPE_INTEGER;
> > +       params[1].integer.value =3D 0x02;
> > +       params[2].type =3D ACPI_TYPE_INTEGER;
> > +       params[2].integer.value =3D func;
> > +       params[3].type =3D ACPI_TYPE_PACKAGE;
> > +       params[3].package.count =3D 0;
> > +       params[3].package.elements =3D NULL;
> > +
> > +       err =3D acpi_evaluate_object(handle, "_DSM", &input, output=
);
> > +       if (err) {
> > +               printk(KERN_INFO "failed to evaulate _DSM\n");
> > +               return -1;
> > +       }
> > +
> > +       obj =3D (union acpi_object *)output->pointer;
> > +
> > +       switch (obj->type) {
> > +       case ACPI_TYPE_PACKAGE:
> > +               if (obj->package.count =3D=3D 2) {
> > +                       len =3D obj->package.elements[0].integer.va=
lue;
> > +                       if (buf) {
> > +                               if (!strncmp(attribute, "index",
> strlen(attribute)))
> > +                                       scnprintf(buf, PAGE_SIZE,
> "%lu\n",
> > +
> obj->package.elements[0].integer.value);
> > +                               else
> > +                                       scnprintf(buf, PAGE_SIZE,
> "%s\n",
> > +
> obj->package.elements[1].string.pointer);
> > +                               kfree(output->pointer);
> > +                               return strlen(buf);
> > +                       }
> > +               }
> > +               kfree(output->pointer);
> > +               return len;
> > +       break;
> > +       default:
> > +               return -1;
> > +       }
> > +}
> > +
> > +static ssize_t
> > +acpi_index_string_exist(struct device *dev, char *buf, char
> *attribute)
> > +{
> > +       struct pci_dev *pdev =3D to_pci_dev(dev);
> > +
> > +       struct acpi_buffer output =3D {ACPI_ALLOCATE_BUFFER, NULL};
> > +       acpi_handle handle;
> > +       int length;
> > +       int is_addin_card =3D 0;
> > +
> > +       if ((pdev->class >> 16) !=3D PCI_BASE_CLASS_NETWORK)
> > +               return -1;
> > +
> > +       handle =3D DEVICE_ACPI_HANDLE(dev);
> > +
> > +       if (!handle) {
> > +               /*
> > +                * The device is an add-in network controller and d=
oes
> have
> > +                * a valid handle. Try until we get the handle for =
the
> parent
> > +                * bridge
> > +                */
> > +               struct pci_bus *pbus;
> > +               for (pbus =3D pdev->bus; pbus; pbus =3D pbus->paren=
t) {
> > +                       handle =3D
> DEVICE_ACPI_HANDLE(&(pbus->self->dev));
> > +                       if (handle)
> > +                               break;
> > +
> > +               }
> > +       }
> > +
> > +       if ((length =3D dsm_get_label(handle, DELL_DSM_NETWORK,
> > +                                   &output, buf, attribute)) < 0)
> > +               return -1;
> > +
> > +       return length;
> > +}
> > +
> > +static ssize_t
> > +acpilabel_show(struct device *dev, struct device_attribute *attr,
> char *buf)
> > +{
> > +       return acpi_index_string_exist(dev, buf, "label");
> > +}
> > +
> > +static ssize_t
> > +acpiindex_show(struct device *dev, struct device_attribute *attr,
> char *buf)
> > +{
> > +       return acpi_index_string_exist(dev, buf, "index");
> > +}
> > +
> > +struct acpi_attribute acpi_attr_label =3D {
> > +       .attr =3D {.name =3D __stringify(label), .mode =3D 0444, .o=
wner =3D
> THIS_MODULE},
> > +       .show =3D acpilabel_show,
> > +       .test =3D acpi_index_string_exist,
> > +};
> > +
> > +struct acpi_attribute acpi_attr_index =3D {
> > +       .attr =3D {.name =3D __stringify(index), .mode =3D 0444, .o=
wner =3D
> THIS_MODULE},
> > +       .show =3D acpiindex_show,
> > +       .test =3D acpi_index_string_exist,
> > +};
> > +
> > +static int
> > +pci_create_acpi_index_label_files(struct pci_dev *pdev)
> > +{
> > +       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev=
,
> NULL) > 0) {
> > +               sysfs_create_file(&pdev->dev.kobj,
> &acpi_attr_label.attr);
> > +               sysfs_create_file(&pdev->dev.kobj,
> &acpi_attr_index.attr);
> > +               return 0;
> > +       }
> > +       return -1;
> > +}
> > +
> > +static int
> > +pci_remove_acpi_index_label_files(struct pci_dev *pdev)
> > +{
> > +       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev=
,
> NULL) > 0) {
> > +               sysfs_remove_file(&pdev->dev.kobj,
> &acpi_attr_label.attr);
> > +               sysfs_remove_file(&pdev->dev.kobj,
> &acpi_attr_index.attr);
> > +               return 0;
> > +       }
> > +       return -1;
> > +}
> > +
> > +int pci_create_acpi_attr_files(struct pci_dev *pdev)
> > +{
> > +       if (!pci_create_acpi_index_label_files(pdev))
> > +               return 0;
> > +       if (!pci_create_smbiosname_file(pdev))
> > +               return 0;
> > +       return -ENODEV;
> > +}
> > +EXPORT_SYMBOL(pci_create_acpi_attr_files);
>=20
> EXPORT_SYMBOL_GPL?
>=20
> Wait, why does this need to be exported at all?  What module is ever
> going to call this function?
>=20
> > +int pci_remove_acpi_attr_files(struct pci_dev *pdev)
> > +{
> > +       if (!pci_remove_acpi_index_label_files(pdev))
> > +               return 0;
> > +       if (!pci_remove_smbiosname_file(pdev))
> > +               return 0;
> > +       return -ENODEV;
> > +
> > +}
> > +EXPORT_SYMBOL(pci_remove_acpi_attr_files);
>=20
> Same here, what module will call this?
>=20

These functions need not be exported as they are not called by any modu=
le.

> > +++ b/include/linux/pci-label.h
>=20
> As discussed above, this whole file does not need to exist.
>=20
> > +extern int pci_create_acpi_attr_files(struct pci_dev *pdev);
> > +extern int pci_remove_acpi_attr_files(struct pci_dev *pdev);
>=20
> Just put these two functions in the drivers/pci/pci.h file.
>=20
=46ixed.

In addition to these changes there are a coulple of changes i have done=
 -

1.Removed the check for network devices and evaulate _DSM for any pci d=
evice
that has _DSM defined in adherence to the spec.

2.Renamed the functions pci_create,remove-acpi_attr_files to=20
pci_create,remove_firmware_label_files.

3.Added checks for conditional compilation of if CONFIG_ACPI || CONFIG_=
DMI

Note: While testing the patch with CONFIG_ACPI set to no, the compilati=
on
would fail with the below message.

  CC      drivers/pci/pci-label.o
In file included from drivers/pci/pci-label.c:24:
include/linux/pci-acpi.h:39: error: expected =E2=80=98=3D=E2=80=99, =E2=
=80=98,=E2=80=99, =E2=80=98;=E2=80=99, =E2=80=98asm=E2=80=99 or =E2=80=98=
__attribute__=E2=80=99=20
before =E2=80=98acpi_find_root_bridge_handle=E2=80=99

I had to add make this change to proceed with the compilation. It would=
 be
great to know if i am missing something in the way conditional compilat=
ion
is implemented or is it a issue.

---
 include/linux/pci-acpi.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/pci-acpi.h b/include/linux/pci-acpi.h
index c8b6473..bc40827 100644
--- a/include/linux/pci-acpi.h
+++ b/include/linux/pci-acpi.h
@@ -36,8 +36,8 @@ static inline acpi_handle acpi_pci_get_bridge_handle(=
struct pci_bus *pbus)
 					      pbus->number);
 }
 #else
-static inline acpi_handle acpi_find_root_bridge_handle(struct pci_dev =
*pdev)
-{ return NULL; }
+static inline void acpi_find_root_bridge_handle(struct pci_dev *pdev)
+{ }
 #endif
=20
 #endif	/* _PCI_ACPI_H_ */


Please find the patch with above suggestions and changes -


=46rom: Narendra K <narendra_k@dell.com>
Subject: [PATCH V2 1/2] Export firmware assigned labels of pci devices =
to sysfs

This patch exports the firmware assigned labels of pci devices to
sysfs which could be used by user space.

Signed-off-by: Jordan Hargrave <jordan_hargrave@dell.com>
Signed-off-by: Narendra K <narendra_k@dell.com>
---
 drivers/firmware/dmi_scan.c |   24 ++++
 drivers/pci/Makefile        |    2 +-
 drivers/pci/pci-label.c     |  273 +++++++++++++++++++++++++++++++++++=
++++++++
 drivers/pci/pci-sysfs.c     |    5 +
 drivers/pci/pci.h           |    2 +
 include/linux/dmi.h         |    9 ++
 6 files changed, 314 insertions(+), 1 deletions(-)
 create mode 100644 drivers/pci/pci-label.c

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index d464672..7d8439b 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -277,6 +277,28 @@ static void __init dmi_save_ipmi_device(const stru=
ct dmi_header *dm)
 	list_add_tail(&dev->list, &dmi_devices);
 }
=20
+static void __init dmi_save_devslot(int id, int seg, int bus, int devf=
n, const char *name)
+{
+	struct dmi_devslot *slot;
+
+	slot =3D dmi_alloc(sizeof(*slot) + strlen(name) + 1);
+	if (!slot) {
+		printk(KERN_ERR "dmi_save_devslot: out of memory.\n");
+		return;
+	}=09
+	slot->id =3D id;
+	slot->seg =3D seg;
+	slot->bus =3D bus;
+	slot->devfn =3D devfn;
+
+	strcpy((char *)&slot[1], name);
+	slot->dev.type =3D DMI_DEV_TYPE_DEVSLOT;
+	slot->dev.name =3D (char *)&slot[1];
+	slot->dev.device_data =3D slot;
+
+	list_add(&slot->dev.list, &dmi_devices);
+}
+
 static void __init dmi_save_extended_devices(const struct dmi_header *=
dm)
 {
 	const u8 *d =3D (u8*) dm + 5;
@@ -285,6 +307,7 @@ static void __init dmi_save_extended_devices(const =
struct dmi_header *dm)
 	if ((*d & 0x80) =3D=3D 0)
 		return;
=20
+	dmi_save_devslot(-1, *(u16 *)(d+2), *(d+4), *(d+5), dmi_string_nosave=
(dm, *(d-1)));
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
=20
@@ -333,6 +356,7 @@ static void __init dmi_decode(const struct dmi_head=
er *dm, void *dummy)
 		break;
 	case 41:	/* Onboard Devices Extended Information */
 		dmi_save_extended_devices(dm);
+		break;
 	}
 }
=20
diff --git a/drivers/pci/Makefile b/drivers/pci/Makefile
index 0b51857..69c503a 100644
--- a/drivers/pci/Makefile
+++ b/drivers/pci/Makefile
@@ -4,7 +4,7 @@
=20
 obj-y		+=3D access.o bus.o probe.o remove.o pci.o \
 			pci-driver.o search.o pci-sysfs.o rom.o setup-res.o \
-			irq.o vpd.o
+			irq.o vpd.o pci-label.o
 obj-$(CONFIG_PROC_FS) +=3D proc.o
 obj-$(CONFIG_SYSFS) +=3D slot.o
=20
diff --git a/drivers/pci/pci-label.c b/drivers/pci/pci-label.c
new file mode 100644
index 0000000..b35d48c
--- /dev/null
+++ b/drivers/pci/pci-label.c
@@ -0,0 +1,273 @@
+/*
+ * Purpose: Export the firmware label associated with a pci network in=
terface
+ * device to sysfs
+ * Copyright (C) 2010 Dell Inc.
+ * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargra=
ve@dell.com>
+ *
+ * This code checks if the pci network device has a related ACPI _DSM.=
 If
+ * available, the code calls the _DSM to retrieve the index and string=
 and
+ * exports them to sysfs. If the ACPI _DSM is not available, it falls =
back on
+ * SMBIOS. SMBIOS defines type 41 for onboard pci devices. This code r=
etrieves
+ * strings associated with the type 41 and exports it to sysfs.
+ *
+ * Please see http://linux.dell.com/wiki/index.php/Oss/libnetdevname f=
or more
+ * information.
+ */
+
+#include <linux/dmi.h>
+#include <linux/sysfs.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
+#include <linux/module.h>
+#include <linux/acpi.h>
+#include <linux/pci-acpi.h>
+#include <acpi/acpi_drivers.h>
+#include <acpi/acpi_bus.h>
+#include "pci.h"
+
+#define	DEVICE_LABEL_DSM	0x07
+
+#if defined CONFIG_DMI
+
+struct smbios_attribute {
+	struct attribute attr;
+	ssize_t (*show) (struct device *dev, char *buf);
+	ssize_t (*test) (struct device *dev, char *buf);
+};
+
+static ssize_t
+smbiosname_string_exists(struct device *dev, char *buf)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+  	const struct dmi_device *dmi;
+  	struct dmi_devslot *dslot;
+  	int bus;
+  	int devfn;
+
+  	bus =3D pdev->bus->number;
+  	devfn =3D pdev->devfn;
+
+  	dmi =3D NULL;
+  	while ((dmi =3D dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL, dmi)) !=
=3D NULL) {
+    		dslot =3D dmi->device_data;
+    		if (dslot && dslot->bus =3D=3D bus && dslot->devfn =3D=3D devfn)=
 {
+			if (buf)
+      				return scnprintf(buf, PAGE_SIZE, "%s\n", dmi->name);
+			return strlen(dmi->name);
+		}
+	}
+=09
+	return 0;
+}
+
+static ssize_t
+smbiosname_show(struct device *dev, struct device_attribute *attr, cha=
r *buf)
+{
+	return smbiosname_string_exists(dev, buf);
+}
+
+struct smbios_attribute smbios_attr_label =3D {
+	.attr =3D {.name =3D "label", .mode =3D 0444, .owner =3D THIS_MODULE}=
,
+	.show =3D smbiosname_show,
+	.test =3D smbiosname_string_exists,
+};
+
+static int=20
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL=
)) {
+		sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+		return 0;
+	}
+	return -1;=09
+}
+
+static int=20
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL=
)) {
+		sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_label.attr);
+		return 0;
+	}
+	return -1;
+}
+#else
+static inline int=20
+pci_create_smbiosname_file(struct pci_dev *pdev)
+{
+	return -1;
+}
+
+static inline int=20
+pci_remove_smbiosname_file(struct pci_dev *pdev)
+{
+	return -1;
+}
+#endif
+
+#if defined CONFIG_ACPI
+
+static const char device_label_dsm_uuid[] =3D {
+	0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
+	0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
+};
+
+struct acpi_attribute {
+	struct attribute attr;
+	ssize_t (*show) (struct device *dev, char *buf);
+	ssize_t (*test) (struct device *dev, char *buf);
+};
+
+static int
+dsm_get_label(acpi_handle handle, int func,=20
+              struct acpi_buffer *output,=20
+              char *buf, char *attribute)
+{
+	struct acpi_object_list input;
+	union acpi_object params[4];
+	union acpi_object *obj;=20
+	int len =3D 0;
+
+	int err;
+
+	input.count =3D 4;
+	input.pointer =3D params;
+	params[0].type =3D ACPI_TYPE_BUFFER;
+	params[0].buffer.length =3D sizeof(device_label_dsm_uuid);
+	params[0].buffer.pointer =3D (char *)device_label_dsm_uuid;
+	params[1].type =3D ACPI_TYPE_INTEGER;
+	params[1].integer.value =3D 0x02;
+	params[2].type =3D ACPI_TYPE_INTEGER;
+	params[2].integer.value =3D func;
+	params[3].type =3D ACPI_TYPE_PACKAGE;
+	params[3].package.count =3D 0;
+	params[3].package.elements =3D NULL;
+
+	err =3D acpi_evaluate_object(handle, "_DSM", &input, output);
+	if (err)=20
+		return -1;
+=09
+=09
+	obj =3D (union acpi_object *)output->pointer;
+
+	switch (obj->type) {
+	case ACPI_TYPE_PACKAGE:
+		if (obj->package.count !=3D 2)=20
+			break;
+		len =3D obj->package.elements[0].integer.value;
+		if (buf) {
+			if (!strncmp(attribute, "index", strlen(attribute)))
+				scnprintf(buf, PAGE_SIZE, "%lu\n",=20
+				obj->package.elements[0].integer.value);
+			else
+				scnprintf(buf, PAGE_SIZE, "%s\n",=20
+				obj->package.elements[1].string.pointer);
+			kfree(output->pointer);
+			return strlen(buf);
+		}
+		kfree(output->pointer);
+		return len;
+	break;
+	default:
+		kfree(output->pointer);
+		return -1;
+	}
+}=09
+
+static ssize_t
+acpi_index_string_exist(struct device *dev, char *buf, char *attribute=
)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+
+	struct acpi_buffer output =3D {ACPI_ALLOCATE_BUFFER, NULL};
+	acpi_handle handle;
+	int length;
+=09
+	handle =3D DEVICE_ACPI_HANDLE(dev);
+
+	if (!handle)=20
+		return -1;
+
+	if ((length =3D dsm_get_label(handle, DEVICE_LABEL_DSM,=20
+				    &output, buf, attribute)) < 0)
+		return -1;
+
+	return length;
+}
+=09
+static ssize_t
+acpilabel_show(struct device *dev, struct device_attribute *attr, char=
 *buf)
+{
+	return acpi_index_string_exist(dev, buf, "label");
+}
+
+static ssize_t
+acpiindex_show(struct device *dev, struct device_attribute *attr, char=
 *buf)
+{
+	return acpi_index_string_exist(dev, buf, "index");
+}
+
+struct acpi_attribute acpi_attr_label =3D {
+	.attr =3D {.name =3D "label", .mode =3D 0444, .owner =3D THIS_MODULE}=
,
+	.show =3D acpilabel_show,
+	.test =3D acpi_index_string_exist,
+};
+
+struct acpi_attribute acpi_attr_index =3D {
+	.attr =3D {.name =3D "index", .mode =3D 0444, .owner =3D THIS_MODULE}=
,
+	.show =3D acpiindex_show,
+	.test =3D acpi_index_string_exist,
+};
+
+static int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+	if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > =
0) {
+		sysfs_create_file(&pdev->dev.kobj, &acpi_attr_label.attr);
+		sysfs_create_file(&pdev->dev.kobj, &acpi_attr_index.attr);
+		return 0;
+	}
+	return -1;
+}
+
+static int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+	if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > =
0) {
+		sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_label.attr);
+		sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_index.attr);
+		return 0;
+	}
+	return -1;
+}
+#else
+static inline int
+pci_create_acpi_index_label_files(struct pci_dev *pdev)
+{
+	return -1;
+}
+
+static inline int
+pci_remove_acpi_index_label_files(struct pci_dev *pdev)
+{
+	return -1;
+}
+#endif
+
+int pci_create_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_create_acpi_index_label_files(pdev))
+		return 0;
+	if (!pci_create_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
+
+int pci_remove_firmware_label_files(struct pci_dev *pdev)
+{
+	if (!pci_remove_acpi_index_label_files(pdev))
+		return 0;
+	if (!pci_remove_smbiosname_file(pdev))
+		return 0;
+	return -ENODEV;
+}
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index fad9398..4ed517f 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -1073,6 +1073,8 @@ int __must_check pci_create_sysfs_dev_files (stru=
ct pci_dev *pdev)
 	if (retval)
 		goto err_vga_file;
=20
+	pci_create_firmware_label_files(pdev);
+
 	return 0;
=20
 err_vga_file:
@@ -1140,6 +1142,9 @@ void pci_remove_sysfs_dev_files(struct pci_dev *p=
dev)
 		sysfs_remove_bin_file(&pdev->dev.kobj, pdev->rom_attr);
 		kfree(pdev->rom_attr);
 	}
+
+	pci_remove_firmware_label_files(pdev);
+
 }
=20
 static int __init pci_sysfs_init(void)
diff --git a/drivers/pci/pci.h b/drivers/pci/pci.h
index 4eb10f4..f223283 100644
--- a/drivers/pci/pci.h
+++ b/drivers/pci/pci.h
@@ -11,6 +11,8 @@
 extern int pci_uevent(struct device *dev, struct kobj_uevent_env *env)=
;
 extern int pci_create_sysfs_dev_files(struct pci_dev *pdev);
 extern void pci_remove_sysfs_dev_files(struct pci_dev *pdev);
+extern int pci_create_firmware_label_files(struct pci_dev *pdev);
+extern int pci_remove_firmware_label_files(struct pci_dev *pdev);
 extern void pci_cleanup_rom(struct pci_dev *dev);
 #ifdef HAVE_PCI_MMAP
 extern int pci_mmap_fits(struct pci_dev *pdev, int resno,
diff --git a/include/linux/dmi.h b/include/linux/dmi.h
index a8a3e1a..cc57c3a 100644
--- a/include/linux/dmi.h
+++ b/include/linux/dmi.h
@@ -20,6 +20,7 @@ enum dmi_device_type {
 	DMI_DEV_TYPE_SAS,
 	DMI_DEV_TYPE_IPMI =3D -1,
 	DMI_DEV_TYPE_OEM_STRING =3D -2,
+	DMI_DEV_TYPE_DEVSLOT =3D -3,
 };
=20
 struct dmi_header {
@@ -37,6 +38,14 @@ struct dmi_device {
=20
 #ifdef CONFIG_DMI
=20
+struct dmi_devslot {
+	struct dmi_device dev;
+	int id;
+	int seg;
+	int bus;
+	int devfn;
+};
+
 extern int dmi_check_system(const struct dmi_system_id *list);
 const struct dmi_system_id *dmi_first_match(const struct dmi_system_id=
 *list);
 extern const char * dmi_get_system_info(int field);
--=20
1.6.5.2

With regards,
Narendra K
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
