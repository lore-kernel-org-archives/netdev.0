From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 09:12:22 -0700
Message-ID: <20160606161222.GA12114@kroah.com>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
 <20160606143947.GA4758@kroah.com>
 <e0b44bac635f41a9a3f47f909cf16f42@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e0b44bac635f41a9a3f47f909cf16f42@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 02:56:32PM +0000, Mario_Limonciello@Dell.com wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Sent: Monday, June 6, 2016 9:40 AM
> > To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> > Cc: hayeswang@realtek.com; LKML <linux-kernel@vger.kernel.org>; Netdev
> > <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> > pali.rohar@gmail.com; anthony.wong@canonical.com
> > Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
> > address on RTL8153-AD
> > 
> > On Mon, Jun 06, 2016 at 09:15:21AM -0500, Mario Limonciello wrote:
> > > The RTL8153-AD supports a persistent system specific MAC address.
> > > This means a device plugged into two different systems with host side
> > > support will show different (but persistent) MAC addresses.
> > >
> > > This information for the system's persistent MAC address is burned in
> > when
> > > the system HW is built and available under _SB\AMAC in the DSDT at
> > runtime.
> > >
> > > This technology is currently implemented in the Dell TB15 and WD15 Type-C
> > > docks.  More information is available here:
> > > http://www.dell.com/support/article/us/en/04/SLN301147
> > >
> > > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> > > ---
> > >  drivers/net/usb/r8152.c | 60
> > +++++++++++++++++++++++++++++++++++++++++++++++--
> > >  1 file changed, 58 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> > > index 3f9f6ed..f4bd46d 100644
> > > --- a/drivers/net/usb/r8152.c
> > > +++ b/drivers/net/usb/r8152.c
> > > @@ -26,6 +26,7 @@
> > >  #include <linux/mdio.h>
> > >  #include <linux/usb/cdc.h>
> > >  #include <linux/suspend.h>
> > > +#include <linux/acpi.h>
> > >
> > >  /* Information for net-next */
> > >  #define NETNEXT_VERSION		"08"
> > > @@ -455,6 +456,11 @@
> > >  /* SRAM_IMPEDANCE */
> > >  #define RX_DRIVING_MASK		0x6000
> > >
> > > +/* MAC PASSTHRU */
> > > +#define AD_MASK			0xfee0
> > > +#define EFUSE			0xcfdb
> > > +#define PASS_THRU_MASK		0x1
> > > +
> > >  enum rtl_register_content {
> > >  	_1000bps	= 0x10,
> > >  	_100bps		= 0x08,
> > > @@ -1030,6 +1036,53 @@ out1:
> > >  	return ret;
> > >  }
> > >
> > > +static int get_passthru_addr(struct r8152 *tp, struct sockaddr *sa)
> > 
> > I see no "Dell" specific markings or tests here at all, please be
> > EXPLICIT in the code exactly what this is for, and what it is doing.
> > Otherwise no one can tell you what machines/devices this will trigger on
> > at all.
> > 
> > As it is, it's totally vague and unknown what this whole function is
> > here for.
> > 
> 
> I intentionally removed the Dell tests.  I tried to go into this in the cover
> Letter as I knew there would be discussion about it.
> 
> This is intended because the better approach (as mentioned by this ML)
> is to look for the exact chip that supports this feature, and query the bit
> that can be set on that device's eFuse to indicate it supports this feature.
> 
> That device is an RTL8153-AD and there is a bit on the eFuse for MAC
> pass through.
> 
> The ACPI code is intended to run on any device that has one of these
> Devices plugged in.  From what I learned discussing with others is that
> is the approach the Realtek driver takes on the Windows side as well.
> 
> If the Dell TB15 (containin RTL8153-AD with this pass through bit set)
> is plugged into for example an HP machine with the latest Realtek driver
> installed this ACPI query will be run on Windows too.  It will fail and fall
> back to the address burned into the HW.
> 
> If the netdev maintainers still want a DMI check put in place again 
> here I'll put it back in, but I really think this is overkill.

I'm not asking for a DMI check, I'm asking for the ability to look at
this code, no changelog text at all, and know what is going on and what
this whole function is here for.

