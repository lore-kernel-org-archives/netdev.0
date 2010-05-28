From: "K, Narendra" <Narendra_K@dell.com>
Subject: [PATCH 2/2] dmi: save OEM defined slot information
Date: Fri, 28 May 2010 07:06:45 -0500
Message-ID: <20100528120644.GB24114@littleblue.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "achiang@hp.com" <achiang@hp.com>,
	"Domsch, Matt" <Matt_Domsch@dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@dell.com>,
	"Rose, Charles" <Charles_Rose@dell.com>,
	"Nijhawan, Vijay" <Vijay_Nijhawan@dell.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patch from Alex Chiang exports onboard device information as defined by 
SMBIOS type 209 for HP Proliants systems.


From: Alex Chiang <achiang@hp.com>

Some legacy platforms provide onboard device information in an SMBIOS OEM-
defined field, notably HP Proliants.

This information can be used to provide information to userspace that allows
correlation between a Linux PCI device and a chassis label.

Save this information so that it can be exposed to userspace. We choose the
string "Embedded NIC %d" since there are known platforms from other vendors
(Dell) that provide a string in this format for their onboard NICs (although
theirs is provided by a Type 41 record). This consistency will help simplify
life for userspace tools.

Only support HP platforms for now. If we need support for another vendor in
the future, we can write a fancier implementation then.

This code was inspired by the implementation in the userspace dmidecode tool,
which was originally written by John Cagle.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
 drivers/firmware/dmi_scan.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/firmware/dmi_scan.c b/drivers/firmware/dmi_scan.c
index 7d8439b..291b876 100644
--- a/drivers/firmware/dmi_scan.c
+++ b/drivers/firmware/dmi_scan.c
@@ -311,6 +311,32 @@ static void __init dmi_save_extended_devices(const struct dmi_header *dm)
 	dmi_save_one_device(*d & 0x7f, dmi_string_nosave(dm, *(d - 1)));
 }
 
+static void __init dmi_save_oem_devices(const struct dmi_header *dm) {
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
@@ -357,6 +383,9 @@ static void __init dmi_decode(const struct dmi_header *dm, void *dummy)
 	case 41:	/* Onboard Devices Extended Information */
 		dmi_save_extended_devices(dm);
 		break;
+	case 209:
+		dmi_save_oem_devices(dm);
+		break;
 	}
 }
 
-- 
1.6.5.2


With regards,
Narendra K
