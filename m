From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH] vsock: only load vmci transport on VMware hypervisor by
 default
Date: Thu, 17 Aug 2017 08:00:29 +0000
Message-ID: <KL1P15301MB0008F70D4E5248AB7A296CE3BF830@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "'gregkh@linuxfoundation.org'" <gregkh@linuxfoundation.org>,
        "'devel@linuxdriverproject.org'" <devel@linuxdriverproject.org>,
        "KY Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        'George Zhang' <georgezhang@vmware.com>,
        'Michal Kubecek' <mkubecek@suse.cz>,
        'Asias He' <asias@redhat.com>,
        'Stefan Hajnoczi' <stefanha@redhat.com>,
        "'Vitaly Kuznetsov'" <vkuznets@redhat.com>,
        'Cathy Avery' <cavery@redhat.com>,
        "'jasowang@redhat.com'" <jasowang@redhat.com>,
        'Rolf Neugebauer' <rolf.neugebauer@docker.com>,
        'Dave Scott' <dave.scott@docker.com>,
        "'Marcelo Cerri'" <marcelo.cerri@canonical.com>,
        "'apw@canonical.com'" <apw@canonical.com>,
        "'olaf@aepfle.de'" <olaf@aepfle.de>,
        "'joe@perches.com'" <j
To: "'Jorgen S. Hansen'" <jhansen@vmware.com>,
        "'davem@davemloft.net'" <davem@davemloft.net>,
        "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Without the patch, vmw_vsock_vmci_transport.ko can automatically load
when an application creates an AF_VSOCK socket.

This is the expected good behavior on VMware hypervisor, but as we
are going to add hv_sock.ko (i.e. Hyper-V transport for AF_VSOCK), we
should make sure vmw_vsock_vmci_transport.ko can't load on Hyper-V,
otherwise there is a -EBUSY conflict when both vmw_vsock_vmci_transport.ko
and hv_sock.ko try to call vsock_core_init() on Hyper-V.

On the other hand, hv_sock.ko can only load on Hyper-V, because it
depends on hv_vmbus.ko, which detects Hyper-V in hv_acpi_init().

KVM's vsock_virtio_transport doesn't have the issue because it doesn't
define MODULE_ALIAS_NETPROTO(PF_VSOCK).

The patch also adds a module parameter "skip_hypervisor_check" for
vmw_vsock_vmci_transport.ko.

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
 net/vmw_vsock/Kconfig          |  2 +-
 net/vmw_vsock/vmci_transport.c | 11 +++++++++++
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/vmw_vsock/Kconfig b/net/vmw_vsock/Kconfig
index a24369d..3f52929 100644
--- a/net/vmw_vsock/Kconfig
+++ b/net/vmw_vsock/Kconfig
@@ -17,7 +17,7 @@ config VSOCKETS
=20
 config VMWARE_VMCI_VSOCKETS
 	tristate "VMware VMCI transport for Virtual Sockets"
-	depends on VSOCKETS && VMWARE_VMCI
+	depends on VSOCKETS && VMWARE_VMCI && HYPERVISOR_GUEST
 	help
 	  This module implements a VMCI transport for Virtual Sockets.
=20
diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.=
c
index 10ae782..c068873 100644
--- a/net/vmw_vsock/vmci_transport.c
+++ b/net/vmw_vsock/vmci_transport.c
@@ -16,6 +16,7 @@
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/cred.h>
+#include <linux/hypervisor.h>
 #include <linux/init.h>
 #include <linux/io.h>
 #include <linux/kernel.h>
@@ -73,6 +74,10 @@ struct vmci_transport_recv_pkt_info {
 	struct vmci_transport_packet pkt;
 };
=20
+static bool skip_hypervisor_check;
+module_param(skip_hypervisor_check, bool, 0444);
+MODULE_PARM_DESC(hot_add, "If set, attempt to load on non-VMware platforms=
");
+
 static LIST_HEAD(vmci_transport_cleanup_list);
 static DEFINE_SPINLOCK(vmci_transport_cleanup_lock);
 static DECLARE_WORK(vmci_transport_cleanup_work, vmci_transport_cleanup);
@@ -2085,6 +2090,12 @@ static int __init vmci_transport_init(void)
 {
 	int err;
=20
+	/* Check if we are running on VMware's hypervisor and bail out
+	 * if we are not.
+	 */
+	if (!skip_hypervisor_check && x86_hyper !=3D &x86_hyper_vmware)
+		return -ENODEV;
+
 	/* Create the datagram handle that we will use to send and receive all
 	 * VSocket control messages for this context.
 	 */
--=20
2.7.4
