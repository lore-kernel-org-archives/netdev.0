From: Laurent Pinchart <laurent.pinchart@skynet.be>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Wed, 22 Apr 2009 01:21:10 +0200
Message-ID: <200904220121.12002.laurent.pinchart@skynet.be>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <200904202208.23899.laurent.pinchart@skynet.be> <d82e647a0904201847n403424efnb5a0c40a4cac365d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	video4linux-list@redhat.com, mchehab@infradead.org
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <d82e647a0904201847n403424efnb5a0c40a4cac365d@mail.gmail.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tuesday 21 April 2009 03:47:34 Ming Lei wrote:
> 2009/4/21 Laurent Pinchart <laurent.pinchart@skynet.be>:
> > On Saturday 18 April 2009 06:51:11 leiming wrote:
> >> On Fri, 17 Apr 2009 19:55:29 -0700 (PDT)
> >>
> >> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> >> > > @@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct
> >> > > uvc_video_device *video,
> >> > >   /* Buffers are already allocated, bail out. */
> >> > >   if (video->urb_size)
> >> > > -         return 0;
> >> > > +         return DIV_ROUND_UP(video->urb_size, psize);
> >> >
> >> > I don't think this is right. It should round _down_.
> >> >
> >> > It's supposed to return 'npackets', but if you pass it a different
> >> > packet size than it was passed originally, it can now return a
> >> > potentially bigger number than the already allocated buffer, no?
> >> >
> >> > So I think it should round down (ie use a regular divide). No?
> >>
> >> Yes,you are correct, please ignore my last reply, and following is
> >> the fixed patch.
> >
> > psize and video->urb_size shouldn't have changed before and after resume,
> > otherwise we'll get into trouble anyway. A regular divide and a round-up
> > divide should then return the same result. I'll take the regular divide,
> > as it will be more efficient.
>
> Yes.
>
> >> Thanks.
> >>
> >> From a3b3d72cdd57a0699fb643b41b78eb7beb211ff5 Mon Sep 17 00:00:00 2001
> >> From: Ming Lei <tom.leiming@gmail.com>
> >> Date: Wed, 15 Apr 2009 22:32:51 +0800
> >> Subject: [PATCH] V4L/DVB:usbvideo:fix uvc resume failed(v2)
> >>
> >> Now urb buffers is not freed before suspend, so uvc_alloc_urb_buffers
> >> should return packet counts allocated originally during uvc resume
> >> , instead of zero.
> >>
> >> This version uses round down to return packet counts on Linus's
> >> suggestions, or else may lead to buffer destructed if packet size
> >> is changed before calling uvc_alloc_urb_buffers() in this kind of
> >> case.
> >
> > The comment is misleading. If the packet size changes we need to
> > reallocate the buffers anyway. Have you checked if the packet size (which
> > depends on the endpoint being selected) can be changed between suspend
> > and resume, either by the uvcvideo driver (I don't think it can) or the
> > USB core ?
>
> The packet size does not change between suspend and resume.  I mean
> uvc_alloc_urb_buffers() still can be used in other cases if buffers was not
> freed and is reuesed in future. It seems there is no such cases in uvcvideo
> now, but uvc_alloc_urb_buffers() really __can__ work in such case, isn't it?
>
> IMHO It is only used to allocate or reserve UVC_URBS usb buffers, which size
> is video->urb_size, and npackets can be shortened or enlarged if psize is
> changed, after all.

You're right. Patch applied, thanks.

Best regards,

Laurent Pinchart

