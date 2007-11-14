From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ipconfig.c : implement DHCP Class-identifier
Date: Wed, 14 Nov 2007 09:56:15 +0100
Message-ID: <473AB82F.8050801@trash.net>
References: <20071108143205.GA22490@mpi-sb.mpg.de> <47332F1F.5040401@trash.net> <20071114084420.GA29241@mpi-sb.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pcernko@mpi-sws.mpg.de
To: Rainer Jochem <rainer.jochem@mpi-sb.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38247 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbXKNI40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 03:56:26 -0500
In-Reply-To: <20071114084420.GA29241@mpi-sb.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rainer Jochem wrote:
> Corrected version below.
> 
>>> +			printk(KERN_INFO "Sending class identifier \"%s\"\n",
>>> +			       vendor_class_identifier);
>> Seems like useless noise.
> 
> This information is only sent in the case that the option is actually used.
> And in this case it might be useful for the user to see to which string the 
> option was set.


I don't think its very useful since you can simply get this information
from /proc/cmdline in case something goes wrong, but if you insist at
least give it a meaningful prefix.

> @@ -580,6 +582,7 @@ ic_dhcp_init_options(u8 *options)
>  	u8 mt = ((ic_servaddr == NONE)
>  		 ? DHCPDISCOVER : DHCPREQUEST);
>  	u8 *e = options;
> +	int len = 0;

The initialization is unnecessary.

>  #ifdef IPCONFIG_DEBUG
>  	printk("DHCP: Sending message type %d\n", mt);
> @@ -620,6 +623,16 @@ ic_dhcp_init_options(u8 *options)
>  		*e++ = sizeof(ic_req_params);
>  		memcpy(e, ic_req_params, sizeof(ic_req_params));
>  		e += sizeof(ic_req_params);
> +
> +		if (*vendor_class_identifier) {
> +			printk(KERN_INFO "Sending class identifier \"%s\"\n",
> +			       vendor_class_identifier);
> +			*e++ = 60;	/* Class-identifier */
> +			len = strlen(vendor_class_identifier);
> +			*e++ = len;
> +			memcpy(e, vendor_class_identifier, len);
> +			e += len;
> +		}
>  	}
>  
>  	*e++ = 255;	/* End of the list */
> @@ -1507,5 +1520,16 @@ static int __init nfsaddrs_config_setup(
>  	return ip_auto_config_setup(addrs);
>  }
>  
> +static int __init vendor_class_identifier_setup(char *addrs)
> +{
> +	if (strlcpy(vendor_class_identifier, addrs,
> +		    sizeof(vendor_class_identifier))
> +	    > sizeof(vendor_class_identifier))
> +		printk(KERN_WARNING "vendorclass too long, truncated to \"%s\"",
> +		       vendor_class_identifier);

Should be >= I think.
