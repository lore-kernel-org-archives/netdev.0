From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 12:08:32 +0200
Message-ID: <1691674.ASueyuVmUn@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <1631246.gHVDWoZpLi@linux-lqwf.site> <CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57782 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755573Ab2JJKKR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 06:10:17 -0400
In-Reply-To: <CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 October 2012 17:48:54 Ming Lei wrote:
> On Wed, Oct 10, 2012 at 4:39 PM, Oliver Neukum <oneukum@suse.de> wrote:
> > On Wednesday 10 October 2012 16:17:25 Ming Lei wrote:
> >> On Wed, Oct 10, 2012 at 1:51 PM, Oliver Neukum <oneukum@suse.de> wrote:
> >
> >> > We need to use GFP_NOIO in situations the helper cannot know about.
> >> > Please add a gfp_t parameter. Then the caller will solve that.
> >>
> >> Considered that most of drivers call the helpers in different context, I think
> >> it is better to switch the gpf_t flag runtime inside helpers, like below:
> >>
> >>            if (dev->power.runtime_status == RPM_RESUMING)
> >>                    gfp = GFP_NOIO;
> >>           else
> >>                    gfp = GFP_KERNEL;
> >
> > You are admirably persistent ;-)
> 
> I am only trying to solve the problem more generally, :-)

The most generic solution is passing the parameter.

> > If you extended the check to RPM_SUSPENDING it might work,
> > but still the problem with error handling exists.
> 
> Could you describe the error handling case in a bit detail so
> that callers of these helpers can know when GFP_KERNEL
> is to be passed and when GFP_NOIO is taken if the gfp
> patamerer has to be added?

A reset always applies to the whole device. Resets are used in error
handling of block devices (storage and uas). If you reset a device,
pre_reset() and post_reset() of all interfaces need to be called. So they
are part of the SCSI error handler. SCSI error handlers can allocate memory
only with GFP_NOIO (or GFP_ATOMIC) because any IO for paging
can cause the SCSI layer to wait for the error handling to finish. The error
handling can only finish when pre/post_reset() have finished. Catch-22

So any control messages in block error handling need to use GFP_NOIO.
If you look at the control message helpers in usbcore you will find a lot
of GFP_NOIO. That is the reason.

	Regards
		Oliver
