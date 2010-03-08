From: Alex Chiang <achiang@hp.com>
Subject: Re: [PATCH] Export smbios strings associated with onboard devices
	to sysfs
Date: Mon, 8 Mar 2010 10:38:38 -0700
Message-ID: <20100308173838.GC20953@ldl.fc.hp.com>
References: <20100225202941.GA19404@mock.linuxdev.us.dell.com> <20100225204905.GC20147@mdomsch-pws380.aus.amer.dell.com> <EDA0A4495861324DA2618B4C45DCB3EE6122A2@blrx3m08.blr.amer.dell.com> <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matt_domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	jordan_hargrave@dell.com, sandeep_k_shandilya@dell.com,
	charles_rose@dell.com, shyam_iyer@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100302173302.GA20936@mock.linuxdev.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Narendra K <Narendra_K@dell.com>:
> 
> Resending the patch with review comments incorporated.
> 
> Signed-off-by: Jordan Hargrave <Jordan_Hargrave@dell.com>
> Signed-off-by: Narendra K <Narendra_K@dell.com>

Here is a patch I wrote that would be nice if you could
incorporate into your patch series.

It adds support for HP OEM SMBIOS record Type 209, so that you
can populate the 'label' attribute on existing HP platforms.

It needs that hunk I suggested in my previous mail to apply
cleanly.

Thanks,
/ac

From: Alex Chiang <achiang@hp.com>

dmi: save OEM defined slot information

Some legacy platforms provide onboard device information in an SMBIOS
OEM-defined field, notably HP Proliants.

This information can be used to provide information to userspace that
allows correlation between a Linux PCI device and a chassis label.

Save this information so that it can be exposed to userspace. We choose
the string "Embedded NIC %d" since there are known platforms from other
vendors (Dell) that provide a string in this format for their onboard
NICs (although theirs is provided by a Type 41 record). This consistency
will help simplify life for userspace tools.

Only support HP platforms for now. If we need support for another vendor
in the future, we can write a fancier implementation then.

This code was inspired by the implementation in the userspace dmidecode
tool, which was originally written by John Cagle.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 dmi_scan.c |   30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)
---
diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index 5a81a8b..cb2a57a 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -314,6 +314,33 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
+static void __init dmi_save_oem_devices(const struct dmi_header *dm)
+{
+	int bus, devfn, count;
+	const u8 *d = (u8 *)dm + 4;
+	char name[20];
+
+	/* Only handle HP extensions for now */
+	if (strcmp(dmi_ident[DMI_BIOS_VENDOR], "HP"))
+		return;
+
+	count = 1;
+	while ((d + 8) <= ((u8 *)dm + dm->length)) {
+		if ((*d == 0x00 && *(d + 1) == 0x00) ||
+		    (*d == 0xff && *(d + 1) == 0xff))
+			goto next;
+
+		bus = *(d + 1);
+		devfn = *d;
+		sprintf(name, "Embedded NIC %d", count);
+		dmi_save_devslot(-1, 0, bus, devfn, name);
+
+next:
+		count++;
+		d += 8;
+	}
+}
+
 /*
  *	Process a DMI table entry. Right now all we care about are the BIOS
  *	and machine entries. For 2.5 we should pull the smbus controller info
@@ -360,6 +387,9 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
 	case 41:	/* Onboard Devices Extended Information */
 		dmi_save_extended_devices(dm);
 		break;
+	case 209:
+		dmi_save_oem_devices(dm);
+		break;
 	}
 }
 
