From: Subrata Modak <subrata@linux.vnet.ibm.com>
Subject: Re: [RFC] ehea: kdump support using new shutdown hook
Date: Thu, 13 Dec 2007 17:06:55 +0530
Message-ID: <1197545815.4755.31.camel@subratamodak.linux.ibm.com>
References: <200712121753.43543.osstklei@de.ibm.com>
Reply-To: subrata@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Stefan Roscher <stefan.roscher@de.ibm.com>,
	Michael Ellermann <michael@ellerman.id.au>,
	Michael Neuling <mikey@neuling.org>,
	ltp-list <ltp-list@lists.sourceforge.net>
To: Thomas Klein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:36976 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbXLMLhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 06:37:15 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lBDAZIfM010314
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 05:35:18 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lBDBb1C8111608
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 04:37:06 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lBDBaxuh018470
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 04:37:00 -0700
In-Reply-To: <200712121753.43543.osstklei@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you think we can improve upon our own LTP-KDUMP test cases housed
here:
http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kdump/,

because of your changes below:

--Subrata

On Wed, 2007-12-12 at 17:53 +0100, Thomas Klein wrote:
> This patch adds kdump support using the new PPC crash shutdown hook to the
> ehea driver. The driver now keeps a list of firmware handles which have to
> be freed in case of a crash. The crash handler does the minimum required: it
> frees the firmware resource handles plus broadcast/multicast registrations.
> 
> Please comment.
> 
> Shutdown hook patches:
>   http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048058.html
>   http://ozlabs.org/pipermail/linuxppc-dev/2007-December/048059.html
> 
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> 
> ---
> diff -Nurp -X dontdiff linux-2.6.24-rc5/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
> --- linux-2.6.24-rc5/drivers/net/ehea/ehea.h	2007-12-11 04:48:43.000000000 +0100
> +++ patched_kernel/drivers/net/ehea/ehea.h	2007-12-12 17:30:53.000000000 +0100
> @@ -40,7 +40,7 @@
>  #include <asm/io.h>
> 
>  #define DRV_NAME	"ehea"
> -#define DRV_VERSION	"EHEA_0083"
> +#define DRV_VERSION	"EHEA_0084"
> 
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> @@ -386,6 +386,7 @@ struct ehea_port_res {
> 
> 
>  #define EHEA_MAX_PORTS 16
> +#define EHEA_MAX_RES_HANDLES (100 * EHEA_MAX_PORTS + 10)
>  struct ehea_adapter {
>  	u64 handle;
>  	struct of_device *ofdev;
> @@ -397,6 +398,7 @@ struct ehea_adapter {
>  	u64 max_mc_mac;            /* max number of multicast mac addresses */
>  	int active_ports;
>  	struct list_head list;
> +	u64 res_handles[EHEA_MAX_RES_HANDLES];
>  };
> 
> 
> diff -Nurp -X dontdiff linux-2.6.24-rc5/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
> --- linux-2.6.24-rc5/drivers/net/ehea/ehea_main.c	2007-12-11 04:48:43.000000000 +0100
> +++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-12-12 17:30:53.000000000 +0100
> @@ -35,6 +35,7 @@
>  #include <linux/if_ether.h>
>  #include <linux/notifier.h>
>  #include <linux/reboot.h>
> +#include <asm-powerpc/kexec.h>
> 
>  #include <net/ip.h>
> 
> @@ -2256,6 +2257,33 @@ static int ehea_clean_all_portres(struct
>  	return ret;
>  }
> 
> +static void ehea_update_adapter_handles(struct ehea_adapter *adapter)
> +{
> +	int i, k;
> +	int j = 0;
> +
> +	memset(adapter->res_handles, sizeof(adapter->res_handles), 0);
> +
> +	for (k = 0; k < EHEA_MAX_PORTS; k++) {
> +		struct ehea_port *port = adapter->port[k];
> +
> +		if (!port || (port->state != EHEA_PORT_UP))
> +			continue;
> +
> +		for(i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
> +			struct ehea_port_res *pr = &port->port_res[i];
> +
> +			adapter->res_handles[j++] = pr->qp->fw_handle;
> +			adapter->res_handles[j++] = pr->send_cq->fw_handle;
> +			adapter->res_handles[j++] = pr->recv_cq->fw_handle;
> +			adapter->res_handles[j++] = pr->eq->fw_handle;
> +			adapter->res_handles[j++] = pr->send_mr.handle;
> +			adapter->res_handles[j++] = pr->recv_mr.handle;
> +		}
> +		adapter->res_handles[j++] = port->qp_eq->fw_handle;
> +	}
> +}
> +
>  static void ehea_remove_adapter_mr(struct ehea_adapter *adapter)
>  {
>  	if (adapter->active_ports)
> @@ -2318,6 +2346,7 @@ static int ehea_up(struct net_device *de
> 
>  	ret = 0;
>  	port->state = EHEA_PORT_UP;
> +	ehea_update_adapter_handles(port->adapter);
>  	goto out;
> 
>  out_free_irqs:
> @@ -2387,6 +2416,8 @@ static int ehea_down(struct net_device *
>  		ehea_info("Failed freeing resources for %s. ret=%i",
>  			  dev->name, ret);
> 
> +	ehea_update_adapter_handles(port->adapter);
> +
>  	return ret;
>  }
> 
> @@ -3302,6 +3333,71 @@ static int __devexit ehea_remove(struct 
>  	return 0;
>  }
> 
> +void ehea_crash_deregister(void)
> +{
> +	struct ehea_adapter *adapter;
> +	int i;
> +	u64 hret;
> +	u8 reg_type;
> +
> +	list_for_each_entry(adapter, &adapter_list, list) {
> +		for (i = 0; i < EHEA_MAX_PORTS; i++) {
> +			struct ehea_port *port = adapter->port[i];
> +			if (port->state == EHEA_PORT_UP) {
> +				struct ehea_mc_list *mc_entry = port->mc_list;
> +				struct list_head *pos;
> +				struct list_head *temp;
> +
> +				/* Undo multicast registrations */
> +				list_for_each_safe(pos, temp,
> +						   &(port->mc_list->list)) {
> +					mc_entry = list_entry(pos,
> +							    struct ehea_mc_list,
> +							    list);
> +					ehea_multicast_reg_helper(port,
> +							      mc_entry->macaddr,
> +							      H_DEREG_BCMC);
> +				}
> +
> +				/* Undo broad registration */
> +				reg_type = EHEA_BCMC_BROADCAST |
> +					   EHEA_BCMC_UNTAGGED;
> +				ehea_h_reg_dereg_bcmc(port->adapter->handle,
> +						      port->logical_port_id,
> +						      reg_type, port->mac_addr,
> +						      0, H_DEREG_BCMC);
> +
> +				reg_type = EHEA_BCMC_BROADCAST |
> +					   EHEA_BCMC_VLANID_ALL;
> +				ehea_h_reg_dereg_bcmc(port->adapter->handle,
> +						      port->logical_port_id,
> +						      reg_type, port->mac_addr,
> +						      0, H_DEREG_BCMC);
> +			}
> +		}
> +		for (i = 0; i < EHEA_MAX_RES_HANDLES; i++) {
> +			u64 handle = adapter->res_handles[i];
> +			if (handle) {
> +				hret = ehea_h_free_resource(adapter->handle,
> +							    handle,
> +							    FORCE_FREE);
> +			}
> +		}
> +
> +		if (adapter->neq) {
> +			hret = ehea_h_free_resource(adapter->handle,
> +						    adapter->neq->fw_handle,
> +						    FORCE_FREE);
> +		}
> +
> +		if (adapter->mr.handle) {
> +			hret = ehea_h_free_resource(adapter->handle,
> +						    adapter->mr.handle,
> +						    FORCE_FREE);
> +		}
> +	}
> +}
> +
>  static int ehea_reboot_notifier(struct notifier_block *nb,
>  				unsigned long action, void *unused)
>  {
> @@ -3373,6 +3469,9 @@ int __init ehea_module_init(void)
>  		goto out;
> 
>  	register_reboot_notifier(&ehea_reboot_nb);
> +	ret = crash_shutdown_register(&ehea_crash_deregister);
> +	if (ret)
> +		ehea_info("failed registering crash handler");
> 
>  	ret = ibmebus_register_driver(&ehea_driver);
>  	if (ret) {
> @@ -3386,6 +3485,7 @@ int __init ehea_module_init(void)
>  		ehea_error("failed to register capabilities attribute, ret=%d",
>  			   ret);
>  		unregister_reboot_notifier(&ehea_reboot_nb);
> +		crash_shutdown_unregister(&ehea_crash_deregister);
>  		ibmebus_unregister_driver(&ehea_driver);
>  		goto out;
>  	}
> @@ -3396,10 +3496,15 @@ out:
> 
>  static void __exit ehea_module_exit(void)
>  {
> +	int ret;
> +
>  	flush_scheduled_work();
>  	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
>  	ibmebus_unregister_driver(&ehea_driver);
>  	unregister_reboot_notifier(&ehea_reboot_nb);
> +	ret = crash_shutdown_unregister(&ehea_crash_deregister);
> +	if (ret)
> +		ehea_info("failed unregistering crash handler");
>  	ehea_destroy_busmap();
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

