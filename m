From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 02/39] wimax: declarations for the in-kernel WiMAX API
Date: Mon, 24 Nov 2008 16:36:41 -0800
Message-ID: <200811241636.42085.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com> <200811241543.33830.inaky@linux.intel.com> <20081124161222.10927011@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:55905 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753148AbYKYAmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 19:42:37 -0500
In-Reply-To: <20081124161222.10927011@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 November 2008, Stephen Hemminger wrote:
> On Mon, 24 Nov 2008 15:43:33 -0800
>
> Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> > On Monday 24 November 2008, Stephen Hemminger wrote:
> > > On Mon, 24 Nov 2008 13:50:25 -0800
> > >
> > > Inaky Perez-Gonzalez <inaky@linux.intel.com> wrote:
> > > > [...snip...]
> > > > + */
> > > > +struct wimax_dev {
> > > > +	struct net_device *net_dev;
> > > > +	struct list_head id_table_node;
> > > > +	struct list_head pipe_list;
> > > > +	struct wimax_pipe *pipe_msg;
> > > > +	struct mutex mutex;		/* Protects all members and API calls */
> > > > +	enum wimax_st state;
> > > > +
> > > > +	int (*op_msg_from_user)(struct wimax_dev *wimax_dev,
> > > > +				const void *, size_t,
> > > > +				const struct genl_info *info);
> > > > +	int (*op_rfkill_sw_toggle)(struct wimax_dev *wimax_dev,
> > > > +				   enum wimax_rf_state);
> > > > +	int (*op_reset)(struct wimax_dev *wimax_dev);
> > >
> > > Move function pointers separate from data??
> >
> > Most devices will have only a single adapter, so I thought it was not
> > worth the overhead of the double dereference when average you will have a
> > single copy.
> >
> > > > +	struct genl_family gnl_family;
> > >
> > > Isn't family for all of wimax not per device?
> >
> > Nope, it is per device. One generic netlink family per device (named
> > "WiMAX DEVICENAME").
> >
> > Makes it very easy in user and kernel space, no need for the overhead of
> > having an extra attribute for the destination interface.
> >
> > > > +	struct rfkill *rfkill;
> > > > +	struct input_dev *rfkill_input;
> > > > +	unsigned rf_hw:1;
> > > > +	unsigned rf_sw:1;
> > >
> > > don't bother with bitfield overhead make them u8
> >
> > sure
> >
> > > > +	char name[32];
> > > > +};
> > >
> > > Why have name in this data structure? Do you handle network device
> > > renames properly?
> >
> > This is a physical name, not the network interface name (recommended name
> > in the members documentation is DRIVERNAME:physical path.
> >
> > The reason is it is used to register different things (rfkill device,
> > input device for rfkill, threads). It being tied to the physical path
> > makes it easy to map and not vulnerable to renames.
> >
> > Now it might be too short, that's another matter.
>
> Then shouldn't it be a 'struct device' and live in sysfs class hierarchy??

I am not sure I am following in the need for that.

In the case of the Intel device, it is a USB device, with the "primary node" 
being a USB interface -- that is the parent of a 'struct device' that is the 
netdev (wmx0).

But the name I am using for those things I need to register is the driver and 
bus path name of the USB interface, as they cannot change.

If we dynamically rename the network ifname from wmx0 to myinterface, for 
example, we won't be able to change the names of the different things were we 
had to give a name (like rfkill, the rfkill associated input devices and the 
kernel threads the driver needs). So we need a name that is not allowed to 
change and still makes sense, ergo the physical path of the device.

That is only for internal kernel stuff, and some stuff will show in user 
space:

$ cat /sys/class/net/wmx0/device/rfkill:rfkill1
i2400m-usb:5-2:1.0

but I think this is still better than showing "wmx0" after a rename from wmx0 
to myinterfacename.

Maybe there is a way to permeate those name changes--if so, I am more than 
happy to look into it if you could give me pointers; but still, would it be 
worth the trouble?

Thanks,

And of course, we still 


-- 
Inaky
