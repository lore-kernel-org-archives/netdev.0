From: Salam Noureddine <noureddine@aristanetworks.com>
Subject: Re: [PATCH 2/2] ipv4 igmp: use del_timer_sync instead of del_timer in ip_mc_down
Date: Fri, 27 Sep 2013 16:28:01 -0700
Message-ID: <CAO7SqHAuyyJXrm5q3_2PW--aQpTjk+j7O_iZ6sg8E_xVBd_4Mg@mail.gmail.com>
References: <1378363404-37749-1-git-send-email-noureddine@aristanetworks.com>
	<20130905084312.091f73b7@nehalam.linuxnetplumber.net>
	<CAO7SqHA4LJhy_NBkPLViJB3s7hM85qd88pmjy3hq-hCCuQstaA@mail.gmail.com>
	<CAO7SqHA5pBs7Tmop1ukS_AEXO8K9Np7odo20QdTYHBg2qoV49Q@mail.gmail.com>
	<20130927231532.GA23750@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f41.google.com ([209.85.212.41]:60637 "EHLO
	mail-vb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753003Ab3I0X2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 19:28:02 -0400
Received: by mail-vb0-f41.google.com with SMTP id g17so2378806vbg.0
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 16:28:01 -0700 (PDT)
In-Reply-To: <20130927231532.GA23750@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the explanation. Currenlty, __in_dev_put is both used in
timer handler function and in ip_mc_down where del_timer is invoked. I
guess we need to change the timer handler so it uses in_dev_put to do
proper cleanup in cases where it runs past the call to ip_mc_down and
has the last reference.

On Fri, Sep 27, 2013 at 4:15 PM, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> On Fri, Sep 27, 2013 at 04:04:00PM -0700, Salam Noureddine wrote:
>>                               I don't quite understand the reason
>> for having __in_dev_put decrement the refcnt without destroying the
>> in_device in case it reaches 0. If the timer handler assumes it cannot
>> be the last one to hold a reference then that would mean it doesn't
>> need the reference in the first place.
>
> I would like to explain this, because this can result in a big mistake.
>
> Timer takes reference, when it _can_ be the last sometimes.
>
> When we do del_timer() and know for sure that someone holds refcnt, we can just
> decrese it. In this cae it is obvious: we sit in context whcih deals with in_dev,
> so that reference from timer acannot be the last: caller of the function holds refcnt.
>
> But in another places timer _expires_ and that last reference is dropped by in_dev_put().
>
> Alexey
