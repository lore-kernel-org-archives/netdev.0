From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net/cdc_ncm: fix null pointer panic at usbnet_link_change
Date: Wed, 30 Oct 2013 09:38:18 +0100
Message-ID: <87y55bduh1.fsf@nemi.mork.no>
References: <0C18FE92A7765D4EB9EE5D38D86A563A019F450F@SHSMSX103.ccr.corp.intel.com>
	<20131029.223823.1852248673779937090.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: changbinx.du@intel.com, oliver@neukum.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131029.223823.1852248673779937090.davem@davemloft.net> (David
	Miller's message of "Tue, 29 Oct 2013 22:38:23 -0400 (EDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> The problem is in cdc_ncm_bind_common().
>
> It seems to leave dangling interface data pointers in some cases, and
> then branches just to "error" so that they don't get cleared back out=
=2E

Sorry, but I fail to see this as well.  I see one "return" and two "got=
o
error", but all are well before any intfdata pointer is set:

    364         ctx =3D kzalloc(sizeof(*ctx), GFP_KERNEL);
    365         if (!ctx)
    366                 return -ENOMEM;
    367=20
[..]
    453         /* check if we got everything */
    454         if ((ctx->control =3D=3D NULL) || (ctx->data =3D=3D NUL=
L) ||
    455             ((!ctx->mbim_desc) && ((ctx->ether_desc =3D=3D NULL=
) || (ctx->control !=3D intf))))
    456                 goto error;
    457=20
    458         /* claim data interface, if different from control */
    459         if (ctx->data !=3D ctx->control) {
    460                 temp =3D usb_driver_claim_interface(driver, ctx=
->data, dev);
    461                 if (temp)
    462                         goto error;
    463         }
[..]
    490         usb_set_intfdata(ctx->data, dev);
    491         usb_set_intfdata(ctx->control, dev);
    492         usb_set_intfdata(ctx->intf, dev);
[..]
    510         return 0;
    511=20
    512 error2:
    513         usb_set_intfdata(ctx->control, NULL);
    514         usb_set_intfdata(ctx->data, NULL);
    515         if (ctx->data !=3D ctx->control)
    516                 usb_driver_release_interface(driver, ctx->data)=
;
    517 error:
    518         cdc_ncm_free((struct cdc_ncm_ctx *)dev->data[0]);
    519         dev->data[0] =3D 0;
    520         dev_info(&dev->udev->dev, "bind() failure\n");
    521         return -ENODEV;
    522 }
=20

This could (and given this thread, probably should) certainly be
refactored and cleaned up a bit.  But I do not see how it leaves any
dangling pointers.  The pointers are only set near the end of the
function, and the only exit points after that are either success or
through the "error2" label.

Side note: It is definitely confusing that we set 3 pointers, but only
clean up 2.  The reason is that there are never more than 2 interfaces
involved here. We always have ctx->intf =3D=3D ctx->control.  I'd reall=
y
like to get rid of that redundant ctx->intf pointer.  That's one issue
to cleanup throughout this driver.



Bj=C3=B8rn
