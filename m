From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 2.6.21.1] nfs-root: added possibility to override default
 MTU (for UDP jumbo frames)
Date: Mon, 02 Jul 2007 09:13:36 -0400
Message-ID: <4688FA00.5050801@redhat.com>
References: <E1I5LAW-0004Dn-8b@skyboo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: manio@skyboo.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173AbXGBNNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 09:13:45 -0400
In-Reply-To: <E1I5LAW-0004Dn-8b@skyboo.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

manio@skyboo.net wrote:
> To use a NFS-root for UDP jumbo frames the kernel on the client need to bring
> up interface with MTU set to 9000 bytes - otherwise it cannot contact server
> with jumbo frames enabled (nfs server not responding, still trying) and cannot
> boot. Added a kernel parameter named 'ipmtu' which can be used to specify
> initial MTU size when booting via nfsroot.
>
>   

Could you describe the problem better, please?  Something does not
sound right.  Both ends need to have jumbo frames enabled in order
to use jumbo frames, but if one end or the other does not, the systems
still should be able to exchange packets using normal sized ethernet
packets.  Isn't this a problem that mtu discovery should handle?

    Thanx...

       ps

> Signed-off-by: Mariusz Bialonczyk <manio@skyboo.net>
>
> diff -Nru linux-2.6.21.1-orig/Documentation/kernel-parameters.txt linux-2.6.21.1/Documentation/kernel-parameters.txt
> --- linux-2.6.21.1-orig/Documentation/kernel-parameters.txt	2007-04-27 23:49:26.000000000 +0200
> +++ linux-2.6.21.1/Documentation/kernel-parameters.txt	2007-07-01 18:47:11.000000000 +0200
> @@ -720,6 +720,9 @@
>  	ip2=		[HW] Set IO/IRQ pairs for up to 4 IntelliPort boards
>  			See comment before ip2_setup() in drivers/char/ip2.c.
>  
> +	ipmtu=		[IP_PNP]
> +			See Documentation/nfsroot.txt.
> +
>  	ips=		[HW,SCSI] Adaptec / IBM ServeRAID controller
>  			See header of drivers/scsi/ips.c.
>  
> diff -Nru linux-2.6.21.1-orig/Documentation/nfsroot.txt linux-2.6.21.1/Documentation/nfsroot.txt
> --- linux-2.6.21.1-orig/Documentation/nfsroot.txt	2007-04-27 23:49:26.000000000 +0200
> +++ linux-2.6.21.1/Documentation/nfsroot.txt	2007-07-01 19:02:40.000000000 +0200
> @@ -153,6 +153,16 @@
>                  Default: any
>  
>  
> +ipmtu=<mtu_value>
> +
> +  This parameter tells the kernel to override default MTU size to specified
> +  <mtu_value>. Useful in cases where NFS server have jumbo frames enabled and
> +  client can't connect via UDP because of default MTU value (in ethernet
> +  usually 1500 bytes). With this option before bringing interface up, kernel
> +  will set the passed MTU size. In case of NFS-root booting server and client
> +  can use UDP jumbo frames (NFS's rsize and wsize set to 8192 for instance).
> +
> +
>  
>  
>  3.) Boot Loader
> diff -Nru linux-2.6.21.1-orig/net/ipv4/ipconfig.c linux-2.6.21.1/net/ipv4/ipconfig.c
> --- linux-2.6.21.1-orig/net/ipv4/ipconfig.c	2007-04-27 23:49:26.000000000 +0200
> +++ linux-2.6.21.1/net/ipv4/ipconfig.c	2007-07-01 15:44:44.000000000 +0200
> @@ -113,6 +113,8 @@
>   */
>  int ic_set_manually __initdata = 0;		/* IPconfig parameters set manually */
>  
> +unsigned int ic_mtu __initdata = 0;		/* IPconfig MTU parameter: 0 - defaults, other - override */
> +
>  static int ic_enable __initdata = 0;		/* IP config enabled? */
>  
>  /* Protocol choice */
> @@ -209,6 +211,11 @@
>  			able &= ic_proto_enabled;
>  			if (ic_proto_enabled && !able)
>  				continue;
> +			if (ic_mtu > 0)
> +			{
> +				printk(KERN_ERR "IP-Config: Overriding %s MTU to %d bytes\n", dev->name, ic_mtu);
> +				dev->mtu = ic_mtu;
> +			}
>  			oflags = dev->flags;
>  			if (dev_change_flags(dev, oflags | IFF_UP) < 0) {
>  				printk(KERN_ERR "IP-Config: Failed to open %s\n", dev->name);
> @@ -1506,5 +1513,14 @@
>  	return ip_auto_config_setup(addrs);
>  }
>  
> +static int __init mtu_config_setup(char *str)
> +{
> +	if (!str)
> +		return 0;
> +	ic_mtu = simple_strtoul(str, &str, 0);
> +	return 1;
> +}
> +
>  __setup("ip=", ip_auto_config_setup);
> +__setup("ipmtu=", mtu_config_setup);
>  __setup("nfsaddrs=", nfsaddrs_config_setup);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>   

