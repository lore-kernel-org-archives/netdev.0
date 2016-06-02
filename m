From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/4] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Thu, 02 Jun 2016 10:52:48 +0200
Message-ID: <3851136.KiJNtFycNm@wuerfel>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <6110875.0k1HlSKhzn@wuerfel> <1464829874.16584.163.camel@buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Scott Wood <oss@buserror.net>, Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Ulf Hansson <ulf.hansson@linaro.org>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joerg Roedel <joro@8bytes.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	Rob Herring <robh+dt@kernel.org>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Yang-Leo Li <leoyang.li@nxp.com>,
	"linux-clk@vger.kernel.org" <linux-clk@vg
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linux-clk-owner@vger.kernel.org>
In-Reply-To: <1464829874.16584.163.camel@buserror.net>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 1, 2016 8:11:14 PM CEST Scott Wood wrote:
> > +#define T4240_HOST_VER ((VENDOR_V_23 << SDHCI_VENDOR_VER_SHIFT) |
> > SDHCI_SPEC_200)
> > +static const struct soc_device_attribute esdhc_t4240_quirk = {
> > +     /* T4240 revision < 0x20 uses vendor version 23, SDHCI version 200
> > */
> > +     { .soc_id = "T4*(0x824000)", .revision = "0x[01]?",
> > +       .data = (void *)(uintptr_t)(T4240_HOST_VER) },
> 
> Why should this code need to care that the string begins with "T4"?  This
> creates dual maintenance if that were to change.  It's also broken because
> T4240 has compatible = "fsl,t4240-device-config", "fsl,qoriq-device-config
> -2.0" and thus with these patches it would incorrectly show up as "P series
> (0x824000)".  The compatible string of this node was never meant to be a key
> for choosing a string to describe the system to userspace.

This is an artifact of not knowing the specific SoC name, and we can change
that by looking up the name from the SVR value in the soc_device driver.
 
> 0x824000 is a magic number which should be represented symbolically.

Sure, feel free to change the format of the soc_device string in any
name, I just converted the information I had available in the comments.
The only thing that is important here is that the string matches what
the soc_device driver calls it.

> If T4240 is affected, then so are the reduced-core variants T4160 and T4080,
> but 0x824000 doesn't match them (Yangbo's patch had the same problem).  And
> please don't respond with "0x824*"
> 
> You also didn't strip out the E bit of SVR which indicates encryption
> capability and nothing else (Yangbo's patch did not have this problem because
> it used SVR_SOC_VER).

Ok, that should be easy enough to fix in the soc_device driver.

> What happens if the revision condition is more complicated, such as <= 0x20
> with 0x21 being fine?  Multiple quirk entries where before we had as simple
> comparison?

I guess yes. I would really hope that there is no need to use this interface
pervasively, it's really just to work around the cases where there is no
way to pass the information in DT otherwise.

> I fail to see how this approach is an improvement (much less one that needs to
> hold up a patchset that is fixing a problem and is not touching any generic
> code).  Why does this need to be a string?

A string is what user space gets in /sys/devices/soc/*, and we already have
code that does the same things there to work around quirks, here we just
use the same interface in a completely generic way. Note that not every
SoC family uses numbers in the same way, some have multiple subrevisions,
some have names etc.

	Arnd
