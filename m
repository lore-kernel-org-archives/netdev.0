From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Tue, 21 Apr 2009 09:47:34 +0800
Message-ID: <d82e647a0904201847n403424efnb5a0c40a4cac365d@mail.gmail.com>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
	 <alpine.LFD.2.00.0904171952260.4042@localhost.localdomain>
	 <20090418125111.6646e997@linux-lm>
	 <200904202208.23899.laurent.pinchart@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	video4linux-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: Laurent Pinchart <laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200904202208.23899.laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2009/4/21 Laurent Pinchart <laurent.pinchart-AgBVmzD5pcezQB+pC5nmwQ@public.gmane.org>:
> On Saturday 18 April 2009 06:51:11 leiming wrote:
>> On Fri, 17 Apr 2009 19:55:29 -0700 (PDT)
>>
>> Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>> > > @@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct
>> > > uvc_video_device *video,
>> > > =A0 /* Buffers are already allocated, bail out. */
>> > > =A0 if (video->urb_size)
>> > > - =A0 =A0 =A0 =A0 return 0;
>> > > + =A0 =A0 =A0 =A0 return DIV_ROUND_UP(video->urb_size, psize);
>> >
>> > I don't think this is right. It should round _down_.
>> >
>> > It's supposed to return 'npackets', but if you pass it a different
>> > packet size than it was passed originally, it can now return a
>> > potentially bigger number than the already allocated buffer, no?
>> >
>> > So I think it should round down (ie use a regular divide). No?
>>
>> Yes,you are correct, please ignore my last reply, and following is
>> the fixed patch.
>
> psize and video->urb_size shouldn't have changed before and after res=
ume,
> otherwise we'll get into trouble anyway. A regular divide and a round=
-up
> divide should then return the same result. I'll take the regular divi=
de, as it
> will be more efficient.

Yes.

>
>> Thanks.
>>
>> From a3b3d72cdd57a0699fb643b41b78eb7beb211ff5 Mon Sep 17 00:00:00 20=
01
>> From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Wed, 15 Apr 2009 22:32:51 +0800
>> Subject: [PATCH] V4L/DVB:usbvideo:fix uvc resume failed(v2)
>>
>> Now urb buffers is not freed before suspend, so uvc_alloc_urb_buffer=
s
>> should return packet counts allocated originally during uvc resume
>> , instead of zero.
>>
>> This version uses round down to return packet counts on Linus's
>> suggestions, or else may lead to buffer destructed if packet size
>> is changed before calling uvc_alloc_urb_buffers() in this kind of
>> case.
>
> The comment is misleading. If the packet size changes we need to real=
locate
> the buffers anyway. Have you checked if the packet size (which depend=
s on the
> endpoint being selected) can be changed between suspend and resume, e=
ither by
> the uvcvideo driver (I don't think it can) or the USB core ?

The packet size does not change between suspend and resume.  I mean
uvc_alloc_urb_buffers()
still can be used in other cases if buffers was not freed and is
reuesed in future. It seems there is no
such cases in uvcvideo now, but uvc_alloc_urb_buffers() really __can__
 work in such case, isn't it?

IMHO It is only used to allocate or reserve UVC_URBS usb buffers,
which size is video->urb_size, and
npackets can be shortened or enlarged if psize is changed, after all.

Thanks!

--=20
Lei Ming
