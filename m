From: Fan Du <fdu@windriver.com>
Subject: [XFRM][PATCH v5] Fix unexpected SA hard expiration after setting new date
Date: Tue, 31 Jul 2012 15:43:53 +0800
Message-ID: <1343720634-1176-1-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40801 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755781Ab2GaHoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 03:44:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Dave

Hope v5 is better than previous ones :)
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

v4->v5
1) remove unnecessary empty line (David Miller)


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
