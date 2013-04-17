From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Wed, 17 Apr 2013 08:55:36 +0200
Message-ID: <5581442.KzM2iaDSQ0@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <1637650.tuYfvStuVJ@linux-5eaq.site> <CACVXFVMN4N2EJ0RSzcr8TuUM0ABcJzFSOotaib4Rb-1AJTLHiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:33227 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab3DQGz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 02:55:28 -0400
In-Reply-To: <CACVXFVMN4N2EJ0RSzcr8TuUM0ABcJzFSOotaib4Rb-1AJTLHiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 17 April 2013 09:56:33 Ming Lei wrote:
> On Tue, Apr 16, 2013 at 3:57 PM, Oliver Neukum <oliver@neukum.org> wrote:

> > Generally, saying that somebody else has a problem is not an argument
> > as long as the fix is very simple. Of course it is a corner case, but why
> > fail to solve it as long as the cost is extremely low?
> 
> The cost isn't low because users have to decide(learn) when to use GFP_NOIO
> and when to use GFP_KERNEL, and GFP_NOIO isn't easy to use,
> especially in the corner case which isn't easy to understand too. I bet few of
> guys can think of the case and the usage if they don't recall previous threads.

1. Kernel coders generally need to learn when to use which GFP
2. We have code review

> If you want to avoid the corner case, just hardcode GFP_NOIO in the API. As
> we see, both current usage of the API may have the corner case.

That would make it a worse API for little gain.

> >> - usbnet_status_start() is called from either probe() or work queue scheduled
> >> from probe(), if we want to address the probable issue, the memflags should
> >
> > No, we export this symbol. So we keep it generic if that is possible at low cost.
> > We cannot assume that the conditions it would be called in now, remain so.
> > Of course we don't add stuff needlessly, but here the fix is trivial.
> 
> Why we can't assume the conditions?  The API is introduced just for solving
> one specific problem of sierra net, and shouldn't apply to general situations
> and its usage is __not__ encouraged since it introduces extra power
> consumption. If you have other use cases which need the API, please post
> them out for discussion.

If we have a function for starting a status URB we want to use it whenever
it applies, that is also when we need to poll status for internal reason while
an interface is up.

> In fact, it is sort of a workaround for sierra device only, so we don't
> need to make it general in the extreme, IMO.

As soon as we export it, it is available to general use.

> The fix isn't trivial since GFP_NOIO isn't trivial and the corner case
> isn't easy
> to understand, as I said above.

You don't need to understand it any more than you need to understand
the rule for usb_submit_urb(). The rules are the very same. There is no
special effort here. 

> > Again, no. This is a generic API. It may be called for devices which need
> > their status polled forever and we cannot block them from sleeping.
> > If a driver wants to block suspend while a status URB is on, it should
> > call the autopm method. This is the way we do it while the connection
> > is up.
> 
> The API can't be called in atomic context at all since mutex is to be held.

???

I meant block suspend in the sense of disallowing it. Which is very problematic.
The CDC protocols generally support remote wakeup for status information,
so we need to be able to sleep while status is running to accomodate devices
which are intended to be always online.

	Regards
		Oliver
