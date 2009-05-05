From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
	synchronization, v5
Date: Tue, 5 May 2009 23:53:38 +0800
Message-ID: <d82e647a0905050853q4a1d5066ib71411cbef186c45@mail.gmail.com>
References: <20090504074522.13f1ed77@infradead.org>
	 <Pine.LNX.4.44L0.0905041100500.3092-100000@iolanthe.rowland.org>
	 <20090505234725.5ab247db@linux-lm>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
	David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090505234725.5ab247db@linux-lm>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/5/5 Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> On Mon, 4 May 2009 11:07:52 -0400 (EDT)
> Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org> wrote:
>
>> On Mon, 4 May 2009, Arjan van de Ven wrote:
>>
>> > > > for normal device probing we already have infrastructure
>> > > > though... wait_for_device_probe, driver_probe_done and
>> > > > friends... (the scsi scanning thread is being converted to the
>> > > > async infrastructure btw)
>> > > >
>> > > > do we need to invent more ?
>> > >
>> > > I suppose the usb-storage scanning thread could also be converte=
d
>> > > to the async infrastructure, although I haven't heard of anybody
>> > > working on it.
>> > >
>> > > But the USB hub driver's thread (khubd) cannot be converted. =A0=
It
>> > > is central to the discovery of USB-based block devices. =A0How
>> > > would you handle that?
>> >
>> > take a ref in the driver_probe_done() sense, and release it when y=
ou
>> > know you're done probing....
>> >
>> > at that point all existing infrastructure will just work.
>>
>> Isn't there still something missing? =A0The wait_for_device_probe()
>> routine would wait until all attached devices had been probed. =A0Bu=
t
>> why should prepare_namespace() have to wait that long? =A0Wouldn't i=
t be
>> better to wait only until the root device has been registered?
>
> Yes, maybe David should merge the following patch into the patch
> No.5(initdev:kernel: USB and SCSI block init device notification, v3)=
=2E
>
> Right?

Also need all block device drivers use initdev_*, much work to do,:-)

>
> diff --git a/init/do_mounts.c b/init/do_mounts.c
> index dd7ee5f..22fd773 100644
> --- a/init/do_mounts.c
> +++ b/init/do_mounts.c
> @@ -358,6 +358,12 @@ void __init mount_root(void)
> =A0#endif
> =A0}
>
> +static int root_dev_done()
> +{
> + =A0 =A0 =A0 return !!(ROOT_DEV =3D name_to_dev_t(saved_root_name));
> +}
> +
> +
> =A0/*
> =A0* Prepare the namespace - decide what/where to mount, load ramdisk=
s,
> etc. */
> @@ -398,12 +404,12 @@ void __init prepare_namespace(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0/* wait for any asynchronous scanning to complete */
> - =A0 =A0 =A0 if ((ROOT_DEV =3D=3D 0) && root_wait) {
> + =A0 =A0 =A0 if (ROOT_DEV =3D=3D 0 && root_wait) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_INFO "Waiting for root dev=
ice %s...\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0saved_root_name);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 while (driver_probe_done() !=3D 0 ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (ROOT_DEV =3D name_to_d=
ev_t(saved_root_name)) =3D=3D
> 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 msleep(100);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 initdev_wait(BOOTDEV_BL=
OCK, root_dev_done);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (!ROOT_DEV);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0async_synchronize_full();
> =A0 =A0 =A0 =A0}
>
>
>
>
> --
> Lei Ming
>



--=20
Lei Ming
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
