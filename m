From: Fan Du <fdu@windriver.com>
Subject: [RESEND][XFRM][PATCH v4] Fix unexpected SA hard expiration after setting new date
Date: Fri, 27 Jul 2012 10:39:18 +0800
Message-ID: <1343356759-24767-1-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37149 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000Ab2G0Cje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 22:39:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Dave

It has been more than one month since my last post of this patch.
Previous posting receives no objection from you and Herbert, so I
rebase it with latest linux-3.5, then it can be easily picked up.
I'm wondering could you please take a look at this patch ?

Any comments are really welcome!

Thanks


Changelog:
v1->v2
1) use xflags instead of creating new flags(suggested by Steffen Klassert)

v2->v3
1) fix email problem, and remove cc to myself(requested by David Miller)

v3->v4
1) fix typo when clearing XFRM_SOFT_EXPIRE(thanks for David Miller)
2) fix email problem, and remove cc to myself AGAIN!!!


*Background*:
Once IPsec SAs are created between two peers, kernel setup a timer to monitor
two events: soft/hard expiration. However the timer handler use xtime to
caculate whether it's soft or hard expiration event.

normal code flow(hard expire time:100s, soft expire time:82s)

a) When new SAs created, xfrm_timer_handler is called one second
after its creation. At this point, calculate soft expire
interval(81s), setup the timer;

b) soft expire occur, rearm the timer with hard expire interval(18s)
then notify racoon2 about soft expire event. racoon2 will create
new SAs.

c) hard expire happen, notify racoon2 about it. racoon2 will delete
the old SAs.

*Scenario*:
Setting a new date before b),and after a) could result c) happens first,
As a result, old SAs is deleted before new ones are created. Normally
new SAs will be created by the next time networking traffic, but there
is a small time being when networking connection is down, this could
result in upper layer connections failed in tel comm area, thus it's
better to keep it strict in sequence.

*Workaround*:
set new time could happen:
1) before a), then SAs is updated with new time.
2) before b),and after a)
2a) When new SAs created, xfrm_timer_handler is called one second
after its creation. At this point, calculate soft expire
interval(81s), setup the timer;(set flag to mark next time should
be soft time expire)

<<---- new date comes

2b) soft expire occur, the calculation results in a hard time expire
event, but flag is set, so catch ya. Sync the addtime, and rearm
the timer with hard expire interval(18s), then notify racoon2
about soft expire event;

2c) hard expire happen, notify racoon2 about it;
so everything is in order.

3) after b), hard expire always happened anyway.
