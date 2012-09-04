From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: fix softirq storm on suspend
Date: Tue, 4 Sep 2012 12:19:28 +0800
Message-ID: <CACVXFVNykwxe-PYP_nin32htFmrFL4d=3DEhZMo3UwTEpb81+A@mail.gmail.com>
References: <1346660778-24539-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1346660778-24539-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 3, 2012 at 4:26 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Suspending an open usbnet device results in constant
> rescheduling of usbnet_bh.
>
> commit 65841fd5 "usbnet: handle remote wakeup asap"
> refactored the usbnet_bh code to allow sharing the
> urb allocate and submit code with usbnet_resume. In
> this process, a test for, and immediate return on,
> ENOLINK from rx_submit was unintentionally dropped.
>
> The rx queue will not grow if rx_submit fails,
> making usbnet_bh reschedule itself.  This results
> in a softirq storm if the error is persistent.
> rx_submit translates the usb_submit_urb error
> EHOSTUNREACH into ENOLINK, so this is an expected
> and persistent error for a suspended device. The
> old code tested for this condition and avoided
> rescheduling.  Putting this test back.
>
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> # v3.5
> Cc: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> Signed-off-by: Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
> ---
> Sorry for not noticing this before, but commit 65841fd5
> makes usbnet autosuspend completely unusable.  The device
> is suspended fine, but burning one CPU core at full load
> uses a tiny bit more power making the power saving
> negative...

I am wondering how you can reproduce the issue.

usbnet_terminate_urbs is called inside usbnet_suspend to
consume all URBs and SKBs, and rx_alloc_submit can't be
called during the period because of !netif_device_present().
Once usbnet_terminate_urbs and netif_device_attach() are
completed, who will schedule tasklet to trigger rx_alloc_submit?

>
> I hope this can go into 3.6 and 3.5-stable ASAP. It is
> a hard to notice regression, but all the same a serious
> one.

Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
