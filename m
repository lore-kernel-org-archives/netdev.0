From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Fri, 1 Apr 2011 20:26:08 +0200
Message-ID: <20110401182607.GC29397@sortiz-mobl>
References: <20110202195417.228e2656@queued.net>
 <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca>
 <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>,
	linux-kernel@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	khali@linux-fr.org, ben-linux@fluff.org,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Mauro Carvalho Chehab <mchehab@infradead.org>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-i2c@vger.kernel.org, linux-media@vger.kernel.org,
	netdev@vger.kernel.org, spi-devel-general@lists.sourceforge.net,
	Mocean Laboratories <info@mocean-labs.com>
To: Andres Salomon <dilinger@queued.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110401104756.2f5c6f7a@debxo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2011 at 10:47:56AM -0700, Andres Salomon wrote:
> On Fri, 1 Apr 2011 13:20:31 +0200
> Samuel Ortiz <sameo@linux.intel.com> wrote:
> 
> > Hi Grant,
> > 
> > On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
> [...]
> > > Gah.  Not all devices instantiated via mfd will be an mfd device,
> > > which means that the driver may very well expect an *entirely
> > > different* platform_device pointer; which further means a very high
> > > potential of incorrectly dereferenced structures (as evidenced by a
> > > patch series that is not bisectable).  For instance, the xilinx ip
> > > cores are used by more than just mfd.
> > I agree. Since the vast majority of the MFD subdevices are MFD
> > specific IPs, I overlooked that part. The impacted drivers are the
> > timberdale and the DaVinci voice codec ones.
> 
> Can you please provide pointers to what you're referring to?  The only
> code that I could find that created platform devices prefixed with
> 'timb-' or named 'xilinx_spi' was drivers/mfd/timberdale.c.
The xilinx-spi, ocores-i2c, i2c-xiic drivers and to some extend the
ks8842 ethernet driver are generic IPs that the timberdale SOC happens to
use. So I agree it's extremely unlikely that anyone could come up with a
platform that would be re-using e.g. the timb-radio IP, but I think it's less
unikely for more generic IPs such as the xilinx-spi one.


> > To fix that problem I propose 2 alternatives:
> > 
> > 1) When declaring the sub devices cells, the MFD driver should
> > specify an mfd_data_size value for sub devices that are not MFD
> > specific. It's the MFD driver responsibility to set the cell
> > properly, and the non MFD specific drivers are kept MFD agnostic.
> > See my patch below for the timberdale case.
> > 
> > 2) Revert the mfd_get_data() call for getting sub devices platform
> > data pointers. That was introduced to ease the MFD cell sharing work,
> > so if we take this route we'll need the cs5535 MFD driver to pass its
> > cells as platform_data pointer. Andres, can you confirm that this
> > would be fine for the mfd_clone_cell() routine to keep working ?
> 
> It would break mfd_clone_cell, as it uses mfd_get_cell to grab the one
> to clone.  We could change it to accept the cell as an argument.  It
> would also break mfd_cell_enable/disable, of course.
I'm talking about reverting the default behaviour of passing the MFD cell as
the platform data, and going back to the cell definitions setting their
platform_data pointer explicitely. In that case, the cs5535 driver would have
to do something like:

diff --git a/drivers/mfd/cs5535-mfd.c b/drivers/mfd/cs5535-mfd.c
index 155fa04..3e3841d 100644
--- a/drivers/mfd/cs5535-mfd.c
+++ b/drivers/mfd/cs5535-mfd.c
@@ -106,6 +106,7 @@ static __devinitdata struct mfd_cell cs5535_mfd_cells[] =
{
                .name = "cs5535-acpi",
                .num_resources = 1,
                .resources = &cs5535_mfd_resources[ACPI_BAR],
+               .platform_data = &cs5535_mfd_cells[ACPI_BAR],
 
                .enable = cs5535_mfd_res_enable,
                .disable = cs5535_mfd_res_disable,

mfd_get_cell would then return &cs5535_mfd_cells[ACPI_BAR].

This fix would put all sub devices drivers back to an MFD agnostic state,
although the vast majority of them will certainly never be found anywhere else
than in their current MFD SoC. That's why I'm still not sure which way to go
to fix that problem.

Cheers,
Samuel.

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