Right now I can't do that.  No one can.  You have documented what the
code does in it, but not described _why_ it is doing that at all.

> > > +{
> > > +	acpi_status status;
> > > +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
> > > +	union acpi_object *obj;
> > > +	int ret = -EINVAL;
> > > +	u32 ocp_data;
> > > +	unsigned char buf[6];
> > > +
> > > +	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_MISC_0);
> > > +	if ((ocp_data & AD_MASK) != 0x1000)
> > > +		return -ENODEV;
> > > +
> > > +	ocp_data = ocp_read_byte(tp, MCU_TYPE_USB, EFUSE);
> > > +	if ((ocp_data & PASS_THRU_MASK) != 1)
> > > +		return -ENODEV;
> > > +
> > > +	/* returns _AUXMAC_#AABBCCDDEEFF# */
> > > +	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
> > > +	obj = (union acpi_object *)buffer.pointer;
> > > +	if (ACPI_SUCCESS(status)) {
> > > +		if (obj->type != ACPI_TYPE_BUFFER ||
> > > +		    obj->string.length != 0x17) {
> > > +			pr_warn("r8152: get_passthru_addr: Invalid buffer");
> > > +			goto amacout;
> > > +		}
> > > +		if (strncmp(obj->string.pointer, "_AUXMAC_#", 9) != 0) {
> > > +			pr_warn("r8152: get_passthru_addr: Invalid
> > header");
> > > +			goto amacout;
> > > +		}
> > > +		ret = hex2bin(buf, obj->string.pointer + 9, 6);
> > > +		if (ret < 0 || !is_valid_ether_addr(buf)) {
> > > +			pr_warn("r8152: get_passthru_addr: Invalid MAC");
> > > +			goto amacout;
> > > +		}
> > > +		memcpy(sa->sa_data, buf, 6);
> > > +		ether_addr_copy(tp->netdev->dev_addr, sa->sa_data);
> > > +		netdev_info(tp->netdev, "Using pass-through MAC address
> > %pM\n",
> > > +			    sa->sa_data);
> > > +		ret = 0;
> > > +	}
> > > +
> > > +amacout:
> > > +	kfree(obj);
> > > +	return ret;
> > > +}
> > > +
> > >  static int set_ethernet_addr(struct r8152 *tp)
> > >  {
> > >  	struct net_device *dev = tp->netdev;
> > > @@ -1038,8 +1091,11 @@ static int set_ethernet_addr(struct r8152 *tp)
> > >
> > >  	if (tp->version == RTL_VER_01)
> > >  		ret = pla_ocp_read(tp, PLA_IDR, 8, sa.sa_data);
> > > -	else
> > > -		ret = pla_ocp_read(tp, PLA_BACKUP, 8, sa.sa_data);
> > > +	else {
> > > +		ret = get_passthru_addr(tp, &sa);
> > > +		if (ret < 0)
> > 
> > an "error" here is a "normal" thing, so please document it.
> 
> OK.
> 
> > 
> > Or again, change the function to be "dell_crazy_hardware_hack_enabled()"
> > so it'b obvious what is going on.
> 
> I'm really trying to be a good citizen here, just because it is implemented in 
> Dell HW first doesn't mean it won't be implemented by our competitors too
> with their docks and dongles that get provided by Realtek.

That's fine, then call it "crazy_vendor_mac_passthrough() or something
like that.  "get_passthru_addr()" makes this look like it is a "normal"
thing to have happen, which really, it isn't at all (hence these long
email threads.)

> Realtek has this in their Windows driver that all OEM's will be taking.
> Another OEM would just need to burn the right information into the SPI at
> manufacturing and expose it to the DSDT.

Where it the match up for the Realtek bit to corrispond with this
specific ACPI field?  If it's not in the ACPI spec, then vendors _WILL_
do this in different ways.

Again, document it, in the code, what is going on here, that's all I'm
asking.  I'm not asking you to change the logic at all!

> If considering all my above comments you still want it to be Dell specific I'll
> return the DMI system vendor match.
> I really don't think the netdev maintainers are going to want a list of every
> specific DMI product string that Dell machine has this  though.  Maybe 
> they can speak up here.

If I were them, I sure would :)

good luck!

greg k-h
