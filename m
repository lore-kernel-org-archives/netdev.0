From: Fan Du <fdu@windriver.com>
Subject: [XFRM][RFC v4] Fix unexpected SA hard expiration after setting new date
Date: Thu, 21 Jun 2012 14:26:00 +0800
Message-ID: <1340259961-30354-1-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47021 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752763Ab2FUG0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2012 02:26:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, Dave and Herbert

Could you give a try to review this?
thanks

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
