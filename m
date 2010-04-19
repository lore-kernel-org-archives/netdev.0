From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2/2] ehea: fix possible DLPAR/mem deadlock
Date: Mon, 19 Apr 2010 14:08:47 +0200
Message-ID: <4BCC47CF.8060107@de.ibm.com>
References: <1221140080-9853-1-git-send-email-sebastien.dugue@bull.net>	<1221140080-9853-3-git-send-email-sebastien.dugue@bull.net>	<48CE7CC3.8040902@de.ibm.com> <20080916085746.194c1510@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20080916085746.194c1510@bull.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Force serialization of userspace-triggered DLPAR/mem operations

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---

Patch created against 2.6.34-rc4

diff -Nurp linux-2.6.34-rc4.orig//drivers/net/ehea/ehea.h linux-2.6.34-rc4//drivers/net/ehea/ehea.h
--- linux-2.6.34-rc4.orig//drivers/net/ehea/ehea.h	2010-04-19 11:54:07.000000000 +0200
+++ linux-2.6.34-rc4//drivers/net/ehea/ehea.h	2010-04-19 12:00:14.000000000 +0200
@@ -40,7 +40,7 @@
  #include <asm/io.h>

  #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0102"
+#define DRV_VERSION	"EHEA_0103"

  /* eHEA capability flags */
  #define DLPAR_PORT_ADD_REM 1
diff -Nurp linux-2.6.34-rc4.orig//drivers/net/ehea/ehea_main.c linux-2.6.34-rc4//drivers/net/ehea/ehea_main.c
--- linux-2.6.34-rc4.orig//drivers/net/ehea/ehea_main.c	2010-04-19 11:59:11.000000000 +0200
+++ linux-2.6.34-rc4//drivers/net/ehea/ehea_main.c	2010-04-19 11:59:50.000000000 +0200
@@ -2889,7 +2889,6 @@ static void ehea_rereg_mrs(struct work_s
  	int ret, i;
  	struct ehea_adapter *adapter;

-	mutex_lock(&dlpar_mem_lock);
  	ehea_info("LPAR memory changed - re-initializing driver");

  	list_for_each_entry(adapter, &adapter_list, list)
@@ -2959,7 +2958,6 @@ static void ehea_rereg_mrs(struct work_s
  		}
  	ehea_info("re-initializing driver complete");
  out:
-	mutex_unlock(&dlpar_mem_lock);
  	return;
  }

@@ -3542,7 +3540,14 @@ void ehea_crash_handler(void)
  static int ehea_mem_notifier(struct notifier_block *nb,
                               unsigned long action, void *data)
  {
+	int ret = NOTIFY_BAD;
  	struct memory_notify *arg = data;
+
+	if (!mutex_trylock(&dlpar_mem_lock)) {
+		ehea_info("ehea_mem_notifier must not be called parallelized");
+		goto out;
+	}
+
  	switch (action) {
  	case MEM_CANCEL_OFFLINE:
  		ehea_info("memory offlining canceled");
@@ -3551,14 +3556,14 @@ static int ehea_mem_notifier(struct noti
  		ehea_info("memory is going online");
  		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
  		if (ehea_add_sect_bmap(arg->start_pfn, arg->nr_pages))
-			return NOTIFY_BAD;
+			goto out_unlock;
  		ehea_rereg_mrs(NULL);
  		break;
  	case MEM_GOING_OFFLINE:
  		ehea_info("memory is going offline");
  		set_bit(__EHEA_STOP_XFER, &ehea_driver_flags);
  		if (ehea_rem_sect_bmap(arg->start_pfn, arg->nr_pages))
-			return NOTIFY_BAD;
+			goto out_unlock;
  		ehea_rereg_mrs(NULL);
  		break;
  	default:
@@ -3566,8 +3571,12 @@ static int ehea_mem_notifier(struct noti
  	}

  	ehea_update_firmware_handles();
+	ret = NOTIFY_OK;

-	return NOTIFY_OK;
+out_unlock:
+	mutex_unlock(&dlpar_mem_lock);
+out:
+	return ret;
  }

  static struct notifier_block ehea_mem_nb = {
