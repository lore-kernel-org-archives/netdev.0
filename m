From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2.6.18] WE-21 support (core API)
Date: Mon, 04 Sep 2006 10:35:09 +0200
Message-ID: <1157358909.3324.42.camel@ux156>
References: <20060830005655.GA8405@bougret.hpl.hp.com>
	 <1157093640.2878.26.camel@ux156>
	 <20060901163558.GB13815@bougret.hpl.hp.com>
	 <200609012055.48799.mb@bu3sch.de>
	 <20060901221045.GB13975@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41091 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751158AbWIDIed
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 04:34:33 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060901221045.GB13975@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uh, please don't strip me from the CC list :)

> 	WE-netlink is optional. And WE-ioctl could be made optional
> (still on the todo list). You can also disable WE-event and WE-iwspy
> for further footprint reduction.

The real question is: Why does removing WE-event reduce footprint? I
guess the answer is that there's a lot of non-generic code needed to
pack/unpack all the data. Which is not really something you want.

wireless.c has about 2.3k lines of code. But, for example airo.c
contains another 15 lines of code just for the trivial *parameter
checking* in airo_set_essid. This is duplicated all over. Did it never
occur to you that things like
                /* Check the size of the string */
                if(dwrq->length > IW_ESSID_MAX_SIZE+1) {
                        return -E2BIG ;
                }
can be checked generically? Maybe you're actually checking this
generically. But if I did it your way, I'd copy and paste this all
over...

genetlink puts this all into the generic code reducing code-size in the
actual handler code a lot. No more checking for nul-termination or foo
like that, it's automatically enforced and if the string isn't
nul-terminated but you want it, it gets rejected much earlier, nl80211
doesn't even get to see it. Same with length restrictions.

> 	If you are trying to write WE without reading any other code,
> that's true. But that's not the way sane people work. 

Excuse me?

> Sane people
> cut'n'paste from other drivers, and then check the source code of
> iwconfig (which is fully commented) in case of doubt.

No no no, you have this all the wrong way around. *Sane* people *DON'T*
just copy and paste random code into their drivers without knowing what
it does. Also, *sane* people *DON'T* check the userspace tools for what
they should send out of the kernel since userspace doesn't define the
ABI, the kernel does.
And this attitudes gets you what you can see: a proliferation of large
amounts of code between all drivers that is ever so slightly different
everywhere and you can't really know whether the differences are on
purpose or just errors.

Note: This is another case point against WE. Why is this code
duplication needed in the first place? Because WE itself doesn't give
the driver authors proper info, it requires them to know about all the
specialties.

> 	It was designed this way on purpose, because you get low
> footprint and very good scalability.

Wtf does scalability have to do with it? One thing you don't seem to
realise that developer time in the open source community can be a much
more precious resource than 1k object code. And an API that isn't buggy,
well-defined, and behaves the same across all drivers (you can't tell me
that softmac behaves the same as airo.c even where it could... I can't
possibly be that lucky) is worth even more.

I, for one, have spent hours on understanding all the magic WE. You seem
to claim I don't need to understand it and I can just copy/paste code.
But as I said above, it doesn't really work that way. Also, I probably
spent more time understanding and writing the WE part of softmac than
writing the rest.

Ideally, we'd have a set of well-defined callbacks that a driver author
assigns (not more memory overhead than the ioctl array) with
well-defined structures that are passed in (admittedly a bit overhead to
deserialize netlink messages into those structures, but a large part of
that is done by genetlink) checked by the generic netlink code that's
present anyway (getting rid of code, most importantly in the drivers
itself, they are complicated enough anyway).

This is what I'm aiming for with nl80211.

And since you don't seem to want to work with me on nl80211 I'll just
have to work against you. I'll do my best to stop proliferation of more
WE stuff because I believe it to be dead as soon as I can manage to
write enough code. I will provide a compatibility layer since I believe
in stable userspace interfaces, but this will simply translate the WE
ioctls calls to appropriate cfg80211 backend calls similar to what
nl80211 does.

wireless.c and driver WE support in its current form must die.

johannes

-- 
VGER BF report: U 0.903988
