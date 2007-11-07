From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error recovery
Date: Wed, 07 Nov 2007 14:45:18 -0800
Message-ID: <47323FFE.2060008@intel.com>
References: <20071107211935.GH4239@austin.ibm.com> <20071107212404.GA15251@austin.ibm.com> <47323319.10709@intel.com> <20071107222446.GM4239@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: wenxiong@us.ibm.com, e1000-devel@lists.sourceforge.net,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	'Stephen Hemminger' <shemminger@linux-foundation.org>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24831 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758436AbXKGWpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 17:45:38 -0500
In-Reply-To: <20071107222446.GM4239@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[adding netdev, jeff G to the Cc]

Linas Vepstas wrote:
> On Wed, Nov 07, 2007 at 01:50:17PM -0800, Kok, Auke wrote:
>> Linas Vepstas wrote:
>>> If a PCI bus error is encountered during device open, the
>>> error recovery routines will attempt to close the device.
>>> If napi has not yet been enabled, the napi disable in the
>>> close will hang. 
>>>
>>> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
>>>
>>> ----
>>> The "elegence" of this solution is arguable: one could
>>> say its "better" to perform this check in e1000_down().
>>> However, doing so will disrupt a commonly used path,
>>> whereas here, the hack is in the infrequently used
>>> error path, and thus less intrusive. 
>>>
>>>  drivers/net/e1000/e1000_main.c |    9 ++++++++-
>>>  1 file changed, 8 insertions(+), 1 deletion(-)
>>>
>>> Index: linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c
>>> ===================================================================
>>> --- linux-2.6.23-rc8-mm1.orig/drivers/net/e1000/e1000_main.c	2007-11-07 15:04:45.000000000 -0600
>>> +++ linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c	2007-11-07 15:04:52.000000000 -0600
>>> @@ -5268,8 +5268,15 @@ static pci_ers_result_t e1000_io_error_d
>>>  
>>>  	netif_device_detach(netdev);
>>>  
>>> -	if (netif_running(netdev))
>>> +	if (netif_running(netdev)) {
>>> +#ifdef CONFIG_E1000_NAPI
>>> +		/* e1000_down will spinlock in napi_disable() if we
>>> +		 * catch an error before napi_enable() was called. */
>>> +		if (test_bit(NAPI_STATE_SCHED, &adapter->napi.state))
>>> +			napi_enable(&adapter->napi);
>>> +#endif
>>>  		e1000_down(adapter);
>>> +	}
>>>  	pci_disable_device(pdev);
>>>  
>>>  	/* Request a slot slot reset. */
>> I think this is OK, but it's quite awful looking if you ask me.
> 
> Yeah, ... 
> 
> There are several alternatives: below are two. If you
> find one to be more appealing.. could you use it? Consider them
> to be "signed-off-by"; I have not actually compiled or tested
> either of them.

I'm not a particular fan of putting extra state tracking in the driver for
something we could extract from the napi subsystem already.

Jeff, Stephen, can't we have a generic napi_enabled() inline in netdevice.h that
tests for NAPI_STATE_SCHED ?

I wonder if there isn't something in the PCI error recovery missing the point and
we can solve this problem better for all drivers somehow.

Auke



> 
> 
>  drivers/net/e1000/e1000_main.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/drivers/net/e1000/e1000_main.c	2007-11-07 16:11:36.000000000 -0600
> +++ linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c	2007-11-07 16:15:17.000000000 -0600
> @@ -633,7 +633,11 @@ e1000_down(struct e1000_adapter *adapter
>  	set_bit(__E1000_DOWN, &adapter->flags);
>  
>  #ifdef CONFIG_E1000_NAPI
> -	napi_disable(&adapter->napi);
> +	/* napi_disable() will spinlock if we are in the
> +	 * pci error recovery path, and caught a pci
> +	 * error before napi_enable() was called. */
> +	if (!test_bit(NAPI_STATE_SCHED, &adapter->napi.state))
> +		napi_disable(&adapter->napi);
>  #endif
>  	e1000_irq_disable(adapter);
>  
> and here's another:
> 
>  drivers/net/e1000/e1000.h      |    1 +
>  drivers/net/e1000/e1000_main.c |    7 ++++++-
>  2 files changed, 7 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000.h
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/drivers/net/e1000/e1000.h	2007-09-26 15:06:56.000000000 -0500
> +++ linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000.h	2007-11-07 16:19:16.000000000 -0600
> @@ -301,6 +301,7 @@ struct e1000_adapter {
>  	struct e1000_rx_ring *rx_ring;      /* One per active queue */
>  #ifdef CONFIG_E1000_NAPI
>  	struct napi_struct napi;
> +	int napi_enabled;
>  	struct net_device *polling_netdev;  /* One per active queue */
>  #endif
>  	int num_tx_queues;
> Index: linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c
> ===================================================================
> --- linux-2.6.23-rc8-mm1.orig/drivers/net/e1000/e1000_main.c	2007-11-07 16:16:11.000000000 -0600
> +++ linux-2.6.23-rc8-mm1/drivers/net/e1000/e1000_main.c	2007-11-07 16:22:30.000000000 -0600
> @@ -545,6 +545,7 @@ int e1000_up(struct e1000_adapter *adapt
>  
>  #ifdef CONFIG_E1000_NAPI
>  	napi_enable(&adapter->napi);
> +	adapter->napi_enabled = 1;
>  #endif
>  	e1000_irq_enable(adapter);
>  
> @@ -633,7 +634,10 @@ e1000_down(struct e1000_adapter *adapter
>  	set_bit(__E1000_DOWN, &adapter->flags);
>  
>  #ifdef CONFIG_E1000_NAPI
> -	napi_disable(&adapter->napi);
> +	if (adapter->napi_enabled) {
> +		napi_disable(&adapter->napi);
> +		adapter->napi_enabled = 0;
> +	}
>  #endif
>  	e1000_irq_disable(adapter);
>  
> @@ -1437,6 +1441,7 @@ e1000_open(struct net_device *netdev)
>  
>  #ifdef CONFIG_E1000_NAPI
>  	napi_enable(&adapter->napi);
> +	adapter->napi_enabled = 1;
>  #endif
>  
>  	e1000_irq_enable(adapter);
