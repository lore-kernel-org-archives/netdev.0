From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH -next] smsc911x: Fix crash seen if neither ACPI nor OF is
 configured or used
Date: Wed, 26 Aug 2015 10:57:11 -0700
Message-ID: <20150826175710.GR4215@atomide.com>
References: <1439844336-21596-1-git-send-email-linux@roeck-us.net>
 <20150826170410.GP4215@atomide.com>
 <55DDF939.9050209@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeremy Linton <jeremy.linton@arm.com>,
	linux-omap@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55DDF939.9050209@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Guenter Roeck <linux@roeck-us.net> [150826 10:40]:
> Hi Tony,
> 
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
> 
> What do you see if you revert my patch ? It should assign -22, or its
> unsigned representation, to phy_interface, which isn't such a good idea
> either.

If I revert patch "smsc911x: Fix crash seen if neither ACPI nor OF is
configured or used" things work as just assign config->phy_interface
directly without returning early. It's -22 in that case also.
 
> >Do any of the the device tree configured smsc911x devices actually
> >have a phy configured?
> >
> Good question, and beats me. Looking into the original code,
> it didn't check for an error return from of_get_phy_mode() either,
> and thus _would_ dutifully assign the error code to phy_interface.
> Wonder how was this supposed to work to start with.
> 
> I'll do some debugging and try to find out what exactly is going on.

Looks like adding "smsc,force-internal-phy" to omap-gpmc-smsc9221.dtsi
does not help. Somehow the default behavior is now different.

Regards,

Tony
