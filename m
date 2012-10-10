From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 07:51:37 +0200
Message-ID: <4085386.s0fOKMaRDP@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <1765908.3QOFSVW2eC@linux-lqwf.site> <CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVOPc0gG3UdWqJ0E+6wiwdPv5EoEgbJ0cvJ4oD4602Yp3A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 10 October 2012 11:19:09 Ming Lei wrote:
> On Tue, Oct 9, 2012 at 4:47 PM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> >
> > Using GFP_KERNEL you preclude using those in resume() and error handling.
> > Please pass a gfp_t parameter.
> 
> IMO, it is not a big deal because generally only several bytes are to be
> allocated inside these helpers.

Any allocation can do it, if the VM layer decides to block.

> If you still think the problem should be considered, another candidate fix
> is to take GFP_NOIO during system suspend/resume, and take GFP_KERNEL
> in other situations.

No, the problem is autoresume.

Suppose we have a device with two interface. Interface A be usbnet; interface B
something you page on. Now consider that you can only resume both interfaces
and this is (and needs to be) done synchronously.

Now we can have this code path:

autoresume of device -> resume() -> kmalloc(..., GFP_KERNEL) ->
VM layer decides to start paging out -> IO to interface B -> autoresume of device
--> DEADLOCK

We need to use GFP_NOIO in situations the helper cannot know about.
Please add a gfp_t parameter. Then the caller will solve that.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
