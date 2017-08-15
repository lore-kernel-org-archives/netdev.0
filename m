From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH net-next 1/3] VMCI: only load on VMware hypervisor
Date: Tue, 15 Aug 2017 22:13:29 +0000
Message-ID: <KL1P15301MB00083C97259FF2A700C78442BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, "olaf@aepfle.de" <olaf@aepfle.de>,
 Stephen Hemminger <sthemmin@microsoft.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, Rolf
 Neugebauer <rolf.neugebauer@docker.com>, Haiyang Zhang <haiyangz@microsoft.com>,
 Dave Scott <dave.scott@docker.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, George Zhang <georgezhang@vmware.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Marcelo Cerri <marcelo.cerri@canonical.com>,
 "joe@perches.com" <joe@perches.com>, Asias He <asias@redhat.com>,
 Vitaly Kuznetsov <vkuznets@redhat.com>, Jorgen Hansen <jhansen@vmware.com>,
 Dan Carpenter <dan.carpenter@oracle.com>
To: "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org"
 <netdev@vger.kernel.org>, "'gregkh@linuxfoundation.org'"
 <'gregkh@linuxfoundation.org'>, "devel@linuxdriverproject.org"
 <devel@linuxdriverproject.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


Without the patch, vmw_vsock_vmci_transport.ko and vmw_vmci.ko can
automatically load when an application creates an AF_VSOCK socket.

This is the expected good behavior on VMware hypervisor, but as we
are going to add hv_sock.ko (i.e. Hyper-V transport for AF_VSOCK), we
should make sure vmw_vsock_vmci_transport.ko doesn't load on Hyper-V,
otherwise there is a -EBUSY conflict when both vmw_vsock_vmci_transport.ko
and hv_sock.ko try to call vsock_core_init() on Hyper-V.

On the other hand, hv_sock.ko can only load on Hyper-V, because it
depends on hv_vmbus.ko, which detects Hyper-V in hv_acpi_init().

KVM's vsock_virtio_transport doesn't have the issue because it doesn't
define MODULE_ALIAS_NETPROTO(PF_VSOCK).

Signed-off-by: Dexuan Cui <decui@microsoft.com>
Cc: Alok Kataria <akataria@vmware.com>
Cc: Andy King <acking@vmware.com>
Cc: Adit Ranadive <aditr@vmware.com>
Cc: George Zhang <georgezhang@vmware.com>
Cc: Jorgen Hansen <jhansen@vmware.com>
Cc: K. Y. Srinivasan <kys@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/misc/vmw_vmci/vmci_driver.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/misc/vmw_vmci/vmci_driver.c b/drivers/misc/vmw_vmci/vmci_driver.c
index d7eaf1e..1789ea7 100644
--- a/drivers/misc/vmw_vmci/vmci_driver.c
+++ b/drivers/misc/vmw_vmci/vmci_driver.c
@@ -19,6 +19,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/hypervisor.h>
 
 #include "vmci_driver.h"
 #include "vmci_event.h"
@@ -58,6 +59,13 @@ static int __init vmci_drv_init(void)
 	int vmci_err;
 	int error;
 
+	/*
+	 * Check if we are running on VMware's hypervisor and bail out
+	 * if we are not.
+	 */
+	if (x86_hyper != &x86_hyper_vmware)
+		return -ENODEV;
+
 	vmci_err = vmci_event_init();
 	if (vmci_err < VMCI_SUCCESS) {
 		pr_err("Failed to initialize VMCIEvent (result=%d)\n",
-- 
2.7.4
