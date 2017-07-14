From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 03/22] scsi: mpt3sas: fix format overflow warning
Date: Fri, 14 Jul 2017 14:06:55 +0200
Message-ID: <20170714120720.906842-4-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>, Hannes Reinecke <hare@suse.de>,
        Calvin Owens <calvinowens@fb.com>,
        Adam Manzanares <adam.manzanares@wdc.com>,
        Bart Van Assche <bart.vanassche@sandisk.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        MPT-FusionLinux.pdl@broadcom.com
To: linux-kernel@vger.kernel.org,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        Chaitra P B <chaitra.basappa@broadcom.com>,
        Suganath Prabu Subramani
        <suganath-prabu.subramani@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We print the driver name into one string and then add and ID
and copy it into a second string of the same length, at which
point gcc complains about a possible overflow:

drivers/scsi/mpt3sas/mpt3sas_scsih.c: In function '_scsih_probe':
drivers/scsi/mpt3sas/mpt3sas_scsih.c:8884:21: error: '_cm' directive writing 3 bytes into a region of size between 1 and 32 [-Werror=format-overflow=]
printf(ioc->name, "%s_cm%d", ioc->driver_name, ioc->id);
                  ^~~~~~~~~
drivers/scsi/mpt3sas/mpt3sas_scsih.c:8884:21: note: directive argument in the range [0, 255]
drivers/scsi/mpt3sas/mpt3sas_scsih.c:8884:2: note: 'sprintf' output between 5 and 38 bytes into a destination of size 32
  sprintf(ioc->name, "%s_cm%d", ioc->driver_name, ioc->id);
  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Making the first string shorter is sufficient to avoid the
warning here, as we know it can only contain either "mpt2sas"
or "mpt3sas".

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/scsi/mpt3sas/mpt3sas_base.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/mpt3sas/mpt3sas_base.h b/drivers/scsi/mpt3sas/mpt3sas_base.h
index 099ab4ca7edf..a77bb7dc12b1 100644
--- a/drivers/scsi/mpt3sas/mpt3sas_base.h
+++ b/drivers/scsi/mpt3sas/mpt3sas_base.h
@@ -970,7 +970,7 @@ struct MPT3SAS_ADAPTER {
 	u8		id;
 	int		cpu_count;
 	char		name[MPT_NAME_LENGTH];
-	char		driver_name[MPT_NAME_LENGTH];
+	char		driver_name[MPT_NAME_LENGTH - 8];
 	char		tmp_string[MPT_STRING_LENGTH];
 	struct pci_dev	*pdev;
 	Mpi2SystemInterfaceRegs_t __iomem *chip;
-- 
2.9.0
