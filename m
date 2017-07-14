From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 12/22] vmxnet3: avoid format strint overflow warning
Date: Fri, 14 Jul 2017 14:07:04 +0200
Message-ID: <20170714120720.906842-13-arnd@arndb.de>
References: <20170714120720.906842-1-arnd@arndb.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org,
        netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
        "James E . J . Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K . Petersen" <martin.petersen@oracle.com>,
        linux-scsi@vger.kernel.org, x86@kernel.org,
        Arnd Bergmann <arnd@arndb.de>
To: linux-kernel@vger.kernel.org,
        Shrikrishna Khare <skhare@vmware.com>,
        "VMware, Inc." <pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170714120720.906842-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-7 notices that "-event-%d" could be more than 11 characters long
if we had larger 'vector' numbers:

drivers/net/vmxnet3/vmxnet3_drv.c: In function 'vmxnet3_activate_dev':
drivers/net/vmxnet3/vmxnet3_drv.c:2095:40: error: 'sprintf' may write a terminating nul past the end of the destination [-Werror=format-overflow=]
sprintf(intr->event_msi_vector_name, "%s-event-%d",
                                     ^~~~~~~~~~~~~
drivers/net/vmxnet3/vmxnet3_drv.c:2095:3: note: 'sprintf' output between 9 and 33 bytes into a destination of size 32

The current code is safe, but making the string a little longer
is harmless and lets gcc see that it's ok.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/vmxnet3/vmxnet3_int.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index ba1c9f93592b..9c51b8be0038 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -311,7 +311,7 @@ struct vmxnet3_intr {
 	u8  num_intrs;			/* # of intr vectors */
 	u8  event_intr_idx;		/* idx of the intr vector for event */
 	u8  mod_levels[VMXNET3_LINUX_MAX_MSIX_VECT]; /* moderation level */
-	char	event_msi_vector_name[IFNAMSIZ+11];
+	char	event_msi_vector_name[IFNAMSIZ+17];
 #ifdef CONFIG_PCI_MSI
 	struct msix_entry msix_entries[VMXNET3_LINUX_MAX_MSIX_VECT];
 #endif
-- 
2.9.0
