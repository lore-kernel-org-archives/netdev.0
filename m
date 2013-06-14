From: <Narendra_K@Dell.com>
Subject: Re: [RFC PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Fri, 14 Jun 2013 08:22:13 -0700
Message-ID: <20130614152144.GB1316@fedora-17-guest.blr.amer.dell.com>
References: <20130613154253.GA1380@fedora-17-guest.blr.amer.dell.com>
 <1371146488.2246.28.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:26497 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494Ab3FNPWY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 11:22:24 -0400
In-Reply-To: <1371146488.2246.28.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:31:28PM +0530, Ben Hutchings wrote:
> 
> On Thu, 2013-06-13 at 08:45 -0700, Narendra_K@Dell.com wrote:
> [...]
> > The requirement is to have a generic interface using which
> > kernel/drivers can provide information/hints to user space about the
> > physical port number used by a network interface.
> >
> > The following options were explored -
> >
> > 1. 'dev_id' sysfs attribute:
> >
> > In addition to being used to differentiate between devices that share
> > the same link layer address, it is being used to indicate the physical
> > port number used by a network interface.
> 
> This last bit is no longer true.

Right. mlx4_en driver is setting dev_id. I have sent a RFC patch to
not set dev_id. I will modify the commit message in the next version
of the patch.

> 
> [...]
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -1059,6 +1059,18 @@ struct net_device_ops {
> >                                                     bool new_carrier);
> >  };
> > 
> > +/* This structure holds a universally unique identifier to
> > + * identify the physical port used by a netdevice
> > + */
> > +struct port_identifier {
> > +     union {
> > +             u8 mac48[6];
> > +             u8 eui64[8];
> > +             u8 uuid[16];
> > +     } id;
> > +     unsigned short length;
> > +};
> 
> I can't think why those three ID-spaces would not be sufficient, but I
> also don't see any reason to restrict to them.  I think it's preferable
> to use a simple array of bytes, like for the link-layer address:
> 
>         unsigned char port_id[MAX_ADDR_LEN];
>         unsigned char port_id_len;
> 

Ok. With the above change, the switch statement below is probably not
required. Could it be like 

if (len < 0 || > MAX_ADDR_LEN)
	return -EINVAL;
if (!len)
	return 0;

ret = sysfs_format_mac(buf, net->phys_port.port_id, len);

> [...]
> > --- a/net/core/net-sysfs.c
> > +++ b/net/core/net-sysfs.c
> > @@ -334,6 +334,36 @@ static ssize_t store_group(struct device *dev, struct
> device_attribute *attr,
> >       return netdev_store(dev, attr, buf, len, change_group);
> >  }
> > 
> > +static ssize_t show_phys_port(struct device *dev,
> > +                           struct device_attribute *attr, char *buf)
> > +{
> > +     struct net_device *net = to_net_dev(dev);
> > +     ssize_t ret = -EINVAL;
> > +     unsigned short len;
> > +
> > +     if (!dev_isalive(net))
> > +             return ret;
> > +
> > +     len = net->phys_port.length;
> > +
> > +     switch (len) {
> > +     case 6:
> > +             ret = sysfs_format_mac(buf, net->phys_port.id.mac48, len);
> > +             break;
> > +     case 8:
> > +             ret = sysfs_format_mac(buf, net->phys_port.id.eui64, len);
> > +             break;
> > +     case 16:
> > +             ret = scnprintf(buf, PAGE_SIZE, "%pU\n",
> > +                             net->phys_port.id.uuid);
> > +             break;
> 
> I see, you want to use conventional UUID formatting.  But since the port
> ID might or might not be a UUID, I don't think it's that helpful to
> userland consumers.  I think it would be preferable to always use
> sysfs_format_mac().

Ok, I will use sysfs_format_mac().
> 
> > +     default:
> 
> Zero-length is the normal case now and I think it should result in
> returning 0 (=> empty file) not -EINVAL.
> 
> Ben.
> 
> > +             break;
> > +     }
> > +
> > +     return ret;
> > +}
> [...]
> 

Thank you for review comments. I will make the changes in the next
version.

> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 

-- 
With regards,
Narendra K
Linux Engineering
Dell Inc.
