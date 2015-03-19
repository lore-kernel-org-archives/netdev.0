From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next] rocker: check for BRIDGE_FLAGS_SELF in bridge
 setlink handler
Date: Wed, 18 Mar 2015 22:49:23 -0700
Message-ID: <CAE4R7bB2GC3_vMvKAcYie1SP0xB9hm-himzP_BGHX5B2gZKisw@mail.gmail.com>
References: <CAE4R7bDrhnK_a9dvyMqSJkGgod6AM=HDE6CAKkG_RnjuDxB2-Q@mail.gmail.com>
	<CAJieiUhHdXOZjWkb4s_GviLwzq5Gct-1o8xv8b-JeM46S4e-dg@mail.gmail.com>
	<20150309064043.GB2053@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067E6A8D@ORSMSX101.amr.corp.intel.com>
	<20150309160754.GA2169@nanopsycho.lan>
	<E4CD12F19ABA0C4D8729E087A761DC35067E6EF0@ORSMSX101.amr.corp.intel.com>
	<20150310063926.GA1995@nanopsycho.orion>
	<E4CD12F19ABA0C4D8729E087A761DC35067E7016@ORSMSX101.amr.corp.intel.com>
	<20150310082817.GC1995@nanopsycho.orion>
	<550752BA.5040702@gmail.com>
	<20150317070046.GB2042@nanopsycho.orion>
	<55083AB6.4060003@intel.com>
	<55088E2C.5000405@cumulusnetworks.com>
	<5508C3EA.80009@intel.com>
	<55091B4C.7090507@cumulusnetworks.com>
	<550998C7.7080108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: roopa <roopa@cumulusnetworks.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:33393 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbbCSFtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 01:49:24 -0400
Received: by qcbjx9 with SMTP id jx9so19370044qcb.0
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 22:49:23 -0700 (PDT)
In-Reply-To: <550998C7.7080108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 18, 2015 at 8:24 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> [...]

>> I am not sure how this would be and what other issues you will hit if
>> you are planning to bypass the kernel and directly go to the switch
>> driver for all l2 and l3 in the stacked netdevice case. For l3, its
>> better to use the in-kernel route fib offload mechanism which was
>> recently submitted by scott feldman.
>>
>
> Why? I saw the patched and liked it but noted that the existing policy
> wont actually work for real networks. Its a good start. My proposal
> is to add a flag to l3 to similarly fail to load a rule if it can't
> be pushed at hardware same as l2.

RIght, what we have is a start to get the basic plumbing in place.
Agreed, the current would be inadequate for a real switch that can't
handle a software fallback.

Maybe the next step is to not flush hw of all routes on failure to add
the Nth one, but rather just fail the Nth completely (don't install in
hw or sw and return err to user).  This would keep the switch alive,
but now moves a decision to the user.  The user must decide what to do
with the failed Nth route.

We also added the netlink flag RTNH_F_EXTERNAL to mark routes
offloaded to hardware, but the marking is only done internally now, by
the kernel.  What I'm hoping is we can use that same flag in the
user's netlink msg to work like you describe: if user requests
RTNH_F_EXTERNAL, and it can't be loaded into hw, don't load into sw.
Or something like that.  Again, punting the decision on what to do
next to the user.

This part of the discussion should probably move to a new thread;
maybe someone brave can propose a patch to move us to the next level?

-scott
