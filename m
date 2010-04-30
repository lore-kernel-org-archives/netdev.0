From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH]PM QOS refresh against next-20100430
Date: Sat, 1 May 2010 00:13:16 +0200
Message-ID: <201005010013.16262.rjw@sisk.pl>
References: <20100430212043.GA30315@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kevin Hilman <khilman@deeprootsystems.com>, aili@codeaurora.org,
	dwalker@codeaurora.org, tiwai@suse.de, bruce.w.allan@intel.com,
	davidb@quicinc.com, mcgrof@gmail.com, pavel@ucw.cz,
	"linux-pm" <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Len Brown <lenb@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: mgross@linux.intel.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <20100430212043.GA30315@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 30 April 2010, mark gross wrote:
> The following is a refresh of the PM_QOS implementation, this patch
> updates some documentation input I got from Randy.
> 
> This patch changes the string based list management to a handle base
> implementation to help with the hot path use of pm-qos, it also renames
> much of the API to use "request" as opposed to "requirement" that was
> used in the initial implementation.  I did this because request more
> accurately represents what it actually does.
> 
> Also, I added a string based ABI for users wanting to use a string
> interface.  So if the user writes 0xDDDDDDDD formatted hex it will be
> accepted by the interface.  (someone asked me for it and I don't think
> it hurts anything.)
> 
> I really would like to get this refresh taken care of.  Its been taking
> me too long to close this.  please review or include it in next.
> 
> Thanks!

Well, I'd take it to suspend-2.6/linux-next, but first, it touches
subsystems whose maintainers were not in the Cc list, like the network
drivers, wireless and ACPI.  The changes are trivial, so I hope they don't
mind.

Second, my tree is based on the Linus' tree rather than linux-next and
the change in net/mac80211/scan.c doesn't seem to match that.  Please tell me
what I'm supposed to do about that.

