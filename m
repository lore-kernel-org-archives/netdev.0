From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [RFCv3 bluetooth-next 4/4] 6lowpan: iphc: add support for
 stateful compression
Date: Fri, 11 Dec 2015 20:49:23 +0100
Message-ID: <20151211194922.GA26064@omega>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-5-git-send-email-alex.aring@gmail.com>
 <20151211170541.GA1119@omega>
 <566B1FEE.5030509@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wpan@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, mcr@sandelman.ca,
	lukasz.duda@nordicsemi.no, martin.gergeleit@hs-rm.de
To: Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34718 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbbLKTtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 14:49:32 -0500
Content-Disposition: inline
In-Reply-To: <566B1FEE.5030509@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 11, 2015 at 08:11:42PM +0100, Stefan Schmidt wrote:
> Hello.
> 
> On 11/12/15 18:05, Alexander Aring wrote:
> >Hi,
> >
> >status update here.
> >
> >I implemented successful basic 6CO RA messages at sending and
> >processing inside radvd.
> >
> >There might also the question if processing 6CO inside kernel or
> >userspace? I put the basic functionality inside userspace for now.
> 
> How are you feeding the entries your receive back into the kernel? The
> debugfs interface right now?
> If we want to go with userspace handling for 6CO we need something better at
> some point.
> 

yes. For testing it's fine, I think we should add first support this way. If
we see it seems to be working well then making better UAPI interface.

I currently complete ignore the lifetime thing and handle it like
lifetime is non-zero.

For the lifetime handling, I think we need more than just a "bool", we
need flags. Because we need indicate "somehow" the "C flag" and if the
entry is "added" or "not added" (some active/enabled flag). See [0], or
we do that by check on "::" address/prefix, but I would not do that so far
nobody says that's an invalid prefix.

Then also the question is if doing the lifetime of a context inside the
kernel or in userspace (handled by $USERSPACE_PROGRAM, e.g. radvd). I think
radvd can handle this. See [1]:

The prefix information is timed out as specified in [RFC4861].  When
the Valid Lifetime for a context table entry expires, the entry is
placed in a receive-only mode, which is the equivalent of
receiving a 6CO for that context with C=0.  The entry is held in
receive-only mode for a period of twice the default Router Lifetime,
after which the entry is removed.

For this we need the "C" flag and "active" flag (indicate remove). That
the entry is held could be very simple by a timer in kernel, but
otherwise $USERSPACE_PROGRAM could also do this job by handle the
lifetime only in userspace, when lifetime expires -> manipulating the table.

I am not sure what's the best option here is.

BTW:

One bad news is, that radvd needs now to run under "root" with this
changes and it seems that it can running without root right before. This
might be getting a problem when trying to send such feature uptream to
radvd.

Testing:

I already test the new stateful compression patch (manipulating entries in
RIOT manually (no RA messages processing on RIOT).
It works fine under RIOT by manipulating RIOT's context table.

- Alex

[0] https://tools.ietf.org/html/rfc6775#section-5.4.2
[1] https://tools.ietf.org/html/rfc6775#section-5.4.3
