From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be
 processed during probe
Date: Fri, 17 Jul 2015 10:00:43 +0000
Message-ID: <4fd650437f864cf2a58e8334253f5dcd@SIXPR30MB031.064d.mgd.msft.net>
References: <1437074222-13020-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KY Srinivasan <kys@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, "vkuznets@redhat.com"
 <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1437074222-13020-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: K. Y. Srinivasan 
> Sent: Friday, July 17, 2015 3:17
> Subject: [PATCH net-next 1/1] hv_netvsc: Wait for sub-channels to be processed
> during probe
> diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
> ...
> @@ -1116,6 +1127,9 @@ int rndis_filter_device_add(struct hv_device *dev,
>  	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
>  	net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
> 
> +	num_rss_qs = net_device->num_chn - 1;
> +	net_device->num_sc_offered = num_rss_qs;
> +
>  	if (net_device->num_chn == 1)
>  		goto out;
> 
> @@ -1157,11 +1171,22 @@ int rndis_filter_device_add(struct hv_device *dev,
> 
>  	ret = rndis_filter_set_rss_param(rndis_device, net_device->num_chn);
> 
> +	/*
> +	 * Wait for the host to send us the sub-channel offers.
> +	 */
> +	spin_lock_irqsave(&net_device->sc_lock, flags);
> +	sc_delta = net_device->num_chn - 1 - num_rss_qs;
> +	net_device->num_sc_offered -= sc_delta;

Hi KY,
IMO here the "-= " should be "+="?

I think sc_delta is usually <= 0, meaning the host may allocate less subchannels than
we expect.
With "-=", net_device->num_sc_offered can become bigger -- this doesn't seem correct.

Why not use 
"net_device->num_sc_offered = net_device->num_chn - 1;" directly?
At this point, net_device->num_chn has been the number of the actual channels.


> +	spin_unlock_irqrestore(&net_device->sc_lock, flags);
> +
> +	if (net_device->num_sc_offered != 0)
> +		wait_for_completion(&net_device->channel_init_wait);

BTW, I also tested the patch and I can confirm the panic I saw disappeared with the patch.

-- Dexuan
