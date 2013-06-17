From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct net_device
 and export it to sysfs
Date: Mon, 17 Jun 2013 11:47:52 -0700
Message-ID: <51BF59D8.10806@gmail.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:39642 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090Ab3FQSsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 14:48:12 -0400
Received: by mail-oa0-f42.google.com with SMTP id n12so3897902oag.1
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 11:48:11 -0700 (PDT)
In-Reply-To: <20130617181004.GA1364@fedora-17-guest.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2013 11:10 AM, Narendra_K@Dell.com wrote:
> It is useful to know if network interfaces from NIC partitions
> 'map to/use the' same physical port. For example,  when creating
> bonding in fault tolerance mode, if  two network interfaces map to/use
> the same physical port, it might not have the desired result. This
> information is not available today in a standard format or it is not
> present.  If this information can be made available in a generic  way
> to user space, tools such as NetworkManager or Libteam or Wicked can
> make smarter bonding decisions (such as warn users when setting up
> configurations which will not have desired effect).
>
> The requirement is to have a generic interface using which
> kernel/drivers can provide information/hints to user space about the
> physical port number used by a network interface.
>
> The following options were explored -
>
> 1. 'dev_id' sysfs attribute:
>
> In addition to being used to differentiate between devices that share
> the same link layer address, it is being used to indicate the physical
> port number used by a network interface.
>
> As dev_id exists to differentiate between devices sharing the same
> link layer address, dev_id option is not selected.
>
> 2. Re-using 'if_port' field in 'struct net_device':
>
> if_port field exists to indicate the media type(please refer to
> netdevice.h). It seemed like it was also used to indicate the physical
> port number.
>
> As re-using 'if_port' might possibly break user space, this option is
> not selected.
>
> 3. Add a new field 'phys_port' to 'struct net_device' and export it
> to sysfs:
>
> The 'phys_port' will be a universally unique identifier, which
> would be a MAC-48 or EUI-64 or a 128 bit UUID value, but not
> restricted to these spaces. It will uniquely identify the physical
> port used by a network interface. The 'length' of the identifier will
> be zero if the field is not set for a network interface.
>
> This patch implements option 3. It creates a new sysfs attribute
> 'phys_port' -
>
> /sys/class/net/<interface name>/phys_port
>
> References: http://marc.info/?l=linux-netdev&m=136920998009209&w=2
> References: http://marc.info/?l=linux-netdev&m=136992041432498&w=2
>
> Signed-off-by: Narendra K <narendra_k@dell.com>
> ---
> Changes from RFC version:
>
> Suggestions from Ben Hutchings -
> 1. 'struct port_identifier' is changed to be generic instead of
> restricting it to MAC-48 or EUI-64 or 128 bit UUID.
> 2. Commit message updated to indicate point 1.
> 3. 'show_phys_port' function modified to handle zero length
> instead of returning -EINVAL
> 4. 'show_phys_port' function made generic to handle all
> lengths instead 6, 8 or 16 bytes.
>
> Hi Ben, I have retained the commit message to indicate that 'dev_id'
> is being used to indicate the physical port number also.
>
> Thank you.
>
>   include/linux/netdevice.h | 13 +++++++++++++
>   net/core/net-sysfs.c      | 17 +++++++++++++++++
>   2 files changed, 30 insertions(+)

[...]

> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -334,6 +334,22 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
>   	return netdev_store(dev, attr, buf, len, change_group);
>   }
>

Is there some missing locking here?

> +static ssize_t show_phys_port(struct device *dev,
> +			      struct device_attribute *attr, char *buf)
> +{
> +	struct net_device *net = to_net_dev(dev);
> +	unsigned char len;
> +

         read_lock(&dev_base_lock);
> +	if (!dev_isalive(net))
> +		return -EINVAL;
> +
> +	len = net->phys_port.port_id_len;
> +	if (!len)
> +		return 0;

	ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
	read_unlock(&dev_base_lock);

	return ret;
}

Please take a look maybe I missed something.

Thanks,
John

-- 
John Fastabend         Intel Corporation
