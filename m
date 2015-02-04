From: Thomas Monjalon <thomas.monjalon@6wind.com>
Subject: Re: hyper-v: allow access to vmbus from userspace driver
Date: Wed, 04 Feb 2015 14:42:43 +0100
Message-ID: <2084158.GG5mBQGd4q@xps13>
References: <20150203110345.15c38345@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	devel@linuxdriverproject.org, netdev@vger.kernel.org, dev@dpdk.org
To: stephen hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:46208 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932995AbbBDNnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 08:43:13 -0500
Received: by mail-wg0-f50.google.com with SMTP id b13so1767404wgh.9
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 05:43:12 -0800 (PST)
In-Reply-To: <20150203110345.15c38345@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

2015-02-03 11:03, stephen hemminger:
> Brocade is submitting a hyper-v driver for DPDK <dev@dpdk.org>
> but this driver needs a hook in the hyper-v bus layer
> to allow the additional hv_uio driver to access the shared vmbus
> pages. The hv_uio driver lives in DPDK (like igb_uio) and provides
> userspace access to raw network packets.
> 
> Signed-off-by: Stas Egorov <segorov@mirantis.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

The hyper-v driver for DPDK has not been sent yet to
	http://dpdk.org/dev/patchwork
but it would be interesting to better explain this uio mapping.

Thanks
-- 
Thomas


> --- a/drivers/hv/connection.c	2015-02-03 10:58:51.751752450 -0800
> +++ b/drivers/hv/connection.c	2015-02-03 10:58:51.751752450 -0800
> @@ -64,6 +64,21 @@ static __u32 vmbus_get_next_version(__u3
>  	}
>  }
>  
> +static const uuid_le HV_NET_GUID = {
> +	.b = {
> +		0x63, 0x51, 0x61, 0xf8, 0x3e, 0xdf, 0xc5, 0x46,
> +		0x91, 0x3f, 0xf2, 0xd2, 0xf9, 0x65, 0xed, 0x0e
> +	}
> +};
> +
> +void vmbus_get_pages(unsigned long *int_page, unsigned long monitor_pages[2])
> +{
> +	*int_page = (unsigned long)vmbus_connection.int_page;
> +	monitor_pages[0] = (unsigned long)vmbus_connection.monitor_pages[0];
> +	monitor_pages[1] = (unsigned long)vmbus_connection.monitor_pages[1];
> +}
> +EXPORT_SYMBOL_GPL(vmbus_get_pages);
> +
>  static int vmbus_negotiate_version(struct vmbus_channel_msginfo *msginfo,
>  					__u32 version)
>  {
> @@ -347,7 +362,8 @@ static void process_chn_event(u32 relid)
>  			else
>  				bytes_to_read = 0;
>  		} while (read_state && (bytes_to_read != 0));
> -	} else {
> +	} else if (!memcmp(&channel->device_obj->dev_type, &HV_NET_GUID,
> +			   sizeof(uuid_le))) {
>  		pr_err("no channel callback for relid - %u\n", relid);
>  	}
>  
> --- a/include/linux/hyperv.h	2015-02-03 10:58:51.751752450 -0800
> +++ b/include/linux/hyperv.h	2015-02-03 10:58:51.751752450 -0800
> @@ -868,6 +868,9 @@ extern int vmbus_recvpacket_raw(struct v
>  
>  extern void vmbus_ontimer(unsigned long data);
>  
> +extern void vmbus_get_pages(unsigned long *int_page,
> +			    unsigned long monitor_pages[2]);
> +
>  /* Base driver object */
>  struct hv_driver {
>  	const char *name;
