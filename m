From: Hannes Reinecke <hare@suse.de>
Subject: Re: SYSFS "errors"
Date: Tue, 19 Feb 2013 14:58:07 +0100
Message-ID: <512384EF.9020602@suse.de>
References: <20130219101121.GJ23197@arwen.pp.htv.fi> <20130219081149.46972f56@redhat.com> <20130219114345.GA26623@pd.tnic> <20130219091610.2b746a30@redhat.com> <20130219123502.GD26623@pd.tnic> <20130219094640.2abf1a66@redhat.com> <20130219130626.GE26623@pd.tnic> <20130219131500.GW23197@arwen.pp.htv.fi> <20130219132853.GG26623@pd.tnic> <20130219133809.GA4390@arwen.pp.htv.fi> <20130219135056.GH26623@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Borislav Petkov <bp@alien8.de>, Felipe Balbi <balbi@ti.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>, JBottomley@parallels.com,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, Doug Thompson <dougthompson@xmission.com>,
	linux-edac@vger.kernel.org, rjw@sisk.pl, linux-pm@vger.kernel.org
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20130219135056.GH26623@pd.tnic>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/19/2013 02:50 PM, Borislav Petkov wrote:
> On Tue, Feb 19, 2013 at 03:38:09PM +0200, Felipe Balbi wrote:
>> because changing the permission will cause the same issue:
>
> Actually, I take that back. Mauro's patch will already create the fil=
e
> anyway:
>
> 	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate)
>
> Adjusting the permissions is simply the last missing piece to this pa=
tch
> to make the interface to userspace 100% coherent.
>
> --
> From: Mauro Carvalho Chehab <mchehab@redhat.com>
> Date: Tue, 19 Feb 2013 09:16:10 -0300
> Subject: [PATCH] EDAC: only create sdram_scrub_rate where supported
>
> Currently, sdram_scrub_rate sysfs node is created even if the device
> doesn't support get/set the scub rate. Change the logic to only
> create this device node when the operation is supported.
>
> If only read or only write is supported, it will keep returning -ENOD=
EV
> just like before.
>
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mauro Carvalho Chehab <mchehab@redhat.com>
> ---
>   drivers/edac/edac_mc_sysfs.c | 21 +++++++++++++++++++--
>   1 file changed, 19 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/edac/edac_mc_sysfs.c b/drivers/edac/edac_mc_sysf=
s.c
> index 0ca1ca71157f..5a788e60ff67 100644
> --- a/drivers/edac/edac_mc_sysfs.c
> +++ b/drivers/edac/edac_mc_sysfs.c
> @@ -7,7 +7,7 @@
>    *
>    * Written Doug Thompson <norsk5@xmission.com> www.softwarebitmaker=
=2Ecom
>    *
> - * (c) 2012 - Mauro Carvalho Chehab <mchehab@redhat.com>
> + * (c) 2012-2013 - Mauro Carvalho Chehab <mchehab@redhat.com>
>    *	The entire API were re-written, and ported to use struct device
>    *
>    */
> @@ -878,7 +878,6 @@ static struct attribute *mci_attrs[] =3D {
>   	&dev_attr_ce_noinfo_count.attr,
>   	&dev_attr_ue_count.attr,
>   	&dev_attr_ce_count.attr,
> -	&dev_attr_sdram_scrub_rate.attr,
>   	&dev_attr_max_location.attr,
>   	NULL
>   };
> @@ -1012,6 +1011,23 @@ int edac_create_sysfs_mci_device(struct mem_ct=
l_info *mci)
>   		return err;
>   	}
>
> +	if (mci->set_sdram_scrub_rate || mci->get_sdram_scrub_rate) {
> +		umode_t mode =3D 0;
> +
> +		if (mci->get_sdram_scrub_rate)
> +			mode =3D S_IRUGO;
> +
> +		if (mci->set_sdram_scrub_rate)
> +			mode |=3D S_IWUSR;
> +
> +		dev_attr_sdram_scrub_rate.attr.mode =3D mode;
> +
> +		err =3D device_create_file(&mci->dev, &dev_attr_sdram_scrub_rate);
> +		if (err) {
> +			edac_dbg(1, "failure: create sdram_scrub_rate\n");
> +			goto fail2;
> +		}
> +	}
>   	/*
>   	 * Create the dimm/rank devices
>   	 */
> @@ -1056,6 +1072,7 @@ fail:
>   			continue;
>   		device_unregister(&dimm->dev);
>   	}
> +fail2:
>   	device_unregister(&mci->dev);
>   	bus_unregister(&mci->bus);
>   	kfree(mci->bus.name);
>
And of course you all know that creating sysfs attributes via=20
'device_create_file' opens all sort of funny race conditions,=20
especially when checking these attributes from udev ...

Please consider adding a default attribute which return '-EINVAL' or=20
somesuch when the function pointers are not set.
But _not_ adding it via device_create_file(). That's evil.

Cheers,

Hannes
--=20
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=C3=BCrnberg
GF: J. Hawn, J. Guild, F. Imend=C3=B6rffer, HRB 16746 (AG N=C3=BCrnberg=
)
