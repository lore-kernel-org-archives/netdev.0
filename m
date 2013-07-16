From: <Narendra_K@Dell.com>
Subject: RE: [patch net-next RFC 3/3] net: export physical port id via sysfs
Date: Tue, 16 Jul 2013 13:03:04 -0700
Message-ID: <E31FB011129F30488D5861F383904915210EF3F51F@BLRX7MCDC201.AMER.DELL.COM>
References: <1373908027-25800-1-git-send-email-jiri@resnulli.us>
 <1373908027-25800-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bhutchings@solarflare.com>, <john.r.fastabend@intel.com>
To: <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:61399 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933333Ab3GPUEQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:04:16 -0400
In-Reply-To: <1373908027-25800-4-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Jiri Pirko [mailto:jiri@resnulli.us]
> Sent: Monday, July 15, 2013 10:37 PM
> To: netdev@vger.kernel.org
> Cc: K, Narendra; bhutchings@solarflare.com; john.r.fastabend@intel.com
> Subject: [patch net-next RFC 3/3] net: export physical port id via sysfs
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/core/net-sysfs.c | 41
> +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 41 insertions(+)
> 
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c index
> 981fed3..fb19ede 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -334,6 +334,46 @@ static ssize_t store_group(struct device *dev, struct
> device_attribute *attr,
>  	return netdev_store(dev, attr, buf, len, change_group);  }
> 
> +static size_t _format_port_id(char *buf, int buflen,
> +			      const unsigned char *id, int len) {
> +	int i;
> +	char *cp = buf;
> +
> +	for (i = 0; i < len; i++)
> +		cp += scnprintf(cp, buflen - (cp - buf), "%02x", id[i]);
> +	return cp - buf;
> +}
> +
> +ssize_t sysfs_format_port_id(char *buf, const unsigned char *id, int
> +len) {
> +	size_t l;
> +
> +	l = _format_port_id(buf, PAGE_SIZE, id, len);
> +	l += scnprintf(buf + l, PAGE_SIZE - l, "\n");
> +	return (ssize_t)l;
> +}
> +static ssize_t show_phys_port_id(struct device *dev,
> +				 struct device_attribute *attr, char *buf) {
> +	struct net_device *netdev = to_net_dev(dev);
> +	ssize_t ret = 0;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	if (dev_isalive(netdev) && netdev->netdev_ops-
> >ndo_get_phys_port_id) {
> +		struct netdev_phys_port_id ppid;
> +
> +		ret = netdev->netdev_ops->ndo_get_phys_port_id(netdev,
> &ppid);
[>] 

Hello,
I am thinking if "ndo_get_phys_port_id()" is required.  With it, the driver needs to generate port_id  every time "ndo_get_phys_port_id()" is called, but the "netdev->phys_port.port_id" might not have changed.  If 'phys_port'  structure is part of 'struct net_device',  then 'netdev->phys_port.port_id' and port_id_len are set by driver before calling 'register_netdev' and are available to the core.  Driver not implementing it would indicate it by a "port_id_len" of zero.     If the "netdev->phys_port.port_id" changes for some reason then the notification sent by the driver would ensure that the interested kernel components and user space are notified of the change.

With regards,
Narendra K
Linux Engineering
Dell Inc.
