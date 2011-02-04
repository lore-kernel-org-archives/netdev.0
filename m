From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.38-rc3-git1: Reported regressions 2.6.36 -> 2.6.37
Date: Thu, 3 Feb 2011 16:30:56 -0800
Message-ID: <AANLkTimQPPDyBwkN0HWM2+bPcbzVd8YHZvn2iR8MVzfL@mail.gmail.com>
References: <e9vOd5LzdBK.A.dyD.h6eSNB@chimera> <AANLkTikELiGS+fM5WguZS=Fo-sSXmej1UnKWqCFmnE0k@mail.gmail.com>
 <s5haaid3xos.wl%tiwai@suse.de> <201102032009.17100.rjw@sisk.pl>
 <AANLkTi=suS1VDL=6EtT0D2=0c1DWwxdwZBBv=-BySNX-@mail.gmail.com>
 <AANLkTi=7EOih=fY5FCvhQbewSc=3a49cYVaKJRWM+-3d@mail.gmail.com> <AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Carlos Mafra <crmafra2@gmail.com>,
	Keith Packard <keithp@keithp.com>,
	Dave Airlie <airlied@redhat.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Takashi Iwai <tiwai@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Dave Airlie <airlied@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50465 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753490Ab1BDAbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 19:31:19 -0500
In-Reply-To: <AANLkTin7kBur95H=UBcYEcjYsUkrdG8znX-7PFZ4rrHf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 3, 2011 at 4:06 PM, Dave Airlie <airlied@gmail.com> wrote:
>
> If we are setting a mode on a connector it automatically will end up
> in a DPMS on state,
> so this seemed correct from what I can see.

The more I look at that function, the more I disagree with you and
with that patch.

The code is just crazy.

First off, it isn't even necessarily setting a mode to begin with,
because as far as I can tell. If the mode doesn't change, neither
mode_changed nor fb_changed will be true, afaik. There seems to be a
fair amount of code there explicitly to avoid changing modes if not
necessary.

But even _if_ we are setting a mode, if I read the code correctly, the
mode may be set to NULL - which seems to mean "turn it off". In which
case it looks to me that drm_helper_disable_unused_functions() will
actually do a

   (*crtc_funcs->dpms)(crtc, DRM_MODE_DPMS_OFF);

call on the crtc in question. So then blindly just saying "it's mode
DRM_MODE_DPMS_ON" afterwards looks rather bogus to me.

_Maybe_ it would work if it was done before that whole
"disable_unused" logic. Or maybe it should just be done in
drm_crtc_helper_set_mode(), which is what actually sets the mode (but
there's the 'fb_changed' case too)

> A future mode set shouldn't ever not turn the connector on, since
> modesetting is an implicit
> DPMS,
>
> It sounds like something more subtle than that, though I'm happy to
> revert this for now, and let Keith
> think about it a bit more.

So I haven't heard anything from Keith. Keith? Just revert it? Or do
you have a patch for people to try?

                               Linus
