From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is
 configured or used
Date: Wed, 26 Aug 2015 13:16:29 -0700
Message-ID: <20150826201628.GU4215@atomide.com>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
 <20150826170410.GP4215@atomide.com>
 <55DE069C.7000402@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-omap@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from muru.com ([72.249.23.125]:46592 "EHLO muru.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932545AbbHZUQc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 16:16:32 -0400
Content-Disposition: inline
In-Reply-To: <55DE069C.7000402@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Guenter Roeck <linux@roeck-us.net> [150826 11:37]:
> On 08/26/2015 10:04 AM, Tony Lindgren wrote:
> >Hi,
> >
> >* Guenter Roeck <linux@roeck-us.net> [150817 13:48]:
> >>Commit 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT") makes
> >>the call to smsc911x_probe_config() unconditional, and no longer fails if
> >>there is no device node. device_get_phy_mode() is called unconditionally,
> >>and if there is no phy node configured returns an error code. This error
> >>code is assigned to phy_interface, and interpreted elsewhere in the code
> >>as valid phy mode. This in turn causes qemu to crash when running a
> >>variant of realview_pb_defconfig.
> >>
> >>	qemu: hardware error: lan9118_read: Bad reg 0x86
> >>
> >>Fixes: 0b50dc4fc971 ("Convert smsc911x to use ACPI as well as DT")
> >>Cc: Jeremy Linton <jeremy.linton@arm.com>
> >>Cc Graeme Gregory <graeme.gregory@linaro.org>
> >>Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> >>---
> >>  drivers/net/ethernet/smsc/smsc911x.c | 7 ++++++-
> >>  1 file changed, 6 insertions(+), 1 deletion(-)
> >>
> >>diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> >>index 0f21aa3bb537..34f97684506b 100644
> >>--- a/drivers/net/ethernet/smsc/smsc911x.c
> >>+++ b/drivers/net/ethernet/smsc/smsc911x.c
> >>@@ -2367,12 +2367,17 @@ static const struct smsc911x_ops shifted_smsc911x_ops = {
> >>  static int smsc911x_probe_config(struct smsc911x_platform_config *config,
> >>  				 struct device *dev)
> >>  {
> >>+	int phy_interface;
> >>  	u32 width = 0;
> >>
> >>  	if (!dev)
> >>  		return -ENODEV;
> >>
> >>-	config->phy_interface = device_get_phy_mode(dev);
> >>+	phy_interface = device_get_phy_mode(dev);
> >>+	if (phy_interface < 0)
> >>+		return phy_interface;
> >>+
> >>+	config->phy_interface = phy_interface;
> >>
> >>  	device_get_mac_address(dev, config->mac, ETH_ALEN);
> >
> >Looks like this change makes at least omap boards using smsc911x
> >fail with -22 for me in Linux next.
> >
> >Do any of the the device tree configured smsc911x devices actually
> >have a phy configured?
> >
> 
> Ok, this is more subtle than I thought.
> 
> Previously, the code would not attempt any devicetree configuration
> if devicetree was not configured.
> 
> Now it does.
> 
> The error return from device_get_phy_mode() isn't the actual problem.
> Apparently it doesn't really matter if a nonsensical value is assigned
> to phy_interface.
> 
> The problem is that the reg-io-width property is obviously not present
> in the non-dt and non-acpi case. This overwrites the existing platform data
> configuration and selects 16 bit mode, to which the (simulated) hardware
> obviously reacts less than enthusiastic.
> 
> Fixing this properly won't be easy. If the "reg-io-width" property
> is not present or wrong, the default register width is 16 bit. Obviously,
> if neither DT nor ACPI is available, it won't be present. This causes
> the crash I had observed.

Heh OK :)
 
> Bad part is that there does not seem to be a reliable means to detect
> that platform data should be used in that situation. Other device_get_XXX
> functions return -ENXIO if that happens, but not device_property_read_u32().
> It is _supposed_ to return it per its API, but it doesn't (it returns
> -ENODATA).
> 
> We may need two separate patches, one to fix up device_property_read_u32()
> to return -ENXIO, and one to fix smsc911x_probe_config() to ignore the error
> from device_get_phy_mode(), and to bail out if device_property_read_u32()
> returns -ENXIO.

I guess the device_property_read_u32() change needs to be discussed
separately.. So probably best to fix up the regression to smsc911x
first.
 
> The simpler alternative would be to check the return value from
> device_property_read_u32() for both -ENXIO and -ENODATA.
> This would make the code independent of the necessary core changes
> (which may take a while). I tested this variant, and it works, at least
> for the non-DT case.
> 
> Does this make sense ?

Yeh I think that would allow fixing up the smsc911x regression while
discussing the device_property_read_u32() change. Got a test patch
for me to try?

Regards,

Tony
