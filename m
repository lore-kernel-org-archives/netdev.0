From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/usb: kalmia: Various fixes for better support of
 non-x86 architectures.
Date: Thu, 23 Jun 2011 14:46:34 +0400
Message-ID: <4E03198A.2060600@ru.mvista.com>
References: <20110619.155755.1854488306547854947.davem@davemloft.net> <1308756376-9920-1-git-send-email-marius@kotsbak.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Marius B. Kotsbak" <marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
To: "Marius B. Kotsbak" <marius.kotsbak-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308756376-9920-1-git-send-email-marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 22-06-2011 19:26, Marius B. Kotsbak wrote:

> -Support for big endian.
> -Do not use USB buffers at the stack.
> -Safer/more efficient code for local constants.

> Signed-off-by: Marius B. Kotsbak<marius-iy5w9mehe2BBDgjK7y7TUQ@public.gmane.org>
> ---
>   drivers/net/usb/kalmia.c |   40 ++++++++++++++++++++++++----------------
>   1 files changed, 24 insertions(+), 16 deletions(-)

> diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
> index d965fb1..d4edeb2 100644
> --- a/drivers/net/usb/kalmia.c
> +++ b/drivers/net/usb/kalmia.c
> @@ -100,27 +100,35 @@ kalmia_send_init_packet(struct usbnet *dev, u8 *init_msg, u8 init_msg_len,
>   static int
>   kalmia_init_and_get_ethernet_addr(struct usbnet *dev, u8 *ethernet_addr)
>   {
> -	char init_msg_1[] =
> +	const static char init_msg_1[] =
>   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00,
>   		0x00, 0x00 };
> -	char init_msg_2[] =
> +	const static char init_msg_2[] =
>   		{ 0x57, 0x50, 0x04, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0xf4,
>   		0x00, 0x00 };

    Actually 'const' alone should've been enough for the variable to be placed 
in the data section ISO stack.

> -	char receive_buf[28];
> +	const static int buflen = 28;

    Why declare it at all, when it's used only once?

> +	char *usb_buf;
>   	int status;
>
> -	status = kalmia_send_init_packet(dev, init_msg_1, sizeof(init_msg_1)
> -		/ sizeof(init_msg_1[0]), receive_buf, 24);
> +	usb_buf = kmalloc(buflen, GFP_DMA | GFP_KERNEL);
> +	if (!usb_buf)
> +		return -ENOMEM;
> +
> +	memcpy(usb_buf, init_msg_1, 12);

    s/12/sizeof(init_msg_1)/

> +	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_1)
> +		/ sizeof(init_msg_1[0]), usb_buf, 24);

    There's ARRAY_SIZE() macro to replace:

sizeof(init_msg_1) / sizeof(init_msg_1[0])

    and why not use just sizeof(init_msg_1)?

>   	if (status != 0)
>   		return status;
>
> -	status = kalmia_send_init_packet(dev, init_msg_2, sizeof(init_msg_2)
> -		/ sizeof(init_msg_2[0]), receive_buf, 28);
> +	memcpy(usb_buf, init_msg_2, 12);

    s/12/sizeof(init_msg_2)/

> +	status = kalmia_send_init_packet(dev, usb_buf, sizeof(init_msg_2)
> +		/ sizeof(init_msg_2[0]), usb_buf, 28);

    The same comment here about:

sizeof(init_msg_2) / sizeof(init_msg_2[0])

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
