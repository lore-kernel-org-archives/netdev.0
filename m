From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [RFC arm-kernel 3/4] caif-u5500: CAIF shared memory mailbox interface
Date: Tue, 12 Oct 2010 13:10:20 +0200
Message-ID: <1286881821-2916-4-git-send-email-sjur.brandeland@stericsson.com>
References: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan.xk.nilsson@stericsson.com, linus.walleij@stericsson.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	kim.lilliestierna@stericsson.com, daniel.martensson@stericsson.com,
	Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:54277 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932178Ab0JLLK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 07:10:57 -0400
Received: by mail-ew0-f46.google.com with SMTP id 20so1136107ewy.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 04:10:56 -0700 (PDT)
In-Reply-To: <1286881821-2916-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Amarnath Revanna <amarnath.bangalore.revanna@stericsson.com>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_shm_u5500.c |  129 +++++++++++++++++++++++++++++=
++++++++
 1 files changed, 129 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/caif_shm_u5500.c

diff --git a/drivers/net/caif/caif_shm_u5500.c b/drivers/net/caif/caif_=
shm_u5500.c
new file mode 100644
index 0000000..7c1f7b9
--- /dev/null
+++ b/drivers/net/caif/caif_shm_u5500.c
@@ -0,0 +1,129 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:  Amarnath Revanna / amarnath.bangalore.revanna@stericsson.c=
om
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s(): " fmt, __func__
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <mach/mbox.h>
+#include <net/caif/caif_shm.h>
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("CAIF Shared Memory protocol driver");
+
+#define MAX_SHM_INSTANCES	1
+
+enum {
+	MBX_ACC0,
+	MBX_ACC1,
+	MBX_DSP
+};
+
+static struct shmdev_layer shmdev_lyr[MAX_SHM_INSTANCES];
+
+static unsigned int shm_start;
+static unsigned int shm_size;
+
+module_param(shm_size, uint  , 0440);
+MODULE_PARM_DESC(shm_total_size, "Start of SHM shared memory");
+
+module_param(shm_start, uint  , 0440);
+MODULE_PARM_DESC(shm_total_start, "Total Size of SHM shared memory");
+
+static int shmdev_send_msg(u32 dev_id, u32 mbx_msg)
+{
+	/* Always block until msg is written successfully */
+	mbox_send(shmdev_lyr[dev_id].hmbx, mbx_msg, true);
+	return 0;
+}
+
+static int shmdev_mbx_setup(void *pshmdrv_cb, struct shmdev_layer *psh=
m_dev,
+							 void *pshm_drv)
+{
+	/*
+	 * For UX5500, we have only 1 SHM instance which uses MBX0
+	 * for communication with the peer modem
+	 */
+	pshm_dev->hmbx =3D mbox_setup(MBX_ACC0, pshmdrv_cb, pshm_drv);
+
+	if (!pshm_dev->hmbx)
+		return -ENODEV;
+	else
+		return 0;
+}
+
+static int __init caif_shmdev_init(void)
+{
+	int i, result;
+
+	/* Loop is currently overkill, there is only one instance */
+	for (i =3D 0; i < MAX_SHM_INSTANCES; i++) {
+
+		shmdev_lyr[i].shm_base_addr =3D shm_start;
+		shmdev_lyr[i].shm_total_sz =3D shm_size;
+
+		if (((char *)shmdev_lyr[i].shm_base_addr =3D=3D NULL)
+			       || (shmdev_lyr[i].shm_total_sz <=3D 0))	{
+			pr_warn("ERROR,"
+				"Shared memory Address and/or Size incorrect"
+				", Bailing out ...\n");
+			result =3D -EINVAL;
+			goto clean;
+		}
+
+		pr_info("SHM AREA (instance %d) STARTS"
+			" AT %p\n", i, (char *)shmdev_lyr[i].shm_base_addr);
+
+		shmdev_lyr[i].shm_id =3D i;
+		shmdev_lyr[i].pshmdev_mbxsend =3D shmdev_send_msg;
+		shmdev_lyr[i].pshmdev_mbxsetup =3D shmdev_mbx_setup;
+
+		/*
+		 * Finally, CAIF core module is called with details in place:
+		 * 1. SHM base address
+		 * 2. SHM size
+		 * 3. MBX handle
+		 */
+		result =3D caif_shmcore_probe(&shmdev_lyr[i]);
+		if (result) {
+			pr_warn("ERROR[%d],"
+				"Could not probe SHM core (instance %d)"
+				" Bailing out ...\n", result, i);
+			goto clean;
+		}
+	}
+
+	return 0;
+
+clean:
+	/*
+	 * For now, we assume that even if one instance of SHM fails, we bail
+	 * out of the driver support completely. For this, we need to release
+	 * any memory allocated and unregister any instance of SHM net device=
=2E
+	 */
+	for (i =3D 0; i < MAX_SHM_INSTANCES; i++) {
+		if (shmdev_lyr[i].pshm_netdev)
+			unregister_netdev(shmdev_lyr[i].pshm_netdev);
+	}
+	return result;
+}
+
+static void __exit caif_shmdev_exit(void)
+{
+	int i;
+
+	for (i =3D 0; i < MAX_SHM_INSTANCES; i++) {
+		caif_shmcore_remove(shmdev_lyr[i].pshm_netdev);
+		kfree((void *)shmdev_lyr[i].shm_base_addr);
+	}
+
+}
+
+module_init(caif_shmdev_init);
+module_exit(caif_shmdev_exit);
--=20
1.7.0.4

