From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ibmveth: Fix more little endian issues
Date: Wed, 25 Dec 2013 10:38:28 +0000
Message-ID: <1387967908.26981.0.camel@deadeye.wl.decadent.org.uk>
References: <1387762163-39662-1-git-send-email-agraf@suse.de>
	 <20131223173833.0a9a6705@kryten> <1387810329.22671.66.camel@joe-AO722>
	 <20131224125529.58970f1b@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, Alexander Graf <agraf@suse.de>,
	<linuxppc-dev@lists.ozlabs.org>,
	Ben Herrenschmidt <benh@kernel.crashing.org>,
	Dinar Valeev <dvaleev@suse.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	<netdev@vger.kernel.org>
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17149 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3LYKih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 05:38:37 -0500
In-Reply-To: <20131224125529.58970f1b@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2013-12-24 at 12:55 +1100, Anton Blanchard wrote:
> The hypervisor expects MAC addresses passed in registers to be big
> endian u64. Create a helper function called ibmveth_encode_mac_addr
> which does the right thing in both big and little endian.
> 
> We were storing the MAC address in a long in struct ibmveth_adapter.
> It's never used so remove it - we don't need another place in the
> driver where we create endian issues with MAC addresses.
[...]
> @@ -523,10 +523,20 @@ retry:
>  	return rc;
>  }
>  
> +/* The hypervisor expects MAC addresses passed in registers to be
> + * big endian u64.
> + */
> +static __be64 ibmveth_encode_mac_addr(char *mac)
> +{
> +	unsigned long encoded = 0;

u64

> +	memcpy(((char *)&encoded) + 2, mac, ETH_ALEN);
> +	return cpu_to_be64(encoded);
> +}
[...]

So on big-endian systems the byte order of the result will be:

    0 0 mac0 mac1 mac2 mac3 mac4 mac5

and on little-endian systems it's:

    mac5 mac4 mac3 mac2 mac1 mac0 0 0

It seems to me that 'encoded' is actually in big-endian order and this
function returns the address in CPU order.

So are you sure your explanation isn't backwards, because it looks to me
like the driver was already holding the MAC address in big-endian order
and perhaps the hypercall mechanism does a byte-swap when the guest is
little-endian.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
