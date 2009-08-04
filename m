From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 2.6.31] ehea: Fix napi list corruption on ifconfig down
Date: Tue, 4 Aug 2009 16:20:15 +0200
Message-ID: <200908041620.16542.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755572AbZHDOUb@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the napi list handling when an ehea interface is shut down to
avoid corruption of the napi list.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>

---

diff -Nurp -X dontdiff linux-2.6.31-rc5/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.31-rc5/drivers/net/ehea/ehea.h	2009-08-01 02:40:45.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea.h	2009-08-03 17:59:26.696079433 +0200
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0101"
+#define DRV_VERSION	"EHEA_0102"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.31-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.31-rc5/drivers/net/ehea/ehea_main.c	2009-08-01 02:40:45.000000000 +0200
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-08-03 17:59:26.696079433 +0200
@@ -1545,6 +1545,9 @@ static int ehea_clean_portres(struct ehe
 {
 	int ret, i;
 
+	if (pr->qp)
+		netif_napi_del(&pr->napi);
+
 	ret = ehea_destroy_qp(pr->qp);
 
 	if (!ret) {
