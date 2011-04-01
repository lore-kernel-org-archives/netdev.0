From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 07/19] timberdale: mfd_cell is now implicitly available to drivers
Date: Fri, 1 Apr 2011 11:56:35 -0600
Message-ID: <BANLkTi=bCd_+f=EG-O=U5VH_ZNjFhxkziQ@mail.gmail.com>
References: <20110202195417.228e2656@queued.net> <20110202200812.3d8d6cba@queued.net>
 <20110331230522.GI437@ponder.secretlab.ca> <20110401112030.GA3447@sortiz-mobl>
 <20110401104756.2f5c6f7a@debxo>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Brown <broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org, ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org,
	Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>,
	Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Mocean Laboratories <info-l7gf1WXxx3uGw+nKnLezzg@public.gmane.org>
To: Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110401104756.2f5c6f7a@debxo>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 1, 2011 at 11:47 AM, Andres Salomon <dilinger-pFFUokh25LWsTnJN9+BGXg@public.gmane.org> w=
rote:
> On Fri, 1 Apr 2011 13:20:31 +0200
> Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org> wrote:
>
>> Hi Grant,
>>
>> On Thu, Mar 31, 2011 at 05:05:22PM -0600, Grant Likely wrote:
> [...]
>> > Gah. =A0Not all devices instantiated via mfd will be an mfd device=
,
>> > which means that the driver may very well expect an *entirely
>> > different* platform_device pointer; which further means a very hig=
h
>> > potential of incorrectly dereferenced structures (as evidenced by =
a
>> > patch series that is not bisectable). =A0For instance, the xilinx =
ip
>> > cores are used by more than just mfd.
>> I agree. Since the vast majority of the MFD subdevices are MFD
>> specific IPs, I overlooked that part. The impacted drivers are the
>> timberdale and the DaVinci voice codec ones.

Another option is you could do this for MFD devices:

struct mfd_device {
        struct platform_devce pdev;
        struct mfd_cell *cell;
};

However, that requires that drivers using the mfd_cell will *never*
get instantiated outside of the mfd infrastructure, and there is no
way to protect against this so it is probably a bad idea.

Or, mfd_cell could be added to platform_device directly which would
*by far* be the safest option at the cost of every platform_device
having a mostly unused mfd_cell pointer.  Not a significant cost in my
opinion.

One last option is I'm prototyping a way to add type-safe structure
pointers to a device, but that requires nasty CPP tricks and it's not
complete yet.  The cure might be worse than the disease here.

g.

>
> Can you please provide pointers to what you're referring to? =A0The o=
nly
> code that I could find that created platform devices prefixed with
> 'timb-' or named 'xilinx_spi' was drivers/mfd/timberdale.c.
>
>
>
>> To fix that problem I propose 2 alternatives:
>>
>> 1) When declaring the sub devices cells, the MFD driver should
>> specify an mfd_data_size value for sub devices that are not MFD
>> specific. It's the MFD driver responsibility to set the cell
>> properly, and the non MFD specific drivers are kept MFD agnostic.
>> See my patch below for the timberdale case.

This approach worries me because it changes the behaviour on a
per-device basis.  That could be difficult to maintain a mental model
for.  I'd rather see consistent behaviour.

>>
>> 2) Revert the mfd_get_data() call for getting sub devices platform
>> data pointers. That was introduced to ease the MFD cell sharing work=
,
>> so if we take this route we'll need the cs5535 MFD driver to pass it=
s
>> cells as platform_data pointer. Andres, can you confirm that this
>> would be fine for the mfd_clone_cell() routine to keep working ?
>
> It would break mfd_clone_cell, as it uses mfd_get_cell to grab the on=
e
> to clone. =A0We could change it to accept the cell as an argument. =A0=
It
> would also break mfd_cell_enable/disable, of course.
>
>
>
>>
>> Patch for solution 1:
>>
>>
>> =A0drivers/mfd/mfd-core.c =A0 =A0 =A0 =A0 =A0| =A0 13 ++++++++++---
>> =A0drivers/mfd/timberdale.c =A0 =A0 =A0 =A0| =A0 11 +++++++++++
>> =A0include/linux/mfd/core.h =A0 =A0 =A0 =A0| =A0 =A01 +
>> =A0drivers/i2c/busses/i2c-ocores.c | =A0 =A03 +--
>> =A0drivers/i2c/busses/i2c-xiic.c =A0 | =A0 =A03 +--
>> =A0drivers/net/ks8842.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +--
>> =A0drivers/spi/xilinx_spi.c =A0 =A0 =A0 =A0| =A0 =A03 +--
>> =A07 files changed, 26 insertions(+), 11 deletions(-)
>>
>> diff --git a/drivers/mfd/mfd-core.c b/drivers/mfd/mfd-core.c
>> index d01574d..8abe510 100644
>> --- a/drivers/mfd/mfd-core.c
>> +++ b/drivers/mfd/mfd-core.c
>> @@ -75,9 +75,16 @@ static int mfd_add_device(struct device *parent,
>> int id,
>> =A0 =A0 =A0 pdev->dev.parent =3D parent;
>>
>> - =A0 =A0 ret =3D platform_device_add_data(pdev, cell, sizeof(*cell)=
);
>> - =A0 =A0 if (ret)
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto fail_res;
>> + =A0 =A0 if (cell->mfd_data_size > 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D platform_device_add_data(pdev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 cell->mfd_data,
>> cell->mfd_data_size);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_res;
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D platform_device_add_data(pdev, cel=
l,
>> sizeof(*cell));
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail_res;
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 for (r =3D 0; r < cell->num_resources; r++) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 res[r].name =3D cell->resources[r].name;
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
