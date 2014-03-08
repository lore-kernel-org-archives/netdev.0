From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54usb: fix leaks at failure path in p54u_probe()
Date: Sun, 09 Mar 2014 00:08:54 +0100
Message-ID: <2894930.q0nCt6o0pg@debian64>
References: <1394226709-10763-1-git-send-email-khoroshilov@ispras.ru> <CABPxzYLzMvtWShP_PFdyTzV8P1P177yPZh=xAO=3tiy97UfEmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: Krishna Chaitanya <chaitanya.mgit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:48620 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbaCHXJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 18:09:23 -0500
In-Reply-To: <CABPxzYLzMvtWShP_PFdyTzV8P1P177yPZh=xAO=3tiy97UfEmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday, March 09, 2014 04:14:32 AM Krishna Chaitanya wrote:
> On Sat, Mar 8, 2014 at 2:41 AM, Alexey Khoroshilov
> <khoroshilov@ispras.ru> wrote:
> > If p54u_load_firmware() fails, p54u_probe() does not deallocate
> > already allocated resources. The patch adds proper failure handling.
> >
> > Found by Linux Driver Verification project (linuxtesting.org).
> >
> > Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
> > ---
> >  drivers/net/wireless/p54/p54usb.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
> > index 6e635cfa24c8..5df74503fd4f 100644
> > --- a/drivers/net/wireless/p54/p54usb.c
> > +++ b/drivers/net/wireless/p54/p54usb.c
> > @@ -1053,6 +1053,10 @@ static int p54u_probe(struct usb_interface *intf,
> >                 priv->upload_fw = p54u_upload_firmware_net2280;
> >         }
> >         err = p54u_load_firmware(dev, intf);
> > +       if (err) {
> > +               usb_put_dev(udev);
> > +               p54_free_common(dev);
> > +       }
> >         return err;
> >  }
> The load_firmware puts down the reference
> in case of error. Only free is required here.
No, the put is required too... But let me explain:

p54u_load_firmware calls usb_get_dev(udev) before it requests the firmware
load. The Reason is: the firmware callback is usually run in another thread
(usually it's pretty quick, but due to timeouts it could take up to 60 seconds 
- or at least it did when I wrote it). Therefore I found it appropriate to give 
that request callback its "reference++" as it needs the "udev" too (e.g.: for
dev_info, dev_err and releasing the driver if the device couldn't be 
initialized).

Regards,
Christian
