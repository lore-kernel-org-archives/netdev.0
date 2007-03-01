From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: replace system timer with work queue
Date: Thu, 01 Mar 2007 09:00:29 -0800
Message-ID: <200703011700.l21H0T22003070@death.nxdomain.ibm.com>
References: <Pine.LNX.4.61.0702281000050.9439@tm8103-a.perex-int.cz> <20070228233512.d2d275a2.akpm@linux-foundation.org>
Cc: Jaroslav Kysela <perex@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Oleg Nesterov <oleg@tv-sign.ru>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:35909 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965396AbXCARAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2007 12:00:39 -0500
In-reply-to: <20070228233512.d2d275a2.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> wrote:

>On Wed, 28 Feb 2007 10:12:01 +0100 (CET) Jaroslav Kysela <perex@suse.cz> wrote:
>> ==================
>> bonding: replace system timer with work queue
>> 
>> This patch replaces system timer with work queue in monitor functions.
>> The reason for this change is that bonding handlers calls various
>> sleeping functions from the timer handler which is not allowed.
>
>Which sleeping functions?  I'd have expected the kernel to spew runtime
>warnings when this happens, but I don't recall any such reports.

	This affects one specific mode (balance-alb) in one specific
case (moving MAC addresses around, which happens during failover or
initialization), and a full fix is more complicated than just a switch
to work queues, although that is part of the full fix.  There are three
things going on: calls to sleeping functions with locks held, the same
calls from the timer context, and rtnl hold issues.

	The actual functions affected are various things called by
notifier NETDEV_CHANGEADDR callbacks started by dev_set_mac_address() as
well as some of the driver level set_mac_address functions that may
sleep.

	Andy Gospodarek <andy@greyhouse.net> and I have been working
jointly on a two phased fix for these problems: he's working up the
short term fix, which includes the changeover to workqueues, and I've
been working on the long term fix, which involves refactoring the
bonding link monitoring and failover system.  Jaroslav's patch looks to
be a subset of the patch Andy is working on.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
