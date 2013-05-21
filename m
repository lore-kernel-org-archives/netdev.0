From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 18:23:50 +0100
Message-ID: <1369157030.2615.24.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>
	 <20130521142650.18498.71715.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Don Skidmore" <donald.c.skidmore@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130521142650.18498.71715.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-05-21 at 17:26 +0300, Eliezer Tamir wrote:
> Adds a new ndo_ll_poll method and the code that supports and uses it.
> This method can be used by low latency applications to busy poll ethernet
> device queues directly from the socket code. The ip_low_latency_poll sysctl
> entry controls how many cycles to poll. Set to zero to disable.

Microseconds, not cycles.

[...]
> --- a/Documentation/networking/ip-sysctl.txt
> +++ b/Documentation/networking/ip-sysctl.txt
> @@ -19,6 +19,12 @@ ip_no_pmtu_disc - BOOLEAN
>  	Disable Path MTU Discovery.
>  	default FALSE
>  
> +ip_low_latency_poll - INTEGER
> +	Low latency busy poll timeout. (needs CONFIG_INET_LL_RX_POLL)
> +	Approximate time in ms to spin waiting for packets on the device queue.

us, not ms.

[...]
> --- /dev/null
> +++ b/include/net/ll_poll.h
> @@ -0,0 +1,117 @@
> +/*
> + * low latency network device queue flush
> + * Copyright(c) 2013 Intel Corporation.
> + * Author: Eliezer Tamir
> + *
> + * For now this depends on CONFIG_I86_TSC

CONFIG_X86_TSC

[...]
> +static inline bool sk_poll_ll(struct sock *sk, int nonblock)
> +{
> +	unsigned long end_time = TSC_MHZ * ACCESS_ONCE(sysctl_net_ll_poll)
> +					+ get_cycles();
> +	struct napi_struct *napi = sk->dev_ref;
> +	const struct net_device_ops *ops;
> +	int rc;
> +
> +	if (!napi->dev->netdev_ops->ndo_ll_poll)
> +		return false;
> +
> +	local_bh_disable();
> +
> +	ops = napi->dev->netdev_ops;

Should be done before testing ndo_ll_poll above, so you can avoid
repeating the indirections.

> +	while (skb_queue_empty(&sk->sk_receive_queue) &&
> +			!time_after((unsigned long)get_cycles(), end_time)) {
> +		rc = ops->ndo_ll_poll(napi);
> +
> +		if (rc == LL_FLUSH_FAILED)
> +			break; /* premanent failure */
[...]

Typo: 'permanent'.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
