From: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available
 to drivers
Date: Fri, 1 Apr 2011 10:47:56 -0700
Message-ID: <20110401104756.2f5c6f7a@debxo>
References: <20110202195417.228e2656@queued.net>
	<20110202200812.3d8d6cba@queued.net>
	<20110331230522.GI437@ponder.secretlab.ca>
	<20110401112030.GA3447@sortiz-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110401112030.GA3447@sortiz-mobl>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 1 Apr 2011 13:20:31 +0200
Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:

> Hi Grant,
> 
> On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
[...]
> > Gah.  Not all devices instantiated via mfd will be an mfd device,
> > which means that the driver may very well expect an *entirely
> > different* platform_device pointer; which further means a very high
> > potential of incorrectly dereferenced structures (as evidenced by a
> > patch series that is not bisectable).  For instance, the xilinx ip
> > cores are used by more than just mfd.
> I agree. Since the vast majority of the MFD subdevices are MFD
> specific IPs, I overlooked that part. The impacted drivers are the
> timberdale and the DaVinci voice codec ones.

Can you please provide pointers to what you're referring to?  The only
code that I could find that created platform devices prefixed with
'timb-' or named 'xilinx_spi' was drivers/mfd/timberdale.c.



> To fix that problem I propose 2 alternatives:
> 
> 1) When declaring the sub devices cells, the MFD driver should
> specify an mfd_data_size value for sub devices that are not MFD
> specific. It's the MFD driver responsibility to set the cell
> properly, and the non MFD specific drivers are kept MFD agnostic.
> See my patch below for the timberdale case.
> 
> 2) Revert the mfd_get_data() call for getting sub devices platform
> data pointers. That was introduced to ease the MFD cell sharing work,
> so if we take this route we'll need the cs5535 MFD driver to pass its
> cells as platform_data pointer. Andres, can you confirm that this
> would be fine for the mfd_clone_cell() routine to keep working ?

It would break mfd_clone_cell, as it uses mfd_get_cell to grab the one
to clone.  We could change it to accept the cell as an argument.  It
would also break mfd_cell_enable/disable, of course.



> 
> Patch for solution 1:
> 
> 
>  drivers/mfd/mfd-core.c          |   13 ++++++++++---
>  drivers/mfd/timberdale.c        |   11 +++++++++++
>  include/linux/mfd/core.h        |    1 +
>  drivers/i2c/busses/i2c-ocores.c |    3 +--
>  drivers/i2c/busses/i2c-xiic.c   |    3 +--
>  drivers/net/ks8842.c            |    3 +--
>  drivers/spi/xilinx_spi.c        |    3 +--
>  7 files changed, 26 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
> index d01574d..8abe510 100644
> --- a/drivers/mfd/mfd-core.c
> +++ b/drivers/mfd/mfd-core.c
> @@ -75,9 +75,16 @@ static int mfd_add_device(struct device *parent,
> int id, 
>  	pdev->dev.parent = parent;
>  
> -	ret = platform_device_add_data(pdev, cell, sizeof(*cell));
> -	if (ret)
> -		goto fail_res;
> +	if (cell->mfd_data_size > 0) {
> +		ret = platform_device_add_data(pdev,
> +					cell->mfd_data,
> cell->mfd_data_size);
> +		if (ret)
> +			goto fail_res;
> +	} else {
> +		ret = platform_device_add_data(pdev, cell,
> sizeof(*cell));
> +		if (ret)
> +			goto fail_res;
> +	}
>  
>  	for (r = 0; r < cell->num_resources; r++) {
>  		res[r].name = cell->resources[r].name;
