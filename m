From: <Narendra_K@Dell.com>
Subject: RE: [PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Wed, 19 Jun 2013 07:29:49 -0700
Message-ID: <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>
 <51BF59D8.10806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<john.r.fastabend@intel.com>
To: <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:17249 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934417Ab3FSOak convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 10:30:40 -0400
In-Reply-To: <51BF59D8.10806@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: John Fastabend [mailto:john.fastabend@gmail.com]
> Sent: Tuesday, June 18, 2013 12:18 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> john.r.fastabend@intel.com
> Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct
> net_device and export it to sysfs
> 
> On 06/17/2013 11:10 AM, Narendra_K@Dell.com wrote:
[...] 

> > 3. Add a new field 'phys_port' to 'struct net_device' and export it to
> > sysfs:
> >
> > The 'phys_port' will be a universally unique identifier, which would
> > be a MAC-48 or EUI-64 or a 128 bit UUID value, but not restricted to
> > these spaces. It will uniquely identify the physical port used by a
> > network interface. The 'length' of the identifier will be zero if the
> > field is not set for a network interface.
> >
> > This patch implements option 3. It creates a new sysfs attribute
> > 'phys_port' -
> >
> > /sys/class/net/<interface name>/phys_port
> >
> > References: http://marc.info/?l=linux-netdev&m=136920998009209&w=2
> > References: http://marc.info/?l=linux-netdev&m=136992041432498&w=2
> >
> > Signed-off-by: Narendra K <narendra_k@dell.com>
> > ---
> > Changes from RFC version:
> >
> > Suggestions from Ben Hutchings -
> > 1. 'struct port_identifier' is changed to be generic instead of
> > restricting it to MAC-48 or EUI-64 or 128 bit UUID.
> > 2. Commit message updated to indicate point 1.
> > 3. 'show_phys_port' function modified to handle zero length instead of
> > returning -EINVAL 4. 'show_phys_port' function made generic to handle
> > all lengths instead 6, 8 or 16 bytes.
> >
> > Hi Ben, I have retained the commit message to indicate that 'dev_id'
> > is being used to indicate the physical port number also.
> >
> > Thank you.
> >
> >   include/linux/netdevice.h | 13 +++++++++++++
> >   net/core/net-sysfs.c      | 17 +++++++++++++++++
> >   2 files changed, 30 insertions(+)
> 
> [...]
> 
> > --- a/net/core/net-sysfs.c
> > +++ b/net/core/net-sysfs.c
> > @@ -334,6 +334,22 @@ static ssize_t store_group(struct device *dev,
> struct device_attribute *attr,
> >   	return netdev_store(dev, attr, buf, len, change_group);
> >   }
> >
> 
> Is there some missing locking here?
> 
> > +static ssize_t show_phys_port(struct device *dev,
> > +			      struct device_attribute *attr, char *buf) {
> > +	struct net_device *net = to_net_dev(dev);
> > +	unsigned char len;
> > +
> 
>          read_lock(&dev_base_lock);
> > +	if (!dev_isalive(net))
> > +		return -EINVAL;
> > +
> > +	len = net->phys_port.port_id_len;
> > +	if (!len)
> > +		return 0;
> 
> 	ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
> 	read_unlock(&dev_base_lock);
> 
> 	return ret;
> }
> 
> Please take a look maybe I missed something.
> 

Hi John, thanks for the pointer. It seems like we need  to hold the ' dev_base_lock' here.  I missed this initially as I was looking at ' show_broadcast' function . But looks like the 'show_broadcast' function is also missing the lock.  Attributes such as 'dev_id' are read with read_lock(&dev_base_lock) generically in netdev_show function. 

While looking at the use of ' dev_base_lock',  the 'write_lock' is being held when the 'netdev' is being added to and removed from 'dev_base_head'.  It is also being held when the 'dev->operstate'  and 'dev->link_mode' are being changed. 

The 'read_lock(&dev_base_lock)' needs to be held  before the 'dev_isalive(net) ' call because

1. netdev is not removed from 'dev_base_head' when 'show_phys_port'   accesses 'netdev->phys_port.port_id' (and port_id_len)
2. show_phys_port  function sees a consistent value of  'netdev->phys_port.port_id and netdev->phys_port.port_id_len '  if another execution path changes the value of 'netdev->phys_port.port_id and netdev->phys_port.port_id_len '  with write_lock(&dev_base_lock) held (similar to how dev->operstate is being changed).

Is the above understanding correct ? Sorry, if I missed some detail here. 

With regards,
Narendra K
Linux Engineering
Dell Inc.