Thanks,
Rafael

 
> Ooops! forgot the signed off by line!
> 
> Signed-off-by: mark gross <mgross@linux.intel.com>
> 
> From c45d8d86f89ac55fbb9a499fbc754e35258bf818 Mon Sep 17 00:00:00 2001
> From: mgross <mark.gross@gmail.com>
> Date: Sat, 13 Mar 2010 08:18:36 -0800
> Subject: [PATCH 1/2] PM_QOS to use handle based list implementation and exported function name changes to be more descriptive of what is actually happening.
> 
> ---
>  Documentation/power/pm_qos_interface.txt |   48 ++++---
>  drivers/acpi/processor_idle.c            |    2 +-
>  drivers/cpuidle/governors/ladder.c       |    2 +-
>  drivers/cpuidle/governors/menu.c         |    2 +-
>  drivers/net/e1000e/netdev.c              |   22 ++--
>  drivers/net/igbvf/netdev.c               |    6 +-
>  drivers/net/wireless/ipw2x00/ipw2100.c   |   11 +-
>  include/linux/netdevice.h                |    4 +
>  include/linux/pm_qos_params.h            |   14 +-
>  include/sound/pcm.h                      |    3 +-
>  kernel/pm_qos_params.c                   |  214 ++++++++++++++---------------
>  net/mac80211/mlme.c                      |    2 +-
>  net/mac80211/scan.c                      |    2 +-
>  sound/core/pcm.c                         |    3 -
>  sound/core/pcm_native.c                  |   14 +-
>  15 files changed, 177 insertions(+), 172 deletions(-)
> 
> diff --git a/Documentation/power/pm_qos_interface.txt b/Documentation/power/pm_qos_interface.txt
> index c40866e..bfed898 100644
> --- a/Documentation/power/pm_qos_interface.txt
> +++ b/Documentation/power/pm_qos_interface.txt
> @@ -18,44 +18,46 @@ and pm_qos_params.h.  This is done because having the available parameters
>  being runtime configurable or changeable from a driver was seen as too easy to
>  abuse.
>  
> -For each parameter a list of performance requirements is maintained along with
> +For each parameter a list of performance requests is maintained along with
>  an aggregated target value.  The aggregated target value is updated with
> -changes to the requirement list or elements of the list.  Typically the
> -aggregated target value is simply the max or min of the requirement values held
> +changes to the request list or elements of the list.  Typically the
> +aggregated target value is simply the max or min of the request values held
>  in the parameter list elements.
>  
>  From kernel mode the use of this interface is simple:
> -pm_qos_add_requirement(param_id, name, target_value):
> -Will insert a named element in the list for that identified PM_QOS parameter
> -with the target value.  Upon change to this list the new target is recomputed
> -and any registered notifiers are called only if the target value is now
> -different.
>  
> -pm_qos_update_requirement(param_id, name, new_target_value):
> -Will search the list identified by the param_id for the named list element and
> -then update its target value, calling the notification tree if the aggregated
> -target is changed.  with that name is already registered.
> +handle = pm_qos_add_request(param_class, target_value):
> +Will insert an element into the list for that identified PM_QOS class with the
> +target value.  Upon change to this list the new target is recomputed and any
> +registered notifiers are called only if the target value is now different.
> +Clients of pm_qos need to save the returned handle.
>  
> -pm_qos_remove_requirement(param_id, name):
> -Will search the identified list for the named element and remove it, after
> -removal it will update the aggregate target and call the notification tree if
> -the target was changed as a result of removing the named requirement.
> +void pm_qos_update_request(handle, new_target_value):
> +Will update the list element pointed to by the handle with the new target value
> +and recompute the new aggregated target, calling the notification tree if the
> +target is changed.
> +
> +void pm_qos_remove_request(handle):
> +Will remove the element.  After removal it will update the aggregate target and
> +call the notification tree if the target was changed as a result of removing
> +the request.
>  
>  
>  From user mode:
> -Only processes can register a pm_qos requirement.  To provide for automatic
> -cleanup for process the interface requires the process to register its
> -parameter requirements in the following way:
> +Only processes can register a pm_qos request.  To provide for automatic
> +cleanup of a process, the interface requires the process to register its
> +parameter requests in the following way:
>  
>  To register the default pm_qos target for the specific parameter, the process
>  must open one of /dev/[cpu_dma_latency, network_latency, network_throughput]
>  
>  As long as the device node is held open that process has a registered
> -requirement on the parameter.  The name of the requirement is "process_<PID>"
> -derived from the current->pid from within the open system call.
> +request on the parameter.
>  
> -To change the requested target value the process needs to write a s32 value to
> -the open device node.  This translates to a pm_qos_update_requirement call.
> +To change the requested target value the process needs to write an s32 value to
> +the open device node.  Alternatively the user mode program could write a hex
> +string for the value using 10 char long format e.g. "0x12345678".  This
> +translates to a pm_qos_update_request call.
>  
>  To remove the user mode request for a target value simply close the device
>  node.
> diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
> index 5939e7f..c3817e1 100644
> --- a/drivers/acpi/processor_idle.c
> +++ b/drivers/acpi/processor_idle.c
> @@ -698,7 +698,7 @@ static int acpi_processor_power_seq_show(struct seq_file *seq, void *offset)
>  		   "max_cstate:              C%d\n"
>  		   "maximum allowed latency: %d usec\n",
>  		   pr->power.state ? pr->power.state - pr->power.states : 0,
> -		   max_cstate, pm_qos_requirement(PM_QOS_CPU_DMA_LATENCY));
> +		   max_cstate, pm_qos_request(PM_QOS_CPU_DMA_LATENCY));
>  
>  	seq_puts(seq, "states:\n");
>  
> diff --git a/drivers/cpuidle/governors/ladder.c b/drivers/cpuidle/governors/ladder.c
> index 1c1ceb4..12c9890 100644
> --- a/drivers/cpuidle/governors/ladder.c
> +++ b/drivers/cpuidle/governors/ladder.c
> @@ -67,7 +67,7 @@ static int ladder_select_state(struct cpuidle_device *dev)
>  	struct ladder_device *ldev = &__get_cpu_var(ladder_devices);
>  	struct ladder_device_state *last_state;
>  	int last_residency, last_idx = ldev->last_state_idx;
> -	int latency_req = pm_qos_requirement(PM_QOS_CPU_DMA_LATENCY);
> +	int latency_req = pm_qos_request(PM_QOS_CPU_DMA_LATENCY);
>  
>  	/* Special case when user has set very strict latency requirement */
>  	if (unlikely(latency_req == 0)) {
> diff --git a/drivers/cpuidle/governors/menu.c b/drivers/cpuidle/governors/menu.c
> index 1aea715..61ca939 100644
> --- a/drivers/cpuidle/governors/menu.c
> +++ b/drivers/cpuidle/governors/menu.c
> @@ -183,7 +183,7 @@ static u64 div_round64(u64 dividend, u32 divisor)
>  static int menu_select(struct cpuidle_device *dev)
>  {
>  	struct menu_device *data = &__get_cpu_var(menu_devices);
> -	int latency_req = pm_qos_requirement(PM_QOS_CPU_DMA_LATENCY);
> +	int latency_req = pm_qos_request(PM_QOS_CPU_DMA_LATENCY);
>  	int i;
>  	int multiplier;
>  
> diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
> index 904bd6b..7550879 100644
> --- a/drivers/net/e1000e/netdev.c
> +++ b/drivers/net/e1000e/netdev.c
> @@ -2882,12 +2882,12 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
>  			 * excessive C-state transition latencies result in
>  			 * dropped transactions.
>  			 */
> -			pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
> -						  adapter->netdev->name, 55);
> +			pm_qos_update_request(
> +				adapter->netdev->pm_qos_req, 55);
>  		} else {
> -			pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY,
> -						  adapter->netdev->name,
> -						  PM_QOS_DEFAULT_VALUE);
> +			pm_qos_update_request(
> +				adapter->netdev->pm_qos_req,
> +				PM_QOS_DEFAULT_VALUE);
>  		}
>  	}
>  
> @@ -3181,8 +3181,8 @@ int e1000e_up(struct e1000_adapter *adapter)
>  
>  	/* DMA latency requirement to workaround early-receive/jumbo issue */
>  	if (adapter->flags & FLAG_HAS_ERT)
> -		pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY,
> -		                       adapter->netdev->name,
> +		adapter->netdev->pm_qos_req =
> +			pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
>  				       PM_QOS_DEFAULT_VALUE);
>  
>  	/* hardware has been reset, we need to reload some things */
> @@ -3244,9 +3244,11 @@ void e1000e_down(struct e1000_adapter *adapter)
>  	e1000_clean_tx_ring(adapter);
>  	e1000_clean_rx_ring(adapter);
>  
> -	if (adapter->flags & FLAG_HAS_ERT)
> -		pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY,
> -		                          adapter->netdev->name);
> +	if (adapter->flags & FLAG_HAS_ERT) {
> +		pm_qos_remove_request(
> +			      adapter->netdev->pm_qos_req);
> +		adapter->netdev->pm_qos_req = NULL;
> +	}
>  
>  	/*
>  	 * TODO: for power management, we could drop the link and
> diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
> index 7012e3d..5e2b2a8 100644
> --- a/drivers/net/igbvf/netdev.c
> +++ b/drivers/net/igbvf/netdev.c
> @@ -48,6 +48,7 @@
>  #define DRV_VERSION "1.0.0-k0"
>  char igbvf_driver_name[] = "igbvf";
>  const char igbvf_driver_version[] = DRV_VERSION;
> +struct pm_qos_request_list *igbvf_driver_pm_qos_req;
>  static const char igbvf_driver_string[] =
>  				"Intel(R) Virtual Function Network Driver";
>  static const char igbvf_copyright[] = "Copyright (c) 2009 Intel Corporation.";
> @@ -2901,7 +2902,7 @@ static int __init igbvf_init_module(void)
>  	printk(KERN_INFO "%s\n", igbvf_copyright);
>  
>  	ret = pci_register_driver(&igbvf_driver);
> -	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, igbvf_driver_name,
> +	igbvf_driver_pm_qos_req = pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
>  	                       PM_QOS_DEFAULT_VALUE);
>  
>  	return ret;
> @@ -2917,7 +2918,8 @@ module_init(igbvf_init_module);
>  static void __exit igbvf_exit_module(void)
>  {
>  	pci_unregister_driver(&igbvf_driver);
> -	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, igbvf_driver_name);
> +	pm_qos_remove_request(igbvf_driver_pm_qos_req);
> +	igbvf_driver_pm_qos_req = NULL;
>  }
>  module_exit(igbvf_exit_module);
>  
> diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
> index 2088ac0..7040e3b 100644
> --- a/drivers/net/wireless/ipw2x00/ipw2100.c
> +++ b/drivers/net/wireless/ipw2x00/ipw2100.c
> @@ -174,6 +174,8 @@ that only one external action is invoked at a time.
>  #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2100 Network Driver"
>  #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
>  
> +struct pm_qos_request_list *ipw2100_pm_qos_req;
> +
>  /* Debugging stuff */
>  #ifdef CONFIG_IPW2100_DEBUG
>  #define IPW2100_RX_DEBUG	/* Reception debugging */
> @@ -1739,7 +1741,7 @@ static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
>  	/* the ipw2100 hardware really doesn't want power management delays
>  	 * longer than 175usec
>  	 */
> -	pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY, "ipw2100", 175);
> +	pm_qos_update_request(ipw2100_pm_qos_req, 175);
>  
>  	/* If the interrupt is enabled, turn it off... */
>  	spin_lock_irqsave(&priv->low_lock, flags);
> @@ -1887,8 +1889,7 @@ static void ipw2100_down(struct ipw2100_priv *priv)
>  	ipw2100_disable_interrupts(priv);
>  	spin_unlock_irqrestore(&priv->low_lock, flags);
>  
> -	pm_qos_update_requirement(PM_QOS_CPU_DMA_LATENCY, "ipw2100",
> -			PM_QOS_DEFAULT_VALUE);
> +	pm_qos_update_request(ipw2100_pm_qos_req, PM_QOS_DEFAULT_VALUE);
>  
>  	/* We have to signal any supplicant if we are disassociating */
>  	if (associated)
> @@ -6669,7 +6670,7 @@ static int __init ipw2100_init(void)
>  	if (ret)
>  		goto out;
>  
> -	pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY, "ipw2100",
> +	ipw2100_pm_qos_req = pm_qos_add_request(PM_QOS_CPU_DMA_LATENCY,
>  			PM_QOS_DEFAULT_VALUE);
>  #ifdef CONFIG_IPW2100_DEBUG
>  	ipw2100_debug_level = debug;
> @@ -6692,7 +6693,7 @@ static void __exit ipw2100_exit(void)
>  			   &driver_attr_debug_level);
>  #endif
>  	pci_unregister_driver(&ipw2100_pci_driver);
> -	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY, "ipw2100");
> +	pm_qos_remove_request(ipw2100_pm_qos_req);
>  }
>  
>  module_init(ipw2100_init);
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 40d4c20..5dd6d8c 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -31,6 +31,7 @@
>  #include <linux/if_link.h>
>  
>  #ifdef __KERNEL__
> +#include <linux/pm_qos_params.h>
>  #include <linux/timer.h>
>  #include <linux/delay.h>
>  #include <linux/mm.h>
> @@ -778,6 +779,9 @@ struct net_device {
>  	 * the interface.
>  	 */
>  	char			name[IFNAMSIZ];
> +
> +	struct pm_qos_request_list *pm_qos_req;
> +
>  	/* device name hash chain */
>  	struct hlist_node	name_hlist;
>  	/* snmp alias */
> diff --git a/include/linux/pm_qos_params.h b/include/linux/pm_qos_params.h
> index d74f75e..8ba440e 100644
> --- a/include/linux/pm_qos_params.h
> +++ b/include/linux/pm_qos_params.h
> @@ -14,12 +14,14 @@
>  #define PM_QOS_NUM_CLASSES 4
>  #define PM_QOS_DEFAULT_VALUE -1
>  
> -int pm_qos_add_requirement(int qos, char *name, s32 value);
> -int pm_qos_update_requirement(int qos, char *name, s32 new_value);
> -void pm_qos_remove_requirement(int qos, char *name);
> +struct pm_qos_request_list;
>  
> -int pm_qos_requirement(int qos);
> +struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value);
> +void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> +		s32 new_value);
> +void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req);
>  
> -int pm_qos_add_notifier(int qos, struct notifier_block *notifier);
> -int pm_qos_remove_notifier(int qos, struct notifier_block *notifier);
> +int pm_qos_request(int pm_qos_class);
> +int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier);
> +int pm_qos_remove_notifier(int pm_qos_class, struct notifier_block *notifier);
>  
> diff --git a/include/sound/pcm.h b/include/sound/pcm.h
> index 8b611a5..dd76cde 100644
> --- a/include/sound/pcm.h
> +++ b/include/sound/pcm.h
> @@ -29,6 +29,7 @@
>  #include <linux/poll.h>
>  #include <linux/mm.h>
>  #include <linux/bitops.h>
> +#include <linux/pm_qos_params.h>
>  
>  #define snd_pcm_substream_chip(substream) ((substream)->private_data)
>  #define snd_pcm_chip(pcm) ((pcm)->private_data)
> @@ -365,7 +366,7 @@ struct snd_pcm_substream {
>  	int number;
>  	char name[32];			/* substream name */
>  	int stream;			/* stream (direction) */
> -	char latency_id[20];		/* latency identifier */
> +	struct pm_qos_request_list *latency_pm_qos_req; /* pm_qos request */
>  	size_t buffer_bytes_max;	/* limit ring buffer size */
>  	struct snd_dma_buffer dma_buffer;
>  	unsigned int dma_buf_id;
> diff --git a/kernel/pm_qos_params.c b/kernel/pm_qos_params.c
> index 3db49b9..a1aea04 100644
> --- a/kernel/pm_qos_params.c
> +++ b/kernel/pm_qos_params.c
> @@ -2,7 +2,7 @@
>   * This module exposes the interface to kernel space for specifying
>   * QoS dependencies.  It provides infrastructure for registration of:
>   *
> - * Dependents on a QoS value : register requirements
> + * Dependents on a QoS value : register requests
>   * Watchers of QoS value : get notified when target QoS value changes
>   *
>   * This QoS design is best effort based.  Dependents register their QoS needs.
> @@ -14,19 +14,21 @@
>   * timeout: usec <-- currently not used.
>   * throughput: kbs (kilo byte / sec)
>   *
> - * There are lists of pm_qos_objects each one wrapping requirements, notifiers
> + * There are lists of pm_qos_objects each one wrapping requests, notifiers
>   *
> - * User mode requirements on a QOS parameter register themselves to the
> + * User mode requests on a QOS parameter register themselves to the
>   * subsystem by opening the device node /dev/... and writing there request to
>   * the node.  As long as the process holds a file handle open to the node the
>   * client continues to be accounted for.  Upon file release the usermode
> - * requirement is removed and a new qos target is computed.  This way when the
> - * requirement that the application has is cleaned up when closes the file
> + * request is removed and a new qos target is computed.  This way when the
> + * request that the application has is cleaned up when closes the file
>   * pointer or exits the pm_qos_object will get an opportunity to clean up.
>   *
>   * Mark Gross <mgross@linux.intel.com>
>   */
>  
> +/*#define DEBUG*/
> +
>  #include <linux/pm_qos_params.h>
>  #include <linux/sched.h>
>  #include <linux/spinlock.h>
> @@ -42,25 +44,25 @@
>  #include <linux/uaccess.h>
>  
>  /*
> - * locking rule: all changes to requirements or notifiers lists
> + * locking rule: all changes to requests or notifiers lists
>   * or pm_qos_object list and pm_qos_objects need to happen with pm_qos_lock
>   * held, taken with _irqsave.  One lock to rule them all
>   */
> -struct requirement_list {
> +struct pm_qos_request_list {
>  	struct list_head list;
>  	union {
>  		s32 value;
>  		s32 usec;
>  		s32 kbps;
>  	};
> -	char *name;
> +	int pm_qos_class;
>  };
>  
>  static s32 max_compare(s32 v1, s32 v2);
>  static s32 min_compare(s32 v1, s32 v2);
>  
>  struct pm_qos_object {
> -	struct requirement_list requirements;
> +	struct pm_qos_request_list requests;
>  	struct blocking_notifier_head *notifiers;
>  	struct miscdevice pm_qos_power_miscdev;
>  	char *name;
> @@ -72,7 +74,7 @@ struct pm_qos_object {
>  static struct pm_qos_object null_pm_qos;
>  static BLOCKING_NOTIFIER_HEAD(cpu_dma_lat_notifier);
>  static struct pm_qos_object cpu_dma_pm_qos = {
> -	.requirements = {LIST_HEAD_INIT(cpu_dma_pm_qos.requirements.list)},
> +	.requests = {LIST_HEAD_INIT(cpu_dma_pm_qos.requests.list)},
>  	.notifiers = &cpu_dma_lat_notifier,
>  	.name = "cpu_dma_latency",
>  	.default_value = 2000 * USEC_PER_SEC,
> @@ -82,7 +84,7 @@ static struct pm_qos_object cpu_dma_pm_qos = {
>  
>  static BLOCKING_NOTIFIER_HEAD(network_lat_notifier);
>  static struct pm_qos_object network_lat_pm_qos = {
> -	.requirements = {LIST_HEAD_INIT(network_lat_pm_qos.requirements.list)},
> +	.requests = {LIST_HEAD_INIT(network_lat_pm_qos.requests.list)},
>  	.notifiers = &network_lat_notifier,
>  	.name = "network_latency",
>  	.default_value = 2000 * USEC_PER_SEC,
> @@ -93,8 +95,7 @@ static struct pm_qos_object network_lat_pm_qos = {
>  
>  static BLOCKING_NOTIFIER_HEAD(network_throughput_notifier);
>  static struct pm_qos_object network_throughput_pm_qos = {
> -	.requirements =
> -		{LIST_HEAD_INIT(network_throughput_pm_qos.requirements.list)},
> +	.requests = {LIST_HEAD_INIT(network_throughput_pm_qos.requests.list)},
>  	.notifiers = &network_throughput_notifier,
>  	.name = "network_throughput",
>  	.default_value = 0,
> @@ -135,31 +136,34 @@ static s32 min_compare(s32 v1, s32 v2)
>  }
>  
>  
> -static void update_target(int target)
> +static void update_target(int pm_qos_class)
>  {
>  	s32 extreme_value;
> -	struct requirement_list *node;
> +	struct pm_qos_request_list *node;
>  	unsigned long flags;
>  	int call_notifier = 0;
>  
>  	spin_lock_irqsave(&pm_qos_lock, flags);
> -	extreme_value = pm_qos_array[target]->default_value;
> +	extreme_value = pm_qos_array[pm_qos_class]->default_value;
>  	list_for_each_entry(node,
> -			&pm_qos_array[target]->requirements.list, list) {
> -		extreme_value = pm_qos_array[target]->comparitor(
> +			&pm_qos_array[pm_qos_class]->requests.list, list) {
> +		extreme_value = pm_qos_array[pm_qos_class]->comparitor(
>  				extreme_value, node->value);
>  	}
> -	if (atomic_read(&pm_qos_array[target]->target_value) != extreme_value) {
> +	if (atomic_read(&pm_qos_array[pm_qos_class]->target_value) !=
> +			extreme_value) {
>  		call_notifier = 1;
> -		atomic_set(&pm_qos_array[target]->target_value, extreme_value);
> -		pr_debug(KERN_ERR "new target for qos %d is %d\n", target,
> -			atomic_read(&pm_qos_array[target]->target_value));
> +		atomic_set(&pm_qos_array[pm_qos_class]->target_value,
> +				extreme_value);
> +		pr_debug(KERN_ERR "new target for qos %d is %d\n", pm_qos_class,
> +			atomic_read(&pm_qos_array[pm_qos_class]->target_value));
>  	}
>  	spin_unlock_irqrestore(&pm_qos_lock, flags);
>  
>  	if (call_notifier)
> -		blocking_notifier_call_chain(pm_qos_array[target]->notifiers,
> -			(unsigned long) extreme_value, NULL);
> +		blocking_notifier_call_chain(
> +				pm_qos_array[pm_qos_class]->notifiers,
> +					(unsigned long) extreme_value, NULL);
>  }
>  
>  static int register_pm_qos_misc(struct pm_qos_object *qos)
> @@ -185,125 +189,110 @@ static int find_pm_qos_object_by_minor(int minor)
>  }
>  
>  /**
> - * pm_qos_requirement - returns current system wide qos expectation
> + * pm_qos_request - returns current system wide qos expectation
>   * @pm_qos_class: identification of which qos value is requested
>   *
>   * This function returns the current target value in an atomic manner.
>   */
> -int pm_qos_requirement(int pm_qos_class)
> +int pm_qos_request(int pm_qos_class)
>  {
>  	return atomic_read(&pm_qos_array[pm_qos_class]->target_value);
>  }
> -EXPORT_SYMBOL_GPL(pm_qos_requirement);
> +EXPORT_SYMBOL_GPL(pm_qos_request);
>  
>  /**
> - * pm_qos_add_requirement - inserts new qos request into the list
> + * pm_qos_add_request - inserts new qos request into the list
>   * @pm_qos_class: identifies which list of qos request to us
> - * @name: identifies the request
>   * @value: defines the qos request
>   *
>   * This function inserts a new entry in the pm_qos_class list of requested qos
>   * performance characteristics.  It recomputes the aggregate QoS expectations
> - * for the pm_qos_class of parameters.
> + * for the pm_qos_class of parameters, and returns the pm_qos_request list
> + * element as a handle for use in updating and removal.  Call needs to save
> + * this handle for later use.
>   */
> -int pm_qos_add_requirement(int pm_qos_class, char *name, s32 value)
> +struct pm_qos_request_list *pm_qos_add_request(int pm_qos_class, s32 value)
>  {
> -	struct requirement_list *dep;
> +	struct pm_qos_request_list *dep;
>  	unsigned long flags;
>  
> -	dep = kzalloc(sizeof(struct requirement_list), GFP_KERNEL);
> +	dep = kzalloc(sizeof(struct pm_qos_request_list), GFP_KERNEL);
>  	if (dep) {
>  		if (value == PM_QOS_DEFAULT_VALUE)
>  			dep->value = pm_qos_array[pm_qos_class]->default_value;
>  		else
>  			dep->value = value;
> -		dep->name = kstrdup(name, GFP_KERNEL);
> -		if (!dep->name)
> -			goto cleanup;
> +		dep->pm_qos_class = pm_qos_class;
>  
>  		spin_lock_irqsave(&pm_qos_lock, flags);
>  		list_add(&dep->list,
> -			&pm_qos_array[pm_qos_class]->requirements.list);
> +			&pm_qos_array[pm_qos_class]->requests.list);
>  		spin_unlock_irqrestore(&pm_qos_lock, flags);
>  		update_target(pm_qos_class);
> -
> -		return 0;
>  	}
>  
> -cleanup:
> -	kfree(dep);
> -	return -ENOMEM;
> +	return dep;
>  }
> -EXPORT_SYMBOL_GPL(pm_qos_add_requirement);
> +EXPORT_SYMBOL_GPL(pm_qos_add_request);
>  
>  /**
> - * pm_qos_update_requirement - modifies an existing qos request
> - * @pm_qos_class: identifies which list of qos request to us
> - * @name: identifies the request
> + * pm_qos_update_request - modifies an existing qos request
> + * @pm_qos_req : handle to list element holding a pm_qos request to use
>   * @value: defines the qos request
>   *
> - * Updates an existing qos requirement for the pm_qos_class of parameters along
> + * Updates an existing qos request for the pm_qos_class of parameters along
>   * with updating the target pm_qos_class value.
>   *
> - * If the named request isn't in the list then no change is made.
> + * Attempts are made to make this code callable on hot code paths.
>   */
> -int pm_qos_update_requirement(int pm_qos_class, char *name, s32 new_value)
> +void pm_qos_update_request(struct pm_qos_request_list *pm_qos_req,
> +		s32 new_value)
>  {
>  	unsigned long flags;
> -	struct requirement_list *node;
>  	int pending_update = 0;
> +	s32 temp;
>  
>  	spin_lock_irqsave(&pm_qos_lock, flags);
> -	list_for_each_entry(node,
> -		&pm_qos_array[pm_qos_class]->requirements.list, list) {
> -		if (strcmp(node->name, name) == 0) {
> -			if (new_value == PM_QOS_DEFAULT_VALUE)
> -				node->value =
> -				pm_qos_array[pm_qos_class]->default_value;
> -			else
> -				node->value = new_value;
> -			pending_update = 1;
> -			break;
> -		}
> +	if (new_value == PM_QOS_DEFAULT_VALUE)
> +		temp = pm_qos_array[pm_qos_req->pm_qos_class]->default_value;
> +	else
> +		temp = new_value;
> +
> +	if (temp != pm_qos_req->value) {
> +		pending_update = 1;
> +		pm_qos_req->value = temp;
>  	}
>  	spin_unlock_irqrestore(&pm_qos_lock, flags);
>  	if (pending_update)
> -		update_target(pm_qos_class);
> -
> -	return 0;
> +		update_target(pm_qos_req->pm_qos_class);
>  }
> -EXPORT_SYMBOL_GPL(pm_qos_update_requirement);
> +EXPORT_SYMBOL_GPL(pm_qos_update_request);
>  
>  /**
> - * pm_qos_remove_requirement - modifies an existing qos request
> - * @pm_qos_class: identifies which list of qos request to us
> - * @name: identifies the request
> + * pm_qos_remove_request - modifies an existing qos request
> + * @pm_qos_req: handle to request list element
>   *
> - * Will remove named qos request from pm_qos_class list of parameters and
> - * recompute the current target value for the pm_qos_class.
> + * Will remove pm qos request from the list of requests and
> + * recompute the current target value for the pm_qos_class.  Call this
> + * on slow code paths.
>   */
> -void pm_qos_remove_requirement(int pm_qos_class, char *name)
> +void pm_qos_remove_request(struct pm_qos_request_list *pm_qos_req)
>  {
>  	unsigned long flags;
> -	struct requirement_list *node;
> -	int pending_update = 0;
> +	int qos_class;
> +
> +	if (pm_qos_req == NULL)
> +		return;
> +		/* silent return to keep pcm code cleaner */
>  
> +	qos_class = pm_qos_req->pm_qos_class;
>  	spin_lock_irqsave(&pm_qos_lock, flags);
> -	list_for_each_entry(node,
> -		&pm_qos_array[pm_qos_class]->requirements.list, list) {
> -		if (strcmp(node->name, name) == 0) {
> -			kfree(node->name);
> -			list_del(&node->list);
> -			kfree(node);
> -			pending_update = 1;
> -			break;
> -		}
> -	}
> +	list_del(&pm_qos_req->list);
> +	kfree(pm_qos_req);
>  	spin_unlock_irqrestore(&pm_qos_lock, flags);
> -	if (pending_update)
> -		update_target(pm_qos_class);
> +	update_target(qos_class);
>  }
> -EXPORT_SYMBOL_GPL(pm_qos_remove_requirement);
> +EXPORT_SYMBOL_GPL(pm_qos_remove_request);
>  
>  /**
>   * pm_qos_add_notifier - sets notification entry for changes to target value
> @@ -313,7 +302,7 @@ EXPORT_SYMBOL_GPL(pm_qos_remove_requirement);
>   * will register the notifier into a notification chain that gets called
>   * upon changes to the pm_qos_class target value.
>   */
> - int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier)
> +int pm_qos_add_notifier(int pm_qos_class, struct notifier_block *notifier)
>  {
>  	int retval;
>  
> @@ -343,21 +332,16 @@ int pm_qos_remove_notifier(int pm_qos_class, struct notifier_block *notifier)
>  }
>  EXPORT_SYMBOL_GPL(pm_qos_remove_notifier);
>  
> -#define PID_NAME_LEN 32
> -
>  static int pm_qos_power_open(struct inode *inode, struct file *filp)
>  {
> -	int ret;
>  	long pm_qos_class;
> -	char name[PID_NAME_LEN];
>  
>  	pm_qos_class = find_pm_qos_object_by_minor(iminor(inode));
>  	if (pm_qos_class >= 0) {
> -		filp->private_data = (void *)pm_qos_class;
> -		snprintf(name, PID_NAME_LEN, "process_%d", current->pid);
> -		ret = pm_qos_add_requirement(pm_qos_class, name,
> -					PM_QOS_DEFAULT_VALUE);
> -		if (ret >= 0)
> +		filp->private_data = (void *) pm_qos_add_request(pm_qos_class,
> +				PM_QOS_DEFAULT_VALUE);
> +
> +		if (filp->private_data)
>  			return 0;
>  	}
>  	return -EPERM;
> @@ -365,32 +349,40 @@ static int pm_qos_power_open(struct inode *inode, struct file *filp)
>  
>  static int pm_qos_power_release(struct inode *inode, struct file *filp)
>  {
> -	int pm_qos_class;
> -	char name[PID_NAME_LEN];
> +	struct pm_qos_request_list *req;
>  
> -	pm_qos_class = (long)filp->private_data;
> -	snprintf(name, PID_NAME_LEN, "process_%d", current->pid);
> -	pm_qos_remove_requirement(pm_qos_class, name);
> +	req = (struct pm_qos_request_list *)filp->private_data;
> +	pm_qos_remove_request(req);
>  
>  	return 0;
>  }
>  
> +
>  static ssize_t pm_qos_power_write(struct file *filp, const char __user *buf,
>  		size_t count, loff_t *f_pos)
>  {
>  	s32 value;
> -	int pm_qos_class;
> -	char name[PID_NAME_LEN];
> -
> -	pm_qos_class = (long)filp->private_data;
> -	if (count != sizeof(s32))
> +	int x;
> +	char ascii_value[11];
> +	struct pm_qos_request_list *pm_qos_req;
> +
> +	if (count == sizeof(s32)) {
> +		if (copy_from_user(&value, buf, sizeof(s32)))
> +			return -EFAULT;
> +	} else if (count == 11) { /* len('0x12345678/0') */
> +		if (copy_from_user(ascii_value, buf, 11))
> +			return -EFAULT;
> +		x = sscanf(ascii_value, "%x", &value);
> +		if (x != 1)
> +			return -EINVAL;
> +		pr_debug(KERN_ERR "%s, %d, 0x%x\n", ascii_value, x, value);
> +	} else
>  		return -EINVAL;
> -	if (copy_from_user(&value, buf, sizeof(s32)))
> -		return -EFAULT;
> -	snprintf(name, PID_NAME_LEN, "process_%d", current->pid);
> -	pm_qos_update_requirement(pm_qos_class, name, value);
>  
> -	return  sizeof(s32);
> +	pm_qos_req = (struct pm_qos_request_list *)filp->private_data;
> +	pm_qos_update_request(pm_qos_req, value);
> +
> +	return count;
>  }
>  
>  
> diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
> index 358226f..3deaac3 100644
> --- a/net/mac80211/mlme.c
> +++ b/net/mac80211/mlme.c
> @@ -507,7 +507,7 @@ void ieee80211_recalc_ps(struct ieee80211_local *local, s32 latency)
>  		s32 beaconint_us;
>  
>  		if (latency < 0)
> -			latency = pm_qos_requirement(PM_QOS_NETWORK_LATENCY);
> +			latency = pm_qos_request(PM_QOS_NETWORK_LATENCY);
>  
>  		beaconint_us = ieee80211_tu_to_usec(
>  					found->vif.bss_conf.beacon_int);
> diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
> index 8bc961f..be52bb8 100644
> --- a/net/mac80211/scan.c
> +++ b/net/mac80211/scan.c
> @@ -510,7 +510,7 @@ static int ieee80211_scan_state_decision(struct ieee80211_local *local,
>  		bad_latency = time_after(jiffies +
>  				ieee80211_scan_get_channel_time(next_chan),
>  				local->leave_oper_channel_time +
> -				usecs_to_jiffies(pm_qos_requirement(PM_QOS_NETWORK_LATENCY)));
> +				usecs_to_jiffies(pm_qos_request(PM_QOS_NETWORK_LATENCY)));
>  
>  		listen_int_exceeded = time_after(jiffies +
>  				ieee80211_scan_get_channel_time(next_chan),
> diff --git a/sound/core/pcm.c b/sound/core/pcm.c
> index 0d428d0..cbe815d 100644
> --- a/sound/core/pcm.c
> +++ b/sound/core/pcm.c
> @@ -648,9 +648,6 @@ int snd_pcm_new_stream(struct snd_pcm *pcm, int stream, int substream_count)
>  		substream->number = idx;
>  		substream->stream = stream;
>  		sprintf(substream->name, "subdevice #%i", idx);
> -		snprintf(substream->latency_id, sizeof(substream->latency_id),
> -			 "ALSA-PCM%d-%d%c%d", pcm->card->number, pcm->device,
> -			 (stream ? 'c' : 'p'), idx);
>  		substream->buffer_bytes_max = UINT_MAX;
>  		if (prev == NULL)
>  			pstr->substream = substream;
> diff --git a/sound/core/pcm_native.c b/sound/core/pcm_native.c
> index c22ebb0..1bb0e23 100644
> --- a/sound/core/pcm_native.c
> +++ b/sound/core/pcm_native.c
> @@ -481,11 +481,13 @@ static int snd_pcm_hw_params(struct snd_pcm_substream *substream,
>  	snd_pcm_timer_resolution_change(substream);
>  	runtime->status->state = SNDRV_PCM_STATE_SETUP;
>  
> -	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY,
> -				substream->latency_id);
> +	if (substream->latency_pm_qos_req) {
> +		pm_qos_remove_request(substream->latency_pm_qos_req);
> +		substream->latency_pm_qos_req = NULL;
> +	}
>  	if ((usecs = period_to_usecs(runtime)) >= 0)
> -		pm_qos_add_requirement(PM_QOS_CPU_DMA_LATENCY,
> -					substream->latency_id, usecs);
> +		substream->latency_pm_qos_req = pm_qos_add_request(
> +					PM_QOS_CPU_DMA_LATENCY, usecs);
>  	return 0;
>   _error:
>  	/* hardware might be unuseable from this time,
> @@ -540,8 +542,8 @@ static int snd_pcm_hw_free(struct snd_pcm_substream *substream)
>  	if (substream->ops->hw_free)
>  		result = substream->ops->hw_free(substream);
>  	runtime->status->state = SNDRV_PCM_STATE_OPEN;
> -	pm_qos_remove_requirement(PM_QOS_CPU_DMA_LATENCY,
> -		substream->latency_id);
> +	pm_qos_remove_request(substream->latency_pm_qos_req);
> +	substream->latency_pm_qos_req = NULL;
>  	return result;
>  }
>  
> 

