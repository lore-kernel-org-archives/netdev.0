From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 46/62] usb: Use static const
Date: Sun, 21 Nov 2010 17:06:53 +0300
Message-ID: <4CE9277D.9050505@ru.mvista.com>
References: <cover.1290305773.git.joe@perches.com> <ed2a5bd07f07601ba12ce3c8fcbce2dd954c35aa.1290305776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ed2a5bd07f07601ba12ce3c8fcbce2dd954c35aa.1290305776.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 21-11-2010 5:38, Joe Perches wrote:

> Using static const generally increases object text and decreases data size.
> It also generally decreases overall object size.

>     text	   data	    bss	    dec	    hex	filename
>    36120	    312	   9000	  45432	   b178	drivers/net/usb/hso.o.old
>    36043	    312	   9008	  45363	   b133	drivers/net/usb/hso.o.new

> Consolidate duplicated code into new fix_crc_bug function
> and declare data in that function static const.

> Signed-off-by: Joe Perches<joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
[...]

> diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
> index be8cc2a..c77d0ea 100644
> --- a/drivers/net/usb/hso.c
> +++ b/drivers/net/usb/hso.c
> @@ -1001,6 +1001,18 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
>   	}
>   }
>
> +static void fix_crc_bug(struct urb *urb, __le16 max_packet_size)
> +{
> +	static const u8 crc_check[4] = { 0xDE, 0xAD, 0xBE, 0xEF };
> +	u32 rest = urb->actual_length % le16_to_cpu(max_packet_size);
> +
> +	if (((rest == 5) || (rest == 6)) &&
> +	    !memcmp(((u8 *)urb->transfer_buffer) + urb->actual_length - 4,

    Parens around '(u8 *)urb->transfer_buffer' not needed. Could get rid of 
them, while at it...

> +		    crc_check, 4)) {
> +		urb->actual_length -= 4;
> +	}
> +}
> +
>   /* Moving data from usb to kernel (in interrupt state) */
>   static void read_bulk_callback(struct urb *urb)
>   {

WBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
