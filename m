From: Michael Neuling <mikey@neuling.org>
Subject: Re: [PATCH] ehea: Add kdump support
Date: Sat, 10 Nov 2007 11:20:22 +1100
Message-ID: <24258.1194654022@neuling.org>
References: <200711091433.51259.osstklei@de.ibm.com>
Cc: Jeff Garzik <jeff@garzik.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Ellermann <michael@ellerman.id.au>
To: Thomas Klein <osstklei@de.ibm.com>, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47192 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233AbXKJAUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:20:30 -0500
In-reply-to: <200711091433.51259.osstklei@de.ibm.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> To support ehea driver reloading in a kdump kernel the driver has to
> perform firmware handle deregistrations when the original kernel
> crashes. As there's currently no notifier chain for machine crashes
> this patch enables kdump support in the ehea driver by bending the
> ppc_md.machine_crash_shutdown hook to its own machine crash
> handler. The original machine_crash_shutdown() fn is called
> afterwards. This works fine as long as the ehea driver is the only one
> which does so. Problems may occur if other drivers do the same and
> unload regularly .  This patch enables 2.6.24-rc2 to use kdump with
> ehea and only puts a very low risk on base kernel. In 2.6.24 we know
> ehea is the only user of this mechanism. The next step for 2.6.25
> would be to add a proper notifier chain.  The full solution might be
> that register_reboot_notifier() provides sth like a SYS_CRASH
> action. Please apply.

If we are going to do this workaround, I'd prefer the notifier chain be
done correctly now.  The way it's hacked in here, it's more likely to
cause even more issues.  

Either way, if this is going to go in, it at least needs to be acked by
Paulus.

> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> 
> ---
>  drivers/net/ehea/ehea.h      |    2 +-
>  drivers/net/ehea/ehea_main.c |   28 ++++++++++++++++++++++++++++
>  2 files changed, 29 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
> index f78e5bf..5935899 100644
> --- a/drivers/net/ehea/ehea.h
> +++ b/drivers/net/ehea/ehea.h
> @@ -40,7 +40,7 @@
>  #include <asm/io.h>
>  
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0080"
> +#define DRV_VERSION	"EHEA_0081"
>  
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index f0319f1..40a732e 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -37,6 +37,7 @@
>  #include <linux/reboot.h>
>  
>  #include <net/ip.h>
> +#include <asm-powerpc/machdep.h>
>  
>  #include "ehea.h"
>  #include "ehea_qmr.h"
> @@ -98,6 +99,7 @@ static int port_name_cnt = 0;
>  static LIST_HEAD(adapter_list);
>  u64 ehea_driver_flags = 0;
>  struct work_struct ehea_rereg_mr_task;
> +static void (*orig_machine_crash_shutdown)(struct pt_regs *regs);
>  
>  struct semaphore dlpar_mem_lock;
>  
> @@ -3312,6 +3314,29 @@ static struct notifier_block ehea_reboot_nb = {
>          .notifier_call = ehea_reboot_notifier,
>  };
>  
> +void ehea_crash_notifier(struct pt_regs *regs)
> +{
> +	ehea_info("Machine crash: freeing all eHEA resources");
> +	ibmebus_unregister_driver(&ehea_driver);
> +	orig_machine_crash_shutdown(regs);
> +}
> +
> +void ehea_register_crash_notifier(void)
> +{
> +#ifdef CONFIG_KEXEC
> +	orig_machine_crash_shutdown =
> +               (void*)__xchg_u64((unsigned long*)&ppc_md.machine_crash_shutd
own,
> +				 (unsigned long)ehea_crash_notifier);
> +#endif
> +}
> +
> +void ehea_unregister_crash_notifier(void)
> +{
> +#ifdef CONFIG_KEXEC
> +	ppc_md.machine_crash_shutdown = orig_machine_crash_shutdown;
> +#endif
> +}
> +
>  static int check_module_parm(void)
>  {
>  	int ret = 0;
> @@ -3369,6 +3394,7 @@ int __init ehea_module_init(void)
>  		goto out;
>  
>  	register_reboot_notifier(&ehea_reboot_nb);
> +	ehea_register_crash_notifier();
>  
>  	ret = ibmebus_register_driver(&ehea_driver);
>  	if (ret) {
> @@ -3382,6 +3408,7 @@ int __init ehea_module_init(void)
>  		ehea_error("failed to register capabilities attribute, ret=%d",
>  			   ret);
>  		unregister_reboot_notifier(&ehea_reboot_nb);
> +		ehea_unregister_crash_notifier();
>  		ibmebus_unregister_driver(&ehea_driver);
>  		goto out;
>  	}
> @@ -3396,6 +3423,7 @@ static void __exit ehea_module_exit(void)
>  	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
>  	ibmebus_unregister_driver(&ehea_driver);
>  	unregister_reboot_notifier(&ehea_reboot_nb);
> +	ehea_unregister_crash_notifier();
>  	ehea_destroy_busmap();
>  }
>  
> -- 
> 1.5.2
> 
