From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Export firmware assigned labels of network devices
 to sysfs
Date: Fri, 28 May 2010 08:40:41 -0700
Message-ID: <20100528154041.GA27186@kroah.com>
References: <20100528115520.GA24114@littleblue.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"Domsch, Matt" <Matt_Domsch@dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: "K, Narendra" <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100528115520.GA24114@littleblue.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 28, 2010 at 06:55:21AM -0500, K, Narendra wrote:
> Please refer to the PCI-SIG Draft ECN
> "PCIe Device Labeling under Operating Systems Draft ECN" at this link -
> http://www.pcisig.com/specifications/pciexpress/review_zone/.
> 
> It would be great to know your views on this ECN. Please let us know if you have
> have any suggestions or changes.

Note that only members of the PCI-SIG can do this, which pretty much
rules out any "normal" Linux kernel developer :(

Care to post a public version of this for us to review?
> --- /dev/null
> +++ b/drivers/pci/pci-label.c
> @@ -0,0 +1,242 @@
> +/*
> + * File:       drivers/pci/pci-label.c

This line is not needed, we know the file name :)

> + * Purpose:    Export the firmware label associated with a pci network interface
> + * device to sysfs
> + * Copyright (C) 2010 Dell Inc.
> + * by Narendra K <Narendra_K@dell.com>, Jordan Hargrave <Jordan_Hargrave@dell.com>
> + *
> + * This code checks if the pci network device has a related ACPI _DSM. If
> + * available, the code calls the _DSM to retrieve the index and string and
> + * exports them to sysfs. If the ACPI _DSM is not available, it falls back on
> + * SMBIOS. SMBIOS defines type 41 for onboard pci devices. This code retrieves
> + * strings associated with the type 41 and exports it to sysfs.
> + *
> + * Please see http://linux.dell.com/wiki/index.php/Oss/libnetdevname for more
> + * information.
> + */
> +
> +#include <linux/pci-label.h>

Why is this file in include/linux/ ?  Who needs it there?  Can't it just
be in in the drivers/pci/ directory?  Actually all you need is 2
functions in there, so it could go into the internal pci.h file in that
directory without a problem, right?

> +
> +static ssize_t
> +smbiosname_string_exists(struct device *dev, char *buf)
> +{
> +       struct pci_dev *pdev = to_pci_dev(dev);
> +       const struct dmi_device *dmi;
> +       struct dmi_devslot *dslot;
> +       int bus;
> +       int devfn;
> +
> +       bus = pdev->bus->number;
> +       devfn = pdev->devfn;
> +
> +       dmi = NULL;
> +       while ((dmi = dmi_find_device(DMI_DEV_TYPE_DEVSLOT, NULL, dmi)) != NULL) {
> +               dslot = dmi->device_data;
> +               if (dslot && dslot->bus == bus && dslot->devfn == devfn) {
> +                       if (buf)
> +                               return scnprintf(buf, PAGE_SIZE, "%s\n", dmi->name);
> +                       return strlen(dmi->name);
> +               }
> +       }
> +
> +       return 0;
> +}
> +
> +static ssize_t
> +smbiosname_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +       return smbiosname_string_exists(dev, buf);
> +}
> +
> +struct smbios_attribute smbios_attr_label = {
> +       .attr = {.name = __stringify(label), .mode = 0444, .owner = THIS_MODULE},

Can't you just put "label" as the name?

> +       .show = smbiosname_show,
> +       .test = smbiosname_string_exists,
> +};
> +
> +static int
> +pci_create_smbiosname_file(struct pci_dev *pdev)
> +{
> +       if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
> +               sysfs_create_file(&pdev->dev.kobj, &smbios_attr_label.attr);
> +               return 0;
> +       }
> +       return -1;
> +}
> +
> +static int
> +pci_remove_smbiosname_file(struct pci_dev *pdev)
> +{
> +       if (smbios_attr_label.test && smbios_attr_label.test(&pdev->dev, NULL)) {
> +               sysfs_remove_file(&pdev->dev.kobj, &smbios_attr_label.attr);
> +               return 0;
> +       }
> +       return -1;
> +}
> +
> +static const char dell_dsm_uuid[] = {

Um, a dell specific uuid in a generic file?  What happens when we need
to support another manufacturer?

> +       0xD0, 0x37, 0xC9, 0xE5, 0x53, 0x35, 0x7A, 0x4D,
> +       0x91, 0x17, 0xEA, 0x4D, 0x19, 0xC3, 0x43, 0x4D
> +};
> +
> +
> +static int
> +dsm_get_label(acpi_handle handle, int func,
> +              struct acpi_buffer *output,
> +              char *buf, char *attribute)
> +{
> +       struct acpi_object_list input;
> +       union acpi_object params[4];
> +       union acpi_object *obj;
> +       int len = 0;
> +
> +       int err;
> +
> +       input.count = 4;
> +       input.pointer = params;
> +       params[0].type = ACPI_TYPE_BUFFER;
> +       params[0].buffer.length = sizeof(dell_dsm_uuid);
> +       params[0].buffer.pointer = (char *)dell_dsm_uuid;
> +       params[1].type = ACPI_TYPE_INTEGER;
> +       params[1].integer.value = 0x02;
> +       params[2].type = ACPI_TYPE_INTEGER;
> +       params[2].integer.value = func;
> +       params[3].type = ACPI_TYPE_PACKAGE;
> +       params[3].package.count = 0;
> +       params[3].package.elements = NULL;
> +
> +       err = acpi_evaluate_object(handle, "_DSM", &input, output);
> +       if (err) {
> +               printk(KERN_INFO "failed to evaulate _DSM\n");
> +               return -1;
> +       }
> +
> +       obj = (union acpi_object *)output->pointer;
> +
> +       switch (obj->type) {
> +       case ACPI_TYPE_PACKAGE:
> +               if (obj->package.count == 2) {
> +                       len = obj->package.elements[0].integer.value;
> +                       if (buf) {
> +                               if (!strncmp(attribute, "index", strlen(attribute)))
> +                                       scnprintf(buf, PAGE_SIZE, "%lu\n",
> +                                       obj->package.elements[0].integer.value);
> +                               else
> +                                       scnprintf(buf, PAGE_SIZE, "%s\n",
> +                                       obj->package.elements[1].string.pointer);
> +                               kfree(output->pointer);
> +                               return strlen(buf);
> +                       }
> +               }
> +               kfree(output->pointer);
> +               return len;
> +       break;
> +       default:
> +               return -1;
> +       }
> +}
> +
> +static ssize_t
> +acpi_index_string_exist(struct device *dev, char *buf, char *attribute)
> +{
> +       struct pci_dev *pdev = to_pci_dev(dev);
> +
> +       struct acpi_buffer output = {ACPI_ALLOCATE_BUFFER, NULL};
> +       acpi_handle handle;
> +       int length;
> +       int is_addin_card = 0;
> +
> +       if ((pdev->class >> 16) != PCI_BASE_CLASS_NETWORK)
> +               return -1;
> +
> +       handle = DEVICE_ACPI_HANDLE(dev);
> +
> +       if (!handle) {
> +               /*
> +                * The device is an add-in network controller and does have
> +                * a valid handle. Try until we get the handle for the parent
> +                * bridge
> +                */
> +               struct pci_bus *pbus;
> +               for (pbus = pdev->bus; pbus; pbus = pbus->parent) {
> +                       handle = DEVICE_ACPI_HANDLE(&(pbus->self->dev));
> +                       if (handle)
> +                               break;
> +
> +               }
> +       }
> +
> +       if ((length = dsm_get_label(handle, DELL_DSM_NETWORK,
> +                                   &output, buf, attribute)) < 0)
> +               return -1;
> +
> +       return length;
> +}
> +
> +static ssize_t
> +acpilabel_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +       return acpi_index_string_exist(dev, buf, "label");
> +}
> +
> +static ssize_t
> +acpiindex_show(struct device *dev, struct device_attribute *attr, char *buf)
> +{
> +       return acpi_index_string_exist(dev, buf, "index");
> +}
> +
> +struct acpi_attribute acpi_attr_label = {
> +       .attr = {.name = __stringify(label), .mode = 0444, .owner = THIS_MODULE},
> +       .show = acpilabel_show,
> +       .test = acpi_index_string_exist,
> +};
> +
> +struct acpi_attribute acpi_attr_index = {
> +       .attr = {.name = __stringify(index), .mode = 0444, .owner = THIS_MODULE},
> +       .show = acpiindex_show,
> +       .test = acpi_index_string_exist,
> +};
> +
> +static int
> +pci_create_acpi_index_label_files(struct pci_dev *pdev)
> +{
> +       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > 0) {
> +               sysfs_create_file(&pdev->dev.kobj, &acpi_attr_label.attr);
> +               sysfs_create_file(&pdev->dev.kobj, &acpi_attr_index.attr);
> +               return 0;
> +       }
> +       return -1;
> +}
> +
> +static int
> +pci_remove_acpi_index_label_files(struct pci_dev *pdev)
> +{
> +       if (acpi_attr_label.test && acpi_attr_label.test(&pdev->dev, NULL) > 0) {
> +               sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_label.attr);
> +               sysfs_remove_file(&pdev->dev.kobj, &acpi_attr_index.attr);
> +               return 0;
> +       }
> +       return -1;
> +}
> +
> +int pci_create_acpi_attr_files(struct pci_dev *pdev)
> +{
> +       if (!pci_create_acpi_index_label_files(pdev))
> +               return 0;
> +       if (!pci_create_smbiosname_file(pdev))
> +               return 0;
> +       return -ENODEV;
> +}
> +EXPORT_SYMBOL(pci_create_acpi_attr_files);

EXPORT_SYMBOL_GPL?

Wait, why does this need to be exported at all?  What module is ever
going to call this function?

> +int pci_remove_acpi_attr_files(struct pci_dev *pdev)
> +{
> +       if (!pci_remove_acpi_index_label_files(pdev))
> +               return 0;
> +       if (!pci_remove_smbiosname_file(pdev))
> +               return 0;
> +       return -ENODEV;
> +
> +}
> +EXPORT_SYMBOL(pci_remove_acpi_attr_files);

Same here, what module will call this?

> +++ b/include/linux/pci-label.h

As discussed above, this whole file does not need to exist.

> +extern int pci_create_acpi_attr_files(struct pci_dev *pdev);
> +extern int pci_remove_acpi_attr_files(struct pci_dev *pdev);

Just put these two functions in the drivers/pci/pci.h file.

thanks,

greg k-h
