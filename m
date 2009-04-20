From: Laurent Pinchart <laurent.pinchart@skynet.be>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Mon, 20 Apr 2009 22:08:22 +0200
Message-ID: <200904202208.23899.laurent.pinchart@skynet.be>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <alpine.LFD.2.00.0904171952260.4042@localhost.localdomain> <20090418125111.6646e997@linux-lm>
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
To: leiming <tom.leiming@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756448AbZDTUGR@vger.kernel.org>
In-Reply-To: <20090418125111.6646e997@linux-lm>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 18 April 2009 06:51:11 leiming wrote:
> On Fri, 17 Apr 2009 19:55:29 -0700 (PDT)
>
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > > @@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct
> > > uvc_video_device *video,
> > >  	/* Buffers are already allocated, bail out. */
> > >  	if (video->urb_size)
> > > -		return 0;
> > > +		return DIV_ROUND_UP(video->urb_size, psize);
> >
> > I don't think this is right. It should round _down_.
> >
> > It's supposed to return 'npackets', but if you pass it a different
> > packet size than it was passed originally, it can now return a
> > potentially bigger number than the already allocated buffer, no?
> >
> > So I think it should round down (ie use a regular divide). No?
>
> Yes,you are correct, please ignore my last reply, and following is
> the fixed patch.

psize and video->urb_size shouldn't have changed before and after resume, 
otherwise we'll get into trouble anyway. A regular divide and a round-up 
divide should then return the same result. I'll take the regular divide, as it 
will be more efficient.

> Thanks.
>
> From a3b3d72cdd57a0699fb643b41b78eb7beb211ff5 Mon Sep 17 00:00:00 2001
> From: Ming Lei <tom.leiming@gmail.com>
> Date: Wed, 15 Apr 2009 22:32:51 +0800
> Subject: [PATCH] V4L/DVB:usbvideo:fix uvc resume failed(v2)
>
> Now urb buffers is not freed before suspend, so uvc_alloc_urb_buffers
> should return packet counts allocated originally during uvc resume
> , instead of zero.
>
> This version uses round down to return packet counts on Linus's
> suggestions, or else may lead to buffer destructed if packet size
> is changed before calling uvc_alloc_urb_buffers() in this kind of
> case.

The comment is misleading. If the packet size changes we need to reallocate 
the buffers anyway. Have you checked if the packet size (which depends on the 
endpoint being selected) can be changed between suspend and resume, either by 
the uvcvideo driver (I don't think it can) or the USB core ?

Best regards,

Laurent Pinchart
