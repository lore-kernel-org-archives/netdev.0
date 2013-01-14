From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be
 active
Date: Mon, 14 Jan 2013 11:23:21 -0600
Message-ID: <1358184201.1713.30.camel@dcbw.foobar.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	 <1357318096.5370.15.camel@dcbw.foobar.com>
	 <2212516.GkG3xP33yG@linux-5eaq.site>
	 <1357349193.19684.3.camel@dcbw.foobar.com>
	 <CACVXFVOAjHMxRC=uok-OWPYjw-7D1MSnbaWo97LcGFAVRq+o2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757424Ab3ANRxg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2013 12:53:36 -0500
In-Reply-To: <CACVXFVOAjHMxRC=uok-OWPYjw-7D1MSnbaWo97LcGFAVRq+o2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-11 at 11:06 +0800, Ming Lei wrote:
> On Sat, Jan 5, 2013 at 9:26 AM, Dan Williams <dcbw@redhat.com> wrote:
> > On Fri, 2013-01-04 at 23:16 +0100, Oliver Neukum wrote:
> >> On Friday 04 January 2013 10:48:16 Dan Williams wrote:
> >> > Some drivers (ex sierra_net) need the status interrupt URB
> >> > active even when the device is closed, because they receive
> >> > custom indications from firmware.  Allow sub-drivers to set
> >> > a flag that submits the status interrupt URB on probe and
> >> > keeps the URB alive over device open/close.  The URB is still
> >> > killed/re-submitted for suspend/resume, as before.
> >> >
> >> > Signed-off-by: Dan Williams <dcbw@redhat.com>
> >> > ---
> >> > Oliver: alternatively, is there a problem with *always*
> >> > submitting the interrupt URB, and then simply not calling
> >> > the subdriver's .status function when the netdev is
> >> > closed?  That would be a much simpler patch.
> >>
> >> That is quite radical. We have no idea what a device
> >> does when we do not react to a status update. I would
> >> much prefer to not take the risk.
> >> Besides, we don't use bandwidth if we don't have to.
> >
> > Ok, so scratch the alternative.  Thus, does the posted patch look like
> > the right course of action?
> >
> > If I wasn't clear enough before, sierra_net needs to listen to the
> > status interrupt URB to receive the custom Restart indication as part of
> > the driver's device setup.  Thus for sierra_net at least, tying the
> 
> I am curious who are interested in the 'custom Restart indication'
> information after the interface is closed.

It's actually before the interface is even opened.  It's really just a
sync signal that's part of the driver's setup/initialization of the
device.

> If sierra_net provides ways(such as read registers) to query the
> indication event, you can just query the information and setup
> the device in driver_info->reset() during device open, so you can
> avoid submitting interrupt URB always.

As far as I know, it does not, or at least Sierra hasn't released such
information about the firmware API of their devices.

Dan

> > status interrupt URB submission to device open/close isn't right.
> 
> In theory, drivers should support to report its link status
> even it is closed, but looks no much actual usage, so guys opt to
> submit the interrupt URB only after it is opened.
> 
> 
> Thanks,
> --
> Ming Lei
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
