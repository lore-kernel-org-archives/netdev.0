From: linux@horizon.com
Subject: Re: IC Plus Corp IC Plus IP1000
Date: 13 Jun 2007 22:43:59 -0400
Message-ID: <20070614024359.8016.qmail@science.horizon.com>
Cc: linux@horizon.com, netdev@vger.kernel.org
To: plr@udgaard.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:15080 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750861AbXFNCoJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 22:44:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following hacks to bring it up to date got the vendor-supplied
driver working for me.  This is just fixing the things the compiler
complained about; there may be other issues, but they don't seem to
interfere with basic funtionality.


diff --git a/Makefile b/Makefile
index c91b384..31e4172 100644
--- a/Makefile
+++ b/Makefile
@@ -77,10 +77,10 @@ ifeq ($(kernelFlag26),kernel26x)
 EXTRA_CFLAGS+=$(MAPPING_MODE)
 
 all:
-	$(MAKE) -C $(KernelBuildDir) SUBDIRS=$(PWD) modules 
+	$(MAKE) -C $(KernelBuildDir) M=$(PWD)
 	
 install:
-	install -m 644 -c ipg.$(kernelExtension) $(kernelMisc)
+	$(MAKE) -C $(KernelBuildDir) M=$(PWD) modules_install
 
 ipg-objs:=$(OBJS)
 obj-m+=$(TARGET)
diff --git a/ipg.h b/ipg.h
index 2d184d4..cefe5c8 100644
--- a/ipg.h
+++ b/ipg.h
@@ -98,8 +98,8 @@
  */
 
 
-#include <linux/config.h>
 #include <linux/version.h>
+#include <linux/utsrelease.h>
 #include <linux/module.h>
 
 #if ((LINUX_VERSION_CODE < KERNEL_VERSION(2,3,0)) &&  defined(MODVERSIONS))
diff --git a/ipg_main.c b/ipg_main.c
index c39ff4a..3a0dfd4 100644
--- a/ipg_main.c
+++ b/ipg_main.c
@@ -172,9 +172,11 @@ int     ipg_io_config(IPG_DEVICE_TYPE *ipg_ethernet_device);
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
 void    ipg_interrupt_handler(int ipg_irq, void *device_instance,
                                 struct pt_regs *regs);
-#else
+#elif LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19)
 static  irqreturn_t  ipg_interrupt_handler(int ipg_irq, void *device_instance,
                                 struct pt_regs *regs);
+#else
+static  irqreturn_t  ipg_interrupt_handler(int ipg_irq, void *device_instance);
 #endif
 
 void    ipg_nic_txcleanup(IPG_DEVICE_TYPE *ipg_ethernet_device);
@@ -1425,9 +1427,11 @@ int	ipg_io_config(IPG_DEVICE_TYPE *ipg_ethernet_device)
 #if LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)
 void ipg_interrupt_handler(int ipg_irq, void *device_instance,
                                 struct pt_regs *regs)
-#else
+#elif LINUX_VERSION_CODE < KERNEL_VERSION(2,6,19)
 static  irqreturn_t  ipg_interrupt_handler(int ipg_irq, void *device_instance,
                                 struct pt_regs *regs)
+#else
+static  irqreturn_t  ipg_interrupt_handler(int ipg_irq, void *device_instance)
 #endif
 {
 	int				error;
@@ -1957,7 +1961,7 @@ int	ipg_nic_open(IPG_DEVICE_TYPE *ipg_ethernet_device)
 	 */
 	if ((error = request_irq(sp->ipg_pci_device->irq,
 	                         &ipg_interrupt_handler,
-	                         SA_SHIRQ,
+	                         IRQF_SHARED,
 	                         ipg_ethernet_device->name,
 	                         ipg_ethernet_device)) < 0)
 	{
@@ -4041,7 +4045,10 @@ int	init_module(void)
 #endif
 
 	IPG_DEBUG_MSG("init_module\n");
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,0)	
+
+#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,12)	
+	return pci_register_driver(&ipg_pci_driver);
+#elif LINUX_VERSION_CODE > KERNEL_VERSION(2,5,0)	
 	return pci_module_init(&ipg_pci_driver);
 #else
 	
