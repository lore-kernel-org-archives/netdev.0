From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [PATCH] hso: add missing spinlock grab when iterating the serial table
Date: Fri, 27 Feb 2015 21:11:37 +0100
Message-ID: <CAAP7ucLJoUZ-cgeCCxgiVHoYXQqz80BgnN14hTO-etzRtU_nYg@mail.gmail.com>
References: <1425062692-25155-1-git-send-email-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-usb@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Aleksander Morgado <aleksander@aleksander.es>
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:51992 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754632AbbB0ULi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:11:38 -0500
Received: by mail-oi0-f52.google.com with SMTP id u20so17508951oif.11
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:11:37 -0800 (PST)
In-Reply-To: <1425062692-25155-1-git-send-email-aleksander@aleksander.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 7:44 PM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
> Access to the 'serial_table' array needs to be protected by the spinlock.
>
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>
> ---
>  drivers/net/usb/hso.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index 3c8dfe5..4f6deff 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -607,19 +607,24 @@ static struct hso_serial *get_serial_by_shared_int_and_type(
>                                         struct hso_shared_int *shared_int,
>                                         int mux)
>  {
> +       struct hso_serial *serial = NULL;
>         int i, port;
> +       unsigned long flags;
>
>         port = hso_mux_to_port(mux);
>
> +       spin_lock_irqsave(&serial_table_lock, flags);
>         for (i = 0; i < HSO_SERIAL_TTY_MINORS; i++) {
>                 if (serial_table[i] &&
>                     (dev2ser(serial_table[i])->shared_int == shared_int) &&
>                     ((serial_table[i]->port_spec & HSO_PORT_MASK) == port)) {
> -                       return dev2ser(serial_table[i]);
> +                       serial = dev2ser(serial_table[i]);
> +                       break;
>                 }
>         }
> +       spin_unlock_irqrestore(&serial_table_lock, flags);
>
> -       return NULL;
> +       return serial;
>  }
>
>  static struct hso_serial *get_serial_by_index(unsigned index)
> --
> 2.3.1
>

Seems there are actually more places where this has to be done; I'll
send an updated version of the patch.


-- 
Aleksander
https://aleksander.es
