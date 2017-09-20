From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Wed, 20 Sep 2017 07:25:58 +0200
Message-ID: <20170920052558.h6c4lkqmzk2h2pdq@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170918080214.yrejz67wwnp2pjzf@localhost>
 <87k20vip3f.fsf@intel.com>
 <20170919052244.77umdxuze53t6j22@localhost>
 <87wp4ufchl.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33294 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751704AbdITF0F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 01:26:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id m127so1375339wmm.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 22:26:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87wp4ufchl.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 05:19:18PM -0700, Vinicius Costa Gomes wrote:
> One of the problems with OpenAVNU is that it's too coupled with the i210
> NIC. One of the things we want is to decouple OpenAVNU from the
> controller.

Yes, I want that, too.

> The way we thought best was to propose interfaces (that
> would work along side to the Linux networking stack) as close as
> possible to what the current standards define, that means the IEEE
> 802.1Q family of specifications, in the hope that network controller
> vendors would also look at the specifications when designing their
> controllers.

These standard define the *behavior*, not the programming APIs.  Our
task as kernel developers is to invent the best interfaces for
supporting 802.1Q and other standards, the hardware capabilities, and
the widest range of applications (not jut AVB).

> Our objective with the Qdiscs we are proposing (both cbs and taprio) is
> to provide a sane way to configure controllers that support TSN features
> (we were looking specifically at the IEEE specs).

I can see how your proposed Qdiscs are inspired by the IEEE standards.
However, in the case of time based transmission, I think there is a
better way to do it, namely with SO_TXTIME (which BTW was originally
proposed by Eric Mann).
 
> After we have some rough consensus on the interfaces to use, then we can
> start working on OpenAVNU.

Did you see my table in the other mail?  Any comments?

> (Sorry if I am being annoying here, but the idea of an opaque schedule
> is not ours, that comes from the people who wrote the Qbv specification)

The schedule is easy to implement using SO_TXTIME.
 
> I have a question, what about a controller that doesn't provide a way to
> set a per-packet transmission time, but it supports Qbv/Qbu. What would
> be your proposal to configure it?

SO_TXTIME will have a generic SW fallback.

BTW, regarding the i210, there is no sensible way to configure both
CBS and time based transmission at the same time.  The card performs a
logical AND to make the launch decision.  The effect of this is that
each and every packet needs a LaunchTime, and the driver would be
forced to guess the time for a packet before entering it into its
queue.

So if we end up merging CBS and SO_TXTIME, then we'll have to make
them exclusive of each other (in the case of the i210) and manage the
i210 queue configurations correctly.

> (I think LaunchTime is something specific to the i210, right?)

To my knowledge yes.  However, if TSN does take hold, then other MAC
vendors will copy it.

Thanks,
Richard
