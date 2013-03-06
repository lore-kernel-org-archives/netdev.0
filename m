From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v1 4/7] usbnet: cdc_mbim: don't recover device if suspend fails in system sleep
Date: Wed, 06 Mar 2013 13:04:05 +0100
Message-ID: <877glkohu2.fsf@nemi.mork.no>
References: <1362565557-15884-1-git-send-email-ming.lei@canonical.com>
	<1362565557-15884-5-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Kosina <jkosina@suse.cz>,
	Alan Stern <stern@rowland.harvard.edu>,
	Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-input@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1362565557-15884-5-git-send-email-ming.lei@canonical.com> (Ming
	Lei's message of "Wed, 6 Mar 2013 18:25:53 +0800")
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ming Lei <ming.lei@canonical.com> writes:

> If suspend callback fails in system sleep context, usb core will
> ignore the failure and let system sleep go ahead further, so
> this patch doesn't recover device under this situation.
>
> Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/cdc_mbim.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
> index 248d2dc..ec58c2c 100644
> --- a/drivers/net/usb/cdc_mbim.c
> +++ b/drivers/net/usb/cdc_mbim.c
> @@ -338,7 +338,7 @@ static int cdc_mbim_suspend(struct usb_interface =
*intf, pm_message_t message)
> =20
>  	if (intf =3D=3D ctx->control && info->subdriver && info->subdriver-=
>suspend)
>  		ret =3D info->subdriver->suspend(intf, message);
> -	if (ret < 0)
> +	if (ret < 0 && PMSG_IS_AUTO(message))
>  		usbnet_resume(intf);
> =20
>  error:

This condition will never happen because the subdriver callback always
return 0 if !PMSG_IS_AUTO(message), so adding anything here is purely
for documentation purposes.  That is OK for me.  But I do not see any
point adding incomplete or wrong documentation.=20

The above is incomplete because it ignores the failure and still return
an error. And it is wrong because we ignore an error we cannot possibly
handle in resume.  Only the subdriver can do that, which is why we must
delegate this to the subdriver.

I believe the correct here is to document the fact that we require the
subdriver->suspend() callback to always return 0 if !PMSG_IS_AUTO(messa=
ge).
That is best done with a comment. No need to add any redundant code.


Bj=C3=B8rn

--
To unsubscribe from this list: send the line "unsubscribe linux-input" =
in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
