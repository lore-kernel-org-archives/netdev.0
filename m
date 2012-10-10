From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 10:24:31 +0200
Message-ID: <3796645.0tlat2gorQ@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com> <CACVXFVM7CrxXPYzr+dfWhbbmbF+3sXq4C1q2OauvP6x_jebbYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVM7CrxXPYzr+dfWhbbmbF+3sXq4C1q2OauvP6x_jebbYQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 October 2012 13:56:16 Ming Lei wrote:
> On Wed, Oct 10, 2012 at 11:19 AM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> > On Tue, Oct 9, 2012 at 4:47 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> >>
> >> Using GFP_KERNEL you preclude using those in resume() and error handling.
> >> Please pass a gfp_t parameter.
> >
> > IMO, it is not a big deal because generally only several bytes are to be
> > allocated inside these helpers.
> 
> Also pm_restrict_gfp_mask()/pm_restore_gfp_mask() have been introduced
> to address the problem for 2 years, looks the gfp_t isn't needed, doesn't it?

No, absolutely not. Introducing them was a mistake and is hiding errors.
Those helpers solve the problem only for the case of _system_ suspend/resume.
However the runtime case has the same problem. So in addition to not solving
the problem, we now have two code paths.
Frankly, those functions should be removed.

Secondly, in this case a similar deadlock exists with error handling.
Again take a device with network and storage functions (a.k.a. cell phone).
The storage function does a reset. And the deadlock happens like this:

reset storage -> pre_reset() -> physical reset -> post_reset() -> net interface
does a control message -> kmalloc(..., GFP_KERNEL) -> VM layer decide
to page out -> IO to storage function -> SCSI layer waits for error handler --> DEADLOCK

Believe me, you won't find a fancy solution for this. Just pass the gfp_t.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
