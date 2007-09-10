From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATH 0/2] Add RCU locking to SCTP address management
Date: Mon, 10 Sep 2007 15:46:28 -0400
Message-ID: <11894535901969-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:42190 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756728AbXIJTqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 15:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

This is my first attempt to add RCU synchronization to pieces of SCTP
and I want to make sure I do this right.

The RCU docs a somewhat outdated, and the calling conventions differ
between subsystems, so I am using what I've been able to find.

A bit of a background...

The whole problem started with a panic that led me to NULL deref while
walking a global list of addresses that SCTP maitains.  That list
is modified curing the NETDEV_UP and NETDEV_DOWN notifier processing
and all readers are run in user context.  It looks like the list was
modified while a user app was walking it and we crashed.

Easy enough to fix by adding locking.  However, some notifiers
(ipv6 addrconf) run in atomic context and it says that they can't sleep.
(Q1.  Why are ipv6 notifiers atomic, while IPv4 notifires are blocking?)

So, I decided to add RCU locking around that list.  These events are
already synchronized, so no additional locking on the writer side are need,
so should be make for a nice RCU conversion.

While doing this conversion, I saw that the same structures are used to
maintain a list of bound addresses.  This seemed like another opportunity
to use RCU.  In this case, the readers are wide spread, but there are
only 2 wirters: BH processing of specific chunks, and bind() calls.
Again the writers are already synchronized on the socket lock, so they
will keep out of each others way.  Readers are widespread, but rcu takes
care of that nicely.

So, can folks please take a look and make sure I didn't mess up the
rcu conventions.

Thanks a lot
-vlad
