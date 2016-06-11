From: Scott Wood <oss@buserror.net>
Subject: Re: [PATCH 4/4] Revert "powerpc/fsl: Move fsl_guts.h out of
 arch/powerpc"
Date: Fri, 10 Jun 2016 21:13:07 -0500
Message-ID: <1465611186.22191.169.camel@buserror.net>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	 <5513501.AmZs7h1vI2@wuerfel> <1464830660.22191.6.camel@buserror.net>
	 <3225846.9EJ0sHv0XK@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org,
	Ulf Hansson <ulf.hansson@linaro.org>,
	Yangbo Lu <yangbo.lu@nxp.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Xiaobo Xie <xiaobo.xie@nxp.com>,
	"linux-i2c@vger.kernel.org" <linux-i2c@vger.kernel.org>,
	"linux-clk@vger.kernel.org" <linux-clk@vger.kernel.org>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Russell King <linux@arm.linux.org.uk>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Santosh Shilimkar <ssantosh@kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Yang-Leo
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3225846.9EJ0sHv0XK@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-06-02 at 11:01 +0200, Arnd Bergmann wrote:
> On Wednesday, June 1, 2016 8:24:20 PM CEST Scott Wood wrote:
> > On Mon, 2016-05-30 at 15:18 +0200, Arnd Bergmann wrote:
> > > All users of this driver are PowerPC specific and the header file
> > > has no business in the global include/linux/ hierarchy, so move
> > > it back before anyone starts using it on ARM.
> > > 
> > > This reverts commit 948486544713492f00ac8a9572909101ea892cb0.
> > > 
> > > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > > ---
> > > This part of the series is not required for the eSDHC quirk,
> > > but it restores the asm/fsl_guts.h header so it doesn't accidentally
> > > get abused for this in the future. I found two drivers outside of
> > > arch/powerpc that already accessed the registers directly, but the
> > > functions look fairly contained, and can be easily hidden in an
> > > #ifdef CONFIG_PPC
> > 
> > NACK
> > 
> > Besides adding ifdef pollution for no good reason, this register block is
> > used
> > on some ARM chips as well.  Why is it a problem if "anyone starts using it
> > on
> > ARM"?
> 
> It's just not a good interface when it's defined as "this is the layout of
> a register area that any driver can ioremap() if they can figure out the
> device node".

That's why I want to move accesses into one guts driver.

>  It's not uncommon to have register areas like that, but
> normally you have at the minimum a 'syscon' device to handle locking
> between drivers accessing the same registers and to avoid having to map
> the same area multiple times.

syscon requires device tree changes.

I don't see read-modify-write operations in regmap -- how does locking around
an individual, inherently-atomic load or store help?

> If we need to use 'guts' registers on ARM, we can find a way to abstract
> them properly for the given use cases, using a syscon or a driver with
> exported functions, but just making a PowerPC platform specific header
> global to all Linux drivers by putting it into include/linux doesn't seem
> right.

Again, it's not PowerPC-specific!  It started that way but then the same
register block got put onto some ARM chips.

It's not global to "all Linux drivers", just the ones that choose to include
an fsl-specific header.

If and when all uses of guts are moved into the guts driver, the header can be
moved into drivers/soc/fsl.

> Note that the header file uses a structure definition rather than the more
> common macros with register offsets, which is fine for a driver that has
> its own registers and abstracts them, but it doesn't really work with
> the regmap interface, so if we want to use it with syscon, it also needs to
> be rewritten.

We don't want to use it with syscon.  If we did, the solution wouldn't be to
move the header back to arch/powerpc, but to convert the struct into offsets.

-Scott
