From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Fri, 14 Jun 2013 17:27:20 +0100
Message-ID: <1371227240.1940.9.camel@bwh-desktop.uk.level5networks.com>
References: <20130613154253.GA1380@fedora-17-guest.blr.amer.dell.com>
	 <1371146488.2246.28.camel@bwh-desktop.uk.level5networks.com>
	 <20130614152144.GB1316@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:43508 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375Ab3FNQ1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 12:27:30 -0400
In-Reply-To: <20130614152144.GB1316@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-14 at 08:22 -0700, Narendra_K@Dell.com wrote:
> On Thu, Jun 13, 2013 at 11:31:28PM +0530, Ben Hutchings wrote:
> > 
> > On Thu, 2013-06-13 at 08:45 -0700, Narendra_K@Dell.com wrote:
> > [...]
> > > The requirement is to have a generic interface using which
> > > kernel/drivers can provide information/hints to user space about the
> > > physical port number used by a network interface.
> > >
> > > The following options were explored -
> > >
> > > 1. 'dev_id' sysfs attribute:
> > >
> > > In addition to being used to differentiate between devices that share
> > > the same link layer address, it is being used to indicate the physical
> > > port number used by a network interface.
> > 
> > This last bit is no longer true.
> 
> Right. mlx4_en driver is setting dev_id. I have sent a RFC patch to
> not set dev_id. I will modify the commit message in the next version
> of the patch.

Oh, I forgot that mlx4_en also misused dev_id.

> > 
> > [...]
> > > --- a/include/linux/netdevice.h
> > > +++ b/include/linux/netdevice.h
> > > @@ -1059,6 +1059,18 @@ struct net_device_ops {
> > >                                                     bool new_carrier);
> > >  };
> > > 
> > > +/* This structure holds a universally unique identifier to
> > > + * identify the physical port used by a netdevice
> > > + */
> > > +struct port_identifier {
> > > +     union {
> > > +             u8 mac48[6];
> > > +             u8 eui64[8];
> > > +             u8 uuid[16];
> > > +     } id;
> > > +     unsigned short length;
> > > +};
> > 
> > I can't think why those three ID-spaces would not be sufficient, but I
> > also don't see any reason to restrict to them.  I think it's preferable
> > to use a simple array of bytes, like for the link-layer address:
> > 
> >         unsigned char port_id[MAX_ADDR_LEN];
> >         unsigned char port_id_len;
> > 
> 
> Ok. With the above change, the switch statement below is probably not
> required. Could it be like 
> 
> if (len < 0 || > MAX_ADDR_LEN)

I don't think any range check is needed at all.  If the port_id_len is
out of ragne that's an obvious bug in the driver which I don't think you
need to check for.  (The networking core doesn't currently check
addr_len, for example.)  And an unsigned length cannot be < 0 anyway!

> 	return -EINVAL;
> if (!len)
> 	return 0;
> 
> ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
[...]

Right.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
