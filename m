From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH v2 2/7] USB: serial: handle suspend failure path correctly
Date: Thu, 14 Mar 2013 12:10:10 +0100
Message-ID: <20130314111010.GA15776@localhost>
References: <1362672924-22975-1-git-send-email-ming.lei@canonical.com>
 <1362672924-22975-3-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org,
	Johan Hovold <jhovold@gmail.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f43.google.com ([209.85.215.43]:54396 "EHLO
	mail-la0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756688Ab3CNLLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 07:11:05 -0400
Content-Disposition: inline
In-Reply-To: <1362672924-22975-3-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 08, 2013 at 12:15:19AM +0800, Ming Lei wrote:
> This patch kills traffic even though type->suspend returns
> failure inside usb_serial_suspend from system sleep context
> because USB core ignores the failiure and lets system sleep
> go ahread, so the serial URB traffic need to be killed
> in this case.
>=20
> Cc: Johan Hovold <jhovold@gmail.com>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/usb/serial/usb-serial.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/usb/serial/usb-serial.c b/drivers/usb/serial/usb=
-serial.c
> index a19ed74..9d0b9c8 100644
> --- a/drivers/usb/serial/usb-serial.c
> +++ b/drivers/usb/serial/usb-serial.c
> @@ -1142,10 +1142,11 @@ int usb_serial_suspend(struct usb_interface *=
intf, pm_message_t message)
> =20
>  	if (serial->type->suspend) {
>  		r =3D serial->type->suspend(serial, message);
> -		if (r < 0) {
> +		if (r < 0 && PMSG_IS_AUTO(message)) {
>  			serial->suspending =3D 0;
>  			goto err_out;
>  		}
> +		/* TODO: resume() might need to handle suspend failure */
>  	}
> =20
>  	for (i =3D 0; i < serial->num_ports; ++i) {

Sorry for the late reply.

The usb-serial subdriver suspend callbacks do not and must not return
non-zero if !PMSG_IS_AUTO(message) so adding code to handle that case
merely obfuscates this fact.

I'd rather see this documented with a comment just as Bj=F8rn suggested
for cdc_mbim and qmi_wwan.

Thanks,
Johan
