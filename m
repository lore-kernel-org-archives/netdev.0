From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2] usbnet: allow status interrupt URB to always be active
Date: Sat, 05 Jan 2013 12:01:55 +0100
Message-ID: <3476529.YzSzbMTfeu@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <2212516.GkG3xP33yG@linux-5eaq.site> <1357349193.19684.3.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Elina Pasheva <epasheva@sierrawireless.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:57162 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470Ab3AELBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 06:01:54 -0500
In-Reply-To: <1357349193.19684.3.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 04 January 2013 19:26:33 Dan Williams wrote:
> On Fri, 2013-01-04 at 23:16 +0100, Oliver Neukum wrote:
> > On Friday 04 January 2013 10:48:16 Dan Williams wrote:
> > > Some drivers (ex sierra_net) need the status interrupt URB
> > > active even when the device is closed, because they receive
> > > custom indications from firmware.  Allow sub-drivers to set
> > > a flag that submits the status interrupt URB on probe and
> > > keeps the URB alive over device open/close.  The URB is still
> > > killed/re-submitted for suspend/resume, as before.
> > > 
> > > Signed-off-by: Dan Williams <dcbw@redhat.com>
> > > ---
> > > Oliver: alternatively, is there a problem with *always*
> > > submitting the interrupt URB, and then simply not calling
> > > the subdriver's .status function when the netdev is
> > > closed?  That would be a much simpler patch.
> > 
> > That is quite radical. We have no idea what a device
> > does when we do not react to a status update. I would
> > much prefer to not take the risk.
> > Besides, we don't use bandwidth if we don't have to.
> 
> Ok, so scratch the alternative.  Thus, does the posted patch look like
> the right course of action?

In principle yes.

> If I wasn't clear enough before, sierra_net needs to listen to the
> status interrupt URB to receive the custom Restart indication as part of
> the driver's device setup.  Thus for sierra_net at least, tying the
> status interrupt URB submission to device open/close isn't right.

So, there seems to be an inevitable race before probe() is called.
Have you looked at FLAG_AVOID_UNLINK_URBS ?

> I'd previously done a patch to handle this all in sierra_net, but the
> problem there is suspend/resume: without directly accessing the usbnet
> structure's ->suspend_count member (icky!) sierra_net can't correctly
> kill/submit the URB itself.  So I went with a flag to usbnet that Sierra
> can set.

That is absolutely the right way to do it.

	Regards
		Oliver
